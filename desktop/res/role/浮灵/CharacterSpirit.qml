import QtQuick
import QtQuick3D
import "assets"

Item {
    id: root
    width: 560; height: 580
    property string pose: "idle"
    property real clock: 0
    property real lookX: 0
    property real lookY: 0
    property real guideX: 1
    property real guideY: 0
    property real guideStrength: 1
    property real walkStrength: 1
    property real motionX: 0
    property real motionY: 0
    property bool effectsEnabled: true
    property string reactionCaption: ""
    onPoseChanged: reactionCaption = ""
    property real affection: 0
    property real touchResponse: 0
    property real touchSide: 1
    property real greeting: 0
    property string taskReaction: ""
    property real reactionProgress: 0
    property real yaw: 0
    property real lean: 0
    property bool ballVisible: false
    property bool trackingBall: false
    property real ballOpacity: 1
    property real ballX: 1.15
    property real ballHeight: 0
    property real ballDepth: .65
    property real ballRotation: 0
    property real ballGrip: 0
    readonly property vector3d ballTarget: Qt.vector3d(ballX,.32+ballHeight,ballDepth)
    property string expressionOverride: ""
    property real blinkOverride: -1
    // Ratios around the authored neutral eye; independent of body scale.
    property real eyeScale: 1
    property real eyeWidth: 1
    property real eyeHeight: 1
    property real irisScale: 1
    property bool automaticEyeExpressions: true
    property bool showBackdrop: true
    property bool transitionsEnabled: true
    property bool naturalMotionEnabled: true
    property real offsetX: 0
    property real offsetY: 0
    readonly property string activeClipName: spirit.activeClipName
    readonly property real transitionProgress: spirit.transitionProgress
    readonly property real gazeX: spirit.gazeX
    readonly property real gazeY: spirit.gazeY
    readonly property vector3d guideHandPosition: scene.mapFrom3DScene(spirit.guideHandScenePosition)
    readonly property vector3d headPosition: scene.mapFrom3DScene(spirit.headScenePosition)
    function ballAnchor(): vector3d {
        return scene.mapFrom3DScene(toyBall.scenePosition)
    }
    function ballWorldPosition(): vector3d { return toyBall.scenePosition }
    function handAnchor(): vector3d {
        return scene.mapFrom3DScene(ballX>=0?spirit.rightHandScenePosition:spirit.leftHandScenePosition)
    }
    function supportAnchor(): vector3d {
        return scene.mapFrom3DScene(spirit.supportScenePosition)
    }
    function bubbleAt(x: real, y: real): bool { return feedback.bubbleIndex(x, y) >= 0 }
    function popBubble(x: real, y: real): bool { return feedback.popBubble(x, y) }
    readonly property vector3d leftHandPosition: scene.mapFrom3DScene(spirit.leftHandScenePosition)
    readonly property vector3d rightHandPosition: scene.mapFrom3DScene(spirit.rightHandScenePosition)
    function restartAction() {
        spirit.transitionFrom=spirit.capturePose()
        spirit.transitionStart=clock
        spirit.clipStart=clock
        spirit.seekClip(pose,clock)
    }
    Rectangle {anchors.fill: parent; color: "#38343f"; visible: root.showBackdrop}
    View3D {
        id: scene
        anchors.fill: parent
        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            tonemapMode: SceneEnvironment.TonemapModeLinear
        }
        camera: OrthographicCamera {
            position: Qt.vector3d(0,1.94,7)
            clipNear: .01; clipFar: 100
            horizontalMagnification: root.width/4.35
            verticalMagnification: root.height/4.35
        }
        DirectionalLight {eulerRotation: Qt.vector3d(-30,-25,0); brightness: .7; ambientColor: "#74706a"}
        DirectionalLight {eulerRotation: Qt.vector3d(15,40,0); brightness: .27}
        Node {
            position: Qt.vector3d(root.offsetX,root.offsetY,0)
            eulerRotation: Qt.vector3d(0,root.yaw,root.lean)
            DreamSpiritRuntime {
                id: spirit
                pose: root.pose; clock: root.clock
                lookX: root.lookX; lookY: root.lookY
                guideX: root.guideX; guideY: root.guideY
                guideStrength: root.guideStrength
                walkStrength: root.walkStrength
                motionX: root.motionX; motionY: root.motionY
                affection: root.affection
                touchResponse: root.touchResponse
                touchSide: root.touchSide
                greeting: root.greeting
                trackingBall: root.ballVisible && root.trackingBall
                ballScenePosition: root.ballTarget
                taskReaction: root.taskReaction
                reactionProgress: root.reactionProgress
                transitionsEnabled: root.transitionsEnabled
                naturalMotionEnabled: root.naturalMotionEnabled
                expressionOverride: root.expressionOverride
                blinkOverride: root.blinkOverride
                eyeScale: root.eyeScale; eyeWidth: root.eyeWidth
                eyeHeight: root.eyeHeight; irisScale: root.irisScale
                automaticEyeExpressions: root.automaticEyeExpressions
            }
        }
        Node {
            id: toyBall
            visible: root.ballVisible
            // Use the final animated hand while held, without feeding it back into IK.
            position: {
                const hand=root.ballX>=0?spirit.rightHandScenePosition:spirit.leftHandScenePosition
                const held=hand.plus(Qt.vector3d(0,.18,0))
                return root.ballTarget.plus(held.minus(root.ballTarget).times(root.ballGrip))
            }
            eulerRotation.z: root.ballRotation
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(.0036,.0036,.0036)
                materials: PrincipledMaterial {baseColor: "#aa8cdd"; roughness: .36; opacity: root.ballOpacity}
            }
            Model {
                source: "#Sphere"
                position: Qt.vector3d(.07,.07,.135)
                scale: Qt.vector3d(.0014,.0014,.0006)
                materials: PrincipledMaterial {baseColor: "#fff0cf"; roughness: .45; opacity: root.ballOpacity}
            }
        }
    }
    SpiritFeedback {
        id: feedback
        anchors.fill: parent
        clock: root.clock
        pose: root.pose
        motionX: root.motionX; motionY: root.motionY
        headPosition: root.headPosition
        effectsEnabled: root.effectsEnabled
        reactionCaption: root.reactionCaption
    }
}
