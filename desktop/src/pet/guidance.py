"""Local, click-through guidance. Coordinates from the service are physical pixels."""
import ctypes
import math
import os
import sys
import time
from ctypes import wintypes

from PySide6.QtCore import QObject, QPoint, QPointF, QRect, QRectF, Qt, QTimer
from PySide6.QtGui import QColor, QFont, QPainter, QPainterPath, QPen, QPolygonF
from PySide6.QtWidgets import QApplication, QWidget


def logical_target(data):
    """Match a Windows monitor, then map physical pixels to Qt coordinates."""
    monitor = data['monitor']
    values = [monitor.get(k) for k in ('x', 'y', 'width', 'height')]
    if any(type(v) is not int for v in values) or min(values[2:]) <= 0:
        raise ValueError('目标显示器范围无效')
    device = ''
    if sys.platform == 'win32':
        user = ctypes.WinDLL('user32')
        class MonitorInfo(ctypes.Structure):
            _fields_ = [('size', wintypes.DWORD), ('monitor', wintypes.RECT),
                        ('work', wintypes.RECT), ('flags', wintypes.DWORD),
                        ('device', wintypes.WCHAR * 32)]
        user.GetMonitorInfoW.argtypes = [wintypes.HMONITOR, ctypes.POINTER(MonitorInfo)]
        callback_type = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HMONITOR,
                                          wintypes.HDC, ctypes.POINTER(wintypes.RECT), wintypes.LPARAM)
        user.EnumDisplayMonitors.argtypes = [wintypes.HDC, ctypes.c_void_p, callback_type, wintypes.LPARAM]
        user.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
        user.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p
        def visit(handle, _dc, _rect, _param):
            nonlocal device
            info = MonitorInfo(); info.size = ctypes.sizeof(info)
            if user.GetMonitorInfoW(handle, ctypes.byref(info)):
                r = info.monitor
                if [r.left, r.top, r.right-r.left, r.bottom-r.top] == values:
                    device = info.device
            return True
        previous = user.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
        try:
            user.EnumDisplayMonitors(None, None, callback_type(visit), 0)
        finally:
            if previous:
                user.SetThreadDpiAwarenessContext(previous)
    screen = next((s for s in QApplication.screens() if s.name() == device), None)
    if screen is None and device and sys.platform == 'win32':
        # Qt 6 may expose a friendly monitor name instead of \\.\DISPLAYn.
        # On Windows Qt retains the native screen origin while scaling its size.
        matches = []
        for candidate in QApplication.screens():
            g = candidate.geometry(); ratio = candidate.devicePixelRatio()
            physical = [g.x(), g.y(), round(g.width()*ratio), round(g.height()*ratio)]
            if all(abs(a-b) <= 1 for a, b in zip(physical, values)):
                matches.append(candidate)
        if len(matches) == 1:
            screen = matches[0]
    if screen is None:
        # Non-Windows preview: accept only an exact match, never guess a DPI ratio.
        screen = next((s for s in QApplication.screens() if
                       [s.geometry().x(), s.geometry().y(), s.geometry().width(), s.geometry().height()] == values), None)
    if screen is None:
        raise ValueError('目标显示器已变化，请重新查看屏幕')
    raw = data['target']
    vals = [raw.get(k) for k in ('x', 'y', 'width', 'height')]
    if any(type(v) is not int for v in vals) or min(vals[2:]) <= 0:
        raise ValueError('指示区域无效')
    x, y, width, height = vals
    if x < values[0] or y < values[1] or x+width > values[0]+values[2] or y+height > values[1]+values[3]:
        raise ValueError('指示区域超出目标显示器')
    g = screen.geometry(); sx = g.width()/values[2]; sy = g.height()/values[3]
    logical_width, logical_height = width*sx, height*sy
    shown_width, shown_height = min(g.width(), max(12, logical_width)), min(g.height(), max(12, logical_height))
    left = g.x()+(x-values[0])*sx-(shown_width-logical_width)/2
    top = g.y()+(y-values[1])*sy-(shown_height-logical_height)/2
    rect = QRectF(max(g.left(), min(g.x()+g.width()-shown_width, left)),
                  max(g.top(), min(g.y()+g.height()-shown_height, top)),
                  shown_width, shown_height)
    return screen, rect


def window_geometry_is_current(data):
    """Validate the HWND, process and physical frame independently of focus."""
    if sys.platform != 'win32':
        return False
    user = ctypes.WinDLL('user32'); dwm = ctypes.WinDLL('dwmapi')
    user.IsWindow.argtypes = [wintypes.HWND]; user.IsWindow.restype = wintypes.BOOL
    user.IsIconic.argtypes = [wintypes.HWND]; user.IsIconic.restype = wintypes.BOOL
    user.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
    dwm.DwmGetWindowAttribute.argtypes = [wintypes.HWND, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD]
    user.GetWindowRect.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.RECT)]
    handle = data['windowId']; pid = wintypes.DWORD()
    if not user.IsWindow(handle) or user.IsIconic(handle):
        return False
    user.GetWindowThreadProcessId(handle, ctypes.byref(pid))
    if pid.value != data['windowPid']:
        return False
    rect = wintypes.RECT()
    previous = None
    user.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
    user.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p
    previous = user.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
    try:
        if dwm.DwmGetWindowAttribute(handle, 9, ctypes.byref(rect), ctypes.sizeof(rect)) != 0:
            if not user.GetWindowRect(handle, ctypes.byref(rect)):
                return False
    finally:
        if previous:
            user.SetThreadDpiAwarenessContext(previous)
    expected = data['windowBounds']
    if [rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top] != [expected[k] for k in ('x', 'y', 'width', 'height')]:
        return False
    return True


def window_is_current(data):
    """Invalidate a stale target on move, close, PID reuse or focus change."""
    if not window_geometry_is_current(data):
        return False
    user = ctypes.WinDLL('user32')
    user.GetForegroundWindow.restype = wintypes.HWND
    user.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
    front = user.GetForegroundWindow()
    pid = wintypes.DWORD()
    user.GetWindowThreadProcessId(front, ctypes.byref(pid))
    return front in [data['windowId'], *data.get('transientWindowIds', [])] or pid.value == os.getpid()


def beside_target(target, size, available, home):
    """Keep a nearby safe perch; otherwise choose a clear on-screen perch."""
    width, height = size.width(), size.height()
    if width > available.width() or height > available.height():
        return None
    current = QRectF(home.x(), home.y(), width, height)
    dx = max(target.left()-current.right(), current.left()-target.right(), 0)
    dy = max(target.top()-current.bottom(), current.top()-target.bottom(), 0)
    if (QRectF(available).contains(current)
            and not current.intersects(target.adjusted(-18, -18, 18, 18))
            and math.hypot(dx, dy) <= 160):
        return QPoint(home)
    gap = 32
    candidates = [(target.left()-width-gap, target.center().y()-height*.42),
                  (target.right()+gap, target.center().y()-height*.42),
                  (target.center().x()-width*.5, target.bottom()+gap),
                  (target.center().x()-width*.5, target.top()-height-gap)]
    safe = []
    for x, y in candidates:
        x = round(max(available.left(), min(available.right()-width+1, x)))
        y = round(max(available.top(), min(available.bottom()-height+1, y)))
        rect = QRectF(x, y, width, height)
        if not rect.intersects(target.adjusted(-18, -18, 18, 18)):
            safe.append(QPoint(x, y))
    return min(safe, key=lambda p: (p-home).manhattanLength()) if safe else None


class GuidanceOverlay(QWidget):
    def __init__(self):
        super().__init__(None, Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint |
                         Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus)
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setAttribute(Qt.WA_ShowWithoutActivating)
        self.setAttribute(Qt.WA_TransparentForMouseEvents)
        self.target = QRectF(); self.pet_rect = QRectF(); self.label = ''; self.phase = 0
        self.hand_anchor = None; self.line_opacity = 0

    def paintEvent(self, event):
        painter = QPainter(self); painter.setRenderHint(QPainter.Antialiasing)
        offset = QPointF(self.x(), self.y())
        target = self.target.translated(-offset)
        halo = target.adjusted(-7, -7, 7, 7)
        pulse = .5+.5*math.sin(self.phase*3)
        painter.setPen(QPen(QColor(128, 104, 255, round(28+16*pulse)), 9+2*pulse))
        painter.setBrush(Qt.NoBrush); painter.drawRoundedRect(halo, 12, 12)
        painter.setPen(QPen(QColor('#ad96ff'), 2.5)); painter.drawRoundedRect(halo, 12, 12)
        # Only a view with a real projected hand can supply a leader line.
        if self.hand_anchor is not None and self.line_opacity > 0:
            start = self.hand_anchor-offset
            end = QPointF(max(halo.left(), min(halo.right(), start.x())),
                          max(halo.top(), min(halo.bottom(), start.y())))
            dx, dy = end.x()-start.x(), end.y()-start.y()
            length = math.hypot(dx, dy)
        else:
            length = 0
        if length > 22:
            painter.save(); painter.setOpacity(self.line_opacity)
            path = QPainterPath(start)
            bend = min(18, length*.1)
            control = (start+end)*.5+QPointF(-dy/length*bend, dx/length*bend)
            path.quadTo(control, end)
            painter.setPen(QPen(QColor('#d6caff'), 1.8, Qt.SolidLine, Qt.RoundCap))
            painter.drawPath(path)
            tangent_x, tangent_y = end.x()-control.x(), end.y()-control.y()
            tangent_length = math.hypot(tangent_x, tangent_y)
            ux, uy = tangent_x/tangent_length, tangent_y/tangent_length
            painter.setPen(Qt.NoPen); painter.setBrush(QColor('#d6caff'))
            painter.drawPolygon(QPolygonF([end, end-QPointF(ux*7-uy*3.5, uy*7+ux*3.5),
                                                   end-QPointF(ux*7+uy*3.5, uy*7-ux*3.5)]))
            painter.restore()
        if self.label:
            font = QFont('Microsoft YaHei', 10); painter.setFont(font)
            text = painter.fontMetrics().elidedText(self.label, Qt.ElideRight, max(30, min(300, self.width()-32)))
            width = painter.fontMetrics().horizontalAdvance(text)+24
            x = max(12, min(self.width()-width-12, halo.center().x()-width/2))
            y = halo.top()-40 if halo.top() >= 52 else halo.bottom()+12
            y = max(8, min(self.height()-36, y))
            box = QRectF(x, y, width, 30)
            painter.setPen(Qt.NoPen); painter.setBrush(QColor('#423951')); painter.drawRoundedRect(box, 9, 9)
            painter.setPen(QColor('#ffffff')); painter.drawText(box, Qt.AlignCenter, text)


class DesktopGuidance(QObject):
    def __init__(self, owner, mapper=logical_target, validator=window_is_current):
        super().__init__(owner)
        self.owner = owner; self.mapper = mapper; self.validator = validator
        self.overlay = GuidanceOverlay()
        self.state = 'idle'; self.data = None; self.guidance_id = ''; self.home = None
        self.pending = None; self.destination = None; self.last_validation = 0
        self.hidden_for_space = False
        self.activity_pose = None
        self.timer = QTimer(self); self.timer.setInterval(16); self.timer.timeout.connect(self._tick)

    @property
    def busy(self):
        return self.state != 'idle'

    def _activity(self, enabled, pointing=False):
        self.owner.companion.set_guide_target(self.target.center().toPoint() if enabled else None)
        pose = ('guide' if pointing else 'idle') if enabled else None
        if pose != self.activity_pose:
            self.owner.set_activity('guidance', pose)
            self.activity_pose = pose

    def _cue(self, strength):
        view = getattr(self.owner, 'character_view', None)
        if view and hasattr(view, 'guide_cue'):
            view.guide_cue(strength)

    def _ack(self, status=None, error=None):
        callback, self.pending = self.pending, None
        if callback:
            callback(status, error)

    def start(self, data, guidance_id, callback):
        accepted = False
        try:
            if self.owner.is_dragging or self.owner.left_pressed:
                raise ValueError('正在拖动宠物，请松开后再引导')
            screen, target = self.mapper(data)
            if not self.validator(data):
                raise ValueError('目标窗口已变化，请重新查看屏幕')
            duration = data.get('durationMs', 12000)
            if type(duration) is not int or not 3000 <= duration <= 30000:
                raise ValueError('指示时长应为 3 至 30 秒')
            self._ack(error='引导已被新目标替换')
            self._restore_pet()
            if self.home is None:
                self.home = QPoint(self.owner.pos())
            self.data = data; self.target = target; self.guidance_id = guidance_id
            self.pending = callback; self.duration = duration/1000
            accepted = True
            self.owner.fall_timer.stop()
            self.overlay.setGeometry(screen.geometry())
            self.overlay.target = target; self.overlay.label = str(data.get('label', '看这里'))[:80]
            self.overlay.line_opacity = 0; self.overlay.hand_anchor = None
            self.overlay.show()
            position = beside_target(target, self.owner.size(), screen.availableGeometry(), self.owner.pos())
            self.indicator_only = position is None
            if position is None and QRectF(self.owner.geometry()).intersects(target):
                self.hidden_for_space = self.owner.isVisible()
                if self.hidden_for_space:
                    self.owner.hide()
            self.destination = QPoint(position if position is not None else self.owner.pos())
            self.movement_bounds = screen.availableGeometry()
            self.state = 'noticing'; self.noticed_at = time.monotonic()
            self.last_validation = 0
            self._cue(0)
            self._activity(True)
            self._direction()
            self.timer.start(); self._tick()
        except Exception as error:
            if accepted:
                self._ack(error=str(error))
                self.clear(False)
            else:
                callback(None, str(error))

    def _restore_pet(self):
        if self.hidden_for_space:
            self.hidden_for_space = False
            self.owner.show()

    def _begin_move(self, destination, state):
        self.origin = QPoint(self.owner.pos()); self.destination = QPoint(destination)
        distance = math.hypot(self.destination.x()-self.origin.x(), self.destination.y()-self.origin.y())
        self.started = time.monotonic(); self.travel = min(1.4, max(.55, distance/650))
        self.lift = min(24, distance*.06)
        self.state = state

    def _direction(self):
        center = self.owner.geometry().center()
        dx = self.target.center().x()-center.x()
        dy = self.owner.y()+self.owner.height()*.42-self.target.center().y()
        length = max(1, math.hypot(dx, dy))
        view = getattr(self.owner, 'character_view', None)
        if view and hasattr(view, 'guide_direction'):
            view.guide_direction(dx/length, dy/length)

    def clear(self, return_home=True, guidance_id=None):
        if guidance_id and guidance_id != self.guidance_id:
            return
        self.overlay.hide(); self._ack(error='引导已取消')
        self.overlay.line_opacity = 0; self.overlay.hand_anchor = None
        self._restore_pet()
        self._cue(0)
        self.data = None; self.guidance_id = ''
        if return_home and self.home is not None and self.owner.pos() != self.home:
            self._activity(True)
            self.owner.companion.set_guide_target(None)
            # A removed display must not pull the pet out of reach.
            screen = QApplication.screenAt(self.home) or self.owner.screen()
            rect = screen.availableGeometry()
            self.movement_bounds = rect
            destination = QPoint(max(rect.left(), min(rect.right()-self.owner.width()+1, self.home.x())),
                                 max(rect.top(), min(rect.bottom()-self.owner.height()+1, self.home.y())))
            self._begin_move(destination, 'returning'); self.timer.start()
        else:
            self._activity(False)
            self.timer.stop(); self.state = 'idle'; self.home = None

    def _tick(self):
        now = time.monotonic()
        if self.data and now-self.last_validation > .2:
            self.last_validation = now
            try:
                valid = self.validator(self.data)
                screen, current = self.mapper(self.data)
                valid = valid and current == self.target and screen.geometry() == self.overlay.geometry()
            except Exception:
                valid = False
            if not valid:
                self.clear(); return
        if self.state == 'noticing' and now-self.noticed_at >= .32:
            if (self.destination-self.owner.pos()).manhattanLength() > 4:
                self._begin_move(self.destination, 'moving')
            else:
                self.state = 'settling'; self.settled_at = now
        if self.state in ('moving', 'returning'):
            progress = min(1, (now-self.started)/self.travel)
            ease = progress*progress*(3-2*progress)
            x = self.origin.x()+(self.destination.x()-self.origin.x())*ease
            y = self.origin.y()+(self.destination.y()-self.origin.y())*ease-self.lift*math.sin(math.pi*progress)**2
            bounds = self.movement_bounds
            self.owner.move(round(max(bounds.left(), min(bounds.right()-self.owner.width()+1, x))),
                            round(max(bounds.top(), min(bounds.bottom()-self.owner.height()+1, y))))
            self.owner._set_current_screen_from_point(self.owner.geometry().center())
            self.owner._sync_voice_popup_position()
            if progress >= 1:
                if self.state == 'returning':
                    self.clear(False); return
                self.state = 'settling'; self.settled_at = now
        if self.state == 'settling' and now-self.settled_at >= .26:
            self.state = 'holding'; self.cued_at = now; self.expires = now+self.duration
            self._ack('indicator_only' if self.indicator_only else 'arrived')
        elif self.state == 'holding' and now >= self.expires:
            self.clear()
        if self.data:
            self._direction()
            elapsed = now-self.cued_at if self.state == 'holding' else -1
            def smooth(value):
                value = max(0, min(1, value))
                return value*value*(3-2*value)
            pointing = elapsed >= 0 and not self.indicator_only
            strength = smooth(elapsed/.42)*(1-smooth((elapsed-1.25)/.85)) if pointing else 0
            self._cue(strength)
            self._activity(True, 0 <= elapsed < 2.2 and not self.indicator_only)
            self.overlay.line_opacity = (smooth((elapsed-.32)/.25)*(1-smooth((elapsed-1.15)/.45))
                                         if pointing else 0)
            self.overlay.hand_anchor = None
            view = getattr(self.owner, 'character_view', None)
            if pointing and not self.hidden_for_space and view and hasattr(view, 'guide_anchor'):
                self.overlay.hand_anchor = view.guide_anchor()
            self.overlay.pet_rect = QRectF() if self.hidden_for_space else QRectF(self.owner.geometry())
            self.overlay.phase = now; self.overlay.update()

    def stop(self):
        self.clear(False); self.overlay.close()
