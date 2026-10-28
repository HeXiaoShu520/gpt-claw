# coding:utf-8
"""回复卡片窗口。

ReplyCard 是桌宠核心 UI 组件，负责展示 LLM 回复、工具状态和用户交互控件。
主要能力：
- 流式文本渲染（Typewriter 逐字显示 Markdown → HTML）
- 多媒体 elements（文本、分隔线）+ controls（输入/单选/多选）+ actions（按钮）
- 倒计时头像：显示自动关闭进度，拖动后永久停留
- 独立状态栏、自动展开过程记录、可收起正文和精简用量
- 声音、固定和框选复制；阅读、打字及朗读期间暂停倒计时
- 双击展开引用输入区：支持粘贴/拖拽图片附件
- 宽度自适应：根据内容长度和结构在6个离散档位间动画切换
"""

import base64

from PySide6.QtCore import QBuffer, QByteArray, QEvent, QEasingCurve, QIODevice, Property, QElapsedTimer, QPropertyAnimation, QRectF, Qt, QTimer, Signal
from PySide6.QtGui import QColor, QPainter, QPainterPath, QPen, QPixmap
from PySide6.QtWidgets import QApplication, QButtonGroup, QCheckBox, QFrame, QGridLayout, QHBoxLayout, QLabel, QLineEdit, QMenu, QPushButton, QRadioButton, QScrollArea, QSizePolicy, QVBoxLayout, QWidget

import config
import theme
from log_util import get_logger
from typewriter import Typewriter

log = get_logger('voice.card')
from widgets.notifications.constants import REPLY_CARD_TIMEOUT_MS
from protocols.surface_utils import surface_text_mode, TERMINAL_SURFACE_STATUSES
from widgets.notifications.card_metadata import usage_summary
from widgets.notifications.text_format import has_structured_markdown, markdown_to_html
from widgets.notifications.card_window import ReplyCardWindow

REPLY_CARD_WIDTH_LEVELS = (248, 288, 328, 368, 408, 456)  # 卡片宽度的 6 个离散档位（逻辑像素）
REPLY_CARD_DEFAULT_WIDTH = 288  # 事件未指定宽度时的默认档位
REPLY_CARD_MIN_WIDTH = REPLY_CARD_WIDTH_LEVELS[0]  # 宽度下限（最小档）
REPLY_CARD_MAX_WIDTH = REPLY_CARD_WIDTH_LEVELS[-1]  # 宽度上限（最大档）
REPLY_CARD_AVATAR_SIZE = 36  # 头像逻辑尺寸
REPLY_CARD_RESIZE_ANIM_MS = 180  # 宽度动画时长（毫秒）
REPLY_CARD_COUNTDOWN_TICK_MS = 80  # 倒计时进度刷新间隔（毫秒）


def _scale_for_dpi():
    """根据屏幕 DPI 返回卡片尺寸缩放系数，避免高 DPI 屏幕上卡片过窄。"""
    try:
        screen = QApplication.primaryScreen()
        if screen is None:
            return 1.0
        dpi = screen.logicalDotsPerInch()
        # 96 DPI 为基准，125% 缩放 (120 DPI) 返回 1.0，150% (144 DPI) 返回 1.15
        if dpi <= 120:
            return 1.0
        return min(1.3, 1.0 + (dpi - 120) / 240)
    except:
        return 1.0


class CountdownAvatarLabel(QLabel):
    """在头像图片上叠加圆弧倒计时进度条的 QLabel 子类。

    progress 从 1.0 → 0.0 表示剩余时间比例；
    set_permanent() 切换到永久模式（不再绘制进度弧，只保留完整圆圈）。
    圆弧从12点方向顺时针绘制，与直觉一致。
    """
    def __init__(self, parent=None):
        super().__init__(parent)
        self._progress = 1.0
        self._permanent = False

    def set_progress(self, value):
        """设置剩余时间比例（0.0~1.0），触发重绘。"""
        self._permanent = False
        self._progress = max(0.0, min(1.0, float(value)))
        self.update()

    def set_permanent(self):
        """切换为永久模式：不再绘制倒计时弧，只保留完整圆圈。"""
        self._permanent = True
        self._progress = 1.0
        self.update()

    def paintEvent(self, event):
        """先画底圈（浅色完整圆），再按剩余比例从12点方向顺时针画进度弧。"""
        super().paintEvent(event)
        progress = 1.0 if self._permanent else self._progress
        painter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing, True)
        width = 2.0
        rect = QRectF(width / 2, width / 2, self.width() - width, self.height() - width)
        painter.setPen(QPen(QColor(135, 224, 224, 120), width, Qt.SolidLine, Qt.RoundCap))
        painter.drawArc(rect, 0, 360 * 16)
        if progress > 0:
            painter.setPen(QPen(QColor(0, 194, 203, 235), width, Qt.SolidLine, Qt.RoundCap))
            painter.drawArc(rect, 90 * 16, -int(360 * 16 * progress))
        painter.end()


def _common_prefix_len(a, b):
    """两个字符串的最长公共前缀长度。"""
    n = min(len(a), len(b))
    i = 0
    while i < n and a[i] == b[i]:
        i += 1
    return i


class CopyableLabel(QLabel):
    """选中文字后弹出复制入口，同时支持 Ctrl+C。"""

    def __init__(self, text='', parent=None):
        """启用文本选择，光标设为 I 型以提示可选中文本。"""
        super().__init__(text, parent)
        self.setTextInteractionFlags(Qt.TextSelectableByMouse | Qt.TextSelectableByKeyboard)
        self.setCursor(Qt.IBeamCursor)
        self._copy_text = ''
        self._selection_menu = QMenu(self)
        self._selection_menu.addAction('复制', self._copy_selection)

    def mouseReleaseEvent(self, event):
        super().mouseReleaseEvent(event)
        if event.button() != Qt.LeftButton:
            return
        self._selection_menu.hide()
        text = self.selectedText()
        if text:
            self._copy_text = text
            self._selection_menu.popup(event.globalPosition().toPoint())

    def _copy_selection(self):
        QApplication.clipboard().setText(self._copy_text)

    def contextMenuEvent(self, event):
        """禁用右键菜单，避免与卡片拖拽/打断交互冲突。"""
        event.accept()


class ElidedLabel(QLabel):
    """单行提示保持紧凑；完整文字可通过悬停查看。"""

    def __init__(self, text='', parent=None):
        self._full_text = ''
        super().__init__(parent)
        self.setMinimumWidth(0)
        self.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Preferred)
        self.setTextFormat(Qt.PlainText)
        self.setText(text)

    def setText(self, text):
        self._full_text = str(text)
        self.setToolTip(self._full_text)
        self._elide()

    def _elide(self):
        super().setText(self.fontMetrics().elidedText(self._full_text, Qt.ElideRight, max(1, self.width())))

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self._elide()


class ElidedActionButton(QPushButton):
    """长按钮保留完整提示，避免撑破窄卡片。"""

    def __init__(self, text, parent=None):
        super().__init__(str(text), parent)
        self._full_text = str(text)
        self.setToolTip(self._full_text)
        self.setMinimumWidth(0)
        self.setSizePolicy(QSizePolicy.Ignored, QSizePolicy.Preferred)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self.setText(self.fontMetrics().elidedText(self._full_text, Qt.ElideRight, max(1, self.width() - 28)))


class ChoiceLabel(QLabel):
    """选项文字自动换行，点击文字也可以选择。"""

    def __init__(self, text, choice, parent=None):
        super().__init__(str(text), parent)
        self.choice = choice
        self.setObjectName('ReplyCardElement')
        self.setTextFormat(Qt.PlainText)
        self.setWordWrap(True)
        self.setMinimumWidth(0)
        self.setCursor(Qt.PointingHandCursor)

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.choice.click()
            event.accept()
            return
        super().mouseReleaseEvent(event)


def _reply_card_style_qss(style=None):
    """按主题色生成整张回复卡片的 QSS 样式表（标题/正文/控件/按钮）。"""
    t = theme.get_theme(style) if style else theme.current_theme()
    c = t['card']
    card_css = 'background: %s; border: 1px solid %s;' % (c['bg'], c['border'])
    title = c['title']
    body = c['body']
    meta = c['meta']
    box_bg = c['box_bg']
    return f'''
            QFrame#ReplyCard {{ border-radius: 22px; {card_css} }}
            QFrame#ReplyCardSectionBox {{ border: 1px solid rgba(222,231,255,180); border-radius: 14px; background: {box_bg}; }}
            QFrame#ReplyCardHr {{ border: none; border-top: 1px solid rgba(180,190,215,130); background: transparent; max-height: 1px; }}
            QLabel {{ border: none; background: transparent; font-family: "Microsoft YaHei UI", "Microsoft YaHei"; }}
            QLabel#ReplyCardTitle {{ color: {title}; font-size: 16px; font-weight: 700; }}
            QLabel#ReplyCardAvatar {{ border-radius: 18px; background: #e8f2ff; }}
            QLabel#ReplyCardStatus {{ color: {body}; font-size: 12px; font-weight: 700; }}
            QLabel#ReplyCardProgress {{ color: {meta}; font-size: 12px; }}
            QLabel#ReplyCardMeta, QLabel#ReplyCardControlLabel, QLabel#ReplyCardOptionDescription, QLabel#ReplyCardUsageName {{ color: {meta}; font-size: 11px; }}
            QLabel#ReplyCardSummary, QLabel#ReplyCardElement {{ color: {body}; font-size: 13px; line-height: 1.45; }}
            QFrame#ReplyCardUsageBox {{ border-top: 1px solid rgba(180,190,215,130); background: transparent; }}
            QLabel#ReplyCardUsageName {{ font-size: 11px; }}
            QFrame#ReplyCardStatusBox {{ border: none; border-radius: 10px; background: {box_bg}; }}
            QScrollArea, QScrollArea > QWidget > QWidget {{ background: transparent; border: none; }}
            QScrollBar:vertical {{ background: transparent; width: 8px; margin: 2px 0; }}
            QScrollBar::handle:vertical {{ background: rgba(135,150,180,110); border-radius: 4px; min-height: 24px; }}
            QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {{ height: 0; }}
            QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical {{ background: transparent; }}
            QRadioButton, QCheckBox {{ color: {body}; font: 13px "Microsoft YaHei UI"; background: transparent; border: none; }}
            QRadioButton::indicator, QCheckBox::indicator {{ width: 14px; height: 14px; border: 1px solid #8b9bb5; background: transparent; }}
            QRadioButton::indicator {{ border-radius: 8px; }}
            QCheckBox::indicator {{ border-radius: 3px; }}
            QRadioButton::indicator:checked, QCheckBox::indicator:checked {{ border-color: #1677ff; background: #1677ff; }}
            QLineEdit {{ border: 1px solid rgba(218,226,238,220); border-radius: 9px; background: rgba(255,255,255,210); color: {body}; padding: 6px 8px; font: 13px "Microsoft YaHei UI"; }}
            QPushButton {{ border: 1px solid rgba(218,226,238,220); border-radius: 13px; background: rgba(255,255,255,190); color: #3a4054; font: 13px "Microsoft YaHei UI"; padding: 7px 12px; }}
            QPushButton:hover {{ background: #eef6ff; color: #1677ff; border-color: #b9dcff; }}
            QPushButton#PrimaryAction {{ border: 1px solid #7ebcff; background: qlineargradient(x1:0,y1:0,x2:1,y2:0,stop:0 #5aa8ff,stop:1 #8b7cff); color: white; font-weight: 700; }}
            QPushButton#DangerAction {{ background: #fff1f0; color: #d93026; border-color: #ffd1cc; }}
            QPushButton#QuietAction {{ background: transparent; color: {meta}; border-color: transparent; }}
            QPushButton#CardIcon {{ background: transparent; color: {meta}; border: none; border-radius: 7px; padding: 0; font-size: 16px; }}
            QPushButton#CardIcon:hover, QPushButton#CardIcon:checked {{ background: {box_bg}; color: #1677ff; }}
            QPushButton#CardSmallAction {{ background: transparent; color: {meta}; border: none; border-radius: 7px; padding: 3px 5px; font-size: 11px; }}
            QPushButton#CardSmallAction:hover {{ background: {box_bg}; color: #1677ff; }}
            QPushButton#CardStopAction {{ background: transparent; color: #c75c52; border: none; border-radius: 7px; padding: 3px 5px; font-size: 11px; }}
            QPushButton#CardStopAction:hover {{ background: #fff1f0; }}
            QPushButton#CardStopAction:disabled {{ color: {meta}; }}
        '''


class _QuoteImageChip(QFrame):
    """卡片双击输入框中的图片附件缩略条。"""

    remove_requested = Signal(str)

    def __init__(self, key, image, parent=None):
        """构建 16px 缩略图 + "图片"文字 + 关闭按钮的单行附件条。"""
        super().__init__(parent)
        self.key = key
        self.setFixedHeight(26)
        self.setStyleSheet(
            'QFrame { border: 1px solid rgba(210,216,226,245); border-radius: 7px; background: rgba(255,255,255,245); }'
            'QLabel { border: none; background: transparent; color: #3a4054; font-size: 12px; }'
            'QPushButton { border: none; background: transparent; color: #7b8496; font-weight: 700; }'
            'QPushButton:hover { color: #d93026; }'
        )
        row = QHBoxLayout(self)
        row.setContentsMargins(5, 2, 5, 2)
        row.setSpacing(4)
        thumb = QLabel(self)
        thumb.setFixedSize(16, 16)
        thumb.setStyleSheet('QLabel{border:1px solid rgba(210,216,226,200);border-radius:3px;background:white;}')
        thumb.setPixmap(QPixmap.fromImage(image).scaled(16, 16, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation))
        name = QLabel('图片', self)
        close_btn = QPushButton('×', self)
        close_btn.setFixedSize(14, 14)
        close_btn.clicked.connect(lambda: self.remove_requested.emit(self.key))
        row.addWidget(thumb)
        row.addWidget(name)
        row.addWidget(close_btn)


class ReplyCard(ReplyCardWindow):
    """回复卡片，按需渲染展示内容、输入控件和操作按钮。

    生命周期：
      1. __init__：构建头部、body、usage footer，启动倒计时自动关闭
      2. update_card()：收到新事件时更新文本/宽度/状态；纯进度帧只刷新状态行
      3. _render_body()：结构变化时全量重建 body 区域（elements/controls/actions）
      4. _do_update_card()：结构不变时只更新 Typewriter 文本，避免重建 widget 树
      5. request_close() / _before_close_event()：停止所有定时器，清理 Typewriter

    宽度策略：
      根据内容长度/类型在 REPLY_CARD_WIDTH_LEVELS 6档中选择，
      宽度变化时用 QPropertyAnimation 平滑过渡（adaptiveWidth 属性）。
    """

    action_clicked = Signal(dict, dict)
    layout_changed = Signal()
    quote_reply_submitted = Signal(str, object, str, str)  # card_id, full_message_or_content, quoted_text, user_text

    def __init__(self, card_id, event, timeout=REPLY_CARD_TIMEOUT_MS, parent=None):
        """构建头部、正文、usage 底栏三层布局，并启动倒计时自动关闭。"""
        super().__init__(card_id, parent, fade_in=False, initial_opacity=1.0)
        self.event_data = dict(event)
        self._is_local_notice = bool(event.get('local_notice'))
        self.control_widgets = {}
        self._action_buttons = []
        self._action_pending = False
        self._typewriters = []
        self._tts_active = False
        self._primary_text = ''
        self._primary_text_html = ''
        self._primary_structured = False
        self._primary_typewriter = None
        self._body_structure_signature = None
        self._animated_width = 0
        self._resize_anim = None
        self._resize_anchor_center_x = None
        self._resize_anchor_bottom_y = None
        self._content_resize_pending = False
        self._streaming_resize_pending = False
        self._quote_area = None
        self._quote_edit = None
        self._quote_attachment_holder = None
        self._quote_attachment_row = None
        self._timeout_ms = 0
        self._remaining_ms = 0
        self._pinned = False
        self._hovered = False
        self._progress_history = []
        self._process_manual = None
        self._process_follow_pending = False
        self._collapsed = False
        self._stop_pending = False
        self._body_rendering = False
        self._body_follow_pending = False
        self._countdown_elapsed = QElapsedTimer()
        self.setStyleSheet(_reply_card_style_qss())
        # 顶层透明窗口叠加 QGraphicsDropShadowEffect 在 Windows 多屏/缩放环境下
        # 容易产生负 dirty rect，触发 UpdateLayeredWindowIndirect 参数错误。
        # 卡片本身已有边框和半透明背景，这里不再给顶层窗口加 Qt 阴影。

        self._card_width = self._card_width_for_event(self.event_data)
        self._animated_width = self._card_width
        self._content_width = self._content_width_for_card(self._card_width)
        dpi_scale = _scale_for_dpi()
        scaled_min_width = int(REPLY_CARD_MIN_WIDTH * dpi_scale)
        self.setMinimumWidth(scaled_min_width)
        self.resize(self._card_width, self.height())
        card = QFrame(self)
        card.setObjectName('ReplyCard')
        self.card_frame = card
        shell = QHBoxLayout(card)
        shell.setContentsMargins(0, 0, 0, 0)
        shell.setSpacing(0)
        self.layout_box = QVBoxLayout()
        self.layout_box.setContentsMargins(15, 10, 15, 11)
        self.layout_box.setSpacing(5)
        shell.addLayout(self.layout_box, 1)

        self._build_header(card)
        self._build_status_area(card)
        self._render_body(card)
        self._refresh_progress()
        self._build_usage_footer(card)
        self._refresh_footer_text()

        outer = QVBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.addWidget(card)
        self._size_body_viewport()
        self.adjustSize()
        self._clamp_height()
        self.timer = QTimer(self)
        self.timer.setSingleShot(True)
        self.timer.timeout.connect(self._auto_close_expired)
        self.countdown_timer = QTimer(self)
        self.countdown_timer.timeout.connect(self._tick_countdown)
        self._refresh_status()
        self._start_auto_close(timeout)

    def _normalized_card_width(self, width):
        """按 DPI 缩放后取最近档位，再做上下限裁剪。"""
        try:
            value = int(width or REPLY_CARD_DEFAULT_WIDTH)
        except (TypeError, ValueError):
            value = REPLY_CARD_DEFAULT_WIDTH
        dpi_scale = _scale_for_dpi()
        scaled_value = int(value * dpi_scale)
        scaled_levels = tuple(int(level * dpi_scale) for level in REPLY_CARD_WIDTH_LEVELS)
        nearest = min(scaled_levels, key=lambda level: abs(level - scaled_value))
        return self._clamped_card_width(nearest)

    def _clamped_card_width(self, width):
        """把宽度裁剪到 DPI 缩放后的最小/最大档位之间。"""
        try:
            value = int(width or REPLY_CARD_DEFAULT_WIDTH)
        except (TypeError, ValueError):
            value = REPLY_CARD_DEFAULT_WIDTH
        dpi_scale = _scale_for_dpi()
        scaled_min = int(REPLY_CARD_MIN_WIDTH * dpi_scale)
        scaled_max = int(REPLY_CARD_MAX_WIDTH * dpi_scale)
        return max(scaled_min, min(scaled_max, value))

    def _content_width_for_card(self, card_width):
        """内容区宽度 = 卡片宽度 - 左右各 15px 边距，最小不低于 168。"""
        return max(168, card_width - 30)

    def _sync_content_widths(self):
        """宽度变化后同步状态、正文和页脚，收起时保持卡片宽度。"""
        self.status_box.setFixedWidth(self._content_width)
        self._size_process_viewport()
        for label in self.body_widget.findChildren(CopyableLabel, 'ReplyCardElement'):
            label.setFixedWidth(self._body_content_width())
        self.body_widget.setFixedWidth(self._body_content_width())
        self.actions_widget.setFixedWidth(self._content_width)
        for box in self.findChildren(QFrame, 'ReplyCardUsageBox'):
            box.setFixedWidth(self._content_width)

    def _body_content_width(self):
        # 预留滚动条位置，出现滚动条时正文不跳行。
        return self._content_width - 12

    def _size_body_viewport(self):
        if not hasattr(self, 'body_scroll'):
            return
        self.body_widget.setFixedWidth(self._body_content_width())
        self.body_layout.invalidate()
        height = self.body_layout.totalHeightForWidth(self._body_content_width())
        if height < 0:
            height = self.body_layout.sizeHint().height()
        height = max(1, height)
        self.body_widget.setFixedHeight(height)
        screen = QApplication.screenAt(self.pos()) or QApplication.primaryScreen()
        available = screen.availableGeometry().height() if screen else 900
        # 状态、操作按钮和追问保持可见，正文使用剩余空间滚动。
        margins = self.layout_box.contentsMargins()
        overhead = margins.top() + margins.bottom() + 2
        visible_items = 1 if self.body_layout.count() else 0
        for index in range(self.layout_box.count()):
            item = self.layout_box.itemAt(index)
            widget = item.widget()
            if widget is self.body_scroll or item.isEmpty():
                continue
            if widget is not None:
                widget.ensurePolished()
            visible_items += 1
            item_height = item.heightForWidth(self._content_width) if item.hasHeightForWidth() else -1
            overhead += item_height if item_height >= 0 else item.sizeHint().height()
        overhead += max(0, visible_items - 1) * self.layout_box.spacing()
        limit = max(80, min(420, int(available * 0.8) - overhead))
        self.body_scroll.setFixedHeight(min(height, limit))
        self.body_scroll.setVisible(bool(self.body_layout.count()) and not self._collapsed)
        QTimer.singleShot(0, self._finish_body_resize)

    def _schedule_content_resize(self):
        """合并高频调整请求为一次事件循环内的重排，避免抖动。"""
        if self.closing or self._content_resize_pending:
            return
        self._content_resize_pending = True
        QTimer.singleShot(0, self._resize_to_current_content)

    def _clamp_height(self):
        """卡片最大高度限制为所在屏幕可用高度的 80%。"""
        screen = QApplication.screenAt(self.pos()) or QApplication.primaryScreen()
        if screen is None:
            return
        max_h = int(screen.availableGeometry().height() * 0.8)
        self.setMaximumHeight(max_h)

    def _resize_to_current_content(self):
        """按当前内容重算卡片尺寸，以锚点（中心x/底部y）为基准补偿位移。"""
        self._content_resize_pending = False
        if self.closing:
            return
        anchor_center_x, anchor_bottom_y = self._resize_anchor()
        old_size = self.size()
        for label in self.findChildren(QLabel, 'ReplyCardElement'):
            label.updateGeometry()
        self._size_body_viewport()
        self.layout_box.invalidate()
        self.card_frame.layout().invalidate()
        self.card_frame.layout().activate()
        layout = self.layout()
        if layout is not None:
            layout.invalidate()
            layout.activate()
        self.adjustSize()
        self._clamp_height()
        if self.size() != old_size:
            self._move_to_resize_anchor(anchor_center_x, anchor_bottom_y)
            self.layout_changed.emit()
            self._refresh_topmost_soon()

    def _do_streaming_resize(self):
        """流式期间的延迟重排：优先用更新前保存的锚点，保持视觉稳定。"""
        self._streaming_resize_pending = False
        if self.closing:
            return
        saved = getattr(self, '_streaming_resize_anchor', None)
        if saved is not None:
            anchor_center_x, anchor_bottom_y = saved
            self._streaming_resize_anchor = None
        else:
            anchor_center_x, anchor_bottom_y = self._resize_anchor()
        old_size = self.size()
        self._size_body_viewport()
        self.adjustSize()
        self._clamp_height()
        self._move_to_resize_anchor(anchor_center_x, anchor_bottom_y)
        if self.size() != old_size:
            self.layout_changed.emit()
        self._refresh_topmost_soon()

    def _start_auto_close(self, timeout):
        """设置阅读预算，任务、打字、朗读和交互结束后才消耗预算。"""
        self.timer.stop()
        self._countdown_elapsed.invalidate()
        self._timeout_ms = max(0, int(timeout or 0))
        self._remaining_ms = self._timeout_ms
        if self._timeout_ms <= 0:
            self.countdown_timer.stop()
            self.avatar_label.set_permanent()
            return
        self.countdown_timer.start(REPLY_CARD_COUNTDOWN_TICK_MS)
        self._sync_auto_close()

    def _busy_or_reading(self):
        focus = QApplication.focusWidget()
        return (self._status_value() not in TERMINAL_SURFACE_STATUSES
                or self._tts_active or any(tw.is_running for tw in self._typewriters)
                or self._hovered
                or (not self._collapsed and (self._quote_area is not None or self.process_btn.isChecked()))
                or (focus is not None and self.isAncestorOf(focus)))

    @property
    def protect_from_eviction(self):
        return self._pinned or self.manual_position or self._busy_or_reading()

    def _sync_auto_close(self):
        if not hasattr(self, 'timer') or self.closing:
            return
        paused = self._pinned or self.manual_position or self._busy_or_reading()
        if paused or self._timeout_ms <= 0:
            if self._countdown_elapsed.isValid():
                self._remaining_ms = max(0, self._remaining_ms - self._countdown_elapsed.elapsed())
                self._countdown_elapsed.invalidate()
            self.timer.stop()
        elif not self.timer.isActive():
            self._countdown_elapsed.start()
            self.timer.start(max(1, self._remaining_ms))
        if self._pinned or self.manual_position or self._timeout_ms <= 0:
            self.avatar_label.set_permanent()
        else:
            elapsed = self._countdown_elapsed.elapsed() if self._countdown_elapsed.isValid() else 0
            self.avatar_label.set_progress((self._remaining_ms - elapsed) / self._timeout_ms)

    def _tick_countdown(self):
        self._sync_auto_close()

    def _auto_close_expired(self):
        # 到期与输入/朗读事件可能在同一轮事件循环到达，再检查一次。
        if self.protect_from_eviction:
            self._sync_auto_close()
        else:
            self.request_close()

    def enterEvent(self, event):
        self._hovered = True
        self._sync_auto_close()
        super().enterEvent(event)

    def leaveEvent(self, event):
        self._hovered = False
        self._sync_auto_close()
        super().leaveEvent(event)

    def _toggle_pin(self, pinned):
        self._pinned = bool(pinned)
        if not pinned:
            self.manual_position = False
        self.pin_btn.setText('◆' if pinned else '◇')
        self.pin_btn.setToolTip('取消固定' if pinned else '固定卡片，保留到手动关闭')
        self._sync_auto_close()

    def _close_card(self):
        self._mute_tts()
        self.request_close()

    def _interrupt(self):
        """请求停止但保留卡片，等待服务返回实际结果。"""
        if self.closing or self._stop_pending or self._status_value() in TERMINAL_SURFACE_STATUSES:
            return
        self._stop_pending = True
        self._mute_tts()
        self._refresh_status()
        self.interrupted.emit(self.card_id)

    def _set_collapsed(self, collapsed):
        self._collapsed = bool(collapsed)
        self._refresh_card_visibility()
        self._toggle_process(self.process_btn.isChecked())
        self._schedule_content_resize()
        self._sync_auto_close()

    def _refresh_card_visibility(self):
        self.status_box.setVisible(
            not self._is_local_notice
            and (bool(self.status_label.text()) or self._collapsed or bool(self._progress_history))
        )
        self.pin_btn.setVisible(not self._is_local_notice)
        self.collapse_btn.setVisible(not self._is_local_notice)
        self.collapse_btn.setText('▾' if self._collapsed else '▴')
        self.collapse_btn.setToolTip('展开卡片' if self._collapsed else '收起卡片，保留任务和回复')
        self.body_scroll.setVisible(not self._collapsed and bool(self.body_layout.count()))
        self.actions_widget.setVisible(not self._collapsed and bool(self._action_buttons))
        if hasattr(self, 'usage_footer'):
            self.usage_footer.setVisible(
                not self._is_local_notice and not self._collapsed
                and bool(self.footer_label.text())
            )
        if self._quote_area is not None:
            self._quote_area.setVisible(not self._collapsed)

    def _get_adaptive_width(self):
        """adaptiveWidth 属性 getter，返回当前动画中的宽度。"""
        return int(self._animated_width or self.width() or self._card_width)

    def _set_adaptive_width(self, width):
        """adaptiveWidth 属性 setter，动画每帧回调到这里应用新宽度。"""
        self._apply_card_width(
            int(width),
            anchor_center_x=self._resize_anchor_center_x,
            anchor_bottom_y=self._resize_anchor_bottom_y,
        )

    adaptiveWidth = Property(int, _get_adaptive_width, _set_adaptive_width)

    def _resize_anchor(self):
        """返回缩放锚点（水平中心 x，底部 y），保证尺寸变化时底部不动。"""
        return self.x() + self.width() / 2, self.y() + self.height()

    def _move_to_resize_anchor(self, anchor_center_x=None, anchor_bottom_y=None):
        """位移卡片使锚点保持不动；手动定位/不可见/动画中则跳过。"""
        if self.manual_position or not self.isVisible():
            return
        if self.anim_group is not None and self.anim_group.state() == self.anim_group.State.Running:
            return
        center_x = self.x() + self.width() / 2 if anchor_center_x is None else anchor_center_x
        bottom_y = self.y() + self.height() if anchor_bottom_y is None else anchor_bottom_y
        self.move(int(center_x - self.width() / 2), int(bottom_y - self.height()))

    def _apply_card_width(self, width, anchor_center_x=None, anchor_bottom_y=None):
        """立即应用目标宽度：裁剪、同步内容区宽度、重排并锚定位置。"""
        width = self._clamped_card_width(width)
        self._animated_width = width
        self._content_width = self._content_width_for_card(width)
        self._sync_content_widths()
        layout = self.layout()
        if layout is not None:
            layout.activate()
        height = max(self.height(), self.minimumHeight(), self.minimumSizeHint().height())
        self.resize(width, height)
        self._size_body_viewport()
        self.adjustSize()
        self._clamp_height()
        self._move_to_resize_anchor(anchor_center_x, anchor_bottom_y)
        self._refresh_topmost_soon()

    def _animate_card_width_to(self, width, anchor_center_x=None, anchor_bottom_y=None):
        """用 QPropertyAnimation 驱动 adaptiveWidth 属性平滑过渡到目标档位。"""
        width = self._clamped_card_width(width)
        start_width = self._get_adaptive_width()
        if self._resize_anim is not None:
            self._resize_anim.stop()
            self._resize_anim = None
        self._resize_anchor_center_x = anchor_center_x
        self._resize_anchor_bottom_y = anchor_bottom_y
        # 差值 ≤1px 或窗口不可见时直接跳到目标宽度，避免触发看不见的动画
        if abs(start_width - width) <= 1 or not self.isVisible():
            self._apply_card_width(width, anchor_center_x, anchor_bottom_y)
            self._resize_anchor_center_x = None
            self._resize_anchor_bottom_y = None
            self.layout_changed.emit()
            return
        anim = QPropertyAnimation(self, b'adaptiveWidth', self)
        anim.setDuration(REPLY_CARD_RESIZE_ANIM_MS)
        anim.setStartValue(start_width)
        anim.setEndValue(width)
        anim.setEasingCurve(QEasingCurve.OutCubic)
        anim.finished.connect(lambda: self._finish_resize_animation(width))
        self._resize_anim = anim
        anim.start()

    def _finish_resize_animation(self, width):
        """动画结束回调：最终应用宽度并清理锚点状态。"""
        self._apply_card_width(width, self._resize_anchor_center_x, self._resize_anchor_bottom_y)
        self._resize_anim = None
        self._resize_anchor_center_x = None
        self._resize_anchor_bottom_y = None
        self.layout_changed.emit()

    def _card_width_for_event(self, event):
        return self._normalized_card_width(self._logical_card_width_for_event(event))

    def _logical_card_width_for_event(self, event):
        """根据事件内容自动选择合适的卡片宽度档位。

        优先级：
        1. 事件显式指定 width
        2. 含结构化 Markdown 且较长 → 456（最大档）
        3. 含 controls/actions → 根据数量和文本长度决定
        4. 纯文本 → 按加权字符数映射到对应档位
        加权规则：换行/制表符计8，中文字符计2，ASCII计1。
        """
        # 使用档位而不是像素连续值，是为了让宽度动画跳跃幅度可预测、避免频繁微小调整
        if event.get('width') is not None:
            return event.get('width')
        controls = event.get('controls') or []
        actions = event.get('actions') or []
        elements = event.get('elements') or []
        text = self._event_text_for_width(event)
        length = self._weighted_text_length(text)
        source = str(event.get('source_label') or '').strip()
        if has_structured_markdown(text) and length > 90:
            return 456
        if controls:
            return 408 if len(controls) > 2 or length > 90 else 368
        if actions:
            return 408 if len(actions) > 2 or length > 70 else 368
        if isinstance(elements, list) and len(elements) > 1:
            return 408 if length > 90 else 368
        # 纯文本：宽度取决于最长的一行（其余行换行由高度吸收），多行短句
        # 服务回复留出状态和操作按钮的空间，短欢迎语仍使用窄卡片。
        longest = max((self._weighted_text_length(line) for line in str(text or '').split('\n')), default=0)
        if source:
            longest = max(longest + self._weighted_text_length(source), 53)
        if longest <= 24:
            return 248
        if longest <= 52:
            return 288
        if longest <= 78:
            return 328
        if longest <= 130:
            return 368
        return 408

    def _event_text_for_width(self, event):
        """拼合事件中所有文本字段（含 elements），作为宽度估算依据。"""
        parts = [event.get('summary'), event.get('content'), event.get('message'), event.get('text')]
        for element in event.get('elements') or []:
            if isinstance(element, dict):
                parts.append(element.get('content') or element.get('text'))
        return '\n'.join(str(part) for part in parts if part)

    def _weighted_text_length(self, text):
        """计算加权字符长度：换行/制表计8、中文计2、ASCII计1。"""
        total = 0
        for ch in str(text or ''):
            if ch in '\r\n\t':
                total += 8
            elif ord(ch) > 127:
                total += 2
            else:
                total += 1
        return total

    def _build_header(self, card):
        """身份和来源置左，常用窗口操作置右。"""
        header = QHBoxLayout()
        header.setSpacing(6)
        dpi_scale = _scale_for_dpi()
        avatar_size = int(REPLY_CARD_AVATAR_SIZE * dpi_scale)
        self.avatar_label = CountdownAvatarLabel(card)
        self.avatar_label.setObjectName('ReplyCardAvatar')
        self.avatar_label.setFixedSize(avatar_size, avatar_size)
        self.avatar_label.setAlignment(Qt.AlignCenter)
        avatar_kind = self.event_data.get('avatar_kind') or 'pet'
        icon = QPixmap(str(config.avatar_path(avatar_kind)))
        if not icon.isNull():
            self.avatar_label.setPixmap(self._rounded_avatar(icon, avatar_size))
        else:
            self.avatar_label.setText('你' if avatar_kind == 'user' else '宠')
        header.addWidget(self.avatar_label, 0, Qt.AlignTop)
        title_row = QVBoxLayout()
        title_row.setContentsMargins(0, 0, 0, 0)
        title_row.setSpacing(0)
        self.title_label = ElidedLabel(config.pet_display_name(), card)
        self.title_label.setObjectName('ReplyCardTitle')
        title_row.addWidget(self.title_label)
        self.source_chip = ElidedLabel(str(self.event_data.get('source_label') or ''), card)
        self.source_chip.setObjectName('ReplyCardUsageName')
        self.source_chip.setVisible(bool(self.event_data.get('source_label')))
        title_row.addWidget(self.source_chip)
        header.addLayout(title_row, 1)
        self.mute_btn = QPushButton('🔊', card)
        self.mute_btn.setToolTip('停止语音播放')
        self.mute_btn.clicked.connect(self._mute_tts)
        self.pin_btn = QPushButton('◇', card)
        self.pin_btn.setCheckable(True)
        self.pin_btn.setToolTip('固定卡片，保留到手动关闭')
        self.pin_btn.toggled.connect(self._toggle_pin)
        self.collapse_btn = QPushButton('⌃', card)
        self.collapse_btn.clicked.connect(lambda: self._set_collapsed(not self._collapsed))
        self.close_btn = QPushButton('×', card)
        self.close_btn.setToolTip('关闭卡片')
        self.close_btn.clicked.connect(self._close_card)
        for button in (self.mute_btn, self.pin_btn, self.collapse_btn, self.close_btn):
            button.setObjectName('CardIcon')
            button.setFixedSize(24, 26)
            button.setFocusPolicy(Qt.NoFocus)
            header.addWidget(button, 0, Qt.AlignVCenter)
        self.layout_box.addLayout(header)
        self._refresh_title_meta()

    def _build_status_area(self, card):
        self.status_box = QFrame(card)
        self.status_box.setObjectName('ReplyCardStatusBox')
        self.status_box.setFixedWidth(self._content_width)
        status_layout = QVBoxLayout(self.status_box)
        status_layout.setContentsMargins(9, 5, 9, 5)
        status_layout.setSpacing(3)
        row = QHBoxLayout()
        self.status_label = QLabel('', self.status_box)
        self.status_label.setObjectName('ReplyCardStatus')
        self.status_label.setTextFormat(Qt.PlainText)
        row.addWidget(self.status_label, 1)
        self.process_btn = QPushButton('', self.status_box)
        self.process_btn.setObjectName('CardSmallAction')
        self.process_btn.setCheckable(True)
        self.process_btn.setFocusPolicy(Qt.NoFocus)
        self.process_btn.toggled.connect(self._toggle_process)
        self.process_btn.clicked.connect(self._process_toggled_by_user)
        row.addWidget(self.process_btn)
        self.stop_btn = QPushButton('停止', self.status_box)
        self.stop_btn.setObjectName('CardStopAction')
        self.stop_btn.setToolTip('请求中断当前对话任务')
        self.stop_btn.setFocusPolicy(Qt.NoFocus)
        self.stop_btn.clicked.connect(self._interrupt)
        row.addWidget(self.stop_btn)
        status_layout.addLayout(row)
        self.progress_label = ElidedLabel('', self.status_box)
        self.progress_label.setObjectName('ReplyCardProgress')
        status_layout.addWidget(self.progress_label)
        self.process_scroll = QScrollArea(self.status_box)
        self.process_scroll.setWidgetResizable(True)
        self.process_scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.process_scroll.setFixedHeight(32)
        self.process_history_label = CopyableLabel('', self.process_scroll)
        self.process_history_label.setTextFormat(Qt.PlainText)
        self.process_history_label.setObjectName('ReplyCardProgress')
        self.process_history_label.setWordWrap(True)
        self.process_history_label.setAlignment(Qt.AlignTop)
        self.process_scroll.setWidget(self.process_history_label)
        self.process_scroll.verticalScrollBar().rangeChanged.connect(self._follow_process_if_at_end)
        self.process_scroll.setVisible(False)
        status_layout.addWidget(self.process_scroll)
        self.layout_box.addWidget(self.status_box)

    def _toggle_process(self, expanded):
        visible = expanded and bool(self._progress_history) and not self._collapsed
        self.process_scroll.setVisible(visible)
        self.process_btn.setText(f'过程 {len(self._progress_history)} {"−" if expanded else "+"}')
        self.process_btn.setVisible(bool(self._progress_history) and not self._collapsed)
        terminal = self._status_value() in TERMINAL_SURFACE_STATUSES
        text = '' if terminal else str(self.event_data.get('progress') or '').strip()
        if self._collapsed and not text:
            text = '展开查看回复' if terminal else '任务继续处理中'
        self.progress_label.setText(text)
        self.progress_label.setVisible(bool(text) and not visible)
        if visible:
            self._size_process_viewport()
        self._refresh_card_visibility()
        self._schedule_content_resize()
        self._sync_auto_close()

    def _size_process_viewport(self):
        width = max(1, self._content_width - 28)
        self.process_history_label.setFixedWidth(width)
        height = self.process_history_label.heightForWidth(width)
        self.process_scroll.setFixedHeight(max(32, min(112, height + 4)))

    def _process_toggled_by_user(self, expanded):
        self._process_manual = bool(expanded)

    def _refresh_process_history(self):
        text = '\n\n'.join(self._progress_history)
        if text != self.process_history_label.text():
            bar = self.process_scroll.verticalScrollBar()
            self._process_follow_pending = bar.maximum() - bar.value() <= 24
            self.process_history_label.setText(text)
            QTimer.singleShot(0, self._finish_process_resize)

    def _follow_process_if_at_end(self, minimum, maximum):
        if self._process_follow_pending:
            self.process_scroll.verticalScrollBar().setValue(maximum)

    def _finish_process_resize(self):
        if not self.closing and self._process_follow_pending:
            bar = self.process_scroll.verticalScrollBar()
            bar.setValue(bar.maximum())
        self._process_follow_pending = False

    def _rounded_avatar(self, pixmap, size):
        """把头像裁成圆形 QPixmap，带高 DPI 适配。"""
        # 高 DPI 屏幕下用物理像素尺寸绘制，再设置 devicePixelRatio，避免头像模糊
        # 用 QPainterPath.addEllipse + setClipPath 实现圆形裁剪，比 border-radius CSS 更可靠
        screen = QApplication.primaryScreen()
        dpr = screen.devicePixelRatio() if screen else 1.0
        target = max(1, int(size * dpr))
        scaled = pixmap.scaled(target, target, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)
        if scaled.width() != target or scaled.height() != target:
            x = max(0, (scaled.width() - target) // 2)
            y = max(0, (scaled.height() - target) // 2)
            scaled = scaled.copy(x, y, target, target)
        result = QPixmap(target, target)
        result.fill(Qt.transparent)
        painter = QPainter(result)
        painter.setRenderHint(QPainter.Antialiasing, True)
        path = QPainterPath()
        path.addEllipse(0, 0, target, target)
        painter.setClipPath(path)
        painter.drawPixmap(0, 0, scaled)
        painter.end()
        result.setDevicePixelRatio(dpr)
        return result

    def _clear_layout(self, layout):
        """递归清空布局：嵌套布局逐层移除，widget 全部 deleteLater。"""
        while layout.count():
            item = layout.takeAt(0)
            child_layout = item.layout()
            widget = item.widget()
            if child_layout is not None:
                self._clear_layout(child_layout)
            if widget is not None:
                widget.hide()
                widget.setParent(None)
                widget.deleteLater()

    def _render_body(self, card=None):
        """重建可滚动正文、控件和独立操作区，并记录结构签名。"""
        card = card or self
        self._body_rendering = True
        self._body_follow_pending = False
        for tw in self._typewriters:
            tw.set_text('')
        if hasattr(self, 'body_layout'):
            self._clear_layout(self.body_layout)
            self._clear_layout(self.actions_layout)
        else:
            self.body_scroll = QScrollArea(card)
            self.body_scroll.setWidgetResizable(True)
            self.body_scroll.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
            self.body_scroll.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
            self.body_widget = QWidget(self.body_scroll)
            self.body_widget.setFixedWidth(self._body_content_width())
            self.body_layout = QVBoxLayout(self.body_widget)
            self.body_layout.setContentsMargins(0, 0, 0, 0)
            self.body_layout.setSpacing(9)
            self.body_layout.setAlignment(Qt.AlignTop)
            self.body_scroll.setWidget(self.body_widget)
            self.layout_box.addWidget(self.body_scroll)
            self.body_scroll.verticalScrollBar().rangeChanged.connect(self._follow_body_if_at_end)
            self.actions_widget = QWidget(card)
            self.actions_widget.setFixedWidth(self._content_width)
            self.actions_layout = QVBoxLayout(self.actions_widget)
            self.actions_layout.setContentsMargins(0, 0, 0, 0)
            self.actions_layout.setSpacing(0)
            self.layout_box.addWidget(self.actions_widget)
        self.control_widgets = {}
        self._action_buttons = []
        self._typewriters = []
        self._primary_typewriter = None
        self._primary_text = ''
        self._primary_text_html = ''
        self._primary_structured = False
        self._add_elements(self.body_layout, self.body_widget, self._normalized_elements())
        self._add_controls(self.body_layout, self.body_widget, self.event_data.get('controls') or [])
        self._add_actions(self.actions_layout, self.actions_widget, self.event_data.get('actions') or [])
        self.actions_widget.setVisible(bool(self._action_buttons))
        self._refresh_card_visibility()
        self._refresh_usage_footer()
        self._body_structure_signature = self._structure_signature()
        self.body_scroll.verticalScrollBar().setValue(0)
        self._body_rendering = False

    def _build_usage_footer(self, card):
        """仅显示一行用量，详细统计留在悬停提示中。"""
        self.usage_footer = QFrame(card)
        self.usage_footer.setObjectName('ReplyCardUsageBox')
        self.usage_footer.setFixedWidth(self._content_width)
        self.usage_layout = QHBoxLayout(self.usage_footer)
        self.usage_layout.setContentsMargins(0, 7, 0, 0)
        self.usage_layout.setSpacing(3)
        self.footer_label = ElidedLabel('', self.usage_footer)
        self.footer_label.setObjectName('ReplyCardUsageName')
        self.usage_layout.addWidget(self.footer_label, 1)
        self.layout_box.addWidget(self.usage_footer)
        self._refresh_usage_footer()

    def _refresh_usage_footer(self):
        if not hasattr(self, 'footer_label'):
            return
        text, details = usage_summary(self.event_data.get('result_usage'), self.event_data.get('footer_text'))
        self.footer_label.setText(text)
        self.footer_label.setToolTip(details)
        self._refresh_card_visibility()

    def _refresh_footer_text(self):
        self._refresh_usage_footer()

    def _follow_body_if_at_end(self, minimum, maximum):
        if self._body_follow_pending:
            self.body_scroll.verticalScrollBar().setValue(maximum)

    def _on_body_text_update(self):
        # 只有追加正文才跟随底部；初次展示和展开追问不改变阅读位置。
        if not self._body_rendering:
            bar = self.body_scroll.verticalScrollBar()
            self._body_follow_pending = bar.maximum() - bar.value() <= 24
        self._schedule_content_resize()

    def _finish_body_resize(self):
        if self.closing:
            return
        if self._body_follow_pending:
            bar = self.body_scroll.verticalScrollBar()
            bar.setValue(bar.maximum())
        self._body_follow_pending = False

    def _refresh_progress(self):
        text = str(self.event_data.get('progress') or '').strip()
        if text and (not self._progress_history or self._progress_history[-1] != text):
            self._progress_history.append(text)
            self._progress_history = self._progress_history[-50:]
        self._refresh_process_history()
        expanded = self._process_manual
        if expanded is None:
            expanded = bool(self._progress_history) and self._status_value() not in TERMINAL_SURFACE_STATUSES and self._status_value() != 'waiting'
        self.process_btn.setChecked(expanded)
        self._toggle_process(expanded)
        self._schedule_content_resize()

    def _primary_text_value(self):
        """主文本取值优先级：summary → content → message。"""
        return self.event_data.get('summary') or self.event_data.get('content') or self.event_data.get('message') or self.event_data.get('text') or ''

    def _normalized_elements(self):
        """把主文本和媒体归一化为 element 块（主文本标记 _primary）。"""
        elements = self.event_data.get('elements') or []
        normalized = list(elements) if isinstance(elements, list) else []
        text = self._primary_text_value()
        if text:
            normalized = [{'type': 'text', 'content': text, '_primary': True}] + normalized
        if self.event_data.get('image_data_url'):
            normalized.append({'type': 'image', 'data_url': self.event_data['image_data_url']})
        return normalized

    def _structure_signature(self):
        """生成正文结构指纹，用于判断是否需要全量重建 widget 树。"""
        return (repr(self.event_data.get('elements') or []), repr(self.event_data.get('controls') or []), repr(self.event_data.get('actions') or []), self.event_data.get('image_data_url', '')[:80])

    def update_card(self, event, timeout=None):
        """进度帧只更新状态行，正文帧由 Typewriter 连续接收。"""
        if self.closing:
            return
        event = dict(event or {})
        old_surface = self.event_data.get('surface_id')
        new_surface = event.get('surface_id')
        if old_surface and new_surface and old_surface != new_surface:
            self._progress_history.clear()
            self._process_manual = None
            self._stop_pending = False
            self.process_btn.setChecked(False)
            self._set_collapsed(False)
            for key in ('done', 'error', 'progress', 'summary', 'content', 'message', 'text',
                        'elements', 'controls', 'actions', 'image_data_url', 'footer_text', 'result_usage'):
                self.event_data.pop(key, None)
            self._primary_text = ''
            self._primary_text_html = ''
        if surface_text_mode(event) == 'delta':
            delta = str(event.get('text') or event.get('message') or event.get('content') or '')
            current = str(self._primary_text or self._primary_text_value())
            event['content'] = current + delta
            event['elements'] = []
            event['summary'] = event['content']
        elif any(key in event for key in ('summary', 'content', 'message', 'text')):
            # 新文本帧覆盖旧的 summary，避免 delta/完整帧混用后停在旧正文。
            event['summary'] = next((event[key] for key in ('summary', 'content', 'message', 'text')
                                     if key in event and event[key]), '')
        status = str(event.get('status') or event.get('state') or '').strip().lower()
        if status and status not in TERMINAL_SURFACE_STATUSES and self._status_value() in TERMINAL_SURFACE_STATUSES:
            self._process_manual = None
            self._stop_pending = False
        if status and status not in TERMINAL_SURFACE_STATUSES:
            self.event_data.pop('done', None)
            self.event_data.pop('error', None)
        recover_waiting = event.get('type') == 'surface.show' and status == 'waiting'
        if recover_waiting:
            event.setdefault('progress', '')
        is_terminal = event.get('done') or event.get('error') or status in TERMINAL_SURFACE_STATUSES
        if is_terminal:
            event.setdefault('progress', '')
        if (status in ('streaming', 'running', 'working')
                and not any(key in event for key in (
                    'content', 'text', 'message', 'summary', 'elements',
                    'controls', 'actions', 'image_data_url',
                ))):
            self.event_data.update(event)
            self._refresh_progress()
            self._refresh_usage_footer()
            self._refresh_status()
            if timeout is not None:
                self._start_auto_close(timeout)
            return
        self._do_update_card(event, timeout)
        if recover_waiting:
            self.set_approval_pending(False)

    def _do_update_card(self, event, timeout=None):
        if self.closing:
            return
        anchor_center_x, anchor_bottom_y = self._resize_anchor()
        self.event_data.update(event or {})
        new_width = self._card_width_for_event(self.event_data)
        width_changed = new_width != self._card_width
        if width_changed:
            self._card_width = new_width
        self._refresh_title_meta()
        new_text = str(self._primary_text_value())
        new_html = markdown_to_html(new_text)
        new_structured = has_structured_markdown(new_text)
        # 结构签名不变时走快速路径：只更新 Typewriter，不重建 widget 树
        # 这是性能关键路径：避免流式回复期间每帧重建 DOM 结构导致闪烁和卡顿
        if self._structure_signature() == self._body_structure_signature and self._primary_typewriter is not None:
            if new_text != self._primary_text:
                previous_html = self._primary_text_html or ''
                # 增量追加让打字动画跨流式更新持续推进。前缀断裂通常是
                # markdown 对尾部的重写：从公共前缀处继续打字——新回复
                # （即使内容大改）同样逐字输出，不再瞬间整段替换。
                common = _common_prefix_len(previous_html, new_html)
                if previous_html and new_html.startswith(previous_html):
                    self._primary_typewriter.append_chunk(new_html[len(previous_html):])
                else:
                    self._primary_typewriter.continue_from(new_html, common)
            self._primary_text = new_text
            self._primary_text_html = new_html
            self._primary_structured = new_structured
        else:
            self._render_body()
            self._schedule_content_resize()
        self._refresh_usage_footer()
        self._refresh_progress()
        self._refresh_footer_text()
        self._refresh_status()
        if timeout is not None:
            self._start_auto_close(timeout)
        if width_changed:
            self._animate_card_width_to(new_width, anchor_center_x, anchor_bottom_y)
        else:
            is_streaming = self._status_value() in ('streaming', 'running', 'working')
            if is_streaming:
                self._streaming_resize_anchor = (anchor_center_x, anchor_bottom_y)
                if not self._streaming_resize_pending:
                    self._streaming_resize_pending = True
                    QTimer.singleShot(120, self._do_streaming_resize)
            else:
                old_size = self.size()
                self._size_body_viewport()
                self.adjustSize()
                self._clamp_height()
                self._move_to_resize_anchor(anchor_center_x, anchor_bottom_y)
                if self.size() != old_size:
                    self.layout_changed.emit()
                self._refresh_topmost_soon()

    def update_message(self, message, timeout=None):
        """兼容纯文本回复的更新入口。"""
        self.update_card({'content': message, 'elements': []}, timeout=timeout)

    def _refresh_title_meta(self):
        """刷新标题；事件未指定时回落到宠物显示名。"""
        self.title_label.setText(str(self.event_data.get('title') or config.pet_display_name()))
        source = str(self.event_data.get('source_label') or '')
        self.source_chip.setText(source)
        self.source_chip.setVisible(bool(source))

    def _status_value(self):
        """归一化状态值：done/error 字段优先，否则取 status/state 文本。"""
        if self.event_data.get('error'):
            return 'failed'
        if self.event_data.get('done'):
            return 'done'
        return str(self.event_data.get('status') or self.event_data.get('state') or '').strip().lower().replace('_', '-')

    def set_tts_active(self, active):
        """外部通知 TTS 播放状态，刷新状态显示。"""
        self._tts_active = bool(active)
        self._refresh_status()

    def _refresh_status(self):
        status = self._status_value()
        terminal = status in TERMINAL_SURFACE_STATUSES
        if terminal:
            self._stop_pending = False
        if self._stop_pending:
            label = '正在停止…'
        elif self._tts_active:
            label = '朗读中'
        elif status in ('failed', 'failure', 'error'):
            label = '未完成'
        elif terminal:
            label = ''
        elif status == 'waiting':
            label = '等待确认'
        elif status == 'thinking':
            label = '思考中'
        elif status == 'streaming':
            label = '回复中'
        else:
            label = '处理中'
        self.status_label.setText(label)
        self.status_label.setVisible(bool(label))
        self.stop_btn.setVisible(not terminal)
        self.stop_btn.setEnabled(not self._stop_pending)
        self.close_btn.setVisible(terminal)
        self._refresh_card_visibility()
        self._schedule_content_resize()
        self._sync_auto_close()

    def _make_permanent(self):
        """转为永久卡片：停掉超时和倒计时定时器，头像切为完整圆圈。"""
        self.pin_btn.setChecked(True)
        self._sync_auto_close()

    def _on_manual_positioned(self):
        """拖拽定位后转为永久卡片，不再自动关闭。"""
        self._make_permanent()

    def _mute_tts(self):
        """停止当前 TTS，不切换按钮外观。"""
        super()._mute_tts()

    def _before_request_close(self):
        """关闭前收起引用输入区并停掉所有定时器。"""
        super()._before_request_close()
        self._collapse_quote_area()
        self.countdown_timer.stop()
        if hasattr(self, 'avatar_label'):
            self.avatar_label.set_progress(0.0)

    def _add_elements(self, layout, card, elements):
        # 长回复交给正文滚动区，不截断内容。
        for element in elements:
            if not isinstance(element, dict):
                continue
            tag = element.get('tag') or element.get('type')
            if tag in ('hr', 'divider'):
                # 分隔线元素不再渲染（易产生高度跳变），直接省略
                continue
            if tag == 'image':
                data_url = element.get('data_url') or ''
                if not data_url.startswith('data:image/') or ';base64,' not in data_url:
                    continue
                pixmap = QPixmap()
                if not pixmap.loadFromData(base64.b64decode(data_url.split(',', 1)[1])):
                    continue
                image = QLabel(card)
                image.setPixmap(pixmap.scaled(self._body_content_width(), 320, Qt.KeepAspectRatio, Qt.SmoothTransformation))
                image.setToolTip('生成的图片')
                layout.addWidget(image)
                continue
            if tag not in ('markdown', 'text', 'plain_text', 'code'):
                continue
            content = element.get('content') or element.get('text') or ''
            if not content:
                continue
            is_primary = bool(element.get('_primary'))
            label = CopyableLabel('', card)
            label.setObjectName('ReplyCardElement')
            label.setTextFormat(Qt.RichText)
            label.setWordWrap(True)
            label.setFixedWidth(self._body_content_width())
            content_text = str(content)
            structured = has_structured_markdown(content_text)
            html_text = markdown_to_html(content_text)
            layout.addWidget(label)
            tw = Typewriter(label, on_update=self._on_body_text_update)
            self._typewriters.append(tw)
            if is_primary:
                self._primary_text = content_text
                self._primary_text_html = html_text
                self._primary_structured = structured
                self._primary_typewriter = tw
            # 结构化 Markdown 同样走打字机：Qt 富文本对未闭合标签有容错，逐字推进不破坏块级布局
            tw.typewrite(html_text)

    def _add_controls(self, layout, card, controls):
        """渲染输入/单选/多选控件区，记录到 control_widgets 供收集取值。"""
        def add_choice(box, box_layout, choice, text, description=''):
            row = QHBoxLayout()
            row.setSpacing(6)
            choice.setText('')
            choice.setFixedSize(20, 20)
            row.addWidget(choice, 0, Qt.AlignTop)
            label = ChoiceLabel(text, choice, box)
            label.setToolTip(str(description or text))
            choice.setToolTip(str(description or text))
            row.addWidget(label, 1)
            box_layout.addLayout(row)

        # 完整保留控件和选项；长确认内容由正文滚动区承载。
        for control in controls:
            if not isinstance(control, dict):
                continue
            ctype = (control.get('type') or 'text').lower()
            cid = control.get('id') or control.get('name')
            if not cid:
                continue
            box = QFrame(card)
            box.setObjectName('ReplyCardSectionBox')
            box_layout = QVBoxLayout(box)
            box_layout.setContentsMargins(10, 8, 10, 8)
            box_layout.setSpacing(6)
            label_text = control.get('label') or control.get('title') or ''
            if label_text:
                label = QLabel(label_text, box)
                label.setObjectName('ReplyCardControlLabel')
                label.setTextFormat(Qt.PlainText)
                label.setWordWrap(True)
                box_layout.addWidget(label)
            if ctype in ('text', 'input'):
                edit = QLineEdit(box)
                edit.setPlaceholderText(control.get('placeholder') or '')
                edit.setText(str(control.get('default_value') or control.get('value') or ''))
                self.control_widgets[cid] = {'type': 'text', 'widget': edit}
                box_layout.addWidget(edit)
            elif ctype in ('radio', 'radio_group', 'select'):
                group = QButtonGroup(box)
                buttons = []
                for option in control.get('options') or []:
                    if not isinstance(option, dict):
                        continue
                    btn = QRadioButton(box)
                    btn._minipet_value = option.get('id') or option.get('value') or option.get('label')
                    group.addButton(btn)
                    add_choice(box, box_layout, btn, option.get('label') or option.get('id') or '', option.get('description'))
                    buttons.append(btn)
                custom_edit = None
                if control.get('allow_custom'):
                    custom = QRadioButton(box)
                    custom._minipet_value = control.get('custom_id') or 'custom'
                    group.addButton(custom)
                    add_choice(box, box_layout, custom, control.get('custom_label') or '其他')
                    custom_edit = QLineEdit(box)
                    custom_edit.setPlaceholderText(control.get('custom_placeholder') or '请输入')
                    box_layout.addWidget(custom_edit)
                    buttons.append(custom)
                if buttons:
                    buttons[0].setChecked(True)
                self.control_widgets[cid] = {'type': 'radio_group', 'buttons': buttons, 'custom_edit': custom_edit}
            elif ctype in ('checkbox', 'checkbox_group', 'multi_select'):
                checks = []
                for option in control.get('options') or []:
                    if not isinstance(option, dict):
                        continue
                    chk = QCheckBox(box)
                    chk._minipet_value = option.get('id') or option.get('value') or option.get('label')
                    add_choice(box, box_layout, chk, option.get('label') or option.get('id') or '', option.get('description'))
                    checks.append(chk)
                custom_edit = None
                if control.get('allow_custom'):
                    chk = QCheckBox(box)
                    chk._minipet_value = control.get('custom_id') or 'custom'
                    add_choice(box, box_layout, chk, control.get('custom_label') or '其他')
                    custom_edit = QLineEdit(box)
                    custom_edit.setPlaceholderText(control.get('custom_placeholder') or '请输入')
                    box_layout.addWidget(custom_edit)
                    checks.append(chk)
                self.control_widgets[cid] = {'type': 'checkbox_group', 'checks': checks, 'custom_edit': custom_edit}
            else:
                continue
            layout.addWidget(box)

    def _add_actions(self, layout, card, actions):
        if not actions:
            return
        action_row = QGridLayout()
        action_row.setSpacing(7)
        valid_actions = [action for action in actions if isinstance(action, dict)]
        half_width = (self._content_width - 7) // 2
        metrics = self.fontMetrics()
        columns = 2 if len(valid_actions) > 1 and all(
            metrics.horizontalAdvance(str(action.get('label') or action.get('id') or '操作')) + 40 <= half_width
            for action in valid_actions) else 1
        for index, action in enumerate(valid_actions):
            btn = ElidedActionButton(action.get('label') or action.get('id') or '操作', card)
            btn.setCursor(Qt.PointingHandCursor)
            style = action.get('style') or action.get('intent') or ''
            intent = action.get('intent') or ''
            action_id = action.get('id') or ''
            if style in ('primary', 'confirm') or intent == 'confirm' or action_id in ('confirm', 'send', 'ok', 'submit'):
                btn.setObjectName('PrimaryAction')
            elif style in ('danger', 'reject') or intent == 'reject':
                btn.setObjectName('DangerAction')
            elif style in ('quiet', 'cancel') or intent == 'cancel' or action_id in ('cancel', 'ignore'):
                btn.setObjectName('QuietAction')
            btn.clicked.connect(lambda checked=False, a=action: self._click_action(a))
            action_row.addWidget(btn, index // columns, index % columns)
            self._action_buttons.append(btn)
        layout.addLayout(action_row)

    def _collect_values(self):
        """收集所有控件当前值；allow_custom 选中时附带 xxx_text 自定义输入。"""
        values = {}
        for cid, spec in self.control_widgets.items():
            if spec['type'] == 'text':
                values[cid] = spec['widget'].text()
            elif spec['type'] == 'radio_group':
                selected = None
                for btn in spec['buttons']:
                    if btn.isChecked():
                        selected = getattr(btn, '_minipet_value', btn.text())
                        break
                values[cid] = selected
                if selected == 'custom' and spec.get('custom_edit') is not None:
                    values[cid + '_text'] = spec['custom_edit'].text()
            elif spec['type'] == 'checkbox_group':
                selected = [getattr(chk, '_minipet_value', chk.text()) for chk in spec['checks'] if chk.isChecked()]
                values[cid] = selected
                if 'custom' in selected and spec.get('custom_edit') is not None:
                    values[cid + '_text'] = spec['custom_edit'].text()
        return values

    def _click_action(self, action):
        """按钮点击：收集控件值并入 event，发信号后关闭卡片。"""
        if action.get('action_type') == 'approval' and self._action_pending:
            return
        event = dict(self.event_data)
        values = self._collect_values()
        if values:
            event['values'] = values
        if action.get('action_type') == 'approval':
            self.set_approval_pending(True, '正在提交选择…')
        self.action_clicked.emit(event, action)
        # 授权按钮要等待服务端用同一张卡回写结果；普通按钮仍保持原来的点击即关闭。
        if not action.get('keep_open'):
            self.request_close()

    def set_approval_pending(self, pending, message=None):
        self._action_pending = bool(pending)
        for button in self._action_buttons:
            button.setEnabled(not pending)
        if message is not None:
            self.event_data['progress'] = message
            self._refresh_progress()

    def _on_double_click(self):
        """双击切换引用输入区：已展开则收起，否则展开。"""
        if self._is_local_notice:
            return
        if self._collapsed:
            self._set_collapsed(False)
        elif hasattr(self, '_quote_area') and self._quote_area is not None:
            self._collapse_quote_area()
        else:
            self._expand_quote_area()

    def _quote_image_to_data_url(self, image):
        """附件图片统一压成 JPEG 85 的 data URL，便于直接嵌入 prompt。"""
        data = QByteArray()
        buffer = QBuffer(data)
        buffer.open(QIODevice.WriteOnly)
        image.save(buffer, 'JPEG', 85)
        return 'data:image/jpeg;base64,' + bytes(data.toBase64()).decode('ascii')

    def _quote_add_image(self, image):
        """去重后追加图片附件：入列表、建缩略条、展开附件行。"""
        data_url = self._quote_image_to_data_url(image)
        if data_url in self._quote_image_keys:
            return
        self._quote_image_keys.add(data_url)
        self._quote_images.append(data_url)
        chip = _QuoteImageChip(data_url, image, self._quote_attachment_holder)
        chip.remove_requested.connect(self._quote_remove_image)
        self._quote_image_chips[data_url] = chip
        self._quote_attachment_row.addWidget(chip)
        self._quote_edit.setPlaceholderText('可继续输入，Enter 发送')
        self._quote_attachment_holder.setVisible(True)
        self._schedule_content_resize()

    def _quote_remove_image(self, key):
        """移除指定附件缩略条和数据，全部移完后收起附件行。"""
        chip = self._quote_image_chips.pop(key, None)
        if chip is not None:
            self._quote_attachment_row.removeWidget(chip)
            chip.deleteLater()
        self._quote_image_keys.discard(key)
        self._quote_images = [k for k in self._quote_images if k != key]
        if not self._quote_images:
            self._quote_edit.setPlaceholderText('输入内容，Enter 发送，Shift+Enter 换行')
            self._quote_attachment_holder.setVisible(False)
        self._schedule_content_resize()

    def _expand_quote_area(self):
        """展开引用输入区：分隔线 + 附件行 + 多行输入框 + 取消/发送按钮。"""
        from PySide6.QtWidgets import QPlainTextEdit
        self._quote_images = []
        self._quote_image_keys = set()
        self._quote_image_chips = {}
        card = None
        for child in self.children():
            if hasattr(child, 'objectName') and child.objectName() == 'ReplyCard':
                card = child
                break
        if card is None:
            card = self
        area = QFrame(card)
        area.setObjectName('QuoteInputArea')
        area.setStyleSheet('QFrame#QuoteInputArea { background: transparent; border: none; }')
        area_layout = QVBoxLayout(area)
        area_layout.setContentsMargins(0, 4, 0, 0)
        area_layout.setSpacing(4)
        hr = QFrame(area)
        hr.setObjectName('ReplyCardHr')
        hr.setFixedHeight(1)
        area_layout.addWidget(hr)
        # 图片附件行
        attachment_holder = QWidget(area)
        attachment_holder.setVisible(False)
        attachment_row = QHBoxLayout(attachment_holder)
        attachment_row.setContentsMargins(0, 0, 0, 0)
        attachment_row.setSpacing(4)
        area_layout.addWidget(attachment_holder)
        self._quote_attachment_holder = attachment_holder
        self._quote_attachment_row = attachment_row
        edit = QPlainTextEdit(area)
        edit.setObjectName('QuoteInputEdit')
        edit.setPlaceholderText('输入内容，Enter 发送，Shift+Enter 换行')
        edit.setMaximumHeight(72)
        edit.installEventFilter(self)
        edit.setAcceptDrops(True)
        edit.setStyleSheet(
            'QPlainTextEdit#QuoteInputEdit { border: 1px solid rgba(218,226,238,220); border-radius: 9px;'
            ' background: rgba(255,255,255,210); padding: 6px 8px; font: 13px "Microsoft YaHei UI"; }'
        )
        area_layout.addWidget(edit)
        btn_row = QHBoxLayout()
        btn_row.addStretch(1)
        cancel_btn = QPushButton('取消', area)
        cancel_btn.setObjectName('QuietAction')
        cancel_btn.clicked.connect(self._collapse_quote_area)
        btn_row.addWidget(cancel_btn)
        send_btn = QPushButton('发送', area)
        send_btn.setObjectName('PrimaryAction')
        send_btn.clicked.connect(self._send_quote_reply)
        btn_row.addWidget(send_btn)
        area_layout.addLayout(btn_row)
        self.layout_box.addWidget(area)
        self._quote_area = area
        self._quote_edit = edit
        self._sync_auto_close()
        self._schedule_content_resize()
        edit.setFocus()

    def eventFilter(self, watched, event):
        """输入框事件过滤：右键透传给卡片、Enter 发送、Ctrl+V 粘贴图片、拖放附件。"""
        if watched is getattr(self, '_quote_edit', None):
            if event.type() == QEvent.MouseButtonPress and event.button() == Qt.RightButton:
                ReplyCardWindow.mousePressEvent(self, event)
                return True
            if event.type() == QEvent.KeyPress:
                if event.key() in (Qt.Key_Return, Qt.Key_Enter) and not event.modifiers() & Qt.ShiftModifier:
                    self._send_quote_reply()
                    return True
                if event.key() == Qt.Key_V and event.modifiers() & Qt.ControlModifier:
                    image = QApplication.clipboard().image()
                    if not image.isNull():
                        self._quote_add_image(image)
                        return True
            if event.type() == QEvent.Drop:
                mime = event.mimeData()
                if mime.hasImage():
                    self._quote_add_image(mime.imageData())
                    return True
                if mime.hasUrls():
                    for url in mime.urls():
                        if url.isLocalFile():
                            pixmap = QPixmap(url.toLocalFile())
                            if not pixmap.isNull():
                                self._quote_add_image(pixmap.toImage())
                    return True
            if event.type() == QEvent.DragEnter:
                mime = event.mimeData()
                if mime.hasImage() or mime.hasUrls():
                    event.acceptProposedAction()
                    return True
        return super().eventFilter(watched, event)

    def _collapse_quote_area(self):
        """移除引用输入区并立即恢复卡片布局。"""
        area = self._quote_area
        if area is None:
            return
        edit = self._quote_edit
        if edit is not None:
            edit.removeEventFilter(self)
        self._quote_area = None
        self._quote_edit = None
        self._quote_attachment_holder = None
        self._quote_attachment_row = None
        self._quote_images = []
        self._quote_image_keys = set()
        self._quote_image_chips = {}
        self.layout_box.removeWidget(area)
        area.hide()
        area.setParent(None)
        area.deleteLater()
        self.layout_box.activate()
        self._sync_auto_close()
        self._schedule_content_resize()

    def _send_quote_reply(self):
        """发送继续对话消息：输入内容（可含图片附件）直接作为新消息发出。"""
        if not hasattr(self, '_quote_edit') or self._quote_edit is None:
            return
        user_text = self._quote_edit.toPlainText().strip()
        images = getattr(self, '_quote_images', [])
        if not user_text and not images:
            return
        if images:
            content = []
            if user_text:
                content.append({'type': 'text', 'text': user_text})
            for img in images:
                content.append({'type': 'image', 'src': img, 'alt': '图片'})
            full_message = content
        else:
            full_message = user_text
        quoted = ''
        self._collapse_quote_area()
        self.quote_reply_submitted.emit(self.card_id, full_message, quoted, user_text or '[图片]')

    def _before_close_event(self):
        """窗口关闭前停止全部定时器/动画并释放 Typewriter 文本。"""
        self.closing = True
        self.timer.stop()
        self.countdown_timer.stop()
        if self._resize_anim is not None:
            self._resize_anim.stop()
            self._resize_anim = None
        for tw in self._typewriters:
            tw.set_text('')
