import QtQuick
import QtQuick3D
import QtQuick.Window

Window {
    width: 400; height: 600
    visible: true
    title: "CharacterVRM Test"

    View3D {
        anchors.fill: parent
        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: "#1a1a2e"
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }
        PerspectiveCamera {
            position: Qt.vector3d(0, 140, 300)
            eulerRotation.x: -8
            clipNear: 1; clipFar: 5000
        }
        DirectionalLight { eulerRotation: Qt.vector3d(-40,20,0); brightness: 1.5 }
        DirectionalLight { eulerRotation: Qt.vector3d(30,-130,0); brightness: 0.5; color: "#aabbff" }
        Node {
            id: root3d
            scale: Qt.vector3d(85,85,85)
            Avatar_qt { id: avatar }
        }
    }
    property real sx: 0; property real ry: 0
    MouseArea {
        anchors.fill: parent
        onPressed: sx = mouseX
        onPositionChanged: if(pressed) root3d.eulerRotation.y = ry + (mouseX-sx)*0.5
        onReleased: ry = root3d.eulerRotation.y
    }
}
