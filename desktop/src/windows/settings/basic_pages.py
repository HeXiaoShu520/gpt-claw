# coding:utf-8
"""基础和智能体设置页面。

BasicPage  ：外观/打印字效果等与 LLM 无关的全局设置
AgentPage  ：后端模式选择及各模式的连接参数配置

两页共用同一个 save_callback 模式（点保存按钮 → _save），
避免用户切换选项时就立即写入配置，保留"不保存就取消"的操作空间。
"""


from PySide6.QtCore import Qt, QThread, Signal
from PySide6.QtWidgets import QLabel
from qfluentwidgets import InfoBar, InfoBarPosition, PrimaryPushButton, SettingCard, SettingCardGroup, SwitchSettingCard
from qfluentwidgets import FluentIcon as FIF

import config
from base_page import MiniPetScrollPage
from clients.event_client import probe_minipet_backend
from widgets.setting_cards import ComboSettingCard, RangeSettingCard
from theme import THEME_OPTIONS, THEMES, DEFAULT_THEME


STYLE_PREVIEW_QSS = {
    name: data['preview_qss']
    for name, data in THEMES.items()
}


VOICE_FOLLOW_EFFECT_OPTIONS = [
    ('spring', '弹力绳'),
    ('magnet', '丝滑吸附'),
]


def _attach_style_preview(card):
    # 在下拉卡片右侧插入一个小预览块，让用户切换主题时能即时看到效果，无需保存后刷新
    # 用 QLabel + 内联 QSS 实现，避免引入额外的自定义 widget 类
    preview = QLabel(card)
    preview.setFixedSize(92, 32)
    preview.setAlignment(Qt.AlignCenter)
    preview.setToolTip('当前样式预览')

    def update_preview(value=None):
        """按当前主题刷新预览块的底色和文字。"""
        value = value or card.currentValue()
        qss = STYLE_PREVIEW_QSS.get(value, '')
        theme_data = THEMES.get(value, THEMES[DEFAULT_THEME])
        color = '#f4f6fb' if theme_data['card']['dark'] else '#263238'
        text = theme_data.get('_label', value)
        preview.setText(text)
        preview.setStyleSheet('QLabel{%s color:%s; font:12px "Microsoft YaHei UI"; font-weight:600;}' % (qss, color))

    update_preview()
    card.comboBox.currentIndexChanged.connect(lambda _index: update_preview())
    card.hBoxLayout.insertWidget(card.hBoxLayout.count() - 2, preview, 0, Qt.AlignRight)
    return preview


class BasicPage(MiniPetScrollPage):
    """外观、打印字效果等与 LLM 无关的基础设置页。"""

    settings_changed = Signal()

    def __init__(self, parent=None):
        """从当前配置读取初始值并搭建视觉样式/回复设置两个分组。"""
        super().__init__('基础设置', parent, save_callback=lambda: self._save())
        typewriter_cfg = config.typewriter_config
        typewriter_defaults = config.DEFAULT_TYPEWRITER_CONFIG

        # 视觉样式分组：主题、跟随效果、音量统一管理，方便后续扩展
        self.visualGroup = SettingCardGroup('视觉样式', self.scrollWidget)
        self.appThemeCard = ComboSettingCard(THEME_OPTIONS, FIF.PALETTE, '整体风格', '统一设置回复卡片、语音球、快捷输入框、菜单、聊天窗口等的视觉风格', self.visualGroup)
        self.appThemeCard.setCurrentValue(config.app_config.get('app_theme', DEFAULT_THEME))
        _attach_style_preview(self.appThemeCard)
        self.voiceFollowEffectCard = ComboSettingCard(VOICE_FOLLOW_EFFECT_OPTIONS, FIF.SPEED_HIGH, '语音球跟随效果', '弹力绳有惯性过冲；丝滑吸附更稳、更少跳变', self.visualGroup)
        self.voiceFollowEffectCard.setCurrentValue(config.app_config.get('voice_follow_effect', 'spring'))
        self.volumeCard = RangeSettingCard(0, 100, 0.01, FIF.VOLUME, '声音大小', '影响语音播报和语音聊天的音量', self.visualGroup)
        self.volumeCard.setValue(round(float(config.app_config.get('volume', 0.9)) * 100))

        self.replyDisplayGroup = SettingCardGroup('回复设置', self.scrollWidget)
        self.typewriterEnabledCard = SwitchSettingCard(FIF.MESSAGE, '打印字效果', '开启后，回复文字会一字一字显示；关闭后直接显示完整回复', parent=self.replyDisplayGroup)
        self.typewriterEnabledCard.setChecked(bool(typewriter_cfg.get('enabled', typewriter_defaults['enabled'])))
        self.typewriterSpeedCard = RangeSettingCard(8, 120, 1, FIF.MESSAGE, '打印字速度', '每个字的最大显示间隔，单位毫秒，数值越小越快', self.replyDisplayGroup)
        self.typewriterSpeedCard.setValue(int(typewriter_cfg.get('speed_ms', typewriter_defaults['speed_ms'])))
        self.typewriterMaxDurationCard = RangeSettingCard(500, 15000, 1, FIF.FONT_SIZE, '最长显示时长', '单条回复打印字效果的最长时间，单位毫秒', self.replyDisplayGroup)
        self.typewriterMaxDurationCard.setValue(int(typewriter_cfg.get('max_duration_ms', typewriter_defaults['max_duration_ms'])))
        self.typewriterTtsDelayCard = RangeSettingCard(0, 3000, 1, FIF.VOLUME, '语音播报文字延迟', '开启语音播报时，回复文字延迟显示的时间，单位毫秒', self.replyDisplayGroup)
        self.typewriterTtsDelayCard.setValue(int(typewriter_cfg.get('tts_delay_ms', typewriter_defaults['tts_delay_ms'])))

        self.visualGroup.addSettingCard(self.appThemeCard)
        self.visualGroup.addSettingCard(self.voiceFollowEffectCard)
        self.visualGroup.addSettingCard(self.volumeCard)
        for card in [self.typewriterEnabledCard, self.typewriterSpeedCard, self.typewriterMaxDurationCard, self.typewriterTtsDelayCard]:
            self.replyDisplayGroup.addSettingCard(card)
        self.expandLayout.addWidget(self.visualGroup)
        self.expandLayout.addWidget(self.replyDisplayGroup)

    def _save(self):
        """把界面值写回 app/typewriter 配置文件并广播变更信号。"""
        config.app_config.update({
            'app_theme': self.appThemeCard.currentValue() or DEFAULT_THEME,
            'voice_follow_effect': self.voiceFollowEffectCard.currentValue() or 'spring',
            'volume': round(float(self.volumeCard.value()), 2),
        })
        config.save_app_config()
        config.save_typewriter_config({
            'enabled': self.typewriterEnabledCard.isChecked(),
            'speed_ms': int(self.typewriterSpeedCard.value()),
            'max_duration_ms': int(self.typewriterMaxDurationCard.value()),
            'tts_delay_ms': int(self.typewriterTtsDelayCard.value()),
        })
        InfoBar.success('保存成功', '基础已保存', duration=2000, position=InfoBarPosition.BOTTOM, parent=self.window())
        self.settings_changed.emit()


class AgentProbeWorker(QThread):
    result_ready = Signal(bool, str)

    def run(self):
        self.result_ready.emit(*probe_minipet_backend())


class AgentPage(MiniPetScrollPage):
    """The desktop has one kernel; this page only reports its connection."""

    settings_changed = Signal()
    reset_backend_history_requested = Signal(str)

    def __init__(self, parent=None):
        super().__init__('智能体', parent, save_callback=self._save)
        self.worker = None
        group = SettingCardGroup('gpt-claw', self.scrollWidget)
        self.statusCard = SettingCard(FIF.ROBOT, '唯一内核', '桌宠、聊天、图片和确认都使用本工程的 Codex 会话', group)
        self.probeCard = SettingCard(FIF.SYNC, '连接状态', '检查本机 gpt-claw 桌面通道', group)
        self.probeButton = PrimaryPushButton('检查连接', self.probeCard)
        self.probeCard.hBoxLayout.addStretch(1)
        self.probeCard.hBoxLayout.addWidget(self.probeButton, 0, Qt.AlignRight)
        self.probeCard.hBoxLayout.addSpacing(16)
        self.probeButton.clicked.connect(self._probe)
        group.addSettingCard(self.statusCard)
        group.addSettingCard(self.probeCard)
        self.expandLayout.addWidget(group)

    def _probe(self):
        if self.worker is not None:
            return
        self.probeButton.setEnabled(False)
        self.worker = AgentProbeWorker(self)
        self.worker.result_ready.connect(self._probe_result)
        self.worker.finished.connect(self._probe_finished)
        self.worker.start()

    def _probe_result(self, connected, detail):
        if connected:
            InfoBar.success('已连接', detail[:180], duration=3000,
                            position=InfoBarPosition.BOTTOM, parent=self.window())
        else:
            InfoBar.error('未连接', detail[:180], duration=5000,
                          position=InfoBarPosition.BOTTOM, parent=self.window())

    def _probe_finished(self):
        self.probeButton.setEnabled(True)
        self.worker.deleteLater()
        self.worker = None

    def sync_from_config(self):
        pass

    def _save(self):
        self.settings_changed.emit()
