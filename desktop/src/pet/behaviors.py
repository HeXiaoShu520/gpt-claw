"""Local activities composed from the character's authored clips."""
from dataclasses import dataclass


@dataclass(frozen=True)
class Step:
    pose: str
    seconds: float
    travel: str = ''
    ball: str = ''
    attention: str = ''


@dataclass(frozen=True)
class Behavior:
    label: str
    mood: str
    steps: tuple[Step, ...]
    cooldown: float = 180
    ambient: bool = True


MOODS = {
    'content': '自在', 'curious': '好奇', 'playful': '想玩一会儿',
    'sleepy': '困了', 'social': '想和你打个招呼', 'focused': '专心帮你',
}

# Task feedback is short and event driven; it is not part of ambient selection.
TASK_REACTIONS = {
    'succeeded': Behavior('做好了，看看你', 'social', (
        Step('idle', 1.2), Step('wave', 2.1), Step('idle', .8))),
    'failed': Behavior('遇到问题，等你看看', 'focused', (
        Step('shrug', 3.8, attention='user'), Step('idle', 1.2))),
    'cancelled': Behavior('收住动作，安静陪你', 'content', (
        Step('idle', 1.4),)),
}

BEHAVIORS = {
    'curious_tilt': Behavior('歪头看看你', 'curious', (
        Step('look', 1.5, attention='user'), Step('tilt', 3.6, attention='user'),
        Step('idle', 2)), 300),
    'warm_hello': Behavior('张开手，点头打招呼', 'social', (
        Step('welcome', 3.8, attention='user'), Step('nod', 2.8, attention='user'),
        Step('idle', 3, attention='settle')), 420),
    'stretch': Behavior('伸个懒腰', 'content', (
        Step('idle', 1), Step('stretch', 3.1), Step('idle', 2))),
    'tidy': Behavior('整理帽子和飘带', 'content', (
        Step('look', 2), Step('groom', 3.1), Step('idle', 2))),
    'wonder': Behavior('四处看看', 'curious', (
        Step('look', 4.1), Step('thinking', 4.1), Step('look', 2), Step('idle', 2))),
    'ponder': Behavior('托腮想点事情', 'curious', (
        Step('sit', 3), Step('thinking', 8.1), Step('stretch', 3.1))),
    'hello': Behavior('看看你再招手', 'social', (
        Step('look', 1.5, attention='user'), Step('wave', 2.1, attention='user'),
        Step('idle', 4.5, attention='wait'), Step('look', 1.3, attention='settle'),
        Step('groom', 3.1, attention='settle'), Step('idle', 1.5, attention='settle')), 240),
    'taskbar': Behavior('沿任务栏散步，再趴着看你', 'social', (
        Step('look', 1.5), Step('walk', 4, 'edge_approach'),
        Step('walk', 4, 'edge_stroll'),
        Step('perch', 2, 'edge_contact'), Step('perch', 20),
        Step('perch', 2, 'edge_leave'), Step('walk', 4, 'edge_home'),
        Step('wave', 2.1)), 600),
    'stroll': Behavior('附近散散步', 'curious', (
        Step('look', 2.5), Step('walk', 7, 'near'), Step('look', 4.1),
        Step('sit', 4.1), Step('walk', 7, 'home'), Step('idle', 2)), 150),
    'patrol': Behavior('走走停停巡视一圈', 'curious', (
        Step('look', 3), Step('walk', 8, 'near'), Step('look', 4.1),
        Step('walk', 6, 'near'), Step('groom', 3.1),
        Step('walk', 8, 'home'), Step('stretch', 3.1)), 300),
    'ball': Behavior('颠颠小球', 'playful', (
        Step('look', 2, ball='settle'), Step('play', 12.1, ball='bounce'),
        Step('look', 2, ball='settle'), Step('groom', 3.1)), 240),
    'roll': Behavior('推球跟着走', 'playful', (
        Step('look', 2, ball='settle'), Step('play', 4.1, ball='bounce'),
        Step('walk', 6, 'ball', 'roll'), Step('look', 3, ball='settle'),
        Step('wave', 2.1)), 300),
    'sit': Behavior('安静坐一会儿', 'content', (
        Step('look', 2), Step('sit', 12.1), Step('stretch', 3.1))),
    'doze': Behavior('打个小盹再醒来', 'sleepy', (
        Step('drowsy', 4.8), Step('sleep', 28), Step('wake', 3.2), Step('look', 3)), 360),
    'nap': Behavior('睡一小觉', 'sleepy', (
        Step('drowsy', 4.8), Step('sleep', 75), Step('wake', 3.2), Step('wave', 2.1)), 900),
    'unwind': Behavior('伸展后慢慢放松', 'content', (
        Step('stretch', 3.1), Step('rest', 8.1), Step('groom', 3.1), Step('idle', 2)), 240),
    'sit_watch': Behavior('坐着看看你', 'social', (
        Step('look', 2, attention='user'), Step('sit', 8.1, attention='user'),
        Step('look', 4.1), Step('idle', 2)), 300),
    'inspect_stroll': Behavior('走近看看，再想一想', 'curious', (
        Step('look', 2), Step('walk', 5, 'near'), Step('look', 4.1),
        Step('thinking', 4.1), Step('walk', 5, 'home'), Step('idle', 2)), 300),
    'outing_rest': Behavior('散步回来歇歇', 'content', (
        Step('stretch', 3.1), Step('walk', 6, 'near'), Step('sit', 8.1),
        Step('look', 2), Step('walk', 6, 'home'), Step('rest', 4.1)), 420),
    'ball_pause': Behavior('玩会球，停下来看看', 'playful', (
        Step('look', 2, ball='settle'), Step('play', 4.1, ball='bounce'),
        Step('look', 3, ball='settle'), Step('play', 4.1, ball='bounce'),
        Step('look', 2, ball='settle'), Step('idle', 2)), 300),
    'sleepy_tidy': Behavior('困了还想整理一下', 'sleepy', (
        Step('drowsy', 4.8), Step('groom', 3.1), Step('drowsy', 4.8),
        Step('sleep', 18), Step('wake', 3.2), Step('idle', 2)), 600),
    # Longer performances are requested explicitly, never picked during work breaks.
    'exercise': Behavior('陪我活动一下', 'content', (
        Step('look', 2, attention='user'), Step('wave', 2.1),
        Step('stretch', 3.1), Step('rest', 4.1), Step('stretch', 3.1),
        Step('groom', 3.1), Step('idle', 2, attention='user')), ambient=False),
    'play_outing': Behavior('带球出门，再回来招手', 'playful', (
        Step('look', 2, ball='settle'), Step('play', 4.1, ball='bounce'),
        Step('walk', 6, 'ball', 'roll'), Step('look', 3, ball='settle'),
        Step('play', 4.1, ball='bounce'), Step('look', 2, ball='settle'),
        Step('walk', 6, 'home'), Step('wave', 2.1, attention='user'),
        Step('idle', 2)), ambient=False),
}
