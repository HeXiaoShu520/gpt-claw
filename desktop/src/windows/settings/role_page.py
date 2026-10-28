# coding:utf-8
"""Desktop pet appearance and animation settings."""

from PySide6.QtCore import Qt, Signal
from PySide6.QtGui import QIcon, QPixmap
from PySide6.QtWidgets import QApplication, QLabel
from qfluentwidgets import InfoBar, InfoBarPosition, SettingCard, SettingCardGroup
from qfluentwidgets import FluentIcon as FIF

import config
from pet.spirit_model import SPIRIT_NAME
from base_page import MiniPetScrollPage
from widgets.setting_cards import AvatarPathSettingCard, LineEditSettingCard, RangeSettingCard


def _icon(name):
    """加载 icons/system 目录下的内置图标。"""
    return QIcon(str(config.RES_DIR / 'icons' / 'system' / name))


class RolePage(MiniPetScrollPage):
    """Maintain the visual pet; model personality belongs to gpt-claw."""

    settings_changed = Signal()

    def __init__(self, parent=None):
        """读取当前配置并搭建"我的设置"和"宠物设置"两个分组。"""
        super().__init__('角色设定', parent, save_callback=lambda: self._save())

        self.userGroup = SettingCardGroup('我的设置', self.scrollWidget)
        self.userAvatarCard = AvatarPathSettingCard(FIF.PEOPLE, '我的头像', '聊天窗口中用户消息显示的头像', self.userGroup)
        self.userAvatarCard.setText(config.app_config.get('user_avatar', ''))

        self.petGroup = SettingCardGroup('宠物设置', self.scrollWidget)
        self.petCard = SettingCard(_icon('homestar.svg'), '浮灵', '唯一的三维角色，使用浮灵动作与指路', self.petGroup)
        self.petPreview = QLabel(self.petCard)
        self.petPreview.setFixedSize(42, 42)
        self.petPreview.setAlignment(Qt.AlignCenter)
        self.petPreview.setStyleSheet('QLabel{border:1px solid #dcdfe6;border-radius:8px;background:#fff;}')
        self.petCard.hBoxLayout.insertWidget(self.petCard.hBoxLayout.count() - 1, self.petPreview, 0, Qt.AlignRight)
        self._update_pet_preview()
        self.petNameCard = LineEditSettingCard(_icon('character.svg'), '宠物名字', '回复卡片、聊天窗口和语音通话中显示的名字', placeholder='例如：浮灵', parent=self.petGroup)
        self.petNameCard.setText(config.app_config.get('pet_name') or SPIRIT_NAME)
        self.petAvatarCard = AvatarPathSettingCard(_icon('character.svg'), '宠物头像', '聊天和语音聊天中显示的宠物头像', self.petGroup)
        self.petAvatarCard.setText(config.app_config.get('pet_avatar', ''))

        self.userGroup.addSettingCard(self.userAvatarCard)
        self.petGroup.addSettingCard(self.petNameCard)
        self.petGroup.addSettingCard(self.petAvatarCard)
        self.petGroup.addSettingCard(self.petCard)
        self.scaleCard = RangeSettingCard(50, 200, 0.01, _icon('homestar.svg'), '宠物大小', '宠物窗口的缩放比例，保存后立即生效', self.petGroup)
        self.scaleCard.setValue(round(float(config.app_config.get('scale', 1.0)) * 100))
        self.petGroup.addSettingCard(self.scaleCard)
        self.expandLayout.addWidget(self.userGroup)
        self.expandLayout.addWidget(self.petGroup)

    def _update_pet_preview(self):
        """在宠物模型卡片右侧刷新 42px 预览图，加载失败显示问号。"""
        path = config.spirit_image_path()
        pixmap = QPixmap(str(path))
        if pixmap.isNull():
            self.petPreview.setPixmap(QPixmap())
            self.petPreview.setText('?')
            return
        self.petPreview.setText('')
        screen = QApplication.primaryScreen()
        dpr = screen.devicePixelRatio() if screen else 1.0
        pm = pixmap.scaled(int(38 * dpr), int(38 * dpr), Qt.KeepAspectRatio, Qt.SmoothTransformation)
        pm.setDevicePixelRatio(dpr)
        self.petPreview.setPixmap(pm)

    def _save(self):
        """保存昵称、头像和大小，模型固定为浮灵。"""
        config.app_config.update({
            'pet_name': self.petNameCard.text(),
            'pet_avatar': self.petAvatarCard.text(),
            'user_avatar': self.userAvatarCard.text(),
            'scale': round(float(self.scaleCard.value()), 2),
        })
        config.save_app_config()
        InfoBar.success('保存成功', '角色设置已保存', duration=2000, position=InfoBarPosition.BOTTOM, parent=self.window())
        self.settings_changed.emit()
