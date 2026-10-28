import QtQuick
import QtQuick3D
import QtQuick.Window

Window {
    width: 480; height: 720
    visible: true
    title: "VRM GLB Test"
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
            position: Qt.vector3d(0, 80, 350)
            eulerRotation.x: -5
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
            scale: Qt.vector3d(80, 80, 80)

            Model {
                source: glbUrl
                pickable: false
            }
        }
    }

    property real _sx: 0
    property real _ry: 0
    MouseArea {
        anchors.fill: parent
        onPressed: _sx = mouseX
        onPositionChanged: if(pressed) root3d.eulerRotation.y = _ry + (mouseX-_sx)*0.4
        onReleased: _ry = root3d.eulerRotation.y
        onWheel: cam.position.z = Math.max(50, Math.min(800, cam.position.z - wheel.angleDelta.y*0.25))
    }
}
