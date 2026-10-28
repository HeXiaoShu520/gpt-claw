"""正式桌宠的浮灵视图；由共享陪伴状态驱动，不另建模型会话。"""

import math

from PySide6.QtCore import QMetaObject, QPoint, QPointF, Qt, QUrl, Q_ARG, Q_RETURN_ARG
from PySide6.QtGui import QColor, QVector3D
from PySide6.QtQuick import QQuickItem
from PySide6.QtQuickWidgets import QQuickWidget

import config
from pet.spirit_model import SPIRIT_ACTIONS, SPIRIT_NAME


class SpiritView(QQuickWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setResizeMode(QQuickWidget.SizeRootObjectToView)
        self.setClearColor(QColor(0, 0, 0, 0))
        self.setAttribute(Qt.WA_TransparentForMouseEvents, True)
        source = config.RES_DIR / 'role' / SPIRIT_NAME / 'CharacterSpirit.qml'
        self.setSource(QUrl.fromLocalFile(str(source)))
        if self.status() != QQuickWidget.Ready or self.rootObject() is None:
            message = '; '.join(error.toString() for error in self.errors())
            self.deleteLater()
            raise RuntimeError(message or '浮灵视图未就绪')
        self.rootObject().setProperty('showBackdrop', False)

    def pose(self, pose):
        if pose not in SPIRIT_ACTIONS:
            return
        root = self.rootObject()
        if root.property('pose') == pose:
            QMetaObject.invokeMethod(root, 'restartAction')
        else:
            root.setProperty('pose', pose)

    def frame(self, clock, x, y):
        root = self.rootObject()
        root.setProperty('lookX', x)
        root.setProperty('lookY', -y)
        root.setProperty('clock', clock)

    def presentation(self, properties):
        root = self.rootObject()
        for name, value in properties.items():
            root.setProperty(name, value)

    def guide_direction(self, x, y):
        self.rootObject().setProperty('guideX', x)
        self.rootObject().setProperty('guideY', y)

    def ball_position(self):
        point = QMetaObject.invokeMethod(self.rootObject(), 'ballWorldPosition', Q_RETURN_ARG(QVector3D))
        return point.x(), point.y() - .32, point.z()

    def hit_target(self, global_point):
        root = self.rootObject()
        point = self.mapFromGlobal(global_point)
        if QMetaObject.invokeMethod(root, 'bubbleAt', Q_RETURN_ARG(bool),
                                   Q_ARG(float, point.x()), Q_ARG(float, point.y())):
            return 'bubble'
        unit_x, unit_y = self.width() / 4.35, self.height() / 4.35
        for name, rx, ry in (('ball', .23, .23), ('head', .69, .65)):
            if name == 'ball' and not root.property('ballVisible'):
                continue
            center = (QMetaObject.invokeMethod(root, 'ballAnchor', Q_RETURN_ARG(QVector3D))
                      if name == 'ball' else root.property('headPosition'))
            if center.z() > 0 and (((point.x() - center.x()) / (unit_x * rx)) ** 2
                                   + ((point.y() - center.y()) / (unit_y * ry)) ** 2 <= 1):
                return name
        return None

    def pop_bubble(self, global_point):
        point = self.mapFromGlobal(global_point)
        return QMetaObject.invokeMethod(self.rootObject(), 'popBubble', Q_RETURN_ARG(bool),
                                       Q_ARG(float, point.x()), Q_ARG(float, point.y()))

    def guide_cue(self, strength):
        self.rootObject().setProperty('guideStrength', strength)

    def guide_anchor(self):
        if self.status() != QQuickWidget.Ready:
            return None
        point = self.rootObject().property('guideHandPosition')
        if point is None or not all(math.isfinite(value) for value in (point.x(), point.y(), point.z())) or point.z() <= 0:
            return None
        return QPointF(self.mapToGlobal(QPoint())) + QPointF(point.x(), point.y())

    def support_anchor(self):
        """Local hand contact plane, independent of the window's desktop position."""
        point = QMetaObject.invokeMethod(self.rootObject(), 'supportAnchor', Q_RETURN_ARG(QVector3D))
        if point is None or not all(math.isfinite(v) for v in (point.x(), point.y(), point.z())) or point.z() <= 0:
            return None
        return QPointF(point.x(), point.y())
