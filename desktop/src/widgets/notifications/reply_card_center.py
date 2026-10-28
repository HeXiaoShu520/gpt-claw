# coding:utf-8
"""通知管理器。

ReplyCardCenter 是所有回复卡片和 Toast 的统一调度入口。
新卡片按实际高度入栈，超出上限时优先关闭闲置的旧卡片。
锚点（宠物位置）更新时，所有未被手动拖拽的卡片会平滑跟随移动。
"""

import uuid

from PySide6.QtCore import QPoint, QUrl, Signal
from PySide6.QtGui import QPixmap
from PySide6.QtMultimedia import QSoundEffect
from PySide6.QtWidgets import QApplication, QWidget

import config
from log_util import get_logger
from protocols.surface_utils import surface_timeout, TERMINAL_SURFACE_STATUSES
from widgets.notifications.constants import CARD_BASE_GAP, CARD_STACK_GAP, MAX_STACKED_REPLY_CARDS
from widgets.notifications.reply_card import ReplyCard
from widgets.notifications.toast import Toast


log = get_logger('notifications.sound')


class ReplyCardCenter(QWidget):
    """回复卡片管理器，负责创建、堆叠、移动和关闭短生命周期卡片。"""

    reply_card_action_clicked = Signal(dict, dict)
    reply_card_interrupted = Signal(str)
    reply_card_mute_tts = Signal(str)
    reply_card_quote_submitted = Signal(str, object, str, str)  # card_id, full_message_or_content, quoted_text, user_text
    reply_card_closed = Signal(str)

    def __init__(self, parent=None):
        """初始化卡片/Toast 容器和通知音效播放器。"""
        super().__init__(parent)
        self.toasts = {}
        self.reply_cards = {}
        self.reply_card_order = []
        self.reply_card_anchor = None
        # 固定 WAV 提示音使用音效播放器，避免初始化视频编解码器。
        self.audio = QSoundEffect(self)
        self.audio.setLoopCount(1)
        self.audio.statusChanged.connect(self._on_sound_status)

    def setup_toast(self, title, message='', icon_path=None):
        """创建 Toast 通知并按已有 Toast 总高度向下偏移叠放，同时播放提示音。"""
        note_id = str(uuid.uuid4())
        icon = QPixmap(icon_path) if icon_path else QPixmap(str(config.avatar_path('pet')))
        toast = Toast(note_id, title, message, icon)
        toast.closed.connect(self._remove_toast)
        offset = sum(t.height() + 10 for t in self.toasts.values())
        self.toasts[note_id] = toast
        toast.show_at(offset)
        self._play_sound()

    def setup_reply_card_text(self, message, x, y, timeout=None, title=None):
        """创建本地短提示，不展示任务状态和对话操作。"""
        title = title or config.APP_DISPLAY_NAME
        card_id = str(uuid.uuid4())
        event = {
            'type': 'surface.show',
            'content': message,
            'title': title,
            'avatar_kind': 'user' if title == '你' else 'pet',
            'status': 'done',
            'local_notice': True,
        }
        card = ReplyCard(card_id, event, surface_timeout(event) if timeout is None else timeout)
        card.action_clicked.connect(self.reply_card_action_clicked)
        card.interrupted.connect(self.reply_card_interrupted)
        card.mute_tts.connect(self.reply_card_mute_tts)
        card.quote_reply_submitted.connect(self.reply_card_quote_submitted)
        card.layout_changed.connect(lambda: self._reflow_reply_cards(animate=True))
        card.closed.connect(self._remove_reply_card)
        self._register_reply_card(card_id, card, x, y)
        return card_id

    def close_reply_card(self, card_id):
        card = self.reply_cards.get(card_id)
        if card is not None:
            card.request_close()

    def set_reply_card_tts_active(self, card_id, active):
        card = self.reply_cards.get(card_id)
        if card is not None and hasattr(card, 'set_tts_active'):
            card.set_tts_active(active)

    def set_approval_pending(self, card_id, pending, message=None):
        card = self.reply_cards.get(card_id)
        if card is not None:
            card.set_approval_pending(pending, message)

    def reject_approval(self, token):
        if not token:
            return
        for card in self.reply_cards.values():
            if card.event_data.get('approval_id') == token and card.event_data.get('status') == 'waiting':
                card.set_approval_pending(False, '选择未生效，请重试。')

    def update_reply_card(self, card_id, message, timeout=None):
        card = self.reply_cards.get(card_id)
        if card is None:
            return False
        old_size = card.size()
        if isinstance(message, dict) and hasattr(card, 'update_card'):
            if timeout is None and any(key in message for key in ('status', 'state', 'done', 'error')):
                # 使用合并后的完整卡片判断时长，正式回复默认保留。
                complete = dict(card.event_data)
                complete.pop('timeout_ms', None)
                status = str(message.get('status') or message.get('state') or '').strip().lower()
                if status and status not in TERMINAL_SURFACE_STATUSES:
                    complete.pop('done', None)
                    complete.pop('error', None)
                if any(key in message for key in ('text', 'message', 'summary', 'content')):
                    for key in ('text', 'message', 'summary', 'content'):
                        complete.pop(key, None)
                complete.update(message)
                timeout = surface_timeout(complete)
            card.update_card(message, timeout=timeout)
        elif hasattr(card, 'update_message'):
            card.update_message(message, timeout=timeout)
        else:
            return False
        if card.size() != old_size:
            self._reflow_reply_cards(animate=True)
        return True

    def setup_reply_card(self, event, x, y, play_sound=True):
        """根据 surface.show 事件创建完整回复卡片并接入各回调信号。"""
        card_id = str(uuid.uuid4())
        timeout = surface_timeout(event)
        card = ReplyCard(card_id, event, timeout)
        card.action_clicked.connect(self.reply_card_action_clicked)
        card.interrupted.connect(self.reply_card_interrupted)
        card.mute_tts.connect(self.reply_card_mute_tts)
        card.quote_reply_submitted.connect(self.reply_card_quote_submitted)
        card.layout_changed.connect(lambda: self._reflow_reply_cards(animate=True))
        card.closed.connect(self._remove_reply_card)
        self._register_reply_card(card_id, card, x, y)
        if play_sound:
            self._play_sound()
        return card_id

    def _register_reply_card(self, card_id, card, x, y):
        # 注册新卡片：先确定目标位置，再裁剪超额旧卡片，最后重排已有卡片，
        # skip_id 防止新卡片在自己的入场动画期间被 reflow 意外移位
        self.reply_card_anchor = QPoint(int(x), int(y))
        self.reply_cards[card_id] = card
        self.reply_card_order.append(card_id)
        target = self._reply_card_target_pos(card, 0, self.reply_card_anchor)
        self._trim_reply_cards()
        self._reflow_reply_cards(animate=True, skip_id=card_id)
        card.animate_in(target)

    def _reply_card_target_pos(self, card, stack_offset, anchor, column_offset=0):
        """用下方卡片的实际总高度计算偏移；屏幕放不下时转入相邻列。"""
        x = int(anchor.x() - card.width() / 2)
        y = int(anchor.y() - card.height() - CARD_BASE_GAP)
        return self._clamp_to_anchor_screen(QPoint(x + column_offset, y - stack_offset), card, anchor)

    def _clamp_to_anchor_screen(self, pos, widget, anchor, margin=4):
        """把位置限制在锚点所在屏幕的可用区域内，留 margin 像素安全边距。"""
        screen = QApplication.screenAt(anchor) or QApplication.primaryScreen()
        if screen is None:
            return pos
        area = screen.availableGeometry()
        x = max(area.left() + margin, min(pos.x(), area.right() - widget.width() - margin))
        y = max(area.top() + margin, min(pos.y(), area.bottom() - widget.height() - margin))
        return QPoint(x, y)

    def _active_reply_card_ids(self):
        self.reply_card_order = [cid for cid in self.reply_card_order if cid in self.reply_cards]
        return [cid for cid in self.reply_card_order if not getattr(self.reply_cards[cid], 'closing', False)]

    def _trim_reply_cards(self):
        # 优先关闭已读完的旧卡片；处理中、交互中和固定的卡片不会被新消息挤掉。
        active_ids = self._active_reply_card_ids()
        overflow = len(active_ids) - MAX_STACKED_REPLY_CARDS
        if overflow <= 0:
            return
        evictable = [card_id for card_id in active_ids
                     if not self.reply_cards[card_id].protect_from_eviction]
        for card_id in evictable[:overflow]:
            card = self.reply_cards.get(card_id)
            if card is not None:
                card.request_close()

    def _reflow_reply_cards(self, animate=True, skip_id=None):
        # 从最新卡片开始向上累加真实高度；手动拖拽的卡片保留位置。
        if self.reply_card_anchor is None:
            return
        active_ids = self._active_reply_card_ids()
        cards = [(cid, self.reply_cards[cid]) for cid in reversed(active_ids)
                 if not getattr(self.reply_cards[cid], 'manual_position', False)]
        screen = QApplication.screenAt(self.reply_card_anchor) or QApplication.primaryScreen()
        area = screen.availableGeometry() if screen else None
        bottom = min(self.reply_card_anchor.y() - CARD_BASE_GAP, area.bottom() - 4) if area else self.reply_card_anchor.y() - CARD_BASE_GAP
        available_height = max(1, bottom - area.top() - 4) if area else float('inf')
        columns = [[]]
        height = 0
        for card_id, card in cards:
            if columns[-1] and height + card.height() > available_height:
                columns.append([])
                height = 0
            columns[-1].append((card_id, card, height))
            height += card.height() + CARD_STACK_GAP
        occupied_left = occupied_right = None
        for column in columns:
            if not column:
                continue
            width = max(card.width() for _, card, _ in column)
            if occupied_left is None:
                left = self.reply_card_anchor.x() - width // 2
                if area:
                    left = max(area.left() + 4, min(left, area.right() - width - 4))
            elif area and occupied_left - CARD_STACK_GAP - width >= area.left() + 4:
                left = occupied_left - CARD_STACK_GAP - width
            else:
                left = occupied_right + CARD_STACK_GAP
            occupied_left = left if occupied_left is None else min(left, occupied_left)
            occupied_right = left + width if occupied_right is None else max(left + width, occupied_right)
            center = left + width // 2
            anchor = QPoint(center, bottom + CARD_BASE_GAP)
            for card_id, card, offset in column:
                if card_id == skip_id:
                    continue
                target = self._reply_card_target_pos(card, offset, anchor)
                if animate:
                    card.animate_to(target)
                else:
                    card.move(target)

    def _remove_toast(self, note_id):
        self.toasts.pop(note_id, None)

    def _remove_reply_card(self, card_id):
        self.reply_cards.pop(card_id, None)
        self.reply_card_order = [cid for cid in self.reply_card_order if cid != card_id]
        self.reply_card_closed.emit(card_id)
        self._reflow_reply_cards(animate=True)

    def _play_sound(self):
        sound = config.RES_DIR / 'sounds' / 'Notification.wav'
        if not sound.is_file():
            log.warning('缺少通知提示音：%s', sound.name)
            return
        self.audio.stop()
        self.audio.setVolume(max(0.0, min(1.0, float(config.app_config.get('volume', 0.4)))))
        source = QUrl.fromLocalFile(str(sound))
        if self.audio.source() != source:
            self.audio.setSource(source)
        self.audio.play()

    def _on_sound_status(self):
        if self.audio.status() == QSoundEffect.Status.Error:
            log.warning('通知提示音加载失败；请检查 Notification.wav 和音频输出设备')
