# coding:utf-8
"""
桌宠全局配置模块。

职责：
- 维护界面资源与本地设置路径。
- 定义各功能模块的默认配置。
- 从设置 JSON 加载配置。
- 保存设置页产生的配置变更。

桌面界面配置保存在 data/minipet_settings.json；Agent 配置由工程根目录管理。
"""

import json
from pathlib import Path

from pet.spirit_model import SPIRIT_NAME

from PySide6.QtCore import QLocale

ROOT_DIR = Path(__file__).resolve().parents[1]
RES_DIR = ROOT_DIR / 'res'
DATA_DIR = ROOT_DIR / 'data'
AVATARS_DIR = DATA_DIR / 'avatars'
SETTINGS_FILE = DATA_DIR / 'minipet_settings.json'

# 冷连接握手时是否显示"正在连接语音服务"动画；
# 直连后握手约 200ms，动画暂时关闭，需要时改回 True 即可
ASR_CONNECTING_ANIMATION = False
DEFAULT_THEME_COLOR = '#009faa'
SCREEN_SHARE_ENABLED = False
APP_DISPLAY_NAME = 'gpt-claw 专属宠物'
# 保留历史应用标识，避免影响已有设置及服务身份。
APP_ID = 'minipet'

TRUE_VALUES = {'1', 'true', 'yes', 'on'}   # 布尔配置的“真”字面量集合
FALSE_VALUES = {'0', 'false', 'no', 'off'}  # 布尔配置的“假”字面量集合

DEFAULT_APP_CONFIG = {
    # 固定置顶并悬浮停留；自主散步不依赖重力掉落。
    'on_top': True,      # 宠物窗口置顶：始终显示在其他窗口上方
    'allow_drop': False,
    'volume': 0.4,
    'language_code': QLocale().name(),
    'theme_color': None,
    'default_pet': SPIRIT_NAME,
    'pet_name': '',
    'scale': 1.0,
    'pet_avatar': '',
    'user_avatar': 'user_avatar_5.png',  # 默认使用 3x3 头像切片的中心图
    'app_theme': 'aurora',
    'voice_follow_effect': 'spring',
    'companion_mode': 'companion',  # 3D 角色的本地陪伴动作，不调用模型
    'pet_effects': True,
    'pet_sounds': True,
}

TTS_VOICE_OPTIONS = [
    ('zh_female_vv_uranus_bigtts', 'vivi 2.0'),
    ('saturn_zh_female_cancan_tob', '知性灿灿'),
    ('zh_female_roumeinvyou_uranus_bigtts', '柔美女友2.0'),
    ('zh_female_sajiaoxuemei_uranus_bigtts', '撒娇学妹2.0'),
]
TTS_VOICE_IDS = {voice_id for voice_id, _ in TTS_VOICE_OPTIONS}

DEFAULT_TTS_CONFIG = {
    'enabled': False,               # 是否启用豆包 TTS 朗读
    'api_key': '',
    'voice_name': TTS_VOICE_OPTIONS[0][0],  # 默认音色：vivi
    'max_chars': 200,               # 单次朗读的最大文本长度
    'test_text': '',
    'disable_emoji_filter': True,   # 是否跳过 emoji 过滤
    'max_length_to_filter_parenthesis': 100,  # 超过该长度才过滤括号内容
}

ASR_RECORDING_MAX_MS = 5 * 60 * 1000  # 单次语音识别录音上限：5 分钟

DEFAULT_VOICE_CHAT_CONFIG = {
    'continuous': False,
}

DEFAULT_WAKE_WORD_CONFIG = {
    'enabled': False,     # 是否启用离线唤醒词
    'words': '小月小月',
    'template_path': 'data/wake_word_templates/default.json',
    'sample_rate': 16000,  # 唤醒模型要求的采样率
    'chunk_ms': 80,        # 每个音频块时长
    'window_ms': 2400,     # 唤醒检测滑窗时长
    'threshold': 0.50,     # 唤醒判定相似度阈值
    'confirm_count': 1,    # 连续命中次数达到该值才确认唤醒
    'cooldown_ms': 1800,   # 唤醒后的冷却时间，防止重复触发
    'restart_delay_ms': 1200,  # 检测器重启延迟
    'weight': 2.0,         # 唤醒词关键词权重，越高越容易命中（误触也随之上升）
}

DEFAULT_TYPEWRITER_CONFIG = {
    'enabled': True,           # 回复是否逐字打字机效果显示
    'speed_ms': 28,            # 每字间隔毫秒数
    'max_duration_ms': 5000,   # 打字动画总时长上限
    'tts_delay_ms': 500,       # 打字动画相对 TTS 播放的延迟
}

app_config = dict(DEFAULT_APP_CONFIG)
tts_config = dict(DEFAULT_TTS_CONFIG)
voice_chat_config = dict(DEFAULT_VOICE_CHAT_CONFIG)
typewriter_config = dict(DEFAULT_TYPEWRITER_CONFIG)
wake_word_config = dict(DEFAULT_WAKE_WORD_CONFIG)

# 桌宠窗口运行态。历史代码直接从 config 模块读写这些状态，先保留集中入口。
screens = []
current_screen = None
on_floor = True
dragging = False
drag_speed_x = 0.0
drag_speed_y = 0.0
current_pet = SPIRIT_NAME


def ensure_data_dir():
    """确保 data 目录存在。"""
    DATA_DIR.mkdir(exist_ok=True)


def local_tts_path(*parts):
    """固定语音优先使用本地缓存，缺失时读取随工程迁移的内置音频。"""
    cached_path = DATA_DIR.joinpath(*parts)
    if cached_path.is_file() and cached_path.stat().st_size > 0:
        return cached_path
    return (RES_DIR / 'audio').joinpath(*parts)


def avatar_path(kind):
    """
    返回用户或宠物头像路径。

    优先使用 data/avatars 中的自定义头像；宠物头像未配置时使用浮灵渲染头像。
    """
    key = 'user_avatar' if kind == 'user' else 'pet_avatar'
    filename = str(app_config.get(key, '') or '').strip()
    if filename:
        path = AVATARS_DIR / filename
        if path.is_file():
            return path
    if kind == 'pet':
        return spirit_image_path()
    return RES_DIR / 'icons' / 'character.svg'


def spirit_image_path():
    """固定使用浮灵的真实渲染头像。"""
    path = RES_DIR / 'role' / SPIRIT_NAME / 'info' / 'pfp.png'
    return path if path.is_file() else RES_DIR / 'icons' / 'character.svg'


def pet_display_name():
    """返回界面和聊天中展示的名字，未设置昵称时使用浮灵。"""
    return str(app_config.get('pet_name') or SPIRIT_NAME).strip() or SPIRIT_NAME


def _coerce_env_value(value, default):
    """按默认值类型把配置值转换成 bool/int/float/str。"""
    if isinstance(default, bool):
        normalized = str(value).strip().lower()
        if normalized in TRUE_VALUES:
            return True
        if normalized in FALSE_VALUES:
            return False
        return default
    if isinstance(default, int) and not isinstance(default, bool):
        try:
            return int(value)
        except (TypeError, ValueError):
            return default
    if isinstance(default, float):
        try:
            return float(value)
        except (TypeError, ValueError):
            return default
    return value


def _load_json_config(defaults, settings, section_key):
    """从 minipet_settings.json 的子 key 读取一组配置。"""
    cfg = dict(defaults)
    data = settings.get(section_key)
    if isinstance(data, dict):
        for k, v in data.items():
            if k in defaults:
                cfg[k] = _coerce_env_value(v, defaults[k])
    return cfg


def load():
    """加载所有配置，并初始化当前宠物等运行时状态。"""
    global app_config, tts_config, voice_chat_config, typewriter_config, wake_word_config, current_pet
    ensure_data_dir()

    settings = {}
    if SETTINGS_FILE.is_file():
        try:
            loaded = json.loads(SETTINGS_FILE.read_text(encoding='utf-8'))
            settings = loaded if isinstance(loaded, dict) else {}
        except Exception:
            pass

    app_config = dict(DEFAULT_APP_CONFIG)
    app_config.update({k: v for k, v in settings.items() if k in DEFAULT_APP_CONFIG and not isinstance(v, dict)})

    # 默认松手悬浮；保留用户显式开启的掉落偏好。
    app_config['on_top'] = True

    app_config['default_pet'] = SPIRIT_NAME
    current_pet = SPIRIT_NAME

    tts_config = _load_json_config(DEFAULT_TTS_CONFIG, settings, 'tts')
    if tts_config['voice_name'] not in TTS_VOICE_IDS:
        tts_config['voice_name'] = DEFAULT_TTS_CONFIG['voice_name']
    voice_chat_config = _load_json_config(DEFAULT_VOICE_CHAT_CONFIG, settings, 'voice_chat')
    typewriter_config = _load_json_config(DEFAULT_TYPEWRITER_CONFIG, settings, 'typewriter')
    wake_word_config = _load_json_config(DEFAULT_WAKE_WORD_CONFIG, settings, 'wake_word')
    if settings and (settings.get('default_pet') != SPIRIT_NAME or 'pet_auto_switch_minutes' in settings):
        # 迁移仅改角色字段，保留语音及其他设置的原始值。
        settings['default_pet'] = SPIRIT_NAME
        settings.pop('pet_auto_switch_minutes', None)
        SETTINGS_FILE.write_text(json.dumps(settings, ensure_ascii=False, indent=2), encoding='utf-8')


def _save_settings_file():
    """将所有配置合并写入 minipet_settings.json。"""
    ensure_data_dir()
    app_config['default_pet'] = SPIRIT_NAME
    app_config.pop('pet_auto_switch_minutes', None)
    data = dict(app_config)
    data['tts'] = dict(tts_config)
    data['voice_chat'] = dict(voice_chat_config)
    data['typewriter'] = dict(typewriter_config)
    data['wake_word'] = dict(wake_word_config)
    SETTINGS_FILE.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')


def save_app_config():
    """保存基础设置到 data/minipet_settings.json。"""
    _save_settings_file()



def save_tts_config(config):
    """保存 TTS 配置到设置 JSON。"""
    global tts_config
    tts_config = {**tts_config, **dict(config)}
    if tts_config.get('voice_name') not in TTS_VOICE_IDS:
        tts_config['voice_name'] = DEFAULT_TTS_CONFIG['voice_name']
    _save_settings_file()


def save_typewriter_config(config):
    """保存回复逐字显示配置到 JSON。"""
    global typewriter_config
    typewriter_config = dict(config)
    _save_settings_file()



def save_voice_chat_config(config):
    """保存本地 AI 语音聊天配置到 JSON。"""
    global voice_chat_config
    voice_chat_config = dict(config)
    _save_settings_file()


def save_wake_word_config(config):
    """保存离线唤醒词配置到 JSON。"""
    global wake_word_config
    wake_word_config = dict(config)
    _save_settings_file()
