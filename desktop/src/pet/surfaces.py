"""Taskbar contact uses screen bounds and the character's projected hand plane."""
from PySide6.QtCore import QPoint
from PySide6.QtGui import QRegion
from PySide6.QtWidgets import QApplication


class TaskbarPerch:
    def __init__(self, owner):
        self.owner = owner
        self.screen = None

    def available(self, nearby=False):
        screen = self.owner.screen()
        area, full = screen.availableGeometry(), screen.geometry()
        supported = (full.bottom() - area.bottom() >= 16
                     and area.width() >= self.owner.width() + 24
                     and area.height() >= self.owner.height() + 24)
        return supported and (not nearby or abs(self.owner.y() - self._approach_y(area)) < 240)

    def _approach_y(self, area):
        return area.bottom() + 1 - self.owner.height() - 12

    def begin(self):
        anchor = self.owner.character_view.support_anchor()
        if not self.available() or anchor is None:
            return False
        self.screen = self.owner.screen()
        self.area = self.screen.availableGeometry()
        self.full = self.screen.geometry()
        self.size = self.owner.size()
        x = max(self.area.left() + 12,
                min(self.owner.x(), self.area.right() - self.owner.width() - 11))
        self.home = self.owner.pos()
        self.approach = QPoint(x, self._approach_y(self.area))
        left, right = self.area.left() + 12, self.area.right() - self.owner.width() - 11
        stroll_x = max(left, min(right, x + (120 if right - x >= x - left else -120)))
        self.stroll = QPoint(stroll_x, self.approach.y())
        self.contact = QPoint(stroll_x, self.area.bottom() + 1 - round(anchor.y()))
        return True

    def target(self, travel):
        return {'edge_approach': self.approach, 'edge_stroll': self.stroll,
                'edge_contact': self.contact, 'edge_leave': self.stroll,
                'edge_home': self.home}[travel]

    def valid(self):
        return (self.screen in QApplication.screens()
                and self.screen.availableGeometry() == self.area
                and self.screen.geometry() == self.full
                and self.owner.size() == self.size)

    def update_mask(self):
        # Clip rendering and input together, so the real taskbar remains clickable.
        height = self.area.bottom() + 1 - self.owner.y()
        if height >= self.owner.height():
            self.owner.clearMask()
        else:
            self.owner.setMask(QRegion(0, 0, self.owner.width(), max(1, height)))

    def clear(self):
        if self.screen is None:
            return
        self.screen = None
        self.owner.clearMask()
        # An interrupted contact must not leave the normal pose below the taskbar.
        approach_y = self._approach_y(self.owner.screen().availableGeometry())
        if self.owner.y() > approach_y:
            self.owner.move(self.owner.x(), approach_y)
