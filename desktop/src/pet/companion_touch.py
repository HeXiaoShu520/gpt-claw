"""Local touch gestures, kept separate from dragging and double-click chat."""
import time

from PySide6.QtCore import QObject, QTimer
from PySide6.QtWidgets import QApplication


class CompanionTouch(QObject):
    def __init__(self, owner):
        super().__init__(owner)
        self.owner = owner
        self._target = None
        self._last = None
        self._direction = 0
        self._distance = 0
        self._turns = 0
        self._last_time = 0
        self._click = QTimer(self)
        self._click.setSingleShot(True)
        self._click.timeout.connect(self._respond)

    def target(self, point):
        view = self.owner.character_view
        return view.hit_target(point) if view is not None else None

    def cancel(self):
        self._click.stop()
        self._target = None
        self._last = None
        self._distance = self._turns = self._direction = 0

    def press(self, point):
        self.cancel()
        self._target = self.target(point)

    def release(self, point):
        if self._target and self._target == self.target(point):
            if self._target == 'bubble':
                self.owner.character_view.pop_bubble(point)
                self._target = None
            else:
                self._click.start(QApplication.doubleClickInterval())

    def _respond(self):
        target, self._target = self._target, None
        if target == 'ball':
            self.owner.companion.tap_ball(self.owner.character_view.ball_position())
        elif target == 'head':
            self.owner.companion.tap()

    def move(self, point):
        now = time.monotonic()
        if self.target(point) != 'head':
            self._last = None
            return
        if self._last is None or now - self._last_time > .65:
            self._distance = self._turns = self._direction = 0
        else:
            dx = point.x() - self._last.x()
            if abs(dx) >= 2:
                direction = 1 if dx > 0 else -1
                if direction != self._direction:
                    if self._distance > self.owner.width() * .06:
                        self._turns += 1
                    self._distance = 0
                self._direction = direction
                self._distance += abs(dx)
                if self._turns >= 2 and self._distance > self.owner.width() * .06:
                    self.owner.companion.pat()
                    self._distance = 0
        self._last, self._last_time = point, now
