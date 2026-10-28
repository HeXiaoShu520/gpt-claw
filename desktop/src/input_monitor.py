"""Observe physical input during an authorized desktop task; never block input."""
import ctypes
import math
import os
import sys
import threading
import time
from ctypes import wintypes

from PySide6.QtCore import QObject, Signal


class InputMonitor(QObject):
    takeover = Signal()
    failed = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._armed = threading.Event()
        self._thread = None
        self._thread_id = 0
        self._stopping = threading.Event()

    def set_active(self, active):
        if self._stopping.is_set():
            return
        if active:
            self._armed.set()
            if self._thread is None or not self._thread.is_alive():
                self._thread = threading.Thread(target=self._run, name='desktop-input-monitor', daemon=True)
                self._thread.start()
        else:
            self._armed.clear()

    def close(self):
        self._armed.clear()
        self._stopping.set()
        if self._thread_id:
            ctypes.windll.user32.PostThreadMessageW(self._thread_id, 0x0012, 0, 0)
        if self._thread:
            self._thread.join(timeout=1)

    def _run(self):
        try:
            self._listen()
        except Exception:
            self._armed.clear()
            self.failed.emit()

    def _listen(self):
        if sys.platform != 'win32':
            self.failed.emit()
            return
        user = ctypes.WinDLL('user32', use_last_error=True)
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        callback_type = ctypes.WINFUNCTYPE(ctypes.c_ssize_t, ctypes.c_int, wintypes.WPARAM, wintypes.LPARAM)

        class Mouse(ctypes.Structure):
            _fields_ = [('point', wintypes.POINT), ('data', wintypes.DWORD), ('flags', wintypes.DWORD),
                        ('time', wintypes.DWORD), ('extra', ctypes.c_size_t)]

        class Keyboard(ctypes.Structure):
            _fields_ = [('key', wintypes.DWORD), ('scan', wintypes.DWORD), ('flags', wintypes.DWORD),
                        ('time', wintypes.DWORD), ('extra', ctypes.c_size_t)]

        user.SetWindowsHookExW.argtypes = [ctypes.c_int, callback_type, wintypes.HINSTANCE, wintypes.DWORD]
        user.SetWindowsHookExW.restype = wintypes.HHOOK
        user.CallNextHookEx.argtypes = [wintypes.HHOOK, ctypes.c_int, wintypes.WPARAM, wintypes.LPARAM]
        user.CallNextHookEx.restype = ctypes.c_ssize_t
        user.UnhookWindowsHookEx.argtypes = [wintypes.HHOOK]
        user.GetForegroundWindow.restype = wintypes.HWND
        user.GetWindowThreadProcessId.argtypes = [wintypes.HWND, ctypes.POINTER(wintypes.DWORD)]
        user.GetMessageW.argtypes = [ctypes.POINTER(wintypes.MSG), wintypes.HWND, wintypes.UINT, wintypes.UINT]
        user.GetMessageW.restype = ctypes.c_int
        kernel.GetCurrentThreadId.restype = wintypes.DWORD
        last_point, last_time, movement = None, 0, 0

        def yield_control():
            if self._armed.is_set():
                self._armed.clear()
                self.takeover.emit()

        def mouse(code, message, data):
            nonlocal last_point, last_time, movement
            try:
                if code >= 0:
                    info = ctypes.cast(data, ctypes.POINTER(Mouse)).contents
                    if not info.flags & 3:  # LLMHF_INJECTED / LOWER_IL_INJECTED
                        now, point = time.monotonic(), (info.point.x, info.point.y)
                        if not self._armed.is_set() or now - last_time > .5:
                            movement = 0
                        elif last_point and message == 0x0200:
                            movement += math.hypot(point[0] - last_point[0], point[1] - last_point[1])
                        last_point, last_time = point, now
                        if message in (0x0201, 0x0204, 0x0207, 0x020A, 0x020E) or movement >= 24:
                            yield_control()
            except Exception:
                self._armed.clear()
                self.failed.emit()
            return user.CallNextHookEx(None, code, message, data)

        def keyboard(code, message, data):
            try:
                if code >= 0 and self._armed.is_set() and message in (0x0100, 0x0104):
                    info = ctypes.cast(data, ctypes.POINTER(Keyboard)).contents
                    if not info.flags & 0x12:  # LLKHF_INJECTED / LOWER_IL_INJECTED
                        pid = wintypes.DWORD()
                        user.GetWindowThreadProcessId(user.GetForegroundWindow(), ctypes.byref(pid))
                        if pid.value != os.getpid():
                            yield_control()
            except Exception:
                self._armed.clear()
                self.failed.emit()
            return user.CallNextHookEx(None, code, message, data)

        callbacks = [callback_type(mouse), callback_type(keyboard)]
        hooks = []
        try:
            self._thread_id = kernel.GetCurrentThreadId()
            # Create the thread message queue before close() can post WM_QUIT.
            message = wintypes.MSG()
            user.PeekMessageW(ctypes.byref(message), None, 0, 0, 0)
            for kind, callback in zip((14, 13), callbacks):
                hook = user.SetWindowsHookExW(kind, callback, None, 0)
                if not hook:
                    raise OSError('Cannot observe physical input')
                hooks.append(hook)
            while not self._stopping.is_set():
                status = user.GetMessageW(ctypes.byref(message), None, 0, 0)
                if status <= 0:
                    if status < 0:
                        raise OSError('Input monitor message loop failed')
                    break
                user.TranslateMessage(ctypes.byref(message))
                user.DispatchMessageW(ctypes.byref(message))
        except Exception:
            self.failed.emit()
        finally:
            for hook in hooks:
                user.UnhookWindowsHookEx(hook)
            self._thread_id = 0
            self._armed.clear()
