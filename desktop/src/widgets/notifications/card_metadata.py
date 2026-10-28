# coding:utf-8
"""回复卡片的紧凑用量展示，完整统计仍保留为悬停提示。"""

import re


def compact_tokens(value):
    number = max(0, int(value))
    if number >= 1000000:
        return f'{number / 1000000:.1f}M'
    if number >= 1000:
        return f'{number / 1000:.1f}K'
    return str(number)


def _token_number(value):
    unit = value[-1:].upper()
    return float(value[:-1] if unit in ('K', 'M') else value) * {'K': 1000, 'M': 1000000}.get(unit, 1)


def usage_summary(usage, footer):
    """兼容结构化用量及服务现有 footer_text；缓存是输入的子集。"""
    parts = []
    details = str(footer or '').strip()
    if isinstance(usage, dict):
        tokens = []
        for key in ('input_tokens', 'output_tokens'):
            try:
                if usage.get(key) is not None:
                    tokens.append(max(0, int(usage[key])))
            except (TypeError, ValueError, OverflowError):
                pass
        if tokens:
            parts.append(f'{compact_tokens(sum(tokens))} tok')
        breakdown = []
        for key, label in (('input_tokens', '输入'), ('output_tokens', '输出'), ('cache_tokens', '缓存')):
            try:
                if usage.get(key) is not None:
                    breakdown.append(f'{label} {int(usage[key]):,}')
            except (TypeError, ValueError, OverflowError):
                pass
        if usage.get('cost_usd') is not None:
            try:
                breakdown.append(f'费用 ${float(usage["cost_usd"]):.6f}')
            except (TypeError, ValueError, OverflowError):
                pass
        if breakdown:
            details = '\n'.join(filter(None, (details, ' · '.join(breakdown))))
    if not parts:
        # 只取本轮/最近请求，累计和缓存不参与相加。
        turn = re.search(r'(?:本轮|最近请求)([^·\n]+)', str(footer or ''))
        if turn:
            counters = re.findall(r'(?:入|出)\s*(\d+(?:\.\d+)?[KkMm]?)', turn.group(1).split('（')[0])
            if counters:
                parts.append(f'{compact_tokens(sum(_token_number(value) for value in counters))} tok')
    elapsed = re.search(r'(?:^|[·\s])([\d.]+s)\s*$', str(footer or ''))
    if elapsed:
        parts.append(elapsed.group(1))
    if not parts and '未上报' in str(footer or ''):
        parts.append('用量未上报')
    return ' · '.join(parts), details
