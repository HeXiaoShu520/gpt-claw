# coding:utf-8
"""管理桌面回复轮次和断线恢复状态，不依赖 Qt、主应用或消息存储。"""

import uuid
from dataclasses import dataclass, field

from text_stream import TextEvent, TextStreamState


@dataclass
class TurnContext:
    """一轮回复的标识、来源、流式文本及聊天窗口回调。"""
    turn_id: str
    backend: str
    session_id: str
    origin: str
    surface_id: str
    source: str
    on_delta: object = None
    on_result: object = None
    stream: TextStreamState = field(default_factory=TextStreamState)

    @property
    def text(self):
        return self.stream.text

    def accept_text(self, text, *, kind='final', terminal=False, result=False):
        return self.stream.accept(TextEvent(
            text=text, kind=kind, terminal=terminal, result=result,
        ))


class ReplyCoordinator:
    """持有轮次状态；调用方负责计时、显示、回调和持久化。"""

    def __init__(self):
        self._active_turns = {}
        self._turn_by_surface_id = {}
        self._disconnected_turn_ids = set()
        self._expired_turn_sources = {}
        self._connection_generation = 0

    @property
    def has_active(self):
        return bool(self._active_turns)

    def begin(self, backend, origin, session_id='', source='quick_chat',
              surface_id='', on_delta=None, on_result=None):
        turn_id = str(uuid.uuid4())
        turn = TurnContext(
            turn_id, backend, session_id, origin, surface_id or 'turn-' + turn_id,
            source, on_delta, on_result,
        )
        self._active_turns[turn_id] = turn
        self._turn_by_surface_id[turn.surface_id] = turn_id
        return turn

    def resolve(self, backend, turn_id='', surface_id=''):
        """仅按明确的轮次或卡片标识查找，不猜测其他正在进行的回复。"""
        turn = self._active_turns.get(turn_id) if turn_id else None
        if turn is None and surface_id:
            turn = self._active_turns.get(self._turn_by_surface_id.get(surface_id, ''))
        return turn if turn and turn.backend == backend else None

    def finish(self, turn):
        """注销一次轮次；重复终态不再触发调用方的收尾动作。"""
        if not turn or self._active_turns.pop(turn.turn_id, None) is None:
            return False
        self._disconnected_turn_ids.discard(turn.turn_id)
        self._turn_by_surface_id.pop(turn.surface_id, None)
        return True

    def disconnected(self):
        self._connection_generation += 1
        self._disconnected_turn_ids.update(self._active_turns)
        return self._connection_generation

    def recovered(self, turn_ids):
        self._disconnected_turn_ids.difference_update(turn_ids)

    def expire_disconnected(self, generation):
        """返回待收尾的失联轮次，旧连接的定时回调不影响新连接。"""
        if generation != self._connection_generation:
            return []
        turns = [self._active_turns[turn_id] for turn_id in self._disconnected_turn_ids]
        self._disconnected_turn_ids.clear()
        for turn in turns:
            self._expired_turn_sources[turn.turn_id] = turn.source
            if len(self._expired_turn_sources) > 64:
                self._expired_turn_sources.pop(next(iter(self._expired_turn_sources)))
        return turns

    def expired_source(self, turn_id, *, consume=False):
        if consume:
            return self._expired_turn_sources.pop(turn_id, None)
        return self._expired_turn_sources.get(turn_id)

    def clear_expired(self):
        self._expired_turn_sources.clear()
