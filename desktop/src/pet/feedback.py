"""Short local movement sounds. Assets are original synthesized PCM tones."""
import time

from PySide6.QtCore import QObject, QUrl
from PySide6.QtMultimedia import QSoundEffect

import config


class PetFeedback(QObject):
    LEVELS = {'step': .25, 'grab': .6, 'land': .65, 'dizzy': .45}

    def __init__(self, owner):
        super().__init__(owner)
        self.owner = owner
        self._last_play = 0.0
        self._last_caption = -30.0
        self._sounds = {}
        for name in self.LEVELS:
            sound = QSoundEffect(self)
            sound.setSource(QUrl.fromLocalFile(str(config.RES_DIR / 'sounds' / 'spirit' / f'{name}.wav')))
            self._sounds[name] = sound

    def play(self, name):
        now = time.monotonic()
        if (name not in self._sounds or self.owner.companion.mode in ('quiet', 'rest')
                or self.owner._voice_chat_active or not self.owner.isVisible()):
            return
        if name == 'dizzy' and now - self._last_caption >= 30:
            self.owner.character_view.presentation({'reactionCaption': '慢一点……月亮都转起来了。'})
            self._last_caption = now
        if not config.app_config['pet_sounds'] or now - self._last_play < .18:
            return
        self.stop()
        sound = self._sounds[name]
        sound.setVolume(config.app_config['volume'] * .35 * self.LEVELS[name])
        sound.play()
        self._last_play = now

    def stop(self):
        for sound in self._sounds.values():
            sound.stop()
