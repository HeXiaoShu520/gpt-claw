"""Capture the production Qt pet and bounded interaction evidence; no service calls."""
import ctypes
from ctypes import wintypes as wt
import json
import math
from pathlib import Path
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'desktop/src'))

from PySide6.QtCore import QPoint, QPointF, QRect, Qt
from PySide6.QtGui import QColor, QFont, QImage, QMouseEvent, QPainter
from PySide6.QtWidgets import QApplication, QWidget
import config

OUT = ROOT / 'artifacts' / 'spirit-only'
OUT.mkdir(parents=True, exist_ok=True)


def wait(seconds):
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        QApplication.processEvents()
        time.sleep(.008)


def save_json(name, value):
    (OUT / name).write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def bounds(image):
    xs, ys = [], []
    for y in range(image.height()):
        for x in range(image.width()):
            if image.pixelColor(x, y).alpha() > 20:
                xs.append(x); ys.append(y)
    if not xs:
        raise RuntimeError('Production render is empty')
    return [min(xs), min(ys), max(xs)-min(xs)+1, max(ys)-min(ys)+1]


def sheet(items, name, columns=4):
    width, height = 340, 350
    image = QImage(columns*width, math.ceil(len(items)/columns)*height, QImage.Format_ARGB32)
    image.fill(QColor('#38343f'))
    painter = QPainter(image)
    painter.setFont(QFont('Microsoft YaHei', 12))
    painter.setPen(QColor('#eee9f5'))
    for i, (label, frame) in enumerate(items):
        x, y = i % columns*width, i//columns*height
        painter.drawText(QRect(x, y+8, width, 32), Qt.AlignCenter, label)
        frame = frame.scaled(280, 290, Qt.KeepAspectRatio, Qt.SmoothTransformation)
        painter.drawImage(x+(width-frame.width())//2, y+48, frame)
    painter.end()
    image.save(str(OUT / name))


def native_data(widget, target):
    """Describe only our preview window in the native physical coordinate space."""
    user = ctypes.WinDLL('user32', use_last_error=True)
    dwm = ctypes.WinDLL('dwmapi')
    user.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
    user.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p
    user.MonitorFromWindow.argtypes = [wt.HWND, wt.DWORD]
    user.MonitorFromWindow.restype = wt.HMONITOR
    user.GetWindowThreadProcessId.argtypes = [wt.HWND, ctypes.POINTER(wt.DWORD)]
    user.GetMonitorInfoW.argtypes = [wt.HMONITOR, ctypes.c_void_p]
    dwm.DwmGetWindowAttribute.argtypes = [wt.HWND, wt.DWORD, ctypes.c_void_p, wt.DWORD]
    class Info(ctypes.Structure):
        _fields_ = [('size', wt.DWORD), ('monitor', wt.RECT), ('work', wt.RECT), ('flags', wt.DWORD)]
    previous = user.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
    try:
        handle = int(widget.winId()); rect = wt.RECT(); pid = wt.DWORD()
        if dwm.DwmGetWindowAttribute(handle, 9, ctypes.byref(rect), ctypes.sizeof(rect)):
            raise RuntimeError('Cannot inspect own preview window')
        user.GetWindowThreadProcessId(handle, ctypes.byref(pid))
        info = Info(); info.size = ctypes.sizeof(info)
        user.GetMonitorInfoW(user.MonitorFromWindow(handle, 2), ctypes.byref(info))
        def value(r):
            return dict(x=r.left, y=r.top, width=r.right-r.left, height=r.bottom-r.top)
        scale = (rect.right-rect.left)/widget.width()
        return dict(windowId=handle, windowPid=pid.value, windowBounds=value(rect),
                    monitor=value(info.monitor), durationMs=5000, label='在这里继续',
                    target=dict(x=round(rect.left+target.x()*scale), y=round(rect.top+target.y()*scale),
                                width=round(target.width()*scale), height=round(target.height()*scale)))
    finally:
        user.SetThreadDpiAwarenessContext(previous)


class Stage(QWidget):
    def __init__(self):
        super().__init__(None, Qt.Tool | Qt.FramelessWindowHint)
        self.resize(1050, 680)
        self.target = QRect(700, 230, 205, 62)
    def paintEvent(self, event):
        painter = QPainter(self)
        painter.fillRect(self.rect(), QColor('#f5f3fa'))
        painter.setPen(QColor('#34303f'))
        painter.setFont(QFont('Microsoft YaHei', 22))
        painter.drawText(55, 80, '浮灵 · 正式桌宠指引')
        painter.setFont(QFont('Microsoft YaHei', 13))
        painter.drawText(55, 125, '察觉 → 靠近 → 抬手 → 收手，目标提示保留')
        painter.fillRect(self.target, QColor('#7554b8'))
        painter.setPen(Qt.white)
        painter.drawText(self.target, Qt.AlignCenter, '继续查看')
        painter.end()


def compose(stage, pet):
    image = stage.grab().toImage()
    painter = QPainter(image)
    # QPainter already uses the image's device pixel ratio for logical positions.
    if pet.isVisible():
        painter.drawImage(QRect(pet.pos()-stage.pos(), pet.size()), pet.character_view.grabFramebuffer())
    overlay = pet.guidance.overlay
    if overlay.isVisible():
        painter.drawPixmap(overlay.pos()-stage.pos(), overlay.grab())
    painter.end()
    return image


def assembly():
    from app import MiniPetApp
    class QuietApp(MiniPetApp):
        def _show_startup_greeting(self):
            self._show_startup_greeting_card()
    with tempfile.TemporaryDirectory(prefix='spirit-assembly-') as folder:
        config.DATA_DIR = Path(folder)
        config.SETTINGS_FILE = Path(folder)/'settings.json'
        app = QuietApp(['spirit-assembly'], start_event_client=False)
        wait(2)
        app.pet.character_view.grabFramebuffer().save(str(OUT/'assembly-pet.png'))
        app.settings.show(); app.settings.switchTo(app.settings.role); wait(.5)
        app.settings.grab().save(str(OUT/'assembly-settings.png'))
        save_json('assembly.json', dict(role=config.current_pet, qml=app.pet.character_view.status().name,
                                       event_client=app.events is not None, settings_visible=app.settings.isVisible()))
        app.settings.hide(); app.shutdown(); app.pet.close(); wait(.2)
        app.quit()


def capture_guidance(pet):
    stage = Stage(); stage.move(pet.current_screen.topLeft()+QPoint(80,90)); stage.show(); stage.raise_(); stage.activateWindow(); wait(.4)
    pet.move(stage.pos()+QPoint(70,330)); home=QPoint(pet.pos())
    ack=[]
    data=native_data(stage, stage.target)
    if '--geometry-only' in sys.argv:
        from pet.guidance import window_geometry_is_current
        pet.guidance.validator = window_geometry_is_current
    result_validation = 'geometry-only' if '--geometry-only' in sys.argv else 'foreground-and-geometry'
    pet.guidance.start(data,'production-preview',lambda status,error:ack.append(dict(status=status,error=error)))
    end=time.monotonic()+4
    while pet.guidance.state != 'holding' and time.monotonic()<end:
        wait(.03)
    wait(.8)
    result = dict(state=pet.guidance.state,ack=ack,pose=pet.companion.pose,
                            hand=pet.character_view.guide_anchor() is not None)
    if pet.guidance.state != 'holding':
        save_json('guidance-error.json', result)
        raise RuntimeError(f'Guidance rejected: {result}')
    mapped = pet.guidance.target.translated(-QPointF(stage.pos()))
    result['target_error'] = max(abs(mapped.x()-stage.target.x()),
                                             abs(mapped.y()-stage.target.y()),
                                             abs(mapped.width()-stage.target.width()),
                                             abs(mapped.height()-stage.target.height()))
    if result['target_error'] > 1:
        raise RuntimeError('Physical-to-Qt target mapping differs from the preview button')
    compose(stage,pet).save(str(OUT/'guidance-point.png'))
    wait(1.6)
    result['settled_pose']=pet.companion.pose
    compose(stage,pet).save(str(OUT/'guidance-settled.png'))
    pet.guidance.clear(True); wait(1.7)
    result['returned']=pet.pos()==home and not pet.guidance.busy
    result['validation'] = result_validation
    result['device_pixel_ratio'] = stage.devicePixelRatioF()
    stage.close()
    if not ack or ack[0]['status'] != 'arrived' or not result['returned']:
        raise RuntimeError('Production native-window guidance did not complete')
    save_json('guidance.json', result)
    return result


def main():
    from pet.desktop_pet import DesktopPet
    from pet.spirit_model import SPIRIT_ACTIONS
    from pet.desktop_interactions import handle_mouse_move, handle_mouse_press, handle_mouse_release
    app = QApplication(['spirit-runtime-capture'])
    app.setQuitOnLastWindowClosed(False)
    temporary = tempfile.TemporaryDirectory(prefix='spirit-preview-')
    config.DATA_DIR = Path(temporary.name)
    config.SETTINGS_FILE = config.DATA_DIR/'settings.json'
    config.load()
    pet = DesktopPet(app.screens())
    pet.companion.set_mode('quiet')
    root = pet.character_view.rootObject()
    report = dict(role=config.current_pet, qml=pet.character_view.status().name, actions={}, priorities=[],
                  source=str(pet.character_view.source().toLocalFile()))
    try:
        wait(1)
        if '--guidance' in sys.argv:
            print(json.dumps(capture_guidance(pet), ensure_ascii=False))
            return
        frames = []
        for name, action in SPIRIT_ACTIONS.items():
            accepted = pet.play_action(name)
            wait(.82 if name != 'fall' else .55)
            frame = pet.character_view.grabFramebuffer()
            frame.save(str(OUT/f'action-{name}.png'))
            active = root.property('activeClipName')
            if not accepted or active != name:
                raise RuntimeError(f'Action mismatch: {name} -> {active}')
            report['actions'][name] = dict(clip=active, bounds=bounds(frame), duration=action.duration)
            frames.append((f'{action.label} · {name}', frame))
        sheet(frames, 'actions.png')
        pet.play_action('wave'); wait(.5)
        pet.play_action('wave'); wait(.06)
        report['repeat_transition'] = root.property('transitionProgress')
        for source, pose in [('work','thinking'), ('voice','listening'), ('voice','speaking'), ('approval','approval')]:
            pet.set_activity(source, pose); wait(.1)
            report['priorities'].append(pet.companion.pose)
        pet.set_activity('approval'); pet.set_activity('voice'); wait(.1)
        report['work_resumed'] = pet.companion.pose
        if report['priorities'] != ['thinking','listening','speaking','approval'] or pet.companion.pose != 'thinking':
            raise RuntimeError('State priority/resume mismatch')
        origin = pet.current_screen.topLeft()+QPoint(320,150)
        pet.move(origin)
        def mouse(kind, point, button, buttons):
            return QMouseEvent(kind, QPointF(120,100), QPointF(point), button, buttons, Qt.NoModifier)
        press = pet.pos()+QPoint(120,100)
        handle_mouse_press(pet, mouse(QMouseEvent.MouseButtonPress, press, Qt.LeftButton, Qt.LeftButton))
        handle_mouse_move(pet, mouse(QMouseEvent.MouseMove, press+QPoint(35,20), Qt.NoButton, Qt.LeftButton))
        report['drag_pose'] = pet.companion.pose
        pet.last_mouse = [press, press]
        handle_mouse_release(pet, mouse(QMouseEvent.MouseButtonRelease, press+QPoint(35,20), Qt.LeftButton, Qt.NoButton))
        report['release_pose'] = pet.companion.pose
        end = time.monotonic()+5
        while pet.fall_timer.isActive() and time.monotonic()<end:
            wait(.03)
        report['landed'] = not pet.fall_timer.isActive() and config.on_floor
        report['landing_pose'] = pet.companion.pose
        if not report['landed'] or (report['drag_pose'], report['release_pose'], report['landing_pose']) != ('drag','fall','thinking'):
            raise RuntimeError('Drag/fall/resume mismatch')
        pet.set_activity('work')
        pet.play_action('idle')
        # QObject lookup also covers the Qt Quick 3D morph target type.
        from PySide6.QtCore import QObject
        blink = root.findChild(QObject, 'DS_Morph_blink_morphtarget')
        weights = []
        end = time.monotonic()+5.5
        while time.monotonic()<end:
            wait(.025)
            if blink is not None:
                weights.append(float(blink.property('weight')))
        report['natural_blink'] = dict(samples=len(weights), minimum=min(weights) if weights else None,
                                      maximum=max(weights) if weights else None)
        pet.companion.set_enabled(False)
        root.setProperty('blinkOverride', 1)
        pet.character_view.pose('idle'); wait(.1)
        angle_frames = []
        for angle in [0,45,90,180]:
            root.setProperty('yaw', angle); wait(.15)
            image = pet.character_view.grabFramebuffer()
            image.save(str(OUT/f'angle-{angle}.png'))
            angle_frames.append((f'{angle}°', image))
        sheet(angle_frames, 'angles.png')
        root.setProperty('yaw',0)
        guide_frames = []
        pet.character_view.pose('guide'); root.setProperty('clock', root.property('clock')+1)
        for label,x,y in [('右',1,0),('右上',.7,.7),('上',0,1),('左上',-.7,.7),('左',-1,0),('左下',-.7,-.7),('下',0,-1),('右下',.7,-.7)]:
            pet.character_view.guide_direction(x,y); pet.character_view.guide_cue(1); wait(.12)
            anchor = pet.character_view.guide_anchor()
            if anchor is None:
                raise RuntimeError('Missing projected guide hand')
            guide_frames.append((label,pet.character_view.grabFramebuffer()))
        sheet(guide_frames,'directions.png')
        report['scales'] = {}
        for scale in [.5,1,2]:
            config.app_config['scale'] = scale; pet._reset_size(); wait(.12)
            image = pet.character_view.grabFramebuffer()
            report['scales'][str(scale)] = dict(size=[image.width(),image.height()],bounds=bounds(image))
        config.app_config['scale']=1; pet._reset_size()
        root.setProperty('blinkOverride',-1); pet.companion.set_enabled(True)
        report['guidance'] = capture_guidance(pet)
        save_json('runtime.json',report)
        print(json.dumps(dict(actions=len(report['actions']),qml=report['qml'],landed=report['landed'],guidance=report['guidance']),ensure_ascii=False))
    finally:
        pet.stop()
        if pet.tray: pet.tray.hide()
        pet.close(); wait(.1)
        app.quit()
        temporary.cleanup()


if __name__=='__main__':
    assembly() if '--assembly' in sys.argv else main()
