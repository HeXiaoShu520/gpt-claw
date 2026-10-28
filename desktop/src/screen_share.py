# coding:utf-8
"""Explicit, non-persistent screen sharing for the sole gpt-claw session."""

import base64
import ctypes
import os
import sys
import uuid
from ctypes import wintypes

from PySide6.QtCore import QByteArray, QBuffer, QIODevice, QObject, Qt, QTimer
from PySide6.QtGui import QImage
from PySide6.QtWidgets import QApplication

from log_util import get_logger
from input_monitor import InputMonitor
from protocols.protocol_v1 import (
    SCREEN_SHARE_SET, SCREEN_SHARE_STATE, SCREEN_CAPTURE_REQUEST,
    SCREEN_CAPTURE_RESULT, USER_CANCEL, SESSION_READY, PET_GUIDE_REQUEST, PET_GUIDE_RESULT,
)


log = get_logger('screen.share')


def capture_rectangle(bounds):
    """Capture physical desktop pixels on the local UI thread, preserving DPI context."""
    if sys.platform != 'win32':
        raise RuntimeError('共享屏幕目前仅支持 Windows')
    if not isinstance(bounds, dict):
        raise ValueError('截图范围无效')
    values = [bounds.get(key) for key in ('x', 'y', 'width', 'height')]
    if any(type(value) is not int for value in values):
        raise ValueError('截图范围必须为整数')
    x, y, width, height = values
    if width <= 0 or height <= 0 or width * height > 64_000_000:
        raise ValueError('截图范围过大或为空')
    user = ctypes.WinDLL('user32', use_last_error=True)
    gdi = ctypes.WinDLL('gdi32', use_last_error=True)
    user.SetThreadDpiAwarenessContext.argtypes = [ctypes.c_void_p]
    user.SetThreadDpiAwarenessContext.restype = ctypes.c_void_p
    user.GetSystemMetrics.argtypes = [ctypes.c_int]
    user.GetSystemMetrics.restype = ctypes.c_int
    user.GetDC.argtypes = [wintypes.HWND]
    user.GetDC.restype = wintypes.HDC
    user.ReleaseDC.argtypes = [wintypes.HWND, wintypes.HDC]
    user.ReleaseDC.restype = ctypes.c_int
    user.GetWindowDisplayAffinity.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
    user.GetWindowDisplayAffinity.restype = wintypes.BOOL
    user.SetWindowDisplayAffinity.argtypes = [wintypes.HWND, wintypes.DWORD]
    user.SetWindowDisplayAffinity.restype = wintypes.BOOL
    gdi.CreateCompatibleDC.argtypes = [wintypes.HDC]
    gdi.CreateCompatibleDC.restype = wintypes.HDC
    gdi.CreateCompatibleBitmap.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int]
    gdi.CreateCompatibleBitmap.restype = wintypes.HBITMAP
    gdi.SelectObject.argtypes = [wintypes.HDC, wintypes.HGDIOBJ]
    gdi.SelectObject.restype = wintypes.HGDIOBJ
    gdi.BitBlt.argtypes = [wintypes.HDC, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                          wintypes.HDC, ctypes.c_int, ctypes.c_int, wintypes.DWORD]
    gdi.BitBlt.restype = wintypes.BOOL
    gdi.GetDIBits.argtypes = [wintypes.HDC, wintypes.HBITMAP, wintypes.UINT, wintypes.UINT,
                             ctypes.c_void_p, ctypes.c_void_p, wintypes.UINT]
    gdi.GetDIBits.restype = ctypes.c_int
    gdi.DeleteObject.argtypes = [wintypes.HGDIOBJ]
    gdi.DeleteObject.restype = wintypes.BOOL
    gdi.DeleteDC.argtypes = [wintypes.HDC]
    gdi.DeleteDC.restype = wintypes.BOOL

    class BitmapInfoHeader(ctypes.Structure):
        _fields_ = [('size', wintypes.DWORD), ('width', wintypes.LONG), ('height', wintypes.LONG),
                    ('planes', wintypes.WORD), ('bits', wintypes.WORD), ('compression', wintypes.DWORD),
                    ('image_size', wintypes.DWORD), ('x_pels', wintypes.LONG), ('y_pels', wintypes.LONG),
                    ('colors_used', wintypes.DWORD), ('colors_important', wintypes.DWORD)]

    previous = user.SetThreadDpiAwarenessContext(ctypes.c_void_p(-4))
    desktop = memory = bitmap = old_bitmap = None
    excluded = []
    try:
        # Exclude our own visible overlays for this capture, then restore their
        # original affinity even on an encoding/GDI failure. Do not hide windows
        # or pump Qt events here, which could change focus during observation.
        for widget in QApplication.topLevelWidgets():
            if not widget.isVisible():
                continue
            handle = int(widget.winId())
            affinity = wintypes.DWORD()
            if not user.GetWindowDisplayAffinity(handle, ctypes.byref(affinity)):
                continue
            if user.SetWindowDisplayAffinity(handle, 0x11):  # WDA_EXCLUDEFROMCAPTURE
                excluded.append((handle, affinity.value))
        if excluded:
            ctypes.WinDLL('dwmapi').DwmFlush()
        vx, vy, vw, vh = [user.GetSystemMetrics(index) for index in (76, 77, 78, 79)]
        if x < vx or y < vy or x + width > vx + vw or y + height > vy + vh:
            raise ValueError('截图范围不在当前桌面内')
        desktop = user.GetDC(None)
        memory = gdi.CreateCompatibleDC(desktop)
        bitmap = gdi.CreateCompatibleBitmap(desktop, width, height)
        if not desktop or not memory or not bitmap:
            raise RuntimeError('无法创建本机截图资源')
        old_bitmap = gdi.SelectObject(memory, bitmap)
        if not old_bitmap or old_bitmap == ctypes.c_void_p(-1).value:
            old_bitmap = None
            raise RuntimeError('无法选择本机截图资源')
        if not gdi.BitBlt(memory, 0, 0, width, height, desktop, x, y, 0x00CC0020 | 0x40000000):
            raise RuntimeError('无法读取当前桌面画面')
        # GetDIBits requires the bitmap to be deselected from its DC.
        gdi.SelectObject(memory, old_bitmap)
        old_bitmap = None
        pixels = ctypes.create_string_buffer(width * height * 4)
        header = BitmapInfoHeader()
        header.size = ctypes.sizeof(BitmapInfoHeader)
        header.width, header.height, header.planes, header.bits = width, -height, 1, 32
        if gdi.GetDIBits(memory, bitmap, 0, height, pixels, ctypes.byref(header), 0) != height:
            raise RuntimeError('截图像素读取失败')
        image = QImage(pixels.raw, width, height, width * 4, QImage.Format_RGB32).copy()
        image = image.scaled(1600, 900, Qt.KeepAspectRatio, Qt.SmoothTransformation) if width > 1600 or height > 900 else image
        data = QByteArray()
        buffer = QBuffer(data)
        buffer.open(QIODevice.WriteOnly)
        if not image.save(buffer, 'JPEG', 85):
            raise RuntimeError('截图编码失败')
        buffer.close()
        return 'data:image/jpeg;base64,' + base64.b64encode(bytes(data)).decode('ascii')
    finally:
        if old_bitmap and memory:
            gdi.SelectObject(memory, old_bitmap)
        if bitmap:
            gdi.DeleteObject(bitmap)
        if memory:
            gdi.DeleteDC(memory)
        if desktop:
            user.ReleaseDC(None, desktop)
        for handle, affinity in excluded:
            user.SetWindowDisplayAffinity(handle, affinity)
        if previous:
            user.SetThreadDpiAwarenessContext(previous)


class ScreenShareController(QObject):
    def __init__(self, events, pet, notify, parent=None):
        super().__init__(parent)
        self.events, self.pet, self.notify = events, pet, notify
        self.active = False
        self.share_id = ''
        self.supported = False
        self.pending_id = ''
        self.pending_enabled = False
        self.original_tooltip = pet.toolTip()
        self.monitor = InputMonitor(self)
        self.monitor.takeover.connect(self._yield_to_user, Qt.QueuedConnection)
        self.monitor.failed.connect(self._monitor_failed, Qt.QueuedConnection)
        QApplication.instance().aboutToQuit.connect(self.monitor.close)
        self.timeout = QTimer(self)
        self.timeout.setSingleShot(True)
        self.timeout.timeout.connect(self._timeout)
        self.stop_shortcut = QTimer(self)
        self.stop_shortcut.setInterval(100)
        self.stop_shortcut.timeout.connect(self._check_stop_shortcut)

    def _local_state(self, enabled, share_id=''):
        self.active, self.share_id = bool(enabled), share_id if enabled else ''
        self.pet.set_screen_share_active(self.active)
        self.pet.setToolTip('共享屏幕已开启 · Ctrl+Alt+Esc 停止共享' if self.active else self.original_tooltip)
        if self.active:
            self.stop_shortcut.start()
        else:
            self.monitor.set_active(False)
            self.stop_shortcut.stop()
            self.pet.guidance.clear()

    def set_enabled(self, enabled):
        enabled = bool(enabled)
        if not enabled:
            self._local_state(False)
        if enabled and (sys.platform != 'win32' or not self.events or not self.events.ready or not self.supported):
            self._local_state(False)
            log.warning('共享屏幕无法开启：桌面通道未就绪或服务不支持')
            self.notify('共享屏幕未开启', '请先连接支持共享屏幕的 Windows gpt-claw 服务。')
            return
        if not self.events or not self.events.ready:
            self.disconnected()
            return
        self.pending_id = uuid.uuid4().hex
        self.pending_enabled = enabled
        if not self.events.send_event(SCREEN_SHARE_SET, {
                'session_id': self.events.session_id, 'enabled': enabled, 'pid': os.getpid(),
        }, self.pending_id):
            log.warning('共享屏幕状态请求发送失败')
            self.disconnected()
            self.notify('共享屏幕未开启', '桌面通道消息发送失败。')
            return
        log.info('请求%s共享屏幕，等待服务确认', '开启' if enabled else '关闭')
        self.timeout.start(10000)

    def disconnected(self):
        if self.active or self.pending_id:
            log.warning('桌面通道已断开，共享屏幕在本机关闭')
        self.timeout.stop()
        self.pending_id = ''
        self.supported = False
        self._local_state(False)

    def _timeout(self):
        was_enabling = self.pending_enabled
        log.warning('共享屏幕%s请求等待服务确认超时（10 秒）', '开启' if was_enabling else '关闭')
        self.pending_id = ''
        self._local_state(False)
        if was_enabling:
            self.set_enabled(False)
        self.notify('共享屏幕状态未确认', '共享已在本机关闭；请检查 gpt-claw 连接。')

    def _check_stop_shortcut(self):
        if not self.active:
            return
        user = ctypes.WinDLL('user32')
        user.GetAsyncKeyState.argtypes = [ctypes.c_int]
        user.GetAsyncKeyState.restype = ctypes.c_short
        if all(user.GetAsyncKeyState(key) & 0x8000 for key in (0x11, 0x12, 0x1B)):
            self.set_enabled(False)
            if self.events:
                self.events.send_event(USER_CANCEL, {'session_id': self.events.session_id})

    def _yield_to_user(self):
        if not self.active:
            return
        self.set_enabled(False)
        if self.events:
            self.events.send_event(USER_CANCEL, {'session_id': self.events.session_id})
        self.notify('已交还电脑控制权', '已停止共享。需要继续时，请重新开启共享并发送新请求。')

    def _monitor_failed(self):
        if self.active:
            self._yield_to_user()
            log.warning('真实输入监听不可用，共享已停止')

    def handle_event(self, event):
        kind = event.get('type')
        payload = event.get('payload') or {}
        request_id = event.get('request_id') or ''
        if kind == SESSION_READY:
            self.supported = SCREEN_SHARE_SET in (payload.get('capabilities') or [])
            return False
        if kind == SCREEN_SHARE_STATE:
            if not self.events or payload.get('session_id') != self.events.session_id:
                return True
            if request_id and request_id != self.pending_id:
                return True
            self.timeout.stop()
            self.pending_id = ''
            enabled = payload.get('enabled') is True and bool(payload.get('share_id'))
            self._local_state(enabled, str(payload.get('share_id') or ''))
            log.info('服务已确认共享屏幕%s', '开启' if enabled else '关闭')
            self.notify('共享屏幕已开启' if enabled else '共享屏幕已关闭',
                        '可用文字或语音要求查看画面、操作电脑。Ctrl+Alt+Esc 可停止共享。' if enabled else '继续正常对话。')
            return True
        if kind == 'screen.control.state':
            if (self.active and self.events and payload.get('session_id') == self.events.session_id
                    and payload.get('share_id') == self.share_id):
                working = payload.get('active') is True
                self.monitor.set_active(working)
                self.pet.setToolTip('正在查看或操作电脑 · 移动鼠标可接管 · Ctrl+Alt+Esc 停止' if working
                                    else '共享屏幕已开启 · Ctrl+Alt+Esc 停止共享')
            return True
        if kind == 'error' and request_id and request_id == self.pending_id:
            was_enabling = self.pending_enabled
            log.warning('共享屏幕请求失败：%s', payload.get('message') or '服务拒绝了共享请求')
            self.timeout.stop()
            self.pending_id = ''
            self._local_state(False)
            if was_enabling:
                self.set_enabled(False)
            self.notify('共享屏幕失败', str(payload.get('message') or '服务拒绝了共享请求'))
            return True
        if kind == PET_GUIDE_REQUEST:
            response = {'session_id': payload.get('session_id'), 'share_id': payload.get('share_id')}
            def finish(status=None, error=None):
                if not request_id:
                    return
                result = dict(response)
                result['error' if error else 'status'] = error or status
                if self.events:
                    self.events.send_event(PET_GUIDE_RESULT, result, request_id)
            if not self.active or not self.events or payload.get('session_id') != self.events.session_id or payload.get('share_id') != self.share_id:
                finish(error='共享屏幕已关闭')
            elif payload.get('target') is None:
                self.pet.guidance.clear(guidance_id=payload.get('guidance_id'))
                finish('cleared')
            else:
                self.pet.guidance.start(payload['target'], request_id, finish)
            return True
        if kind != SCREEN_CAPTURE_REQUEST:
            return False
        response = {'session_id': payload.get('session_id'), 'share_id': payload.get('share_id')}
        try:
            if not self.active or not self.events or payload.get('session_id') != self.events.session_id or payload.get('share_id') != self.share_id:
                raise RuntimeError('共享屏幕已关闭')
            response['data_url'] = capture_rectangle(payload.get('bounds'))
            bounds = payload['bounds']
            log.info('共享截图成功：%s × %s，已编码为 JPEG', bounds['width'], bounds['height'])
        except Exception as error:
            response['error'] = str(error)
            log.warning('共享截图失败：%s', error)
        if self.events and not self.events.send_event(SCREEN_CAPTURE_RESULT, response, request_id):
            log.warning('共享截图结果发送失败：桌面通道不可用')
        return True
