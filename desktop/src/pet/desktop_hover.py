"""事件驱动的悬停入口；停留才展开，经过时不打扰。"""
import time

from PySide6.QtCore import QPoint, QTimer
from PySide6.QtGui import QCursor
from PySide6.QtWidgets import QApplication


def start_hover_tracking(owner):
    owner.hover_menu_armed = False
    owner.hover_timer = QTimer(owner)
    owner.hover_timer.setSingleShot(True)
    owner.hover_timer.timeout.connect(lambda: show_quick_menu_from_hover(owner))


def _inside_pet(owner):
    bounds = owner._current_visible_bounds()
    origin = owner.character_view.mapToGlobal(QPoint(0, 0))
    return bounds.translated(origin).contains(QCursor.pos())


def _can_open(owner):
    return (owner.isVisible() and not owner.is_dragging
            and not owner.companion_interaction_active()
            and time.monotonic() >= owner.block_quick_menu_until
            and _inside_pet(owner))


def arm_hover_menu_from_cursor(owner):
    if not _can_open(owner):
        disarm_hover_menu(owner)
    elif not owner.hover_timer.isActive():
        owner.hover_menu_armed = True
        owner.hover_timer.start(max(550, QApplication.doubleClickInterval() + 80))


def disarm_hover_menu(owner):
    owner.hover_menu_armed = False
    owner.hover_timer.stop()


def show_quick_menu_from_hover(owner):
    armed = owner.hover_menu_armed
    owner.hover_menu_armed = False
    if armed and _can_open(owner):
        owner.show_quick_menu()


def close_quick_menu_if_mouse_away(owner):
    menu = owner.quick_menu
    if menu is not None and not _inside_pet(owner) and not menu.geometry().contains(QCursor.pos()):
        menu.close()
