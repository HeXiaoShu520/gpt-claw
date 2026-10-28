"""Small local toy simulation in character-space units; independent of Qt."""
import math


class BallMotion:
    GRAVITY = 4.2
    RADIUS = .18

    def __init__(self, position, rotation=0, depth=.65):
        self.x, self.height = position
        self.depth = depth
        self.side = 1 if self.x >= 0 else -1
        # A released hand-held ball can start inside the usual play area.
        self.inner_edge = min(.65, abs(self.x))
        self.outer_edge = max(1.65, abs(self.x))
        self.vx = self.vy = 0.0
        self.rotation = rotation

    @property
    def settled(self):
        return self.height == 0 and self.vx == 0 and self.vy == 0

    def tap(self):
        direction = self.side if abs(self.x) < 1.15 else -self.side
        self.vx = max(-.85, min(.85, self.vx + direction * .65))
        # Repeated taps keep the current position without launching out of view.
        ceiling_speed = math.sqrt(2 * self.GRAVITY * max(0, 1.5 - self.height))
        self.vy = min(max(0, self.vy) + 2.3, ceiling_speed)

    def advance(self, dt):
        count = max(1, math.ceil(dt * 120))
        step = dt / count
        for _ in range(count):
            previous_x = self.x
            if self.height > 0 or self.vy > 0:
                self.vy -= self.GRAVITY * step
                self.height += self.vy * step
                if self.height <= 0:
                    self.height = 0
                    self.vy = -self.vy * .48 if self.vy < -.35 else 0
                    self.vx *= .75
            else:
                self.vx *= math.exp(-4 * step)
                if abs(self.vx) < .025:
                    self.vx = 0
            self.x += self.vx * step
            distance = self.x * self.side
            if distance < self.inner_edge or distance > self.outer_edge:
                self.x = self.side * max(self.inner_edge, min(self.outer_edge, distance))
                self.vx *= -.7
            self.rotation -= math.degrees((self.x - previous_x) / self.RADIUS)
