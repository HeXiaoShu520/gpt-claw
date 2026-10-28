# coding:utf-8
"""桌宠相关弹出菜单。"""

import time

from PySide6.QtCore import QEasingCurve, QEvent, QParallelAnimationGroup, QPropertyAnimation, QPoint, QSize, Qt, QTimer, Signal
from PySide6.QtGui import QAction, QColor, QIcon
from PySide6.QtWidgets import QApplication, QFrame, QHBoxLayout, QLabel, QMenu, QPushButton, QVBoxLayout
from qfluentwidgets import FluentIcon as FIF

import config
from pet.behaviors import BEHAVIORS
from pet.spirit_model import SPIRIT_ACTIONS
import theme as _theme
from widgets.ui_utils import clamp_popup_pos


def build_companion_menu(owner, parent):
    """陪伴方式只控制本地动作频率，不调用模型或开启屏幕共享。"""
    menu = QMenu('陪伴方式', parent)
    status = menu.addAction(owner.companion.status)
    status.setEnabled(False)
    menu.addSeparator()
    for mode, label in (('quiet', '安静陪伴'), ('companion', '日常陪伴'),
                        ('lively', '活泼一点')):
        action = menu.addAction(label)
        action.setCheckable(True)
        action.setChecked(owner.companion.mode == mode)
        action.triggered.connect(lambda checked=False, m=mode: owner.set_companion_mode(m))
    sleeping = owner.companion.mode == 'rest'
    sleep_action = menu.addAction('轻轻叫醒' if sleeping else '睡一会儿')
    sleep_action.setEnabled(owner.companion.mood != 'focused')

    def toggle_sleep():
        owner.set_companion_mode('companion' if sleeping else 'rest')
        if sleeping:
            owner.companion.wake()

    sleep_action.triggered.connect(toggle_sleep)
    menu.addSeparator()
    activities = menu.addMenu('一起玩')
    activities.setToolTipsVisible(True)
    activities.setEnabled(owner.companion.mood != 'focused')
    groups = {}
    for name, behavior in BEHAVIORS.items():
        group = ('点播小剧场' if not behavior.ambient else {
            'content': '放松与整理', 'curious': '好奇与散步',
            'social': '亲近与招呼', 'playful': '一起玩球',
            'sleepy': '困倦与睡眠',
        }[behavior.mood])
        if group not in groups:
            groups[group] = activities.addMenu(group)
            groups[group].setToolTipsVisible(True)
        action = groups[group].addAction(behavior.label)
        action.setEnabled(owner.companion.behavior_available(name))
        if name == 'taskbar':
            action.setToolTip('沿底部任务栏散步，再搭着边缘看看你；需要底部任务栏常驻显示')
        action.triggered.connect(lambda checked=False, n=name: owner.companion.play_behavior(n))
    actions_menu = menu.addMenu('浮灵动作')
    actions_menu.setEnabled(owner.companion.mood != 'focused')
    for name, action in SPIRIT_ACTIONS.items():
        if name == 'perch':
            continue
        item = actions_menu.addAction(action.label)
        item.triggered.connect(lambda checked=False, n=name: owner.play_action(n))
    feedback = menu.addMenu('动作反馈')
    for key, label in (('pet_effects', '气泡与眩晕特效'),
                       ('pet_sounds', '轻音效'), ('allow_drop', '松手后掉落')):
        item = feedback.addAction(label)
        item.setCheckable(True)
        item.setChecked(bool(config.app_config[key]))
        item.triggered.connect(lambda checked, k=key: owner.set_pet_preference(k, checked))
    return menu


def build_pet_context_menu(owner):
    """高频入口留在首层，陪伴动作与协助工具各自收拢。"""
    # 右键菜单每次都重建，避免主题切换后样式残留；内容轻量，重建开销可忽略
    menu = QMenu(owner)
    menu.setStyleSheet('''
        QMenu {
            background: %(bg)s;
            border: 1px solid %(border)s;
            border-radius: 10px;
            padding: 4px 0;
            font-family: "Microsoft YaHei UI", "Microsoft YaHei";
            font-size: 13px;
        }
        QMenu::item {
            padding: 6px 20px 6px 14px;
            color: %(text)s;
            border-radius: 6px;
            margin: 1px 4px;
        }
        QMenu::item:selected {
            background: %(btn_hover)s;
            color: %(primary)s;
        }
        QMenu::item:disabled { color: %(disabled)s; }
        QMenu::separator {
            height: 1px;
            background: %(border)s;
            margin: 3px 10px;
        }
    ''' % {
        'bg': '#241e35',
        'border': '#65517f',
        'text': '#eee8fa',
        'btn_hover': '#3b3151',
        'primary': '#bdeef1',
        'disabled': '#a0a8b4',
    })
    icon_dir = config.RES_DIR / 'icons'
    system_icon_dir = icon_dir / 'system'
    # 标题项：展示当前宠物名，置灰不可点，仅作菜单头
    if config.current_pet:
        title = QAction(QIcon(str(system_icon_dir / 'minipet.svg')), config.pet_display_name(), menu)
        title.setEnabled(False)
        menu.addAction(title)
        menu.addSeparator()

    # 主功能入口通过 owner 上的信号/方法分发
    icon_color = QColor('#d7c8ea')
    system_action = QAction(FIF.SETTING.icon(color=icon_color), '设置', menu)
    system_action.triggered.connect(owner.show_settings.emit)
    chat_action = QAction(FIF.CHAT.icon(color=icon_color), '聊天', menu)
    chat_action.triggered.connect(owner.chat_requested.emit)
    observe_action = QAction('看看我在做什么', menu)
    observe_action.triggered.connect(owner.observe_requested.emit)
    voice_chat_action = QAction(FIF.VOLUME.icon(color=icon_color), '语音聊天', menu)
    voice_chat_action.triggered.connect(owner.voice_chat_requested.emit)
    menu.addAction(chat_action)
    menu.addMenu(build_companion_menu(owner, menu))
    assistance = menu.addMenu('协助我')
    assistance.addAction(voice_chat_action)
    assistance.addAction(observe_action)
    share_action = QAction(FIF.VIEW.icon(color=icon_color), '共享屏幕', menu)
    share_action.setCheckable(True)
    share_action.setChecked(owner._share_screen_active)
    share_action.triggered.connect(owner._on_share_screen_toggle)
    assistance.addAction(share_action)
    menu.addSeparator()
    menu.addAction(system_action)
    quit_action = QAction(FIF.POWER_BUTTON.icon(color=icon_color), '退出', menu)
    quit_action.triggered.connect(owner.quit)
    menu.addAction(quit_action)
    return menu


class PetDropIntentPopup(QFrame):
    """用户向桌宠拖放内容后，用来选择总结、起草回复等处理意图的弹窗。"""

    intent_selected = Signal(dict, str)   # 参数：(拖放内容, 选中的意图标识)

    def __init__(self, drop_payload, x, y, parent=None):
        """按拖放内容构建弹窗并在拖放点附近弹出；drop_payload 携带 kind/items/preview。"""
        super().__init__(parent)
        self.drop_payload = drop_payload
        self.anim_group = None
        # Tool/NoDropShadowWindowHint 组合：置顶且不抢焦点，避免打断用户当前操作
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.NoDropShadowWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground, True)
        self.setWindowOpacity(0.0)
        t = _theme.current_theme()
        self.setStyleSheet('''
            QFrame#DropCard {
                border: 1px solid %(border)s;
                border-radius: 16px;
                background: %(bg)s;
            }
            QLabel { border: none; background: transparent; color: #1f2328; font-family: "Microsoft YaHei UI", "Microsoft YaHei"; }
            QLabel#DropTitle { font-size: 14px; font-weight: 700; }
            QLabel#DropDesc { color: #68707d; font-size: 12px; }
            QPushButton { border: none; border-radius: 12px; background: %(btn_bg)s; color: #1f2328; padding: 7px 10px; }
            QPushButton:hover { background: %(btn_hover)s; }
            QPushButton#PrimaryButton { background: %(primary)s; color: white; }
            QPushButton#PrimaryButton:hover { background: %(primary)s; opacity: 0.85; }
            QPushButton#QuietButton { background: transparent; color: #8b8f99; }
            QPushButton#QuietButton:hover { background: %(btn_bg)s; color: #4b5563; }
        ''' % {
            'bg': t['menu_bg'],
            'border': t['menu_border'],
            'btn_bg': t['menu_btn_bg'],
            'btn_hover': t['menu_btn_hover'],
            'primary': t['menu_primary'],
        })
        card = QFrame(self)
        card.setObjectName('DropCard')
        root = QVBoxLayout(card)
        root.setContentsMargins(14, 12, 14, 12)
        root.setSpacing(8)

        title = QLabel(self._title_text(), card)
        title.setObjectName('DropTitle')  # 加粗主标题
        root.addWidget(title)

        desc = QLabel(self._description_text(), card)
        desc.setObjectName('DropDesc')  # 灰色小字预览区
        desc.setWordWrap(True)
        desc.setMaximumWidth(320)
        root.addWidget(desc)

        first_row = QHBoxLayout()
        first_row.setSpacing(6)
        # 第一行放三个高频意图，'总结' 为主按钮强调
        for intent, label, primary in (
            ('summarize', '总结', True),
            ('create_task', '生成待办', False),
            ('draft_reply', '起草回复', False),
        ):
            btn = QPushButton(label, card)
            if primary:
                btn.setObjectName('PrimaryButton')
            btn.clicked.connect(lambda checked=False, i=intent: self._select(i))
            first_row.addWidget(btn)
        root.addLayout(first_row)

        second_row = QHBoxLayout()
        second_row.setSpacing(6)
        # 第二行放低频/辅助意图，'取消' 用弱化样式
        for intent, label in (
            ('send_to_lark', '发到飞书'),
            ('ask', '问它怎么处理'),
            ('cancel', '取消'),
        ):
            btn = QPushButton(label, card)
            if intent == 'cancel':
                btn.setObjectName('QuietButton')
            btn.clicked.connect(lambda checked=False, i=intent: self._select(i))
            second_row.addWidget(btn)
        root.addLayout(second_row)

        outer = QHBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.addWidget(card)
        self.adjustSize()
        end_pos = clamp_popup_pos(QPoint(int(x - self.width() / 2), int(y - self.height() - 18)), self.size(), QPoint(int(x), int(y)))
        self.move(end_pos + QPoint(0, 10))
        self._animate_in(end_pos)
        # 18 秒后自动关闭，防止意图选择卡片长期占屏。
        QTimer.singleShot(18000, self.close)

    def _title_text(self):
        """按拖放内容的类型（文件/链接/图片/文本）生成标题。"""
        kind = self.drop_payload.get('kind')
        count = len(self.drop_payload.get('items') or [])
        if kind == 'file':
            return '收到 %d 个文件' % count
        if kind == 'url':
            return '收到 %d 个链接' % count
        if kind == 'image':
            return '收到图片'
        return '收到一段文字'

    def _description_text(self):
        """返回内容预览文本，超长截断到 90 字符。"""
        preview = self.drop_payload.get('preview') or ''
        if len(preview) > 90:
            preview = preview[:90] + '…'
        return preview or '要我怎么处理这个内容？'

    def _animate_in(self, end_pos):
        """入场动画：位置上滑 + 透明度渐显并行播放。"""
        self.show()
        self.raise_()
        pos_anim = QPropertyAnimation(self, b'pos', self)
        pos_anim.setDuration(160)
        pos_anim.setStartValue(self.pos())
        pos_anim.setEndValue(end_pos)
        pos_anim.setEasingCurve(QEasingCurve.OutCubic)
        opacity_anim = QPropertyAnimation(self, b'windowOpacity', self)
        opacity_anim.setDuration(140)
        opacity_anim.setStartValue(0.0)
        opacity_anim.setEndValue(1.0)
        self.anim_group = QParallelAnimationGroup(self)
        self.anim_group.addAnimation(pos_anim)
        self.anim_group.addAnimation(opacity_anim)
        self.anim_group.start()

    def _select(self, intent):
        """处理用户点选的意图；取消则直接关闭不广播。"""
        if intent != 'cancel':
            self.intent_selected.emit(self.drop_payload, intent)
        self.close()

    def changeEvent(self, event):
        """窗口失活（用户点了别处）时自动关闭，避免残留遮挡。"""
        if event.type() == QEvent.ActivationChange and not self.isActiveWindow():
            self.close()
        super().changeEvent(event)


class PetQuickMenu(QFrame):
    """停留后出现聊天和语音入口，不抢焦点；离开后收起。"""
    closed = Signal()

    def __init__(self, x, top_y, bottom_y, on_chat, on_voice_chat,
                 voice_chat_active=False, parent=None):
        super().__init__(parent)
        self._owner = parent
        self.setWindowFlags(Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.NoDropShadowWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setAttribute(Qt.WA_ShowWithoutActivating)
        self.setAttribute(Qt.WA_DeleteOnClose)
        self.setStyleSheet("""
            QFrame#QuickMenuCard { background:#241e35; border:1px solid #79618e; border-radius:20px; }
            QPushButton { color:#eee8fa; background:transparent; border:none; border-radius:14px;
                          font-family:'Microsoft YaHei UI'; font-size:12px; padding:6px 12px; }
            QPushButton:hover { background:#453555; color:#bdeef1; }
            QPushButton:pressed, QPushButton:checked { background:#514166; color:#bdeef1; }
        """)
        card = QFrame(self)
        card.setObjectName('QuickMenuCard')
        row = QHBoxLayout(card)
        row.setContentsMargins(6, 5, 6, 5)
        row.setSpacing(2)
        for label, tip, callback in (
                ('聊天', '打开身旁的轻聊天 · 双击浮灵也可以', on_chat),
                ('语音', '开始或结束语音聊天', on_voice_chat)):
            button = QPushButton(label, card)
            button.setToolTip(tip)
            button.setCursor(Qt.PointingHandCursor)
            if label == '语音':
                button.setCheckable(True)
                button.setChecked(voice_chat_active)
            button.clicked.connect(lambda checked=False, cb=callback: self._trigger(cb))
            row.addWidget(button)
        outer = QHBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.addWidget(card)
        self.adjustSize()
        screen = QApplication.screenAt(QPoint(int(x), int(bottom_y))) or QApplication.primaryScreen()
        area = screen.availableGeometry() if screen else None
        target_y = int(top_y - self.height() - 8)
        if area and target_y < area.top():
            target_y = int(bottom_y + 8)
        end_pos = clamp_popup_pos(QPoint(int(x - self.width() / 2), target_y),
                                  self.size(), QPoint(int(x), int(bottom_y)))
        self.move(end_pos + QPoint(0, 6))
        self._animate_in(end_pos)

    def _trigger(self, callback):
        self.close()
        callback()

    def leaveEvent(self, event):
        from pet.desktop_hover import close_quick_menu_if_mouse_away
        if self._owner is not None:
            owner = self._owner
            QTimer.singleShot(300, lambda: close_quick_menu_if_mouse_away(owner))
        super().leaveEvent(event)

    def closeEvent(self, event):
        if self._owner is not None:
            self._owner.block_quick_menu_until = time.monotonic() + 0.4
        self.closed.emit()
        super().closeEvent(event)

    def _animate_in(self, end_pos):
        self.setWindowOpacity(0.0)
        self.show()
        self.raise_()
        pos_anim = QPropertyAnimation(self, b'pos', self)
        pos_anim.setDuration(140)
        pos_anim.setStartValue(self.pos())
        pos_anim.setEndValue(end_pos)
        pos_anim.setEasingCurve(QEasingCurve.OutCubic)
        opacity_anim = QPropertyAnimation(self, b'windowOpacity', self)
        opacity_anim.setDuration(120)
        opacity_anim.setStartValue(0.0)
        opacity_anim.setEndValue(1.0)
        self.anim_group = QParallelAnimationGroup(self)
        self.anim_group.addAnimation(pos_anim)
        self.anim_group.addAnimation(opacity_anim)
        self.anim_group.start()
