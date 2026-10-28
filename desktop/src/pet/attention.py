"""Brief local attention, independent of animation and desktop APIs."""
import math
import random


class Attention:
    def __init__(self):
        self._pointer = None
        self._nearby = False
        self._watch_until = 0.0
        self._focus = (0.0, 0.0)
        self._next_glance = random.uniform(5, 9)
        self._glance_until = 0.0
        self._glance = (0.0, 0.0)

    def sample(self, clock, pointer, nearby, target):
        moved = self._pointer is None or math.dist(pointer, self._pointer) >= 12
        if moved:
            self._pointer = pointer
        if nearby and (not self._nearby or moved):
            self._watch_until = clock + 2.4
            self._glance_until = 0.0
            self._next_glance = clock + random.uniform(5, 9)
        elif self._nearby and not nearby:
            self._watch_until = min(self._watch_until, clock + .8)
        self._nearby = nearby
        if clock < self._watch_until:
            if nearby:
                self._focus = target
            return self._focus
        if clock >= self._next_glance:
            self._glance = (random.choice((-1, 1)) * random.uniform(.12, .32),
                            random.uniform(-.12, .12))
            self._glance_until = clock + random.uniform(.7, 1.3)
            self._next_glance = clock + random.uniform(5, 9)
        return self._glance if clock < self._glance_until else (0.0, 0.0)


class Invitation:
    """Recognize a fresh approach and a short stay, not a parked pointer."""

    def __init__(self, pointer, nearby):
        self._pointer = pointer
        self._nearby = nearby
        self._engaged = False
        self._dwell = 0.0
        self.responded = False

    def sample(self, dt, pointer, nearby, active):
        moved = math.dist(pointer, self._pointer) >= 12
        if moved or not active:
            self._pointer = pointer
        if not active or not nearby:
            self._engaged = False
            self._dwell = 0.0
        else:
            if not self._nearby or moved:
                self._engaged = True
            if self._engaged:
                self._dwell += dt
                self.responded |= self._dwell >= .8
        self._nearby = nearby
        return self.responded
