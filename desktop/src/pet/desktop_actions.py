# coding:utf-8
"""浮灵的窗口尺寸、移动和动作入口。"""
import math

from PySide6.QtCore import QRect

import config
from pet.spirit_model import SPIRIT_ACTIONS, SPIRIT_SIZE


def reset_size(owner, keep_position=True):
    owner.companion.reset_home()
    old_pos = owner.pos()
    try:
        scale = float(config.app_config.get('scale', 1.0))
    except (TypeError, ValueError):
        scale = 1.0
    scale = max(0.5, min(2.0, scale)) if math.isfinite(scale) else 1.0
    config.app_config['scale'] = scale
    owner.setFixedSize(*(round(v * scale) for v in SPIRIT_SIZE))
    owner.character_view.setFixedSize(owner.size())
    # Include the floating crescent and the extended hands across the action set.
    owner.visible_bounds = QRect(round(18 * scale), round(34 * scale), round(246 * scale), round(236 * scale))
    if keep_position:
        owner._set_current_screen_from_point(owner._pet_reference_point(old_pos.x(), old_pos.y()))
        owner.move(owner._limit_position(old_pos.x(), old_pos.y()))
    else:
        owner.floor_y = owner.current_screen.bottom() - owner.height() + 1
        owner.move(owner.current_screen.center().x() - owner.width() // 2, owner.floor_y)
    owner._sync_voice_popup_position()
    owner.companion.reset_home()


def move_by(owner, dx, dy):
    owner.companion.reset_home()
    owner.move(owner._limit_position(owner.x() + dx, owner.y() + dy))
    owner._sync_voice_popup_position()
    owner.companion.reset_home()


def play_action(owner, name):
    if name not in SPIRIT_ACTIONS:
        return False
    return owner.companion.play(name)


def pat(owner):
    return owner.companion.pat()
