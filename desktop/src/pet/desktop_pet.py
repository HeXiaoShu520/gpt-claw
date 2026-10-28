# coding:utf-8
"""
桌面宠物主窗口和桌面交互组件。

这个文件目前集中放了桌宠窗口相关的 UI：
- PetInputPopup：双击桌宠弹出的快速输入框，支持粘贴/拖入图片。
- PetVoicePopup / VoiceOrbWidget：桌宠旁边的轻量语音聊天状态球。
- DesktopPet：透明桌宠窗口、动画播放、拖拽/掉落、托盘菜单和快捷菜单。

后续如果继续拆文件，优先把输入弹窗和语音球组件拆到独立模块。
"""

import time

from PySide6.QtCore import QPoint, QRect, Qt, QTimer, Signal
from PySide6.QtGui import QDragEnterEvent, QDropEvent
from PySide6.QtWidgets import QApplication, QVBoxLayout, QWidget

import config
from pet.desktop_actions import move_by as move_pet_by
from pet.desktop_actions import pat as pat_pet
from pet.desktop_actions import play_action as play_pet_action
from pet.desktop_actions import reset_size as reset_pet_size
from pet.desktop_hover import arm_hover_menu_from_cursor, close_quick_menu_if_mouse_away, disarm_hover_menu, start_hover_tracking
from pet.desktop_interactions import drop_payload_from_mime, fall_step, handle_mouse_move, handle_mouse_press, handle_mouse_release, limit_position
from pet.desktop_tray import hide_tray, setup_tray
from pet.desktop_windows import show_chat_window
from pet.spirit_model import SPIRIT_NAME
from pet.spirit_view import SpiritView
from pet.companion import CompanionDirector
from pet.feedback import PetFeedback
from pet.companion_touch import CompanionTouch
from pet.guidance import DesktopGuidance
from widgets.pet_input_popup import PetInputPopup
from widgets.pet_voice_popup import PetVoicePopup
from widgets.menus.pet_menus import PetDropIntentPopup, PetQuickMenu, build_companion_menu, build_pet_context_menu


class DesktopPet(QWidget):
    """桌面宠物主窗口。

    负责透明窗口显示、角色动画、拖拽/掉落、多屏找回、托盘菜单、快捷菜单、
    聊天窗口的打开/关闭。业务请求通过 Qt 信号交给 MiniPetApp，
    避免主窗口直接调用 LLM 或 TTS。
    """

    show_settings = Signal()
    reply_card_text_requested = Signal(str, int, int, int)
    chat_prompt_submitted = Signal(object)
    drop_intent_submitted = Signal(dict, str)
    chat_requested = Signal()
    observe_requested = Signal()
    voice_chat_requested = Signal()
    voice_pause_requested = Signal()
    voice_stop_requested = Signal()
    share_screen_requested = Signal(bool)
    quit_requested = Signal()

    def __init__(self, screens, parent=None):
        """初始化窗口、状态字段、掉落定时器和托盘，并加载默认角色。"""
        super().__init__(parent)
        self.screens = screens
        self.current_screen = screens[0].availableGeometry()
        config.screens = screens
        config.current_screen = screens[0]
        self.character_view = None
        self.companion = CompanionDirector(self, config.app_config.get('companion_mode', 'companion'))
        self.companion.set_enabled(False)
        self.touch = CompanionTouch(self)
        self.companion_menu = None
        self.chat_window = None
        self.tray = None
        self.context_menu = None
        self.input_popup = None
        self.voice_popup = None
        self.quick_menu = None
        self._share_screen_active = False
        self._voice_chat_active = False
        self.drop_popup = None
        self.block_quick_menu_until = 0.0
        self.pet_menu = None
        self.visible_bounds = QRect()
        self.is_dragging = False
        self._quit_requested = False
        self.left_pressed = False
        self.was_dragging = False
        self.mouse_drag_pos = QPoint(0, 0)
        self.press_global_pos = QPoint(0, 0)
        self.last_mouse = []
        self.fall_timer = QTimer(self)
        self.fall_timer.timeout.connect(self._fall_step)
        self.floor_y = 0
        start_hover_tracking(self)
        self._init_window()
        self._init_ui()
        self.guidance = DesktopGuidance(self)
        config.current_pet = SPIRIT_NAME
        self.setWindowTitle(f'{config.APP_DISPLAY_NAME} - {config.pet_display_name()}')
        self._reset_size(keep_position=False)
        self.companion.set_enabled(True)
        self.show()
        self._setup_tray()

    def _init_window(self):
        # Tool | FramelessWindowHint 让窗口不出现在任务栏，NoDropShadowWindowHint 避免 Windows 给透明窗口加阴影。
        # 置顶由统一配置固定开启，与浮灵的桌面指引保持一致。
        flags = Qt.Tool | Qt.FramelessWindowHint | Qt.NoDropShadowWindowHint
        if config.app_config.get('on_top', True):
            flags |= Qt.WindowStaysOnTopHint
        self.setWindowFlags(flags)
        self.setAutoFillBackground(False)
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        self.setMouseTracking(True)
        self.setAcceptDrops(True)

    def _init_ui(self):
        self.character_view = SpiritView(self)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.character_view)
        self.companion.frame.connect(self.character_view.frame)
        self.companion.pose_changed.connect(self.character_view.pose)
        self.companion.presentation_changed.connect(self.character_view.presentation)
        self.character_view.pose(self.companion.pose)
        self.character_view.presentation({'effectsEnabled': config.app_config['pet_effects']})
        self.feedback = PetFeedback(self)
        self.companion.cue.connect(self.feedback.play)

    def companion_interaction_active(self):
        """用户在使用桌宠时，暂停自主活动和位移。"""
        panels = (self.input_popup, self.voice_popup, self.quick_menu,
                  self.drop_popup, self.chat_window)
        return (self.left_pressed or QApplication.activePopupWidget() is not None
                or any(panel is not None and panel.isVisible() and not panel.isMinimized() for panel in panels))

    def return_to_idle(self):
        self.set_activity('voice')

    def set_activity(self, source, pose=None):
        """本地真实状态驱动动作；不同轮次各自释放，避免互相覆盖。"""
        self.companion.activity(source, pose)

    def task_event(self, turn_id, event):
        self.companion.task_event(turn_id, event)

    def _reset_size(self, keep_position=True):
        self.guidance.clear(False)
        reset_pet_size(self, keep_position=keep_position)

    def _screen_at_point(self, point):
        """根据坐标查找所在屏幕，多级降级保证不返回 None。"""
        # QApplication.screenAt 在多屏场景下可能返回 None（点落在屏幕间隙），
        # 依次降级到当前屏幕、主屏幕，确保始终有有效屏幕可用。
        screen = QApplication.screenAt(point)
        if screen is not None:
            return screen
        screen = self.screen()
        if screen is not None:
            return screen
        screen = QApplication.primaryScreen()
        if screen is not None:
            return screen
        return self.screens[0] if self.screens else None

    def _pet_reference_point(self, x=None, y=None):
        """取角色“脚底中心”作为跨屏/地面判定的参考点。"""
        px = self.x() if x is None else int(x)
        py = self.y() if y is None else int(y)
        return QPoint(px + self.width() // 2, py + self.height())

    def _set_current_screen_from_point(self, point):
        """把当前屏幕切换为参考点所在的屏幕，并重算地面高度。"""
        screen = self._screen_at_point(point)
        if screen is not None:
            config.current_screen = screen
            self.current_screen = screen.availableGeometry()
        self.floor_y = self.current_screen.bottom() - self.height() + 1
        return self.current_screen

    def _setup_tray(self):
        setup_tray(self)

    def enterEvent(self, event):
        """鼠标进入角色时预布防悬浮菜单检测。"""
        arm_hover_menu_from_cursor(self)
        super().enterEvent(event)

    def leaveEvent(self, event):
        """鼠标离开时解除悬浮菜单，并延迟关闭可能已弹出的快捷菜单。"""
        disarm_hover_menu(self)
        QTimer.singleShot(300, lambda: close_quick_menu_if_mouse_away(self))
        super().leaveEvent(event)

    def contextMenuEvent(self, event):
        # 由释放事件打开一次，避免平台上下文事件重复弹出。
        event.accept()

    def show_context_menu(self, position=None):
        self.touch.cancel()
        disarm_hover_menu(self)
        if self.quick_menu is not None:
            self.quick_menu.close()
        if self.pet_menu is not None:
            self.pet_menu.close()
            self.pet_menu.deleteLater()
        self.pet_menu = build_pet_context_menu(self)
        self.pet_menu.popup(position or QPoint(*self.reply_card_anchor()))

    def dragEnterEvent(self, event: QDragEnterEvent):
        """能解析出拖放内容时接受拖入，否则交给默认处理。"""
        if drop_payload_from_mime(self, event.mimeData()) is not None:
            event.acceptProposedAction()
            disarm_hover_menu(self)
            return
        super().dragEnterEvent(event)

    def dropEvent(self, event: QDropEvent):
        """解析拖放内容并弹出意图选择卡片。"""
        payload = drop_payload_from_mime(self, event.mimeData())
        if payload is None:
            super().dropEvent(event)
            return
        event.acceptProposedAction()
        self._show_drop_popup(payload)

    def _show_drop_popup(self, payload):
        """在角色头顶弹出拖放意图选择卡片。"""
        if self.drop_popup is not None:
            self.drop_popup.close()
        x, y = self.reply_card_anchor()
        self.drop_popup = PetDropIntentPopup(payload, x, y, self)
        self.drop_popup.intent_selected.connect(self.drop_intent_submitted.emit)
        self.drop_popup.destroyed.connect(lambda: setattr(self, 'drop_popup', None))
        self.pat()

    def mousePressEvent(self, event):
        """鼠标按下转交交互模块处理。"""
        if not handle_mouse_press(self, event):
            super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        """鼠标移动转交交互模块处理。"""
        if not handle_mouse_move(self, event):
            super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event):
        """鼠标释放转交交互模块处理。"""
        if not handle_mouse_release(self, event):
            super().mouseReleaseEvent(event)

    def show_quick_menu(self):
        # 菜单刚关闭后的短时间内拒绝重开，避免同一次点击先关菜单又触发新菜单。
        if time.monotonic() < self.block_quick_menu_until:
            return
        if self.quick_menu is not None and self.quick_menu.isVisible():
            return
        x, top_y, bottom_y = self.quick_menu_anchor()
        menu = PetQuickMenu(x, top_y, bottom_y, self.chat_requested.emit,
                            self._on_voice_chat_requested,
                            voice_chat_active=self._voice_chat_active, parent=self)
        self.quick_menu = menu
        menu.closed.connect(lambda: self._clear_quick_menu(menu))

    def _clear_quick_menu(self, menu):
        if self.quick_menu is menu:
            self.quick_menu = None

    def _show_companion_menu(self):
        if self.companion_menu is not None:
            self.companion_menu.close()
            self.companion_menu.deleteLater()
        self.companion_menu = build_companion_menu(self, self)
        x, y = self.reply_card_anchor()
        self.companion_menu.popup(QPoint(x, y))

    def set_companion_mode(self, mode):
        if mode not in CompanionDirector.MODES:
            return
        config.app_config['companion_mode'] = mode
        config.save_app_config()
        self.companion.set_mode(mode)
        self._setup_tray()

    def _on_share_screen_toggle(self, checked):
        self.share_screen_requested.emit(checked)

    def set_pet_preference(self, key, enabled):
        if key not in ('pet_effects', 'pet_sounds', 'allow_drop'):
            return
        config.app_config[key] = bool(enabled)
        config.save_app_config()
        if key == 'pet_effects':
            self.character_view.presentation({'effectsEnabled': bool(enabled)})
        elif key == 'pet_sounds' and not enabled:
            self.feedback.stop()
        elif key == 'allow_drop' and not enabled and self.fall_timer.isActive():
            self.fall_timer.stop()
            config.drag_speed_x = config.drag_speed_y = 0
            self.set_activity('interaction')
            self.move(limit_position(self, self.x(), self.y()))
            self.companion.reset_home()

    def set_screen_share_active(self, active):
        self._share_screen_active = bool(active)

    def _on_voice_chat_requested(self):
        self.voice_chat_requested.emit()

    def set_voice_chat_active(self, active):
        self._voice_chat_active = bool(active)
        if not active:
            self.set_activity('voice')

    def mouseDoubleClickEvent(self, event):
        # 双击打开轻聊天；取消待结算的单击抚摸。
        if event.button() == Qt.LeftButton:
            self.touch.cancel()
            disarm_hover_menu(self)
            if self.quick_menu is not None:
                self.quick_menu.close()
            self.chat_requested.emit()
            event.accept()
            return
        if event.button() == Qt.RightButton:
            event.accept()
            return
        super().mouseDoubleClickEvent(event)

    def ask_pet(self):
        """打开（或聚焦已有的）快速输入框，提交结果经信号发给主应用。"""
        if self.input_popup is not None and self.input_popup.isVisible():
            self.input_popup.raise_()
            self.input_popup.activateWindow()
            return
        x, y = self.reply_card_anchor()
        self.input_popup = PetInputPopup(x, y, self)
        self.input_popup.submitted.connect(self.chat_prompt_submitted.emit)
        popup = self.input_popup
        popup.closed.connect(lambda: self._input_closed(popup))
        self.set_activity('input', 'listening')

    def _input_closed(self, popup):
        if self.input_popup is popup:
            self.input_popup = None
            self.set_activity('input')

    def show_voice_popup(self, anchor=None, anchor_mode='pet', initial_state='idle', initial_text=''):
        """显示语音状态球：已存在则移动到新锚点，否则按初始状态创建。"""
        self._sync_voice_activity(initial_state)
        if anchor is None:
            anchor = self.reply_card_anchor()
            anchor_mode = 'pet'
        x, y = anchor
        if self.voice_popup is not None and self.voice_popup.isVisible():
            self.voice_popup.move_to_anchor(x, y, smooth=False, anchor_mode=anchor_mode)
            self.voice_popup.raise_()
            return self.voice_popup
        self.voice_popup = PetVoicePopup(
            x,
            y,
            self,
            anchor_mode=anchor_mode,
            initial_state=initial_state,
            initial_text=initial_text,
        )
        self.voice_popup.pause_requested.connect(self.voice_pause_requested.emit)
        self.voice_popup.stop_requested.connect(self.voice_stop_requested.emit)
        self.voice_popup.destroyed.connect(lambda: setattr(self, 'voice_popup', None))
        return self.voice_popup

    def update_voice_popup(self, state, text='', anchor=None, anchor_mode='pet'):
        # 语音弹窗不存在时先创建再更新，已存在时只更新状态，
        # 避免弹窗闪烁或位置跳变。
        is_new = self.voice_popup is None
        popup = self.show_voice_popup(
            anchor=anchor,
            anchor_mode=anchor_mode,
            initial_state=state,
            initial_text=text,
        )
        if not is_new:
            popup.update_state(state, text)

    def _sync_voice_activity(self, state):
        pose = {'listening': 'listening', 'wakeup': 'listening', 'typing': 'listening',
                'thinking': 'thinking', 'connecting': 'thinking', 'speaking': 'speaking'}.get(state)
        self.set_activity('voice', pose)

    def close_voice_popup(self):
        """关闭并释放语音状态球。"""
        self.set_activity('voice')
        if self.voice_popup is not None:
            self.voice_popup.close()
            self.voice_popup = None

    def _fall_step(self):
        fall_step(self)

    def _limit_position(self, x, y):
        return limit_position(self, x, y)

    def _sync_voice_popup_position(self):
        """跟随模式时让语音球贴合角色头顶，掉落中带漂浮效果。"""
        if self.voice_popup is not None and self.voice_popup.isVisible() and self.voice_popup.anchor_mode == 'pet':
            x, y = self.reply_card_anchor()
            self.voice_popup.move_to_anchor(x, y, floaty=self.fall_timer.isActive())

    def _move_by(self, dx, dy):
        move_pet_by(self, dx, dy)

    def play_action(self, name):
        return play_pet_action(self, name)

    def pat(self):
        return pat_pet(self)

    def show_chat(self, history=None, append_message=None, content_for_llm=None, system_prompt_builder=None, clear_history_callback=None, send_callback=None, backend='minipet', backend_select_callback=None, cancel_callback=None):
        show_chat_window(self, history=history, append_message=append_message, content_for_llm=content_for_llm, system_prompt_builder=system_prompt_builder, clear_history_callback=clear_history_callback, send_callback=send_callback, backend=backend, backend_select_callback=backend_select_callback, cancel_callback=cancel_callback)

    def _current_visible_bounds(self):
        """返回角色非透明区域，无效时退回整个窗口矩形。"""
        return self.visible_bounds if not self.visible_bounds.isNull() else QRect(0, 0, self.width(), self.height())

    def reply_card_anchor(self):
        """计算回复卡片锚点：角色头顶中心偏下 12px。"""
        # 锚点基于可见像素区域（非透明边界）而非整个窗口，
        # 保证弹出卡片紧贴角色头顶，不受大量透明边距影响。
        bounds = self._current_visible_bounds()
        view = self.character_view
        center_x = self.x() + view.x() + bounds.left() + bounds.width() // 2
        top_y = self.y() + view.y() + bounds.top()
        return center_x, top_y + 12

    def quick_menu_anchor(self):
        """计算快捷菜单锚点：返回头顶中心横坐标和角色上下边缘纵坐标。"""
        bounds = self._current_visible_bounds()
        view = self.character_view
        center_x = self.x() + view.x() + bounds.left() + bounds.width() // 2
        top_y = self.y() + view.y() + bounds.top()
        bottom_y = self.y() + view.y() + bounds.bottom()
        return center_x, top_y, bottom_y

    def apply_settings(self):
        """设置页保存后重建窗口标志、标题、托盘并保持原位置。"""
        self._init_window()
        self.companion.set_mode(config.app_config.get('companion_mode', 'companion'))
        self.setWindowTitle(f'{config.APP_DISPLAY_NAME} - {config.pet_display_name()}')
        if self.chat_window is not None:
            self.chat_window.set_pet_name(config.pet_display_name())
        self.show()
        self._reset_size(keep_position=True)
        self._setup_tray()

    def quit(self):
        self.quit_requested.emit()

    def stop(self):
        self.guidance.stop()
        self.fall_timer.stop()
        self.companion.stop()

    def quit_now(self):
        """停止桌宠界面并请求 Qt 事件循环退出。"""
        if getattr(self, '_quit_requested', False):
            return
        self._quit_requested = True
        self.stop()
        hide_tray(self)
        QApplication.quit()

    def closeEvent(self, event):
        self.stop()
        super().closeEvent(event)
