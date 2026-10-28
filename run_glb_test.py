"""Quick viewer for GLB model in Qt Quick 3D."""
import sys
import os
from urllib.request import pathname2url

os.environ.setdefault("QSG_RHI_BACKEND", "d3d11")

from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl, QObject, Property, Signal
from PySide6.QtGui import QSurfaceFormat

app = QApplication(sys.argv)

fmt = QSurfaceFormat()
fmt.setSamples(4)
QSurfaceFormat.setDefaultFormat(fmt)

# 把GLB路径作为context property传进QML，避开编码问题
glb_abs = os.path.abspath("AvatarSample_A_qt.glb")
glb_url = QUrl.fromLocalFile(glb_abs)
print("GLB URL:", glb_url.toString())

engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty("glbUrl", glb_url)

qml_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_vrm_glb.qml")
engine.load(QUrl.fromLocalFile(qml_path))

if not engine.rootObjects():
    print("Failed to load QML")
    sys.exit(1)

sys.exit(app.exec())
