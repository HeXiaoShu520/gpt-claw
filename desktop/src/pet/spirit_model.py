"""浮灵的固定资源与动作契约；界面和陪伴控制共用。"""

from dataclasses import dataclass

SPIRIT_NAME = '浮灵'
SPIRIT_SIZE = (280, 290)


@dataclass(frozen=True)
class SpiritAction:
    label: str
    duration: float
    priority: int = 10


SPIRIT_ACTIONS = {
    'idle': SpiritAction('漂浮待机', 4.034, 0),
    'rest': SpiritAction('休息', 4.034, 1),
    'sleep': SpiritAction('睡觉', 12, 1),
    'drowsy': SpiritAction('困倦点头', 4.8, 1),
    'wake': SpiritAction('慢慢醒来', 3.2, 1),
    'wave': SpiritAction('挥手', 2.034),
    'tilt': SpiritAction('歪头看你', 3.6),
    'nod': SpiritAction('轻轻点头', 2.8),
    'welcome': SpiritAction('张开双手欢迎', 3.8),
    'shrug': SpiritAction('困惑摊手', 3.8),
    'guide': SpiritAction('指引', 3.034, 55),
    'thinking': SpiritAction('思考', 4.034, 40),
    'speaking': SpiritAction('说话', 4.034, 50),
    'listening': SpiritAction('倾听', 4.034, 60),
    'approval': SpiritAction('等待确认', 4.034, 70),
    'fall': SpiritAction('下落', 1.034, 90),
    'land': SpiritAction('落地缓冲', .45, 80),
    'dizzy': SpiritAction('晕乎乎', 2.2, 80),
    'recover': SpiritAction('重新站稳', .8, 80),
    'drag': SpiritAction('被提起', 3.034, 100),
    'sit': SpiritAction('坐下', 4.034),
    'stretch': SpiritAction('伸展', 3.034),
    'look': SpiritAction('张望', 4.034),
    'play': SpiritAction('玩耍', 4.034),
    'groom': SpiritAction('整理衣帽', 3.034),
    'walk': SpiritAction('散步摆臂', 3.2),
    'perch': SpiritAction('双手搭边', 4.034),
}
