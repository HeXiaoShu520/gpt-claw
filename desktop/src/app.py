# coding:utf-8
"""
桌宠应用组装入口。

MiniPetApp 是整个桌宠程序的协调层，负责把各模块串联起来：
  - 桌宠窗口（DesktopPet）与设置窗口（SettingsWindow）
  - 聊天记录持久化（ChatStore）与回复卡片（ReplyCardCenter）
  - 语音聊天（VoiceController：ASR / 唤醒词 / TTS）
  - gpt-claw 桌面通道（EventClient）

这里只保留跨模块的信号连接和 Surface（回复卡片）的显示逻辑；
TurnContext 轮次状态由独立的 ReplyCoordinator 持有，
语音实现在 voice_controller 模块中。
"""

import base64
import math
import mimetypes
import signal
import sys
import uuid
from pathlib import Path

from PySide6.QtCore import QLocale, QTimer, QUrl
from PySide6.QtGui import QDesktopServices, QFont, QGuiApplication
from PySide6.QtWidgets import QApplication
from qfluentwidgets import FluentTranslator, setThemeColor

import config
from log_util import get_logger, setup_logging
from storage.chat_store import ChatStore
from pet.desktop_pet import DesktopPet
from clients.event_client import EventClient
from widgets.notifications.reply_card_center import ReplyCardCenter
from protocols.protocol_v1 import (
    SESSION_PING, SESSION_PONG, SESSION_READY,
    SURFACE_ACK, SURFACE_CLOSE, SURFACE_SHOW, SURFACE_UPDATE, USER_CANCEL, USER_INPUT,
    normalize_inbound_event,
)
from protocols.surface_utils import (
    is_silent_surface_text, is_terminal_surface_status,
    normalize_display_event, surface_content_kind, surface_text,
    surface_timeout, surface_tts_eligible,
)
from settings_window import SettingsWindow
from clients.stream_tts import StreamTtsQueue
from stream_display_delay import StreamDisplayDelay
from clients.tts_client import TtsPreviewWorker, stop_tts
from desktop_context import DesktopContext
from screen_share import ScreenShareController
from voice_controller import VoiceController
from audio_resource_coordinator import AudioResourceCoordinator
from reply_coordinator import ReplyCoordinator


# 启动/退出 TTS 之后，再显示对应问候卡片的延迟（让 TTS 先开始播放）
EVENT_CARD_AFTER_TTS_START_DELAY_MS = 450
# 退出问候卡片停留时间（无 TTS 时）
GOODBYE_CARD_QUIT_DELAY_MS = 1800


log = get_logger('app')


class MiniPetApp(QApplication):
    """桌宠主应用：跨模块协调层。

    不直接绘制 UI，而是通过 Qt 信号把各模块的事件串联起来：
    - 桌宠交互 → gpt-claw 输入
    - gpt-claw 回复和 TTS → 回复卡片 / 语音球
    - 设置变更 → 重载唤醒词配置
    - 桌面通道事件 → Surface 卡片显示

    关键子系统（都是 QObject，生命周期由此管理）：
    - VoiceController：语音录制、唤醒词、TTS 回调
    - StreamTtsQueue：gpt-claw 回复的 TTS 管道
    - StreamDisplayDelay：防止 UI 闪烁的延迟队列
    """

    def __init__(self, argv, start_event_client=True):
        super().__init__(argv)
        self.setQuitOnLastWindowClosed(False)
        config.load()
        self.setFont(QFont('Microsoft YaHei UI'))
        locale_code = config.app_config.get('language_code', 'zh_CN')
        self.installTranslator(FluentTranslator(QLocale(locale_code)))
        if config.app_config.get('theme_color'):
            setThemeColor(config.app_config['theme_color'])

        # 多屏：把主屏排在最前，桌宠初始定位和找回优先参考主屏
        screens = self.screens()
        primary = self.primaryScreen()
        if primary in screens:
            screens.insert(0, screens.pop(screens.index(primary)))

        # ---------- 核心对象 ----------
        self.pet = DesktopPet(screens)
        self.desktop_context = DesktopContext(self)
        self.chat_store = ChatStore(config.DATA_DIR / 'chat')
        self.settings = SettingsWindow(self.chat_store)
        self.note = ReplyCardCenter()
        self.audio_resources = AudioResourceCoordinator(self)

        # 唯一的模型通道连接 gpt-claw。
        self.events = EventClient(self.chat_store.global_session_id('minipet')) if start_event_client else None
        self.screen_share = ScreenShareController(self.events, self.pet, self.note.setup_toast, self)

        # ---------- 聊天历史 ----------
        # 每个后端各自一份全局记录，切换后端时切换引用
        self.chat_histories = {}
        self.chat_history = []
        self._restore_chat_history()

        # ---------- 快速聊天状态 ----------
        # quick_chat_* 跟踪当前正在进行的快速输入/语音请求
        self.quick_chat_source = 'quick_chat'   # 触发来源
        self.quick_reply_card_id = None         # 当前回复卡片 ID
        self._tts_reply_card_id = None          # 正在朗读的卡片，可能不是最新卡片
        self.event_tts_worker = None            # 启动/退出音效 worker

        # ---------- 流式显示和 TTS ----------
        self.stream_display_delay = StreamDisplayDelay(self)
        # gpt-claw 流式回复的语音播报。
        self.external_stream_tts = StreamTtsQueue(
            self, label='External TTS',
            on_started=self._on_external_stream_tts_started,
            on_idle=self._finish_external_voice_if_tts_idle,
        )

        # ---------- 子控制器 ----------
        self.voice = VoiceController(
            app=self,
            audio_resources=self.audio_resources,
            submit_voice_text=self._on_voice_text_confirmed,
            stop_all_tts=self._stop_all_tts,
            parent=self,
        )

        # ---------- 杂项状态 ----------
        self.replies = ReplyCoordinator()
        self._surface_cards = {}          # surface_id → reply_card_id
        self._minipet_connected = False
        self._minipet_ready = False
        self._pending_reset_id = ''
        self._BACKEND_SOURCE_LABELS = {'minipet': 'gpt-claw'}
        self.is_quitting = False
        self._shutdown_started = False
        self.startup_greeting_shown = False
        self.exit_card_shown = False
        self._thinking_orb_active = False # 快速输入时显示的思考球
        self._reuse_reply_card_pending = False  # 引用追问时复用原卡片

        # ---------- 信号连接 ----------
        self._connect_signals()

        if self.events and self._agent_backend() == 'minipet':
            self.events.start()
        self.voice.apply_wake_word_settings()
        QTimer.singleShot(0, self._show_startup_greeting)

    def _connect_signals(self):
        """集中连接所有跨模块信号，方便维护。"""
        pet, settings, note = self.pet, self.settings, self.note

        # 桌宠交互
        pet.show_settings.connect(settings.show_window)
        pet.reply_card_text_requested.connect(
            lambda text, x, y, timeout: note.setup_reply_card_text(
                text, x, y, timeout, title=config.pet_display_name()
            )
        )
        pet.chat_prompt_submitted.connect(self._on_quick_chat_prompt)
        pet.drop_intent_submitted.connect(self._on_drop_intent)
        pet.chat_requested.connect(self._show_chat_window)
        pet.observe_requested.connect(self._on_observe_requested)
        pet.voice_chat_requested.connect(self._toggle_voice_orb)
        pet.voice_pause_requested.connect(self.voice.pause)
        pet.voice_stop_requested.connect(self.voice.stop)
        pet.share_screen_requested.connect(self.screen_share.set_enabled)
        pet.quit_requested.connect(self._on_quit_requested)

        # 设置变更
        settings.settings_changed.connect(pet.apply_settings)
        settings.settings_changed.connect(self._apply_agent_settings)
        settings.agent.reset_backend_history_requested.connect(self._reset_backend_history)
        settings.settings_changed.connect(
            lambda: self.voice.apply_wake_word_settings()
        )

        # 回复卡片事件
        note.reply_card_action_clicked.connect(self._on_reply_card_action)
        note.reply_card_interrupted.connect(self._on_reply_card_interrupted)
        note.reply_card_mute_tts.connect(self._on_reply_card_mute_tts)
        note.reply_card_quote_submitted.connect(self._on_reply_card_quote)
        note.reply_card_closed.connect(self._on_reply_card_closed)

        # gpt-claw 桌面通道事件
        if self.events:
            self.events.event_received.connect(self._on_event)
            self.events.connection_changed.connect(self._on_event_connection_changed)
            self.events.ready_changed.connect(self._on_minipet_ready_changed)
            self.events.reset_result.connect(self._on_reset_result)


    def _restore_chat_history(self):
        """恢复当前后端活动会话的短期上下文。"""
        self.chat_history = self._history_for_backend(self._agent_backend())

    def _backend_session_id(self, backend):
        """返回后端对应的全局会话 ID（用于 ChatStore 区分不同后端记录）。"""
        return self.chat_store.global_session_id(backend)

    def _history_for_backend(self, backend):
        """按需加载并缓存指定后端的聊天历史。"""
        backend = 'minipet'
        if backend not in self.chat_histories:
            self.chat_histories[backend] = self.chat_store.load_backend_history(backend)
        return self.chat_histories[backend]

    def _reset_backend_history(self, backend):
        """Reset the Codex thread together with the local presentation history."""
        backend = 'minipet'
        if self.replies.has_active:
            x, y = self.pet.reply_card_anchor()
            self.note.setup_reply_card_text('请先结束当前回复，再新建对话。', x, y, 3500, title=config.pet_display_name())
            return False
        if self._pending_reset_id:
            return False
        request_id = self.events.request_reset() if self.events and self.events.ready else ''
        if not request_id:
            x, y = self.pet.reply_card_anchor()
            self.note.setup_reply_card_text('gpt-claw 未连接，无法新建对话。', x, y, 3500, title=config.pet_display_name())
            return False
        self._pending_reset_id = request_id
        QTimer.singleShot(30000, lambda: self._reset_timeout(request_id))
        return False

    def _reset_timeout(self, request_id):
        if request_id == self._pending_reset_id:
            self._on_reset_result(request_id, False, '等待新建对话结果超时，本地记录未清除。')

    def _on_reset_result(self, request_id, accepted, message):
        if request_id != self._pending_reset_id:
            return
        self._pending_reset_id = ''
        x, y = self.pet.reply_card_anchor()
        if not accepted:
            self.note.setup_reply_card_text(message or '新建对话失败，本地记录未清除。', x, y, 5000, title=config.pet_display_name())
            return
        self._clear_local_history()
        self.note.setup_reply_card_text('已创建新对话。', x, y, 3000, title=config.pet_display_name())

    def _clear_local_history(self):
        """仅在 gpt-claw 确认新线程后清除桌宠展示记录。"""
        backend = 'minipet'
        stop_tts()
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()
        self.replies.clear_expired()
        self.chat_store.clear_backend_history(backend)
        self.chat_histories[backend] = []
        if backend == self._agent_backend():
            self.chat_history = self.chat_histories[backend]
        self._refresh_chat_window()

    def _refresh_chat_window(self):
        """如果聊天窗口当前可见，则重新加载以反映最新历史。"""
        if self.pet.chat_window is not None and self.pet.chat_window.isVisible():
            self._show_chat_window()

    def _agent_backend(self):
        """The desktop has one agent kernel."""
        return 'minipet'

    def _apply_agent_settings(self):
        """设置变更只同步展示数据；桌面连接由 EventClient 自行维护。"""
        backend = self._agent_backend()
        self.chat_history = self._history_for_backend(backend)
        window = self.pet.chat_window
        if window is not None and window.history is not self.chat_history:
            window.history = self.chat_history
            window.reload_history()

    # ------------------------------------------------------------------
    # 语音：代理到 VoiceController（避免 app.py 重复实现）
    # ------------------------------------------------------------------

    def _toggle_voice_orb(self):
        """切换语音球：已开启则关闭，否则打开。"""
        if self.voice.active:
            self.voice.stop()
        else:
            self.voice.open()

    def _on_voice_text_confirmed(self, text, screenshot=''):
        """VoiceController 识别到最终文字后，分发到对应后端。"""
        submitted = self._send_external_command(text, 'voice', 'voice_orb', screenshot=screenshot)
        if submitted:
            self.quick_chat_source = 'voice_chat'
            self.pet.update_voice_popup('thinking', '等待回复')
        if not submitted:
            # 提交失败：重置等待状态，稍后重试录音
            self.voice.waiting_reply = False
            if self.voice.active:
                QTimer.singleShot(800, self.voice.start_recording)

    def _stop_all_tts(self):
        """停止所有 TTS 播放（VoiceController 暂停时调用）。"""
        stop_tts()
        if hasattr(self, 'external_stream_tts'):
            self.external_stream_tts.reset()
            self._clear_reply_card_tts()

    def _pause_wake_word_listener(self):
        """暂停唤醒词监听，供中键语音输入独占麦克风。"""
        self.voice._pause_wake_word()

    def _resume_wake_word_listener(self):
        """中键录音结束后恢复唤醒词监听。"""
        self.voice._resume_wake_word()

    # ==== 启动/退出音效 ====
    def _event_tts_path(self, event_name):
        """返回启动/退出等事件音效文件路径，按音色名称区分。"""
        voice_name = config.tts_config.get('voice_name') or config.DEFAULT_TTS_CONFIG['voice_name']
        safe_name = ''.join(ch if ch.isalnum() or ch in ('-', '_') else '_' for ch in voice_name)
        return config.local_tts_path(f'tts_{event_name}', f'{safe_name}.wav')

    def _play_event_tts(self, event_name):
        """播放事件音效（如启动音、退出音），TTS 未启用或文件不存在时返回 False。"""
        event_label = '欢迎' if event_name == 'startup' else '结束'
        if not config.tts_config.get('enabled'):
            log.info('桌宠 %s语音跳过：语音功能未开启', event_label)
            return False
        path = self._event_tts_path(event_name)
        if not path.is_file():
            log.warning('桌宠 %s语音缺少本地音频：%s', event_label, path.name)
            return False
        stop_tts()
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()
        self.event_tts_worker = TtsPreviewWorker(path, parent=self)
        self.event_tts_worker.result_ready.connect(lambda success, text: self._on_event_tts_done(event_name, success, text))
        log.info('桌宠 %s语音开始播放：%s', event_label, path.name)
        self.event_tts_worker.start()
        return True

    def _on_event_tts_done(self, event_name, success, text):
        """事件音效播放完成回调；退出音效结束后触发真正的退出流程。"""
        event_label = '欢迎' if event_name == 'startup' else '结束'
        if not success:
            log.warning('桌宠 %s语音播放失败：%s', event_label, text)
        else:
            log.info('桌宠 %s语音播放完成', event_label)
        self.event_tts_worker = None
        if event_name == 'exit' and self.is_quitting:
            self._show_exit_card()
            QTimer.singleShot(300 if success else GOODBYE_CARD_QUIT_DELAY_MS, self.pet.quit_now)

    # ==== 问候卡片 ====
    def _show_startup_greeting(self):
        """应用启动后显示问候语，先播音效再显示卡片。"""
        if self._play_event_tts('startup'):
            QTimer.singleShot(EVENT_CARD_AFTER_TTS_START_DELAY_MS, self._show_startup_greeting_card)
            return
        self._show_startup_greeting_card()

    def _show_startup_greeting_card(self):
        """显示启动问候卡片，只显示一次。"""
        if self.startup_greeting_shown:
            return
        self.startup_greeting_shown = True
        x, y = self.pet.reply_card_anchor()
        name = config.pet_display_name()
        self.note.setup_reply_card_text('好久不见，想我了吗？', x, y, 6000, title=name)

    def _show_exit_card(self):
        """显示退出告别卡片，只显示一次。"""
        if self.exit_card_shown:
            return
        self.exit_card_shown = True
        x, y = self.pet.reply_card_anchor()
        self.note.setup_reply_card_text('我会想你的，再见~', x, y, 3000, title=config.pet_display_name())

    # ==== 聊天窗口 ====
    def _select_chat_backend(self, backend):
        """切换聊天窗口查看的对话视图；只加载历史，不改变全局后端。

        全局后端（消息发往哪里）只由设置页选择决定；查看其他后端的
        对话时窗口输入框会置灰，避免"看着 A 发给 B"的混淆。
        """
        if backend != 'minipet':
            return None
        return self._history_for_backend(backend)

    def _show_chat_window(self):
        """打开或刷新聊天窗口，传入当前后端的历史和回调函数。"""
        backend = self._agent_backend()
        self.chat_history = self._history_for_backend(backend)
        self.pet.show_chat(
            self.chat_history, self._append_chat_message, self.chat_store.content_for_llm,
            None, self._clear_chat_history,
            self._send_chat_window_message, backend, self._select_chat_backend,
            cancel_callback=self._cancel_chat_window_turn,
        )

    def _on_observe_requested(self):
        """Send one explicitly requested foreground snapshot to the shared agent."""
        try:
            title, screenshot = self.desktop_context.capture()
        except RuntimeError as error:
            x, y = self.pet.reply_card_anchor()
            self.note.setup_reply_card_text(str(error), x, y, 4500, title=config.pet_display_name())
            return
        prompt = f'我刚才正在使用窗口“{title}”。看看截图，简要说说我在做什么，以及你现在最能帮我的一件事；看不清的内容不要猜。'
        self._send_external_command(prompt, 'text', 'pet_popup', screenshot=screenshot)

    # ==== 退出流程 ====
    def _on_quit_requested(self):
        """用户点退出：停止语音，播退出音效，显示告别卡片。"""
        if self.is_quitting:
            return
        self.screen_share.set_enabled(False)
        self.is_quitting = True
        if self.pet.quick_menu is not None:
            self.pet.quick_menu.close()
        if self.voice.active:
            self.voice.stop()
        if self._play_event_tts('exit'):
            QTimer.singleShot(EVENT_CARD_AFTER_TTS_START_DELAY_MS, self._show_exit_card)
        else:
            self._show_exit_card()
            QTimer.singleShot(GOODBYE_CARD_QUIT_DELAY_MS, self.pet.quit_now)

    # ==== 聊天历史管理 ====
    def _append_chat_message(self, role, content, source, backend=None, footer='', delivery_id=''):
        """保存一条消息到智能体唯一的全局记录。"""
        backend = backend or self._agent_backend()
        if role == 'assistant' and not delivery_id:
            delivery_id = getattr(self, '_surface_delivery_id', '')
        stored_message = self.chat_store.append(
            role, content, source, pet_name=config.pet_display_name(),
            backend=backend, session_id=self._backend_session_id(backend), footer=footer,
            delivery_id=delivery_id,
        )
        history = self._history_for_backend(backend)
        if any(message.get('id') == stored_message['id'] for message in history):
            return stored_message
        history.append(stored_message)
        if backend == self._agent_backend():
            self.chat_history = self.chat_histories[backend]
        window = self.pet.chat_window
        if source != 'chat_window' and window is not None and window.backend == backend:
            window.present_saved_message(stored_message)
        # 同步一份到诊断日志：出问题时可对照当时说了什么
        preview = ' '.join(str(content).split())[:80]
        log.info('聊天记录 +%s [%s] %.80s', role, backend, preview)
        return stored_message

    def _clear_chat_history(self, backend=None):
        """清除聊天窗口正在查看的后端聊天历史（聊天窗口清除按钮回调）。"""
        return self._reset_backend_history(backend or self._agent_backend())

    # ==== 轮次与界面协调 ====
    def _begin_turn(self, backend, origin, session_id='', source='quick_chat',
                    surface_id='', on_delta=None, on_result=None):
        turn = self.replies.begin(
            backend, origin, session_id, source, surface_id, on_delta, on_result,
        )
        self.pet.task_event(turn.turn_id, 'started')
        return turn

    def _finish_turn(self, turn, success, text='', footer='', *, cancelled=False):
        if not self.replies.finish(turn):
            return False
        self.pet.task_event(turn.turn_id, 'cancelled' if cancelled else 'succeeded' if success else 'failed')
        final = (text or turn.text).strip()
        if turn.origin == 'chat_window':
            if turn.on_result:
                turn.on_result(success, final, footer, cancelled=cancelled)
            return True
        self._hide_thinking_orb()
        if success and final:
            self._append_chat_message('assistant', final, turn.source, turn.backend, footer)
        return True

    def _cancel_current_reply_workers(self):
        """暂停语音采集时，向后端请求取消当前轮次。"""
        if self.events:
            self.events.cancel_turn(session_id=self._backend_session_id('minipet'))

    # ==== 聊天窗口消息发送 ====
    def _send_chat_window_message(self, content, on_sent, on_delta, on_result):
        """按当前智能体的全局记录发送消息。"""
        backend = self._agent_backend()
        session_id = self._backend_session_id(backend)
        if backend is None:
            return False
        turn = self._begin_turn(
            backend, 'chat_window', session_id, 'chat_window',
            on_delta=on_delta, on_result=on_result,
        )
        if self._send_external_command(
            content, 'text', 'chat_window', turn_id=turn.turn_id,
            surface_id=turn.surface_id, backend=backend, session_id=session_id,
        ):
            self._append_chat_message('user', content, 'chat_window', backend)
            on_sent(backend)
            return turn.turn_id
        self._finish_turn(turn, False, '消息未发出，请检查连接后重试。')
        return False

    def _cancel_chat_window_turn(self, turn_id):
        turn = self.replies.resolve('minipet', turn_id)
        if turn is None or turn.origin != 'chat_window' or not self.events:
            return False
        return self.events.cancel_turn(
            session_id=turn.session_id, turn_id=turn.turn_id, surface_id=turn.surface_id,
        )

    # ==== 消息内容工具方法 ====
    def _content_text_for_preview(self, content):
        """从结构化内容中提取纯文本，用于消息预览和日志。"""
        if isinstance(content, str):
            return content
        parts = []
        for block in content or []:
            if block.get('type') == 'text':
                parts.append(block.get('text', ''))
            elif block.get('type') == 'code':
                parts.append(block.get('text', ''))
        return '\n'.join(part for part in parts if part).strip()

    def _content_preview(self, content):
        """生成内容的可读预览字符串，图片用占位符表示。"""
        if isinstance(content, str):
            return content
        text = self._content_text_for_preview(content)
        image_count = sum(1 for block in content or [] if block.get('type') == 'image')
        return (text + '\n' if text else '') + ('[图片] × %d' % image_count if image_count else '')

    def _attachment_from_data_url(self, data_url, name='image.png', source='input'):
        """把 base64 data URL 转成附件字典，格式不合法时返回 None。"""
        data_url = str(data_url or '').strip()
        if not data_url.startswith('data:') or ';base64,' not in data_url:
            return None
        header, data = data_url.split(',', 1)
        mime_type = header[5:].split(';', 1)[0] or 'application/octet-stream'
        if not data:
            return None
        return {
            'type': 'image',
            'name': name,
            'mime_type': mime_type,
            'encoding': 'base64',
            'data': data,
            'source': source,
        }

    def _attachment_from_image_file(self, file_path, source='drop'):
        """把受支持的本地图片转成附件。"""
        path = Path(str(file_path or ''))
        if not path.is_file() or path.stat().st_size > 20 * 1024 * 1024:
            return None
        mime_type = mimetypes.guess_type(str(path))[0] or ''
        if mime_type not in ('image/png', 'image/jpeg', 'image/webp', 'image/gif'):
            return None
        return {
            'type': 'image',
            'name': path.name,
            'mime_type': mime_type,
            'encoding': 'base64',
            'data': base64.b64encode(path.read_bytes()).decode('ascii'),
            'source': source,
        }

    def _attachment_from_file(self, file_path):
        """把拖入的普通文件交给桌面通道，限制单个文件大小。"""
        path = Path(str(file_path or ''))
        if not path.is_file() or path.stat().st_size > 20 * 1024 * 1024:
            return None
        return {
            'type': 'file', 'name': path.name,
            'mime_type': mimetypes.guess_type(str(path))[0] or 'application/octet-stream',
            'encoding': 'base64', 'data': base64.b64encode(path.read_bytes()).decode('ascii'),
            'source': 'drop',
        }

    def _content_attachments(self, content, screenshot=''):
        """从消息内容和截图中提取所有附件列表。"""
        attachments = []
        if screenshot:
            item = self._attachment_from_data_url(screenshot, name='screenshot.jpg', source='screenshot')
            if item:
                attachments.append(item)
        if isinstance(content, list):
            for index, block in enumerate(content):
                if block.get('type') != 'image':
                    continue
                src = block.get('src') or block.get('path') or block.get('data_url') or ''
                item = self._attachment_from_data_url(src, name=block.get('name') or 'image_%d.png' % (index + 1), source='message')
                if item is None:
                    item = self._attachment_from_image_file(src, source='message')
                if item:
                    attachments.append(item)
        return attachments

    def _drop_attachments(self, payload):
        """从拖拽投喂 payload 中提取附件列表。"""
        attachments = []
        for index, item in enumerate(payload.get('items') or []):
            if item.get('kind') not in ('image', 'file'):
                continue
            attachment = self._attachment_from_data_url(item.get('data_url'), name=item.get('name') or 'drop_%d.png' % (index + 1), source='drop')
            if attachment is None:
                attachment = self._attachment_from_image_file(item.get('path'), source='drop')
            if attachment is None and item.get('kind') == 'file':
                attachment = self._attachment_from_file(item.get('path'))
            if attachment:
                attachments.append(attachment)
        return attachments

    def _user_input_payload(self, content, mode='text', surface='pet_popup', screenshot='', attachments=None):
        """构造桌面通道的用户输入。"""
        text = self._content_text_for_preview(content)
        preview = self._content_preview(content)
        payload = {
            'text': text or preview,
            'preview': preview,
            'mode': mode,
            'surface': surface,
        }
        merged = list(attachments or [])
        merged.extend(self._content_attachments(content, screenshot=screenshot))
        if merged:
            payload['attachments'] = merged
        return payload


    # ==== 外置后端发送入口 ====
    def _send_external_command(self, content, mode='text', surface='pet_popup', screenshot='',
                              turn_id='', surface_id='', backend=None, session_id='', attachments=None):
        """Send input through the sole gpt-claw desktop transport."""
        if self._pending_reset_id:
            x, y = self.pet.reply_card_anchor()
            self.note.setup_reply_card_text('正在新建对话，请稍后发送。', x, y, 3000, title=config.pet_display_name())
            return False
        backend = backend or self._agent_backend()
        session_id = session_id or self._backend_session_id(backend)
        turn = self.replies.resolve(backend, turn_id, surface_id)
        if turn is None:
            turn = self._begin_turn(backend, 'external', session_id, surface, surface_id)
        turn_id = turn.turn_id
        surface_id = turn.surface_id

        # custom WebSocket 后端
        x, y = self.pet.reply_card_anchor()
        if turn.origin == 'external' and mode in ('text', 'voice'):
            self._begin_reply_card_turn()
            self._reset_external_stream_tts()
            self._show_reply_card('', status='thinking',
                                  progress='等待处理', surface_id='desktop:' + turn_id)
        payload = self._user_input_payload(content, mode=mode, surface=surface, screenshot=screenshot, attachments=attachments)
        if turn_id:
            payload['turn_id'] = turn_id
        if surface_id:
            payload['surface_id'] = surface_id
        if session_id:
            # 桌宠本地会话 ID 不是轮次 ID；传给外置后端后才能让后端跨轮复用同一历史。
            payload['session_id'] = session_id
        if self.events is not None and not self.events.isRunning():
            self.events.running = True
            self.events.start()
        queued = self.events.send_event(USER_INPUT, payload) if self.events else False
        if queued and surface != 'chat_window':
            self._append_chat_message('user', content, surface, backend)
        if not queued:
            if turn.origin != 'chat_window':
                self._finish_turn(turn, False)
            self._close_reply_card()
            self._hide_thinking_orb()
            self.note.setup_reply_card_text(
                'gpt-claw 尚未连接，请先启动服务。', x, y, 4500,
                title=config.pet_display_name()
            )
        return queued

    # ==== 回复卡片管理 ====
    def _show_reply_card(self, content, status='streaming', timeout_ms=None,
                         progress=None, result_usage=None, surface_id='local-quick-reply'):
        """显示或更新快速回复卡片，先尝试更新已有卡片，否则新建。"""
        source_label = 'gpt-claw'
        event = {
            'surface_id': surface_id,
            'content': content,
            'status': status,
            'source_label': source_label,
        }
        if timeout_ms is None:
            timeout_ms = surface_timeout(event)
        event['timeout_ms'] = timeout_ms
        if progress is not None:
            event['progress'] = progress
        event['result_usage'] = result_usage
        x, y = self.pet.reply_card_anchor()
        if self.quick_reply_card_id and self.note.update_reply_card(self.quick_reply_card_id, event, timeout=timeout_ms):
            if surface_id.startswith('desktop:'):
                self._bind_surface_card(surface_id, self.quick_reply_card_id)
            self._reuse_reply_card_pending = False
            return
        self.quick_reply_card_id = self.note.setup_reply_card(event, x, y, play_sound=False)
        if surface_id.startswith('desktop:'):
            self._bind_surface_card(surface_id, self.quick_reply_card_id)
        self._reuse_reply_card_pending = False

    def _bind_surface_card(self, surface_id, card_id):
        for old_surface, mapped_card in list(self._surface_cards.items()):
            if mapped_card == card_id and old_surface != surface_id:
                self._surface_cards.pop(old_surface, None)
        self._surface_cards[surface_id] = card_id

    def _on_reply_card_closed(self, card_id):
        if self.quick_reply_card_id == card_id:
            self.quick_reply_card_id = None
        if self._tts_reply_card_id == card_id:
            self._tts_reply_card_id = None
        for surface_id, mapped_card in list(self._surface_cards.items()):
            if mapped_card == card_id:
                self._surface_cards.pop(surface_id, None)

    def _begin_reply_card_turn(self):
        """开始新一轮回复卡片；引用追问时保留原卡片并重置其正文。"""
        if not self._reuse_reply_card_pending:
            self.quick_reply_card_id = None

    def _close_reply_card(self, preserve_reading=False):
        """关闭当前快速回复卡片并清除 ID。"""
        if self.quick_reply_card_id:
            card = self.note.reply_cards.get(self.quick_reply_card_id)
            if not (preserve_reading and card and card.protect_from_eviction):
                self.note.close_reply_card(self.quick_reply_card_id)
            self.quick_reply_card_id = None

    def _show_thinking_orb(self):
        """标记快速输入的思考状态，不控制独立语音球。"""
        if self.voice.active:
            return
        self._thinking_orb_active = True

    def _hide_thinking_orb(self):
        """清除快速输入的思考状态，不关闭独立语音球。"""
        self._thinking_orb_active = False

    # ==== 快速输入处理 ====
    def _on_quick_chat_prompt(self, text):
        """Send a pet prompt to the shared gpt-claw session."""
        self._show_thinking_orb()
        self._send_external_command(text, 'text', 'pet_popup')
        # 外置后端会用 surface 卡片回复，不使用快速输入弹窗自己的思考浮层。
        # submitted 信号返回后 PetInputPopup 才会 start_thinking，所以延后一拍关闭。
        QTimer.singleShot(0, self._close_input_popup)

    def _close_input_popup(self):
        """关闭快速输入弹窗（下一个事件循环再执行，避免竞态）。"""
        if self.pet.input_popup is not None:
            self.pet.input_popup.close()
            self.pet.input_popup = None

    def _on_drop_intent(self, drop_payload, intent):
        """把拖拽内容交给当前 gpt-claw 会话。"""
        payload = dict(drop_payload)
        payload['intent'] = intent
        payload['surface'] = 'desktop_pet'
        payload['context'] = {'surface': 'desktop_pet'}
        intent_labels = {
            'summarize': '总结',
            'create_task': '生成待办',
            'draft_reply': '起草回复',
            'send_to_lark': '发到飞书',
            'ask': '询问处理方式',
        }
        attachments = self._drop_attachments(payload)
        expected = sum(item.get('kind') in ('image', 'file') for item in payload.get('items') or [])
        if len(attachments) != expected:
            x, y = self.pet.reply_card_anchor()
            self.note.setup_reply_card_text('有文件无法读取或超过 20 MB，请换一个较小的文件。', x, y, 4500)
            return
        prompt = self._drop_prompt(payload, intent_labels.get(intent, intent))
        self._send_external_command(prompt, 'text', 'pet_popup', attachments=attachments)

    def _drop_prompt(self, payload, intent_label):
        """用文件名和路径描述投喂项，绝不把图片 base64 写进提示词。"""
        lines = ['用户投喂了内容，希望你处理：%s。' % intent_label]
        preview = payload.get('preview') or ''
        if preview:
            lines.append('预览：' + str(preview)[:1000])
        items = payload.get('items') or []
        if items:
            lines.append('投喂项：')
            for item in items:
                lines.append('- %s：%s' % (item.get('kind') or '文件', str(item.get('name') or item.get('url') or item.get('text') or '未命名')[:500]))
        return '\n'.join(lines)


    # ==== TTS 回调 ====
    def _on_external_stream_tts_started(self, stream_id, text):
        """gpt-claw 回复的 TTS 开始播放时更新卡片与语音球。"""
        self.pet.set_activity('reply-speech', 'speaking')
        self._sync_reply_card_tts(stream_id)
        if self.quick_chat_source == 'voice_chat' and self.voice.active:
            self.voice._pause_wake_word()
            self.pet.update_voice_popup('speaking', '')

    def _finish_external_voice_if_tts_idle(self):
        """朗读结束后恢复卡片阅读计时，并完成语音轮次。"""
        if self.external_stream_tts.is_active():
            return
        self._clear_reply_card_tts()
        if self.quick_chat_source == 'voice_chat' and self.voice.active:
            self.voice.finish_turn(delay_ms=500)

    def _sync_reply_card_tts(self, stream_id):
        """显示可能晚于语音开始；两条路径都按 surface 关联朗读状态。"""
        if (not self.external_stream_tts.is_active()
                or self.external_stream_tts.current_stream_id != stream_id):
            return
        card_id = self._surface_cards.get(stream_id)
        if not card_id:
            return
        if self._tts_reply_card_id and self._tts_reply_card_id != card_id:
            self.note.set_reply_card_tts_active(self._tts_reply_card_id, False)
        self._tts_reply_card_id = card_id
        self.note.set_reply_card_tts_active(card_id, True)

    def _clear_reply_card_tts(self):
        if not self.external_stream_tts.is_active():
            self.pet.set_activity('reply-speech')
        for card_id in {self._tts_reply_card_id, self.quick_reply_card_id} - {None}:
            self.note.set_reply_card_tts_active(card_id, False)
        self._tts_reply_card_id = None

    def _on_event_connection_changed(self, connected):
        """记录 gpt-claw 连接状态；只在连接过之后提示断线。"""
        if self._agent_backend() != 'minipet':
            return
        previous = self._minipet_connected
        self._minipet_connected = bool(connected)
        if not connected:
            self.screen_share.disconnected()
            self._minipet_ready = False
            self.pet.companion.clear_activities('approval:')
        if previous and not connected and not self.is_quitting and not self._shutdown_started:
            if self._pending_reset_id:
                self._on_reset_result(self._pending_reset_id, False, '连接断开，新建对话结果未确认；本地记录未清除。')
            self.stream_display_delay.reset()
            self.external_stream_tts.reset()
            self._clear_reply_card_tts()
            generation = self.replies.disconnected()
            QTimer.singleShot(20000, lambda: self._expire_disconnected_turns(generation))
            self.note.setup_toast('gpt-claw 连接断开', '正在自动重连；当前回复会在重连后继续显示。')

    def _expire_disconnected_turns(self, generation):
        """Release input only when a disconnected turn cannot be recovered."""
        for turn in self.replies.expire_disconnected(generation):
            turn_id = turn.turn_id
            message = '连接中断，当前结果尚未确认。'
            self._finish_turn(turn, False, message)
            if turn.origin != 'chat_window':
                surface_id = 'desktop:' + turn_id
                card_id = self._surface_cards.get(surface_id)
                failed = {'surface_id': surface_id, 'content': message, 'status': 'failed', 'source_label': 'gpt-claw'}
                if not card_id or not self.note.update_reply_card(card_id, failed, timeout=9000):
                    self._show_reply_card(message, status='failed', timeout_ms=9000)

    def _on_minipet_ready_changed(self, ready, server_name):
        """握手完成后记录后端状态；具体提示由 session.ready 卡片统一展示。"""
        if self._agent_backend() != 'minipet' or not ready:
            if not ready:
                self.screen_share.disconnected()
                self._minipet_ready = False
            return
        self._minipet_ready = True

    # ==== gpt-claw 桌面事件处理 ====
    def _on_event(self, event):
        """处理 gpt-claw 推送的 WebSocket 事件。"""
        event = normalize_inbound_event(event)
        if self.screen_share.handle_event(event):
            return
        # 统一解包：payload 优先用 event[payload]，兜底用整个 event
        event_type = event.get('type', '')
        payload = event.get('payload') if isinstance(event.get('payload'), dict) else event
        x, y = self.pet.reply_card_anchor()
        if event_type == SESSION_READY:
            self._minipet_ready = True
            active = payload.get('active_turn_ids')
            if isinstance(active, list):
                self.replies.recovered(str(turn_id) for turn_id in active)
        elif event_type == SURFACE_SHOW:
            self._handle_surface_show(payload)
        elif event_type == SURFACE_UPDATE:
            self._handle_surface_update(payload)
        elif event_type == SURFACE_CLOSE:
            self._handle_surface_close(payload)
        elif event_type == SESSION_PING:
            if self.events:
                self.events.send_event(SESSION_PONG, {'ts': payload.get('ts')})
        elif event_type == 'approval.result':
            if not payload.get('accepted'):
                self.note.reject_approval(payload.get('token'))
        elif event_type == 'error':
            message = str(payload.get('message') or '未知错误')
            turn = self.replies.resolve('minipet', payload.get('turn_id'))
            if payload.get('failed_event') == USER_CANCEL:
                if turn and turn.origin == 'chat_window' and self.pet.chat_window is not None:
                    self.pet.chat_window.cancellation_failed(turn.turn_id)
                self.note.setup_toast('停止请求未送达', message)
                return
            if turn:
                self._finish_turn(turn, False, message)
                if turn.origin != 'chat_window':
                    self._close_reply_card()
            else:
                card_id = self._surface_cards.get('desktop:' + str(payload.get('turn_id') or ''))
                if card_id:
                    self.note.set_approval_pending(card_id, False, '发送失败，请重试。')
            self.note.setup_toast('gpt-claw 未能处理这条消息', message)
        else:
            self.note.setup_toast(payload.get('title', '外部事件'), payload.get('summary') or payload.get('content') or '')

    def _handle_surface_show(self, payload):
        """处理 SURFACE_SHOW 事件：自定义后端的回复进入 TTS 与卡片。"""
        if self._acknowledged_surface(payload):
            return
        if payload.get('image_data_url'):
            image = payload['image_data_url']
            if image.startswith('data:image/') and ';base64,' in image:
                path = Path(str(payload.get('file_path') or ''))
                if not path.is_file():
                    suffix = '.png' if image.startswith('data:image/png') else '.jpg' if image.startswith('data:image/jpeg') else '.webp'
                    path = config.DATA_DIR / 'images' / (uuid.uuid4().hex + suffix)
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_bytes(base64.b64decode(image.split(',', 1)[1]))
                self._append_chat_message('assistant', [{'type': 'image', 'src': path.as_uri(), 'alt': '生成图片'}], 'generated_image', 'minipet')
        elif payload.get('file_path'):
            path = Path(str(payload['file_path']))
            if path.is_file():
                self._append_chat_message('assistant', [{'type': 'file', 'path': str(path), 'name': path.name}], 'generated_file', 'minipet')
        card_event = normalize_display_event(SURFACE_SHOW, payload)
        if (self._agent_backend() == 'minipet'
                and not self._is_chat_window_surface_turn(card_event)):
            self._queue_external_reply_tts(card_event, surface_text(card_event))
        self._queue_surface_display(card_event, is_update=False)

    def _handle_surface_update(self, payload):
        """处理 SURFACE_UPDATE 事件：更新已有卡片内容。"""
        if not payload.get('surface_id'):
            return
        if self._acknowledged_surface(payload):
            return
        card_event = normalize_display_event(SURFACE_UPDATE, payload)
        if (self._agent_backend() == 'minipet'
                and not self._is_chat_window_surface_turn(card_event)):
            self._queue_external_reply_tts(card_event, surface_text(card_event))
        self._queue_surface_display(card_event, is_update=True)

    def _is_chat_window_surface_turn(self, card_event):
        """判断 surface 对应的 turn 是否归属聊天窗口。"""
        turn = self.replies.resolve(
            'minipet', card_event.get('turn_id'), card_event.get('surface_id'),
        )
        return bool(turn and turn.origin == 'chat_window')

    def _queue_surface_display(self, card_event, is_update):
        """将 surface 显示操作入队（防止流式输出时闪烁）。"""
        surface_id = card_event.get('surface_id') or '__external_reply__'
        self.stream_display_delay.enqueue(
            'surface:' + surface_id,
            lambda: self._show_surface_event(card_event, is_update),
        )

    def _show_surface_event(self, card_event, is_update):
        """终态回复先持久化，再显示并确认；失败时交给服务重试。"""
        delivery_id = str(card_event.get('delivery_id') or '')
        if not delivery_id or not is_terminal_surface_status(card_event):
            self._display_surface_event(card_event, is_update)
            return
        if self._acknowledged_surface(card_event):
            return
        previous_delivery_id = getattr(self, '_surface_delivery_id', '')
        self._surface_delivery_id = delivery_id
        try:
            if not self._surface_failed(card_event) and not card_event.get('session_reset'):
                turn = self.replies.resolve('minipet', card_event.get('turn_id'), card_event.get('surface_id'))
                text = surface_text(card_event) or (turn.text if turn else '')
                if turn:
                    source = 'chat_window' if turn.origin == 'chat_window' else turn.source
                    if source == 'chat_window' and not text.strip():
                        text = '嗯。'
                else:
                    source = self.replies.expired_source(card_event.get('turn_id')) or 'external_reply'
                    if source == 'chat_window':
                        source = 'late_reply'
                if text:
                    self._append_chat_message('assistant', text, source, 'minipet',
                                              str(card_event.get('footer_text') or ''), delivery_id)
            self._display_surface_event(card_event, is_update)
            self.chat_store.mark_delivery(delivery_id)
            self._ack_surface(card_event)
        except Exception:
            log.exception('桌宠回复保存或显示失败，等待重新投递')
        finally:
            self._surface_delivery_id = previous_delivery_id

    def _acknowledged_surface(self, payload):
        delivery_id = str(payload.get('delivery_id') or '')
        if (delivery_id and is_terminal_surface_status(payload)
                and self.chat_store.has_delivery(delivery_id)):
            self._ack_surface(payload)
            return True
        return False

    def _ack_surface(self, payload):
        if self.events:
            self.events.send_v1_event(SURFACE_ACK, {
                'session_id': payload.get('session_id') or self._backend_session_id('minipet'),
                'surface_id': payload.get('surface_id'),
                'delivery_id': payload.get('delivery_id'),
            })

    def _display_surface_event(self, card_event, is_update):
        """实际显示 surface 卡片，更新已有卡片或新建卡片。"""
        if card_event.get('approval_id') and card_event.get('surface_id'):
            self.pet.set_activity('approval:' + card_event['surface_id'],
                                  None if is_terminal_surface_status(card_event) else 'approval')
        handled = self._handle_custom_chat_surface(card_event)
        if card_event.get('session_reset') and is_terminal_surface_status(card_event):
            self._clear_local_history()
        if handled:
            return
        # surface_id 用于关联后续 UPDATE/CLOSE 事件；更新已有卡片时不能关闭当前快速回复卡片。
        surface_id = card_event.get('surface_id')
        card_id = self._surface_cards.get(surface_id)
        if card_id and self.note.update_reply_card(card_id, card_event):
            self._sync_reply_card_tts(surface_id)
            self._handle_external_voice_surface(card_event)
            return
        text = surface_text(card_event)
        if (is_silent_surface_text(text) and not card_event.get('progress')
                and not card_event.get('elements') and not card_event.get('actions')
                and not card_event.get('controls')):
            return
        if not is_update:
            self._close_reply_card(preserve_reading=True)
        x, y = self.pet.reply_card_anchor()
        if not card_event.get('source_label'):
            card_event = dict(card_event)
            card_event['source_label'] = self._BACKEND_SOURCE_LABELS.get(self._agent_backend(), '')
        card_id = self.note.setup_reply_card(card_event, x, y, play_sound=False)
        if surface_id:
            self._bind_surface_card(surface_id, card_id)
            self._sync_reply_card_tts(surface_id)
        self._handle_external_voice_surface(card_event)

    def _handle_custom_chat_surface(self, card_event):
        """处理聊天窗口关联的 surface 事件，通过 turn delta/result 路由。"""
        turn = self.replies.resolve(
            'minipet', card_event.get('turn_id'), card_event.get('surface_id'),
        )
        if turn is None:
            turn_id = card_event.get('turn_id')
            source = self.replies.expired_source(
                turn_id, consume=is_terminal_surface_status(card_event),
            )
            if source is not None and is_terminal_surface_status(card_event):
                text = surface_text(card_event)
                if text and not self._surface_failed(card_event):
                    self._append_chat_message('assistant', text, source if source != 'chat_window' else 'late_reply',
                                              'minipet', str(card_event.get('footer_text') or ''))
            return False
        # 外置后端走 surface 协议，delta/result 复用同一套 turn 系统
        if not is_terminal_surface_status(card_event):
            self.pet.task_event(turn.turn_id, 'running')
        text = surface_text(card_event)
        if turn.origin == 'chat_window':
            if surface_content_kind(card_event) == 'progress' and not is_terminal_surface_status(card_event):
                progress = str(card_event.get('progress') or text).strip()
                if progress:
                    self.pet.chat_window.set_task_status(progress, show_elapsed=False)
                return True
            if text:
                update = turn.accept_text(
                    text, kind=surface_content_kind(card_event),
                    terminal=is_terminal_surface_status(card_event),
                    result=is_terminal_surface_status(card_event),
                )
                if update.changed and update.delta and turn.on_delta:
                    turn.on_delta(update.delta)
            if is_terminal_surface_status(card_event):
                self._finish_turn(turn, not self._surface_failed(card_event), text,
                                  str(card_event.get('footer_text') or ''),
                                  cancelled=card_event.get('task_outcome') == 'interrupted')
            return True
        if is_terminal_surface_status(card_event):
            self._finish_turn(turn, not self._surface_failed(card_event), text,
                              str(card_event.get('footer_text') or ''),
                              cancelled=card_event.get('task_outcome') == 'interrupted')
        return False

    @staticmethod
    def _surface_failed(card_event):
        """终态 surface 是否代表失败；失败文本不应写入 assistant 历史。"""
        status = str(card_event.get('status') or card_event.get('state') or '').strip().lower().replace('_', '-')
        return status in ('failed', 'failure', 'error')

    def _queue_external_reply_tts(self, card_event, text):
        """将外置回复文本入队到 external_stream_tts，不触发 TTS 时直接跳过。"""
        if not text:
            return
        if is_silent_surface_text(text) or not surface_tts_eligible(card_event):
            return
        # 空正文终态帧只表示 surface 生命周期结束，不再回读旧正文补触发 TTS。
        surface_id = card_event.get('surface_id') or '__external_reply__'
        terminal = is_terminal_surface_status(card_event)
        previous_stream = self.external_stream_tts.current_stream_id
        self.external_stream_tts.queue_text(surface_id, text, terminal=terminal)
        if (self.external_stream_tts.is_active()
                and self.external_stream_tts.current_stream_id != previous_stream):
            self.pet.set_activity('reply-speech', 'thinking')

    def _reset_external_stream_tts(self):
        """重置外置 TTS 队列和流式显示延迟（取消后续输出）。"""
        self.stream_display_delay.reset()
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()

    def _handle_external_voice_surface(self, card_event):
        """外置后端有卡片回复时关闭本地语音等待状态。"""
        if not self.voice.active or not self.voice.waiting_reply or self.quick_chat_source != 'voice_chat':
            return
        text = surface_text(card_event)
        if text:
            # 外置后端已经用卡片在回复了，语音等待浮层不应该继续盖在卡片上。
            # V1 surface 协议不允许后端控制宠物动作；有正文后就清掉本地等待动作。
            self.pet.close_voice_popup()
            self.pet.return_to_idle()
        if is_terminal_surface_status(card_event):
            self._finish_external_voice_if_tts_idle()

    def _handle_surface_close(self, payload):
        """处理 SURFACE_CLOSE 事件：关闭卡片并清理 TTS 队列。"""
        surface_id = payload.get('surface_id')
        if not surface_id:
            return
        self.pet.set_activity('approval:' + surface_id)
        self.stream_display_delay.reset('surface:' + surface_id)
        card_id = self._surface_cards.pop(surface_id, None)
        if card_id:
            self.note.close_reply_card(card_id)
        self.external_stream_tts.reset(surface_id)
        if self._tts_reply_card_id == card_id:
            self._clear_reply_card_tts()
        elif not self.external_stream_tts.is_active():
            self.pet.set_activity('reply-speech')

    # ==== 回复卡片事件回调 ====
    def _on_reply_card_action(self, event, action):
        """回复卡片按钮点击回调：处理复制、打开聊天、外置动作等。"""
        action_id = action.get('id') or action.get('type')
        text = action.get('text') or event.get('suggestion') or event.get('summary') or event.get('content') or ''
        x, y = self.pet.reply_card_anchor()
        if action.get('action_type') == 'approval':
            card_id = self._surface_cards.get(event.get('surface_id'))
            if action.get('decision') == 'text' and not str((event.get('values') or {}).get('answer') or '').strip():
                self.note.set_approval_pending(card_id, False, '请先填写回答。')
                return
            if self.events and self._agent_backend() == 'minipet':
                if not self.events.execute_approval(event, action):
                    self.note.set_approval_pending(card_id, False, '连接中断，请重试。')
            else:
                self.note.set_approval_pending(card_id, False, 'gpt-claw 尚未连接。')
            return
        if action.get('action_type') == 'open_local_file':
            path = Path(str(action.get('path') or ''))
            if path.is_file():
                QDesktopServices.openUrl(QUrl.fromLocalFile(str(path)))
            return
        if action_id == 'ignore':
            return
        if action_id == 'copy':
            QGuiApplication.clipboard().setText(text)
            self.note.setup_reply_card_text('已复制到剪贴板', x, y, 3000)
            return
        if action_id == 'open_chat':
            self._show_chat_window()
            return
        if self.events:
            self.events.execute_action(event, action)

    def _on_reply_card_interrupted(self, _card_id):
        """回复卡片中断按钮回调：取消 LLM 请求，重置 TTS。"""
        if self.events and self._agent_backend() == 'minipet':
            surface_id = next((sid for sid, cid in self._surface_cards.items() if cid == _card_id), '')
            turn = self.replies.resolve('minipet', surface_id=surface_id)
            self.events.cancel_turn(
                session_id=turn.session_id if turn else self._backend_session_id('minipet'),
                turn_id=turn.turn_id if turn else '',
                surface_id=surface_id or (turn.surface_id if turn else ''),
            )
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()
        if self.voice.active and self.voice.waiting_reply:
            self.voice.finish_turn(delay_ms=300)

    def _on_reply_card_mute_tts(self, card_id):
        """回复卡片静音回调：停止 TTS，但保留文字回复和卡片。"""
        # 取消尚未执行的流式显示回调，避免静音后旧队列继续触发状态更新。
        self.stream_display_delay.reset('minipet')
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()
        if card_id:
            self.note.set_reply_card_tts_active(card_id, False)
        self._hide_thinking_orb()
        if self.quick_chat_source == 'voice_chat' and self.voice.active and self.voice.waiting_reply:
            self.voice.finish_turn(delay_ms=300)

    def _on_reply_card_quote(self, card_id, message, quoted_text='', user_text=''):
        """Handle a quoted reply within an existing card."""
        backend = self._agent_backend()
        has_images = isinstance(message, list) and any(b.get('type') == 'image' for b in message if isinstance(b, dict))
        # 存储时带结构化 quote block，聊天窗口 reload 时可渲染飞书风格引用
        if quoted_text and user_text and not has_images:
            display_content = [{'type': 'text', 'text': user_text,
                                 'quote': quoted_text[:80] + ('...' if len(quoted_text) > 80 else '')}]
        elif has_images:
            # 图片模式：保留 image blocks，text block 加 quote
            display_content = []
            for block in message:
                if isinstance(block, dict) and block.get('type') == 'text' and quoted_text:
                    display_content.append({'type': 'text', 'text': user_text or block.get('text', ''),
                                            'quote': quoted_text[:80] + ('...' if len(quoted_text) > 80 else '')})
                else:
                    display_content.append(block)
        else:
            display_content = message
        self._append_chat_message('user', display_content, 'reply_card_quote', backend)
        # 追问复用原卡片，处理期间暂停计时；新回复完成后重新给予阅读时间。
        self.quick_reply_card_id = card_id
        self._reuse_reply_card_pending = True
        self.note.update_reply_card(
            card_id,
            {'status': 'thinking', 'timeout_ms': 0},
            timeout=0,
        )
        self._send_external_command(message, 'text', 'reply_card_quote')

    # ==== 应用关闭 ====
    def request_quit(self):
        """请求应用退出，确保信号退出与界面退出使用同一状态。"""
        if self.is_quitting:
            return
        self.screen_share.set_enabled(False)
        self.is_quitting = True
        self.pet.quit_now()

    def shutdown(self):
        """应用退出时清理所有后台线程和资源。"""
        if self._shutdown_started:
            return
        self.screen_share.set_enabled(False)
        self._shutdown_started = True
        self.is_quitting = True
        stop_tts()
        self.settings.shutdown()
        if self.pet.chat_window is not None:
            self.pet.chat_window.shutdown()
        self.pet.close_voice_popup()
        self.external_stream_tts.reset()
        self._clear_reply_card_tts()
        # VoiceController 负责 ASR worker 的清理
        self.voice.stop()
        # 释放剩余的 worker
        for worker_name in ('event_tts_worker',):
            worker = getattr(self, worker_name, None)
            if worker is not None and worker.isRunning():
                worker.requestInterruption()
                worker.quit()
                worker.wait(1000)
            setattr(self, worker_name, None)
        self.pet.stop()
        if self.events:
            self.events.stop()
            self.events = None


def main():
    # 应用入口统一初始化日志：全部模块经 log_util 输出，格式一致、可过滤
    setup_logging()
    app = MiniPetApp(sys.argv)
    log.info('桌宠界面初始化完成，共享屏幕默认关闭')
    signal.signal(signal.SIGINT, lambda signum, frame: app.request_quit())
    signal.signal(signal.SIGTERM, lambda signum, frame: app.request_quit())
    timer = QTimer()
    timer.start(250)
    timer.timeout.connect(lambda: None)
    code = 0
    try:
        code = app.exec()
    finally:
        app.shutdown()
        log.info('桌宠界面已关闭')
    sys.exit(code)
