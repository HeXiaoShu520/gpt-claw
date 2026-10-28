"""Local companion direction. No screen capture, networking, or model calls."""
from collections import deque
from dataclasses import replace
import math
import random
import time

from PySide6.QtCore import QObject, QPoint, QTimer, Signal
from PySide6.QtGui import QCursor

from pet.attention import Attention, Invitation
from pet.ball import BallMotion
from pet.behaviors import BEHAVIORS, MOODS, TASK_REACTIONS, Step
from pet.spirit_model import SPIRIT_ACTIONS
from pet.surfaces import TaskbarPerch


class CompanionDirector(QObject):
    pose_changed = Signal(str)
    frame = Signal(float, float, float)
    presentation_changed = Signal(object)
    cue = Signal(str)
    PRIORITY = {name: action.priority for name, action in SPIRIT_ACTIONS.items()}
    MODES = {'quiet', 'companion', 'lively', 'rest'}
    POSES = set(SPIRIT_ACTIONS)
    INTERVALS = {'quiet': (90, 180), 'companion': (30, 70),
                 'lively': (16, 36), 'rest': (180, 240)}

    def __init__(self, owner, mode='companion'):
        super().__init__(owner)
        self.owner = owner
        self.mode = mode if mode in self.MODES else 'companion'
        self.pose = 'idle'
        self.energy, self.curiosity, self.social = .8, .5, .3
        self._sources = {}
        self._sequence = deque()
        self._step = None
        self._elapsed = 0.0
        self._travel_rate = 1.0
        self._behavior = ''
        self._recent = deque(maxlen=3)
        self._cooldowns = {}
        self._clock = 0.0
        self._next_ambient = random.uniform(*self.INTERVALS[self.mode])
        self._last_tick = time.monotonic()
        self._look = [0.0, 0.0]
        self._attention = Attention()
        self._invitation = None
        self._yaw = 0.0
        self._guide_target = None
        self._conversation_target = None
        self._home = owner.pos()
        self._return_home = False
        self._origin = self._destination = owner.pos()
        self._last_position = owner.pos()
        self._last_step_sound = 0.0
        self._ball_side = 1
        self._ball_rotation = 0.0
        self._ball_position = [1.15, 0.0]
        self._ball_motion = None
        self._response = ''
        self._affection = 0.0
        self._stroke_until = 0.0
        self._touch_until = 0.0
        self._tap_variant = 0
        self._reaction = ''
        self._reaction_elapsed = 0.0
        self._reaction_duration = 0.0
        self._pending_reaction = None
        self._perch = TaskbarPerch(owner)
        self.timer = QTimer(self)
        self.timer.setInterval(33)
        self.timer.timeout.connect(self._tick)

    @property
    def mood(self):
        if self._sources:
            return 'focused'
        if self._reaction in TASK_REACTIONS:
            return TASK_REACTIONS[self._reaction].mood
        if self._ball_motion:
            return 'playful'
        if self._behavior:
            return BEHAVIORS[self._behavior].mood
        if self.mode == 'rest' or self.energy < .3:
            return 'sleepy'
        if self.social > .75:
            return 'social'
        return 'curious' if self.curiosity > .7 else 'content'

    @property
    def status(self):
        source = self._active_source()
        if source is not None:
            activity = '指引中' if source == 'guidance' else SPIRIT_ACTIONS[self._sources[source]].label
        elif self._response:
            activity = self._response
        elif self._behavior:
            activity = {'wait': '等你回应', 'ack': '看到你啦', 'settle': '自己放松一会儿'}.get(
                self._step.attention, BEHAVIORS[self._behavior].label)
        elif self._step or self.pose == 'sleep':
            activity = SPIRIT_ACTIONS[self.pose].label
        else:
            activity = MOODS[self.mood]
        return f'现在：{activity}'

    def set_mode(self, mode):
        if mode in self.MODES:
            self.mode = mode
            self._return_home = False
            self._cancel()
            self._resolve()

    def activity(self, source, pose=None):
        if pose in self.PRIORITY:
            if self._sources.get(source) == pose:
                return
            if pose == 'drag':
                self._pending_reaction = None
                self._return_home = False
            elif (self._step and self._step.travel) or any(step.travel for step in self._sequence):
                self._return_home = True
            self._sources[source] = pose
            self._cancel()
        else:
            self._sources.pop(source, None)
        self._resolve()

    def clear_activities(self, prefix):
        for source in tuple(self._sources):
            if source.startswith(prefix):
                del self._sources[source]
        self._resolve()

    def task_event(self, turn_id, event):
        source = f'turn:{turn_id}'
        if event == 'started':
            if source in self._sources:
                return
            self._pending_reaction = None
            self.activity(source, 'thinking')
            if self.pose == 'thinking':
                self._reaction = 'received'
                self._reaction_elapsed = 0.0
                self._reaction_duration = .9
        elif event == 'running':
            if source in self._sources:
                self.activity(source, 'thinking')
        elif event in TASK_REACTIONS and source in self._sources:
            del self._sources[source]
            self._pending_reaction = (event, time.monotonic() + 6)
            if not self._sources:
                self._cancel()
            self._resolve()

    def greet(self):
        self.social = 0
        return self.play_behavior('hello')

    def tap(self):
        """A short acknowledgment never interrupts an active task."""
        if self.pose in ('drag', 'fall', 'land', 'dizzy', 'recover'):
            return False
        if not self._sources and self.pose in ('sleep', 'drowsy'):
            return self.wake()
        self._tap_variant = 1 - self._tap_variant
        self._touch_until = self._clock + .9
        self.social = 0
        return True

    def pat(self):
        """Renewed by actual pointer strokes; fades shortly after movement stops."""
        if self.pose in ('drag', 'fall', 'land', 'dizzy', 'recover'):
            return False
        if not self._sources and self.pose in ('sleep', 'drowsy'):
            return self.wake()
        self.social = 0
        self._stroke_until = self._clock + .65
        return True

    def wake(self):
        if self._sources or self.pose == 'wake':
            return False
        self._cancel()
        self._response = '慢慢醒来'
        self._sequence.extend((Step('wake', 3.2),
                               Step('look', 3), Step('idle', 2)))
        self._advance()
        return True

    def tap_ball(self, position=None):
        if self._sources or not self._step or not self._step.ball:
            return False
        if self._ball_motion:
            motion = self._ball_motion
        else:
            x, height, depth = position if position is not None else (*self._ball_position, .65)
            motion = BallMotion((x, height), self._ball_rotation, depth)
        motion.tap()
        if self._step.ball == 'touch':
            return True
        self._cancel()
        self._response = '陪你玩球'
        self._ball_motion = motion
        self._sequence.extend((Step('look', .65, ball='touch'),
                               Step('play', 0, ball='touch'),
                               Step('idle', 2.4, ball='held', attention='ack'),
                               Step('idle', 1.4, ball='held', attention='user')))
        self._advance()
        self.presentation_changed.emit({
            'ballVisible': True, 'ballOpacity': 1, 'ballGrip': 0,
            'ballX': motion.x, 'ballHeight': motion.height, 'ballDepth': motion.depth,
        })
        return True

    def play(self, pose, duration=None):
        if pose == 'perch':
            return self.play_behavior('taskbar')
        if pose not in self.POSES or self._sources:
            return False
        self._return_home = False
        self._cancel()
        self._sequence.extend((Step(pose, SPIRIT_ACTIONS[pose].duration if duration is None else duration),
                               Step('idle', 1)))
        self._advance()
        return True

    def play_behavior(self, name):
        if not self.behavior_available(name):
            return False
        self._return_home = False
        self._cancel()
        if name == 'taskbar' and not self._perch.begin():
            self._resolve()
            return False
        behavior = BEHAVIORS[name]
        self._behavior = name
        self._recent.append(name)
        self._cooldowns[name] = self._clock + behavior.cooldown
        self._ball_side = -1 if self.owner.geometry().center().x() > self.owner.current_screen.center().x() else 1
        self._ball_rotation = 0.0
        if name == 'hello':
            cursor = QCursor.pos()
            self._invitation = Invitation((cursor.x(), cursor.y()), self._nearby(cursor))
        self._sequence.extend(behavior.steps)
        self._advance()
        return True

    def behavior_available(self, name, nearby=False):
        return (name in BEHAVIORS and not self._sources
                and (name != 'taskbar' or self._perch.available(nearby)))

    def reset_home(self):
        """An explicit placement becomes the center of future short outings."""
        self._pending_reaction = None
        self._return_home = False
        self._cancel()
        self._home = self.owner.pos()
        self._resolve()

    def set_enabled(self, enabled):
        self._return_home = False
        if enabled:
            self._last_tick = time.monotonic()
            self._home = self.owner.pos()
            self._last_position = self.owner.pos()
            self._resolve()
            self.timer.start()
        else:
            self.timer.stop()
            self._conversation_target = None
            self._pending_reaction = None
            self._cancel()

    def landed(self, impact):
        """A physical landing owns a short reaction, unless a task needs attention."""
        self.reset_home()
        if self._sources:
            return
        self._sequence.append(Step('land', .45))
        if impact > 850:
            self._sequence.append(Step('dizzy', 2.2))
        self._sequence.append(Step('recover', .8))
        self._advance()

    def set_guide_target(self, point):
        self._guide_target = point

    def conversation(self, event, target=None):
        """聊天的局部注视和招呼；任务期间跳过招呼，不排队补播。"""
        self._conversation_target = target
        if self._sources or self.mode == 'rest':
            return
        if event == 'opened':
            self.play('look', .9)
        elif event == 'closed':
            self.play('wave', 1.2)

    def _cancel(self):
        self._perch.clear()
        self._sequence.clear()
        self._step = None
        self._elapsed = 0.0
        self._travel_rate = 1.0
        self._behavior = ''
        self._invitation = None
        self._response = ''
        self._reaction = ''
        self._reaction_elapsed = 0.0
        self._ball_motion = None
        self._next_ambient = self._clock + random.uniform(*self.INTERVALS[self.mode])
        self.presentation_changed.emit({'ballVisible': False,
                                        'taskReaction': '', 'reactionProgress': 0, 'greeting': 0})

    def _active_source(self):
        return max(self._sources, key=lambda source: max(
            self.PRIORITY[self._sources[source]], 55 if source == 'guidance' else 0), default=None)

    def _resolve(self):
        source = self._active_source()
        if source is not None:
            self._set_pose(self._sources[source])
        elif self._step is None:
            if self._pending_reaction:
                event, deadline = self._pending_reaction
                self._pending_reaction = None
                if time.monotonic() <= deadline:
                    reaction = TASK_REACTIONS[event]
                    self._response = reaction.label
                    self._reaction = event
                    self._reaction_elapsed = 0.0
                    self._reaction_duration = sum(step.seconds for step in reaction.steps)
                    self._sequence.extend(reaction.steps)
                    self._advance()
                    return
            if self._return_home:
                delta = self._travel_target('home') - self.owner.pos()
                distance = math.hypot(delta.x(), delta.y())
                if distance > 4:
                    self._response = '忙完啦，慢慢回去'
                    self._sequence.extend((Step('look', .8),
                                           Step('walk', max(1.5, distance / 26), 'home'),
                                           Step('idle', .8)))
                    self._advance()
                    return
                self._return_home = False
            self._set_pose('sleep' if self.mode == 'rest' else 'idle')

    def _set_pose(self, pose, restart=False):
        if self.pose != pose or restart:
            self.pose = pose
            self.pose_changed.emit(pose)
            if pose in ('drag', 'land', 'dizzy'):
                self.cue.emit('grab' if pose == 'drag' else pose)

    def _advance(self):
        self._elapsed = 0.0
        self._travel_rate = 1.0
        if not self._sequence:
            if self._behavior:
                mood = BEHAVIORS[self._behavior].mood
                self.curiosity = max(0, self.curiosity - (.3 if mood == 'curious' else 0))
                self.social = 0 if mood == 'social' else self.social
                self.energy = max(0, self.energy - (.08 if mood == 'playful' else 0))
            self._cancel()
            self._resolve()
            return
        self._step = self._sequence.popleft()
        if self._step.ball == 'held' and self._step.attention == 'ack':
            self._response = '玩得开心，看看你'
            self.social = 0
        self._origin = self.owner.pos()
        self._destination = self._travel_target(self._step.travel)
        if self._step.travel in ('edge_approach', 'edge_stroll', 'edge_home'):
            distance = (self._destination - self._origin).manhattanLength()
            speed = 32 if self._step.travel == 'edge_stroll' else 70
            self._step = replace(self._step, seconds=max(1, distance / speed))
        self._set_pose(self._step.pose, restart=True)

    def _travel_target(self, travel):
        if not travel:
            return self.owner.pos()
        if travel.startswith('edge_'):
            return self._perch.target(travel)
        area = self.owner.current_screen
        left, top = area.left() + 12, area.top() + 12
        right = max(left, area.right() - self.owner.width() - 11)
        bottom = max(top, area.bottom() - self.owner.height() - 11)
        if travel == 'home':
            target = self._home
        else:
            direction = self._ball_side if travel == 'ball' else random.choice((-1, 1))
            distance = 55 if travel == 'ball' else random.randint(90, 170)
            if travel != 'ball' and not left <= self.owner.x() + distance * direction <= right:
                direction *= -1
            target = self.owner.pos() + QPoint(distance * direction,
                                               0 if travel == 'ball' else random.randint(-25, 25))
        x = max(self._home.x() - 240, min(target.x(), self._home.x() + 240))
        y = max(self._home.y() - 100, min(target.y(), self._home.y() + 100))
        return QPoint(max(left, min(x, right)), max(top, min(y, bottom)))

    def _choose_behavior(self):
        choices = [name for name in BEHAVIORS if BEHAVIORS[name].ambient and name not in self._recent
                   and self._clock >= self._cooldowns.get(name, 0)
                   and self.behavior_available(name, nearby=True)]
        if not choices:
            return
        weights = {'content': 1, 'curious': .4 + 2 * self.curiosity,
                   'social': .1 + 2 * self.social, 'playful': 1.5 * self.energy,
                   'sleepy': .05 if self.energy > .5 else 4 * (1 - self.energy)}
        self.play_behavior(random.choices(choices, [weights[BEHAVIORS[n].mood] for n in choices])[0])

    def _nearby(self, cursor):
        return self.owner.geometry().adjusted(-36, -36, 36, 36).contains(cursor)

    def _step_time(self, dt, paused):
        if not self._step.travel:
            return 0.0 if paused else dt
        # Slow the travel clock itself, so position, arms and facing stop together.
        target = 0.0 if paused else 1.0
        ramp = min(dt, abs(target - self._travel_rate) * .2)
        rate = max(0.0, min(1.0, self._travel_rate + math.copysign(ramp / .2, target - self._travel_rate)))
        elapsed = ramp * (self._travel_rate + rate) / 2 + (dt - ramp) * target
        self._travel_rate = rate
        return elapsed

    def _tick(self):
        now = time.monotonic()
        dt = min(.1, now - self._last_tick)
        self._last_tick = now
        if not self.owner.isVisible():
            return
        if self._perch.screen is not None and not self._perch.valid():
            self._cancel()
            self._resolve()
        self._clock += dt
        self.energy = max(0, min(1, self.energy + dt * (1 / 180 if self.pose in ('rest', 'sleep') else -1 / 5400)))
        self.curiosity = min(1, self.curiosity + dt / 1800)
        self.social = min(1, self.social + dt / 2700)
        cursor = QCursor.pos()
        watching = self._step and self._step.pose == 'perch' and not self._step.travel
        nearby = self._nearby(cursor)
        paused = (self.owner.companion_interaction_active()
                  or (nearby and not watching and (self._step is None or bool(self._step.travel))))
        if self._invitation and self._step.attention in ('user', 'wait'):
            responded = self._invitation.sample(dt, (cursor.x(), cursor.y()), nearby, not paused)
            if responded and self._step.attention == 'wait' and not paused:
                self._invitation = None
                self._sequence.clear()
                self._sequence.extend((Step('idle', 2.4, attention='ack'),
                                       Step('idle', 1.4, attention='user')))
                self._advance()
        ending = self._reaction in TASK_REACTIONS
        landing = self._step and self._step.pose in ('land', 'dizzy', 'recover')
        if self._reaction and (not self._sources or self.pose == 'thinking'):
            self._reaction_elapsed += dt
            if self._reaction == 'received' and self._reaction_elapsed >= self._reaction_duration:
                self._reaction = ''
        traveling = self._step and bool(self._step.travel)
        if not self._sources and (not paused or ending or landing or traveling):
            if self._step:
                step_dt = self._step_time(dt, paused and not (ending or landing))
                if self._ball_motion and self._step.ball == 'touch':
                    self._ball_motion.advance(step_dt)
                self._elapsed += step_dt
                waiting_for_ball = (self._step.ball == 'touch' and self._step.pose == 'play'
                                    and not self._ball_motion.settled)
                if self._elapsed >= self._step.seconds and not waiting_for_ball:
                    if self._step.travel:
                        self.owner.move(self._destination)
                    self._advance()
            elif self._clock >= self._next_ambient:
                self._next_ambient = self._clock + random.uniform(*self.INTERVALS[self.mode])
                if self.mode in ('companion', 'lively'):
                    self._choose_behavior()
        self._present(dt, cursor, nearby, paused)
        if self._perch.screen is not None:
            self._perch.update_mask()

    def _point_gaze(self, point):
        return (max(-1, min(1, (point.x() - self.owner.x() - self.owner.width() / 2) / 400)),
                max(-1, min(1, (self.owner.y() + self.owner.height() / 3 - point.y()) / 350)))

    def _gaze_target(self, cursor, nearby, moving, paused, ball, ball_x, height):
        pointer = self._point_gaze(cursor)
        ambient = self._attention.sample(self._clock, (cursor.x(), cursor.y()), nearby, pointer)
        if self._active_source() == 'guidance' and self._guide_target is not None:
            return self._point_gaze(self._guide_target)
        if self.pose in ('rest', 'sleep'):
            return (0, -.3)
        if self.pose == 'thinking':
            return (.15 + .12 * math.sin(self._clock * .31),
                    .2 + .06 * math.sin(self._clock * .47))
        if not self._sources and self._conversation_target is not None:
            return self._point_gaze(self._conversation_target)
        if self.pose in ('listening', 'speaking', 'approval', 'drag') or self.owner.companion_interaction_active():
            return pointer if nearby else (0, 0)
        if ball and ball != 'held':
            return (ball_x * .65, -.75 + height * .45)
        if moving and not paused and self.pose != 'perch':
            return (.65 if self._destination.x() > self._origin.x() else -.65, .1)
        if self._step and self._step.attention in ('user', 'wait', 'ack'):
            return pointer if nearby else (0, 0)
        if self.pose == 'look' and not paused:
            return (math.sin(self._elapsed * 1.2) * .8, .25)
        return ambient

    def _present(self, dt, cursor, nearby, paused):
        step = self._step
        moving = bool(step and step.travel and not self._sources)
        delta = self._destination - self._origin
        walk_strength = 1.0
        travel_velocity = (0.0, 0.0)
        if moving:
            stopped = paused and self._travel_rate == 0 and step.pose != 'perch'
            self._set_pose('idle' if stopped else step.pose)
            t = min(1, self._elapsed / step.seconds)
            progress = t ** 3 * (10 - 15 * t + 6 * t * t)
            rate = 30 * t * t * (1 - t) ** 2 / step.seconds * self._travel_rate
            self.owner.move(self._origin + delta * progress)
            travel_velocity = (delta.x() * rate, delta.y() * rate)
            speed = math.hypot(*travel_velocity)
            walk_strength = min(1, speed / 24)
        displacement = self.owner.pos() - self._last_position
        self._last_position = self.owner.pos()
        velocity = [max(-1600, min(1600, value / max(dt, .001)))
                    for value in (displacement.x(), displacement.y())]
        if moving:
            # Use the curve's velocity; whole-pixel window moves jitter at low speeds.
            velocity = travel_velocity
        if (self.pose == 'walk' and not paused and not self._sources
                and math.hypot(*velocity) > 8 and self._clock - self._last_step_sound > .8):
            self._last_step_sound = self._clock
            self.cue.emit('step')
        ball = step.ball if step else ''
        ball_x, height, grip, depth = 1.15, 0.0, 0.0, .65
        if ball == 'bounce':
            # Hold, toss, catch, then pause before the next four-second cycle.
            flight = max(0, min(1, (self._elapsed % 4 - .6) / 1.6))
            arc = 4 * flight * (1 - flight)
            ball_x, height = .75, 1.03 + .6 * arc
            release = min(1, flight / .15, (1 - flight) / .15)
            grip = 1 - release * release * (3 - 2 * release)
        elif ball == 'roll':
            # The ball gets a little ahead before the companion catches up.
            ball_x += .3 * math.sin(math.pi * self._elapsed / step.seconds)
        ball_x *= self._ball_side
        if ball in ('touch', 'held'):
            ball_x, height = self._ball_motion.x, self._ball_motion.height
            depth = self._ball_motion.depth
            self._ball_rotation = self._ball_motion.rotation
        self._ball_position = [ball_x, height]
        target = self._gaze_target(cursor, nearby, moving, paused, ball, ball_x, height)
        factor = 1 - math.exp(-dt * 4)
        affection = .35 if self._sources else 1.0
        affection *= max(0, min(1, (self._stroke_until - self._clock) / .3))
        touch = max(0, min(1, (self._touch_until - self._clock) / .9))
        greeting = 0
        if step and step.attention == 'ack':
            greeting = max(0, min(1, self._elapsed / .25, (step.seconds - self._elapsed) / .5))
        self._affection += (affection - self._affection) * factor
        attention_factor = 1 - math.exp(-dt * 12)
        for i in range(2):
            self._look[i] += (target[i] - self._look[i]) * attention_factor
        yaw = ((18 if delta.x() > 0 else -18) * walk_strength
               if moving and self.pose != 'perch' else 0)
        self._yaw += (yaw - self._yaw) * factor
        if ball in ('bounce', 'roll') and not paused:
            self._ball_rotation += dt * (110 if ball == 'roll' else 35)
        opacity = 1.0
        if ball == 'held' and step.attention == 'user':
            opacity = max(0, min(1, (step.seconds - self._elapsed) / .5))
        self.presentation_changed.emit({
            'yaw': self._yaw, 'lean': -self._yaw * .12,
            'walkStrength': walk_strength,
            'motionX': velocity[0], 'motionY': velocity[1],
            'affection': self._affection,
            'touchResponse': math.sin(math.pi * touch),
            'touchSide': 1 if self._tap_variant else -1,
            'greeting': greeting,
            'taskReaction': self._reaction,
            'reactionProgress': (min(1, self._reaction_elapsed / self._reaction_duration)
                                 if self._reaction else 0),
            'ballVisible': bool(ball), 'ballX': ball_x, 'ballOpacity': opacity,
            'ballGrip': grip,
            'trackingBall': bool(ball) and ball != 'held',
            'ballHeight': height, 'ballDepth': depth, 'ballRotation': self._ball_rotation,
        })
        self.frame.emit(self._clock, *self._look)

    def stop(self):
        self.timer.stop()
        self._guide_target = None
        self._sources.clear()
        self._pending_reaction = None
        self._return_home = False
        self._cancel()
