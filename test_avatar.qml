import QtQuick
import QtQuick3D
import QtQuick.Window

Window {
    width: 480; height: 720
    visible: true
    title: "Avatar Test"
    color: "#1a1a2e"

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: "#1a1a2e"
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
            id: cam
            position: Qt.vector3d(0, 140, 300)
            eulerRotation.x: -8
            clipNear: 1
            clipFar: 5000
        }

        DirectionalLight {
            eulerRotation.x: -40
            eulerRotation.y: 20
            brightness: 1.5
        }
        DirectionalLight {
            eulerRotation.x: 30
            eulerRotation.y: -130
            brightness: 0.5
            color: "#aabbff"
        }

        Node {
            id: root3d
            scale: Qt.vector3d(100, 100, 100)
            Loader3D {
                source: "file:///C:/Users/13208/AppData/Local/Temp/avatar_balsam/Avatar_qt.qml"
            }
        }
    }

    property real _sx: 0
    property real _ry: 0
    MouseArea {
        anchors.fill: parent
        onPressed: _sx = mouseX
        onPositionChanged: if(pressed) root3d.eulerRotation.y = _ry + (mouseX-_sx)*0.5
        onReleased: _ry = root3d.eulerRotation.y
        onWheel: cam.position.z = Math.max(50, Math.min(900, cam.position.z - wheel.angleDelta.y*0.3))
    }
}
