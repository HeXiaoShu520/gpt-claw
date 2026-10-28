"""User initiated view of the last foreground window.

The timer only remembers a window handle and title. Pixels are captured when the
owner clicks the pet's action, so idle desktop monitoring uses no model tokens.
"""

import base64
import ctypes
import os

from PySide6.QtCore import QByteArray, QBuffer, QIODevice, Qt, QTimer
from PySide6.QtGui import QGuiApplication


class DesktopContext:
    def __init__(self, parent):
        self._user32 = ctypes.windll.user32
        self._user32.GetForegroundWindow.restype = ctypes.c_void_p
        self._user32.GetWindowThreadProcessId.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_ulong)]
        self._user32.GetWindowTextLengthW.argtypes = [ctypes.c_void_p]
        self._user32.GetWindowTextW.argtypes = [ctypes.c_void_p, ctypes.c_wchar_p, ctypes.c_int]
        self._user32.IsWindow.argtypes = [ctypes.c_void_p]
        self._handle = 0
        self._title = ''
        self._timer = QTimer(parent)
        self._timer.timeout.connect(self._remember_foreground)
        self._timer.start(750)

    def _remember_foreground(self):
        handle = self._user32.GetForegroundWindow()
        if not handle:
            return
        pid = ctypes.c_ulong()
        self._user32.GetWindowThreadProcessId(handle, ctypes.byref(pid))
        if pid.value == os.getpid():
            return
        length = self._user32.GetWindowTextLengthW(handle)
        if not length:
            return
        buffer = ctypes.create_unicode_buffer(length + 1)
        self._user32.GetWindowTextW(handle, buffer, len(buffer))
        self._handle, self._title = handle, buffer.value

    def capture(self):
        """Return title and a bounded JPEG data URL for the explicit action."""
        if not self._handle or not self._user32.IsWindow(self._handle):
            raise RuntimeError('还没有发现可查看的工作窗口')
        screen = QGuiApplication.primaryScreen()
        image = screen.grabWindow(self._handle)
        if image.isNull():
            raise RuntimeError('当前窗口无法截图，可能是独占全屏或受保护内容')
        image = image.scaled(1600, 900, Qt.KeepAspectRatio, Qt.SmoothTransformation)
        data = QByteArray()
        buffer = QBuffer(data)
        buffer.open(QIODevice.WriteOnly)
        image.save(buffer, 'JPEG', 82)
        return self._title, 'data:image/jpeg;base64,' + base64.b64encode(bytes(data)).decode('ascii')
