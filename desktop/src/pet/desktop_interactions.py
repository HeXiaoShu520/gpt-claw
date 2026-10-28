# coding:utf-8
"""
桌宠拖拽、掉落和鼠标交互逻辑。

把鼠标事件处理从 DesktopPet 窗口类中分离出来，让窗口类只负责 Qt 事件转发，
交互细节在此集中维护，便于单独测试和复用。
"""
from pathlib import Path
from time import monotonic

from PySide6.QtCore import QBuffer, QByteArray, QIODevice, QPoint, QPointF, Qt
from PySide6.QtWidgets import QApplication

import config
from pet.desktop_hover import arm_hover_menu_from_cursor, disarm_hover_menu

GRAVITY = 2200  # 像素/秒²；不随定时器帧率变化。


def _image_to_data_url(image):
    """把 QImage 编码成 base64 PNG data URL，供弹窗预览拖入图片。"""
    data = QByteArray()
    buffer = QBuffer(data)
    buffer.open(QIODevice.WriteOnly)
    image.save(buffer, 'PNG')
    return 'data:image/png;base64,' + bytes(data.toBase64()).decode('ascii')


def drop_payload_from_mime(owner, mime):
    # 按 URL > 图片 > 纯文本的优先级解析拖入内容，
    # 因为拖文件时 mime 同时包含 URL 和文本，必须先判断 URL 避免误识别为纯文本。
    if mime is None:
        return None
    if mime.hasUrls():
        items = []
        has_file = False
        for url in mime.urls():
            item = drop_item_from_url(url)
            if item:
                has_file = has_file or item.get('kind') == 'file'
                items.append(item)
        if items:
            kind = 'file' if has_file else 'url'
            return {'kind': kind, 'items': items, 'preview': drop_preview(items)}
    if mime.hasImage():
        image = mime.imageData()
        return {
            'kind': 'image',
            'items': [{'kind': 'image', 'name': '拖入的图片', 'data_url': _image_to_data_url(image)}],
            'preview': '一张图片，可以识别文字、总结或发到飞书。',
        }
    if mime.hasText():
        text = (mime.text() or '').strip()
        if text:
            kind = 'url' if looks_like_url(text) else 'text'
            return {'kind': kind, 'items': [{'kind': kind, 'text': text}], 'preview': text}
    return None


def drop_item_from_url(url):
    """把单个 QUrl 转成拖放条目：本地文件标记为 file，否则标记为 url。"""
    if url.isLocalFile():
        path = url.toLocalFile()
        name = Path(path).name or path
        return {'kind': 'file', 'path': path, 'name': name}
    text = url.toString()
    if text:
        return {'kind': 'url', 'url': text, 'name': text}
    return None


def looks_like_url(text):
    """粗略判断一段文本是否是 URL。"""
    lower = text.lower()
    return lower.startswith(('http://', 'https://', 'file://')) or '://' in lower


def drop_preview(items):
    """生成拖放内容的预览文本，最多列 3 项名称，多余用“等 N 项”表示。"""
    names = [item.get('name') or item.get('url') or item.get('text') or item.get('kind') for item in items[:3]]
    text = '、'.join(names)
    if len(items) > 3:
        text += ' 等 %d 项' % len(items)
    return text


def handle_mouse_press(owner, event):
    """处理鼠标按下：左键记录拖拽起点，返回 True 表示事件已消费。"""
    if event.button() == Qt.LeftButton:
        owner.guidance.clear(False)
        if owner.quick_menu is not None:
            owner.quick_menu.close()
        owner.touch.press(event.globalPos())
        disarm_hover_menu(owner)
        owner.left_pressed = True
        owner.was_dragging = False
        owner.mouse_drag_pos = event.globalPos() - owner.pos()
        owner.press_global_pos = event.globalPos()
        owner.last_mouse = [(monotonic(), event.globalPos())]
        config.drag_speed_x = 0
        config.drag_speed_y = 0
        event.accept()
        return True
    return False


def handle_mouse_move(owner, event):
    """处理鼠标移动：超过拖拽阈值进入拖拽，拖拽中实时移动窗口并记录鼠标轨迹。"""
    # 拖拽判定用 manhattanLength >= 6 而非立即触发，避免普通点击抖动误触发拖拽动画。
    if not owner.left_pressed:
        owner.touch.move(event.globalPos())
        if owner.quick_menu is None:
            arm_hover_menu_from_cursor(owner)
        return True
    if not owner.is_dragging and (event.globalPos() - owner.press_global_pos).manhattanLength() >= 6:
        owner.touch.cancel()
        owner.is_dragging = True
        owner.was_dragging = True
        disarm_hover_menu(owner)
        close_interaction_popups(owner)
        owner.fall_timer.stop()
        owner.set_activity('interaction', 'drag')
    if owner.is_dragging:
        owner.move(event.globalPos() - owner.mouse_drag_pos)
        owner._sync_voice_popup_position()
        record_drag_sample(owner, event.globalPos())
        event.accept()
    return True


def handle_mouse_release(owner, event):
    """处理鼠标释放：右键打开功能菜单，左键拖拽结束时按配置掉落或原地落位。"""
    if event.button() == Qt.RightButton:
        owner.show_context_menu(event.globalPosition().toPoint())
        event.accept()
        return True
    if event.button() != Qt.LeftButton:
        return False
    owner.left_pressed = False
    if not owner.was_dragging:
        owner.touch.release(event.globalPos())
        event.accept()
        return True
    owner.is_dragging = False
    record_drag_sample(owner, event.globalPos())
    update_drag_speed(owner)
    owner._set_current_screen_from_point(owner._pet_reference_point())
    if config.app_config.get('allow_drop', False):
        config.on_floor = False
        owner._fall_position = QPointF(owner.pos())
        owner._fall_tick = monotonic()
        owner.set_activity('interaction', 'fall')
        owner.fall_timer.start(16)
    else:
        owner.set_activity('interaction')
        owner.move(limit_position(owner, owner.x(), owner.y()))
        owner.companion.reset_home()
    event.accept()
    return True


def close_interaction_popups(owner):
    """拖拽开始时关闭快捷菜单和输入框。"""
    if owner.quick_menu is not None:
        owner.quick_menu.close()
    if owner.input_popup is not None:
        owner.input_popup.close()


def record_drag_sample(owner, point):
    now = monotonic()
    owner.last_mouse = [(stamp, pos) for stamp, pos in owner.last_mouse if now - stamp < .12]
    owner.last_mouse.append((now, point))


def update_drag_speed(owner):
    """用最近 120ms 的位移估算松手速度，停住再松手不会沿用旧惯性。"""
    if len(owner.last_mouse) < 2:
        config.drag_speed_x = 0
        config.drag_speed_y = 0
        return
    t0, p0 = owner.last_mouse[0]
    t1, p1 = owner.last_mouse[-1]
    dt = max(.001, t1 - t0)
    config.drag_speed_x = max(-1600, min(1600, (p1.x() - p0.x()) / dt))
    config.drag_speed_y = max(-1600, min(1600, (p1.y() - p0.y()) / dt))


def limit_position(owner, x, y):
    """把窗口坐标限制在当前屏幕范围内（底部为地面），返回修正后的 QPoint。"""
    left = owner.current_screen.left() - owner.width() // 2
    right = owner.current_screen.right() - owner.width() // 2
    top = owner.current_screen.top() - owner.height() // 2
    bottom = owner.floor_y
    return QPoint(max(left, min(int(x), right)), max(top, min(int(y), bottom)))


def fall_step(owner):
    """掉落定时器的单帧步进：积分重力、跨屏检测、侧边反弹与落地收尾。"""
    now = monotonic()
    dt = min(.05, now - owner._fall_tick)
    owner._fall_tick = now
    config.drag_speed_y += GRAVITY * dt
    nx = owner._fall_position.x() + config.drag_speed_x * dt
    ny = owner._fall_position.y() + config.drag_speed_y * dt
    screen = QApplication.screenAt(owner._pet_reference_point(nx, ny))
    if screen is not None and screen.availableGeometry() != owner.current_screen:
        owner._set_current_screen_from_point(owner._pet_reference_point(nx, ny))
    limited = limit_position(owner, nx, ny)
    hit_side = limited.x() != int(nx)
    hit_floor = limited.y() >= owner.floor_y
    if hit_side:
        config.drag_speed_x *= -.35
    if ny < limited.y():
        config.drag_speed_y = max(0, config.drag_speed_y)
    owner._fall_position = QPointF(limited.x() if hit_side else nx,
                                   limited.y() if ny < limited.y() or hit_floor else ny)
    owner.move(limited)
    owner._sync_voice_popup_position()
    if hit_floor:
        impact = config.drag_speed_y
        owner.fall_timer.stop()
        owner.set_activity('interaction')
        config.on_floor = True
        config.drag_speed_x = 0
        config.drag_speed_y = 0
        owner.companion.landed(impact)
