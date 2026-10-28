import QtQuick
import QtQuick3D

import QtQuick.Timeline

Node {
    id: root
    objectName: "Root"

    // Resources
    PrincipledMaterial {
        id: pearl_ivory___soft_satin_material
        objectName: "Pearl ivory • soft satin"
        baseColor: "#fff1eae2"
        roughness: 0.4699999988079071
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: curious_morphtarget
        objectName: "Curious"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: thinking_morphtarget
        objectName: "Thinking"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: happy_morphtarget
        objectName: "Happy"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: confused_morphtarget
        objectName: "Confused"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin13
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: curious_morphtarget14
        objectName: "Curious"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: thinking_morphtarget15
        objectName: "Thinking"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: happy_morphtarget16
        objectName: "Happy"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: confused_morphtarget17
        objectName: "Confused"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    PrincipledMaterial {
        id: eye_catchlight_material
        objectName: "Eye catchlight"
        baseColor: "#fffffaef"
        roughness: 0.1899999976158142
        emissiveFactor: Qt.vector3d(0.35, 0.336, 0.301)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin21
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin31
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget32
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget33
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget34
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget35
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget36
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget37
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget38
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin41
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget42
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget43
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget44
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget45
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget46
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget47
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget48
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin51
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget52
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget53
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget54
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget55
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget56
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget57
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget58
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    PrincipledMaterial {
        id: plum_lashes_and_pupils_material
        objectName: "Plum lashes and pupils"
        baseColor: "#ff2a192c"
        roughness: 0.33000001311302185
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin62
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget63
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget64
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget65
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget66
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget67
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget68
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget69
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin72
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget73
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget74
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget75
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget76
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget77
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget78
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget79
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    PrincipledMaterial {
        id: warm_eye_white_material
        objectName: "Warm eye white"
        baseColor: "#fffaead1"
        roughness: 0.3100000023841858
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin83
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget84
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget85
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget86
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget87
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget88
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget89
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget90
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin93
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget94
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget95
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget96
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget97
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget98
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget99
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget100
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    PrincipledMaterial {
        id: iris___dark_honey_to_amber_gold_material
        objectName: "Iris • dark honey to amber gold"
        roughness: 0.27000001072883606
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin104
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget105
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget106
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget107
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget108
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget109
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget110
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget111
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin114
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget115
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget116
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget117
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget118
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget119
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget120
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget121
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin124
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget125
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget126
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget127
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget128
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget129
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget130
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget131
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin134
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget135
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget136
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget137
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget138
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget139
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget140
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget141
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin144
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    PrincipledMaterial {
        id: amethyst_facet_0_material
        objectName: "Amethyst facet 0"
        baseColor: "#ffaf6fdf"
        metalness: 0.15000000596046448
        roughness: 0.2800000011920929
        emissiveFactor: Qt.vector3d(0.0129, 0.0048, 0.0222)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: amethyst_facet_1_material
        objectName: "Amethyst facet 1"
        baseColor: "#ffdaa9fc"
        metalness: 0.15000000596046448
        roughness: 0.2800000011920929
        emissiveFactor: Qt.vector3d(0.021, 0.012, 0.0291)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: amethyst_facet_2_material
        objectName: "Amethyst facet 2"
        baseColor: "#ff9250c0"
        metalness: 0.15000000596046448
        roughness: 0.2800000011920929
        emissiveFactor: Qt.vector3d(0.0087, 0.0024, 0.0159)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: amethyst_facet_3_material
        objectName: "Amethyst facet 3"
        baseColor: "#ffc289eb"
        metalness: 0.15000000596046448
        roughness: 0.2800000011920929
        emissiveFactor: Qt.vector3d(0.0162, 0.0075, 0.0249)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin155
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    PrincipledMaterial {
        id: lilac_crescent_material
        objectName: "Lilac crescent"
        baseColor: "#ffc395f1"
        metalness: 0.10000000149011612
        roughness: 0.30000001192092896
        emissiveFactor: Qt.vector3d(0.0715, 0.039, 0.1144)
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin159
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    PrincipledMaterial {
        id: velvet_plum_material
        objectName: "Velvet plum"
        baseColor: "#ff563863"
        roughness: 0.5699999928474426
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin163
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    Skin {
        id: skin166
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    PrincipledMaterial {
        id: ribbon___ivory___lavender___pale_peach_material
        objectName: "Ribbon • ivory / lavender / pale peach"
        roughness: 0.4300000071525574
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin170
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    Skin {
        id: skin173
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    PrincipledMaterial {
        id: smile_warm_edge_material
        objectName: "Smile warm edge"
        baseColor: "#ffcd9099"
        roughness: 0.5799999833106995
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin177
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: happy_morphtarget178
        objectName: "Happy"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: confused_morphtarget179
        objectName: "Confused"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: mouthOpen_morphtarget
        objectName: "MouthOpen"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin183
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget184
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget185
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget186
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget187
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget188
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget189
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget190
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    Skin {
        id: skin193
        joints: [
            root201,
            body,
            arm_L,
            forearm_L,
            arm_R,
            forearm_R,
            head,
            moon,
            ribbon_L_0,
            ribbon_L_1,
            ribbon_L_2,
            ribbon_R_0,
            ribbon_R_1,
            ribbon_R_2,
            tail
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, -0.441097, -0.896773, 0.60511, -0.896773, -0.409954, 0.166543, 0.190629, -0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, -0.298384, -0.950948, 0.352672, -0.950948, -0.26233, 0.163956, -0.414318, -0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(0.0351009, 0.441097, 0.896773, -0.60511, 0.896773, -0.409954, 0.166543, 0.190629, 0.441097, 0.798356, -0.409954, -1.24624, 0, 0, 0, 1),
            Qt.matrix4x4(-0.0816437, 0.298384, 0.950948, -0.352672, 0.950948, -0.26233, 0.163956, -0.414318, 0.298384, 0.917687, -0.26233, -1.28961, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -1.65, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0, 0, 1, 0, -3.15, 0, 0, 1, 0, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, -0.178692, -0.208966, 1.25241, -0.208965, -0.96884, -0.132979, 1.92381, -0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, -0.496421, -0.531839, 1.40972, -0.531839, -0.841045, 0.0989479, 0.909441, -0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, -0.35708, -0.242756, 1.64932, -0.242756, -0.884319, 0.398812, 0.639308, -0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(0.961461, 0.178692, 0.208966, -1.25241, 0.208965, -0.96884, -0.132979, 1.92381, 0.178689, 0.171519, -0.968841, -0.771573, 0, 0, 0, 1),
            Qt.matrix4x4(0.68609, 0.496421, 0.531839, -1.40972, 0.531839, -0.841045, 0.0989479, 0.909441, 0.496418, 0.214964, -0.841047, -1.14114, 0, 0, 0, 1),
            Qt.matrix4x4(0.90198, 0.35708, 0.242756, -1.64932, 0.242756, -0.884319, 0.398812, 0.639308, 0.357078, -0.30079, -0.88432, -0.413213, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, -8.74228e-08, 0, 0, -1, 0, 0.95, -8.74228e-08, 0, -1, 0, 0, 0, 0, 1)
        ]
    }
    MorphTarget {
        id: blink_morphtarget194
        objectName: "Blink"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeSmile_morphtarget195
        objectName: "EyeSmile"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeWidth_morphtarget196
        objectName: "EyeWidth"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: eyeHeight_morphtarget197
        objectName: "EyeHeight"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: irisScale_morphtarget198
        objectName: "IrisScale"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeX_morphtarget199
        objectName: "GazeX"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }
    MorphTarget {
        id: gazeY_morphtarget200
        objectName: "GazeY"
        attributes: MorphTarget.Position | MorphTarget.Normal
    }

    // Nodes:
    Node {
        id: dreamSpirit_ROOT
        objectName: "DreamSpirit_ROOT"
        Node {
            id: ds_Rig
            objectName: "DS_Rig"
            Model {
                id: brow_L
                objectName: "Brow_L"
                source: "meshes/brow_L_mesh.mesh"
                skin: skin
                materials: [
                    pearl_ivory___soft_satin_material
                ]
                morphTargets: [
                    curious_morphtarget,
                    thinking_morphtarget,
                    happy_morphtarget,
                    confused_morphtarget
                ]
            }
            Model {
                id: brow_R
                objectName: "Brow_R"
                source: "meshes/brow_R_mesh.mesh"
                skin: skin13
                materials: [
                    pearl_ivory___soft_satin_material
                ]
                morphTargets: [
                    curious_morphtarget14,
                    thinking_morphtarget15,
                    happy_morphtarget16,
                    confused_morphtarget17
                ]
            }
            Model {
                id: catchlight_L
                objectName: "Catchlight_L"
                source: "meshes/catchlight_L_runtime_mesh.mesh"
                skin: skin21
                materials: [
                    eye_catchlight_material
                ]
                morphTargets: [
                    blink_morphtarget,
                    eyeSmile_morphtarget,
                    eyeWidth_morphtarget,
                    eyeHeight_morphtarget,
                    irisScale_morphtarget,
                    gazeX_morphtarget,
                    gazeY_morphtarget
                ]
            }
            Model {
                id: catchlight_R
                objectName: "Catchlight_R"
                source: "meshes/catchlight_R_runtime_mesh.mesh"
                skin: skin31
                materials: [
                    eye_catchlight_material
                ]
                morphTargets: [
                    blink_morphtarget32,
                    eyeSmile_morphtarget33,
                    eyeWidth_morphtarget34,
                    eyeHeight_morphtarget35,
                    irisScale_morphtarget36,
                    gazeX_morphtarget37,
                    gazeY_morphtarget38
                ]
            }
            Model {
                id: catchlightSmall_L
                objectName: "CatchlightSmall_L"
                source: "meshes/catchlightSmall_L_runtime_mesh.mesh"
                skin: skin41
                materials: [
                    eye_catchlight_material
                ]
                morphTargets: [
                    blink_morphtarget42,
                    eyeSmile_morphtarget43,
                    eyeWidth_morphtarget44,
                    eyeHeight_morphtarget45,
                    irisScale_morphtarget46,
                    gazeX_morphtarget47,
                    gazeY_morphtarget48
                ]
            }
            Model {
                id: catchlightSmall_R
                objectName: "CatchlightSmall_R"
                source: "meshes/catchlightSmall_R_runtime_mesh.mesh"
                skin: skin51
                materials: [
                    eye_catchlight_material
                ]
                morphTargets: [
                    blink_morphtarget52,
                    eyeSmile_morphtarget53,
                    eyeWidth_morphtarget54,
                    eyeHeight_morphtarget55,
                    irisScale_morphtarget56,
                    gazeX_morphtarget57,
                    gazeY_morphtarget58
                ]
            }
            Model {
                id: eyeSocket_L
                objectName: "EyeSocket_L"
                source: "meshes/eyeSocket_L_runtime_mesh.mesh"
                skin: skin62
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget63,
                    eyeSmile_morphtarget64,
                    eyeWidth_morphtarget65,
                    eyeHeight_morphtarget66,
                    irisScale_morphtarget67,
                    gazeX_morphtarget68,
                    gazeY_morphtarget69
                ]
            }
            Model {
                id: eyeSocket_R
                objectName: "EyeSocket_R"
                source: "meshes/eyeSocket_R_runtime_mesh.mesh"
                skin: skin72
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget73,
                    eyeSmile_morphtarget74,
                    eyeWidth_morphtarget75,
                    eyeHeight_morphtarget76,
                    irisScale_morphtarget77,
                    gazeX_morphtarget78,
                    gazeY_morphtarget79
                ]
            }
            Model {
                id: eyeWhite_L
                objectName: "EyeWhite_L"
                source: "meshes/eyeWhite_L_runtime_mesh.mesh"
                skin: skin83
                materials: [
                    warm_eye_white_material
                ]
                morphTargets: [
                    blink_morphtarget84,
                    eyeSmile_morphtarget85,
                    eyeWidth_morphtarget86,
                    eyeHeight_morphtarget87,
                    irisScale_morphtarget88,
                    gazeX_morphtarget89,
                    gazeY_morphtarget90
                ]
            }
            Model {
                id: eyeWhite_R
                objectName: "EyeWhite_R"
                source: "meshes/eyeWhite_R_runtime_mesh.mesh"
                skin: skin93
                materials: [
                    warm_eye_white_material
                ]
                morphTargets: [
                    blink_morphtarget94,
                    eyeSmile_morphtarget95,
                    eyeWidth_morphtarget96,
                    eyeHeight_morphtarget97,
                    irisScale_morphtarget98,
                    gazeX_morphtarget99,
                    gazeY_morphtarget100
                ]
            }
            Model {
                id: iris_L
                objectName: "Iris_L"
                source: "meshes/iris_L_runtime_mesh.mesh"
                skin: skin104
                materials: [
                    iris___dark_honey_to_amber_gold_material
                ]
                morphTargets: [
                    blink_morphtarget105,
                    eyeSmile_morphtarget106,
                    eyeWidth_morphtarget107,
                    eyeHeight_morphtarget108,
                    irisScale_morphtarget109,
                    gazeX_morphtarget110,
                    gazeY_morphtarget111
                ]
            }
            Model {
                id: iris_R
                objectName: "Iris_R"
                source: "meshes/iris_R_runtime_mesh.mesh"
                skin: skin114
                materials: [
                    iris___dark_honey_to_amber_gold_material
                ]
                morphTargets: [
                    blink_morphtarget115,
                    eyeSmile_morphtarget116,
                    eyeWidth_morphtarget117,
                    eyeHeight_morphtarget118,
                    irisScale_morphtarget119,
                    gazeX_morphtarget120,
                    gazeY_morphtarget121
                ]
            }
            Model {
                id: pupil_L
                objectName: "Pupil_L"
                source: "meshes/pupil_L_runtime_mesh.mesh"
                skin: skin124
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget125,
                    eyeSmile_morphtarget126,
                    eyeWidth_morphtarget127,
                    eyeHeight_morphtarget128,
                    irisScale_morphtarget129,
                    gazeX_morphtarget130,
                    gazeY_morphtarget131
                ]
            }
            Model {
                id: pupil_R
                objectName: "Pupil_R"
                source: "meshes/pupil_R_runtime_mesh.mesh"
                skin: skin134
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget135,
                    eyeSmile_morphtarget136,
                    eyeWidth_morphtarget137,
                    eyeHeight_morphtarget138,
                    irisScale_morphtarget139,
                    gazeX_morphtarget140,
                    gazeY_morphtarget141
                ]
            }
            Model {
                id: spirit_Body
                objectName: "Spirit_Body"
                source: "meshes/spirit_Body_joint_rings_mesh.mesh"
                skin: skin144
                materials: [
                    pearl_ivory___soft_satin_material
                ]
            }
            Model {
                id: spirit_ChestCrystal
                objectName: "Spirit_ChestCrystal"
                source: "meshes/spirit_ChestCrystal_mesh.mesh"
                skin: skin155
                materials: [
                    amethyst_facet_0_material,
                    amethyst_facet_1_material,
                    amethyst_facet_2_material,
                    amethyst_facet_3_material
                ]
            }
            Model {
                id: spirit_Crescent
                objectName: "Spirit_Crescent"
                source: "meshes/crescent_rounded_mesh_mesh.mesh"
                skin: skin159
                materials: [
                    lilac_crescent_material
                ]
            }
            Model {
                id: spirit_Face
                objectName: "Spirit_Face"
                source: "meshes/spirit_Face_mesh.mesh"
                skin: skin163
                materials: [
                    velvet_plum_material
                ]
            }
            Model {
                id: spirit_Hood
                objectName: "Spirit_Hood"
                source: "meshes/spirit_Hood_mesh.mesh"
                skin: skin166
                materials: [
                    pearl_ivory___soft_satin_material
                ]
            }
            Model {
                id: spirit_Ribbon_L
                objectName: "Spirit_Ribbon_L"
                source: "meshes/spirit_Ribbon_L_mesh.mesh"
                skin: skin170
                materials: [
                    ribbon___ivory___lavender___pale_peach_material
                ]
            }
            Model {
                id: spirit_Ribbon_R
                objectName: "Spirit_Ribbon_R"
                source: "meshes/spirit_Ribbon_R_mesh.mesh"
                skin: skin173
                materials: [
                    ribbon___ivory___lavender___pale_peach_material
                ]
            }
            Model {
                id: spirit_Smile
                objectName: "Spirit_Smile"
                source: "meshes/spirit_Smile_mesh.mesh"
                skin: skin177
                materials: [
                    smile_warm_edge_material
                ]
                morphTargets: [
                    happy_morphtarget178,
                    confused_morphtarget179,
                    mouthOpen_morphtarget
                ]
            }
            Model {
                id: upperLid_L
                objectName: "UpperLid_L"
                source: "meshes/upperLid_L_mesh.mesh"
                skin: skin183
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget184,
                    eyeSmile_morphtarget185,
                    eyeWidth_morphtarget186,
                    eyeHeight_morphtarget187,
                    irisScale_morphtarget188,
                    gazeX_morphtarget189,
                    gazeY_morphtarget190
                ]
            }
            Model {
                id: upperLid_R
                objectName: "UpperLid_R"
                source: "meshes/upperLid_R_mesh.mesh"
                skin: skin193
                materials: [
                    plum_lashes_and_pupils_material
                ]
                morphTargets: [
                    blink_morphtarget194,
                    eyeSmile_morphtarget195,
                    eyeWidth_morphtarget196,
                    eyeHeight_morphtarget197,
                    irisScale_morphtarget198,
                    gazeX_morphtarget199,
                    gazeY_morphtarget200
                ]
            }
            Node {
                id: root201
                objectName: "Root"
                Node {
                    id: body
                    objectName: "Body"
                    position: Qt.vector3d(0, 1.15, 0)
                    Node {
                        id: arm_L
                        objectName: "Arm.L"
                        position: Qt.vector3d(-0.4, 0.19, 0)
                        rotation: Qt.quaternion(-0.231945, 0.680993, -0.491146, -0.491146)
                        scale: Qt.vector3d(1, 1, 1)
                        Node {
                            id: forearm_L
                            objectName: "Forearm.L"
                            position: Qt.vector3d(-4.65661e-08, 0.390288, 1.09896e-07)
                            rotation: Qt.quaternion(0.992594, 0.0743326, -0.092599, 0.0256558)
                            scale: Qt.vector3d(1, 1, 1)
                        }
                    }
                    Node {
                        id: arm_R
                        objectName: "Arm.R"
                        position: Qt.vector3d(0.4, 0.19, 0)
                        rotation: Qt.quaternion(-0.231945, 0.680993, 0.491146, 0.491146)
                        scale: Qt.vector3d(1, 1, 1)
                        Node {
                            id: forearm_R
                            objectName: "Forearm.R"
                            position: Qt.vector3d(4.65661e-08, 0.390288, 1.09896e-07)
                            rotation: Qt.quaternion(0.992594, 0.0743326, 0.092599, -0.0256558)
                            scale: Qt.vector3d(1, 1, 1)
                        }
                    }
                    Node {
                        id: head
                        objectName: "Head"
                        position: Qt.vector3d(0, 0.5, 0)
                        scale: Qt.vector3d(1, 1, 1)
                        Node {
                            id: moon
                            objectName: "Moon"
                            position: Qt.vector3d(0, 1.5, 0)
                        }
                        Node {
                            id: ribbon_L_0
                            objectName: "Ribbon.L.0"
                            position: Qt.vector3d(-0.94, 0.57, -0.23)
                            rotation: Qt.quaternion(-0.0771027, 0.987312, -0.0981597, -0.098159)
                            scale: Qt.vector3d(0.999997, 1, 0.999999)
                            Node {
                                id: ribbon_L_1
                                objectName: "Ribbon.L.1"
                                position: Qt.vector3d(-2.98023e-08, 0.526403, 0)
                                rotation: Qt.quaternion(0.963421, -0.039545, -0.168014, 0.205008)
                                scale: Qt.vector3d(1, 1, 1)
                                Node {
                                    id: ribbon_L_2
                                    objectName: "Ribbon.L.2"
                                    position: Qt.vector3d(-1.2666e-07, 0.808517, -2.98023e-08)
                                    rotation: Qt.quaternion(0.960973, -0.197818, 0.180805, -0.0686143)
                                    scale: Qt.vector3d(1, 1, 1)
                                }
                            }
                        }
                        Node {
                            id: ribbon_R_0
                            objectName: "Ribbon.R.0"
                            position: Qt.vector3d(0.94, 0.57, -0.23)
                            rotation: Qt.quaternion(-0.0771027, 0.987312, 0.0981597, 0.098159)
                            scale: Qt.vector3d(0.999997, 1, 0.999999)
                            Node {
                                id: ribbon_R_1
                                objectName: "Ribbon.R.1"
                                position: Qt.vector3d(2.98023e-08, 0.526403, 0)
                                rotation: Qt.quaternion(0.963421, -0.039545, 0.168014, -0.205008)
                                scale: Qt.vector3d(1, 1, 1)
                                Node {
                                    id: ribbon_R_2
                                    objectName: "Ribbon.R.2"
                                    position: Qt.vector3d(1.2666e-07, 0.808517, -2.98023e-08)
                                    rotation: Qt.quaternion(0.960973, -0.197818, -0.180805, 0.0686143)
                                    scale: Qt.vector3d(1, 1, 1)
                                }
                            }
                        }
                    }
                    Node {
                        id: tail
                        objectName: "Tail"
                        position: Qt.vector3d(0, -0.2, 0)
                        rotation: Qt.quaternion(0, 1, 0, -4.37114e-08)
                    }
                }
            }
        }
    }

    // Animations:
    Timeline {
        id: approval_timeline
        objectName: "approval"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_0.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_0.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(5.27457e-08, 0.390289, -5.56632e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_0.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.996195, 0, 0, 0.0871557)
            }
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_0.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-5.27457e-08, 0.390289, -5.56632e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(3.31915e-08, 0.526403, -1.99395e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.55842e-07, 0.808518, 1.9869e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-8.39256e-08, 0.526403, 9.26924e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_0.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-9.9664e-08, 0.808518, 2.31926e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_0.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_0.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_0.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_0.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_0.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_0.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_0.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_0.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_0.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_0.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_0.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_0.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_0.qad"
        }
    }
    Timeline {
        id: drag_timeline
        objectName: "drag"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 3034
            from: 0
            to: 3034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_1.qad"
        }
        KeyframeGroup {
            target: root201
            property: "rotation"
            keyframeSource: "animations/root201_rotation_1.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_1.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-4.95262e-09, 0.390288, 2.20945e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_1.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_1.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_1.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(4.95262e-09, 0.390288, 2.20945e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_1.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_1.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_1.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_1.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_1.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_1.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_1.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_1.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_1.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_1.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_1.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_1.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_1.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_1.qad"
        }
    }
    Timeline {
        id: fall_timeline
        objectName: "fall"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 1034
            from: 0
            to: 1034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_2.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            keyframeSource: "animations/body_rotation_2.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_2.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_2.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_2.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_2.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_2.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_2.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_2.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_2.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_2.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_2.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_2.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_2.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_2.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_2.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_2.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_2.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_2.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_2.qad"
        }
    }
    Timeline {
        id: groom_timeline
        objectName: "groom"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 3034
            from: 0
            to: 3034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_3.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_3.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_3.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_3.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_3.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_3.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_3.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_3.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_3.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_3.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_3.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_3.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_3.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_3.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_3.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_3.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_3.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_3.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_3.qad"
        }
    }
    Timeline {
        id: guide_timeline
        objectName: "guide"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 3034
            from: 0
            to: 3034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_4.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_4.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.1946e-07, 0.390288, -6.6882e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_4.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.990268, 0, -0.139173, 0)
            }
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.114074, 0.751313, 0.0660861, 0.646644)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(3.73885e-08, 0.390288, -5.54811e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.367586, 0.475925, 0.478245, -0.640045)
            }
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_4.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.23763e-08, 0.526403, -3.52615e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_4.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-5.89961e-08, 0.808518, 5.98044e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_4.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_4.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(5.54207e-08, 0.526403, 5.06355e-09)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_4.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(6.1355e-09, 0.808518, 4.97029e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_4.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_4.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_4.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_4.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_4.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_4.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_4.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_4.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_4.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_4.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_4.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_4.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_4.qad"
        }
    }
    Timeline {
        id: idle_timeline
        objectName: "idle"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_5.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_5.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_5.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_5.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_5.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_5.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_5.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_5.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_5.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_5.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_5.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_5.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_5.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_5.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_5.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_5.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_5.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_5.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_5.qad"
        }
    }
    Timeline {
        id: listening_timeline
        objectName: "listening"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_6.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.999391, -0.0348995, 0, 0)
            }
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_6.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.08738e-09, 0.390288, 9.14431e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_6.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_6.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.0264093, -0.799638, -0.0995668, -0.591581)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.99599e-08, 0.390288, 3.28123e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.609043, 0.562304, 0.229253, -0.510219)
            }
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_6.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(4.04714e-08, 0.526403, 8.44712e-09)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_6.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(9.02211e-08, 0.808518, -9.2412e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_6.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_6.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.10251e-07, 0.526403, 1.02127e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_6.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-6.94694e-08, 0.808518, 6.30347e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_6.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_6.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_6.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_6.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_6.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_6.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_6.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_6.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_6.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_6.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_6.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_6.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_6.qad"
        }
    }
    Timeline {
        id: look_timeline
        objectName: "look"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_7.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            keyframeSource: "animations/body_rotation_7.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.0259245, -0.771604, 0.196062, 0.604578)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.85497e-08, 0.390288, -4.33367e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.523583, 0.670196, -0.20854, 0.482918)
            }
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_7.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.0259245, -0.771604, -0.196062, -0.604578)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.85497e-08, 0.390288, -4.33367e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.523583, 0.670196, 0.20854, -0.482918)
            }
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_7.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_7.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_7.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_7.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_7.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_7.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_7.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_7.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_7.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_7.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_7.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_7.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_7.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_7.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_7.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_7.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_7.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_7.qad"
        }
    }
    Timeline {
        id: play_timeline
        objectName: "play"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_8.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_8.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.09132e-07, 0.390288, 5.9476e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_8.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_8.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_8.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.09132e-07, 0.390288, 5.9476e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_8.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_8.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_8.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_8.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_8.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_8.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_8.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_8.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_8.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_8.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_8.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_8.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_8.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_8.qad"
        }
    }
    Timeline {
        id: rest_timeline
        objectName: "rest"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_9.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.997564, 0, 0, -0.0697565)
            }
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_9.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-7.08379e-09, 0.390288, -9.03677e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_9.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_9.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_9.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-4.27866e-10, 0.390288, 2.5408e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(6.58244e-08, 0.526403, -1.32763e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-4.72357e-08, 0.808518, -1.01115e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(5.94424e-08, 0.526403, 9.20091e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_9.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.7762e-07, 0.808518, -1.31087e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_9.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.275637, -0.961262, -1.3564e-08, 4.25341e-08)
            }
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_9.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_9.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_9.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_9.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_9.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_9.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_9.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_9.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_9.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_9.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_9.qad"
        }
    }
    Timeline {
        id: sit_timeline
        objectName: "sit"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_10.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.00869219, -0.809618, 0.0255258, 0.586338)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.58086e-09, 0.390289, -1.24467e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.503365, 0.473525, -0.339548, 0.638048)
            }
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_10.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.00869219, -0.809618, -0.0255258, -0.586338)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.58086e-09, 0.390289, -1.24467e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.503365, 0.473525, 0.339548, -0.638048)
            }
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_10.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.22851e-07, 0.526403, -4.25198e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_10.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.17225e-08, 0.808518, -4.6603e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_10.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_10.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.22851e-07, 0.526403, -4.25198e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_10.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.17225e-08, 0.808518, -4.6603e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_10.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.515038, -0.857167, -2.2513e-08, 3.7468e-08)
            }
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_10.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_10.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_10.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_10.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_10.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_10.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_10.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_10.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_10.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_10.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_10.qad"
        }
    }
    Timeline {
        id: speaking_timeline
        objectName: "speaking"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_11.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_11.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(8.59479e-08, 0.390288, 2.52995e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_11.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_11.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_11.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.75153e-08, 0.390288, 1.11308e-07)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_11.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.42841e-07, 0.808518, 3.9415e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_11.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_11.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_11.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_11.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_11.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_11.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_11.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_11.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_11.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_11.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_11.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_11.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_11.qad"
        }
    }
    Timeline {
        id: stretch_timeline
        objectName: "stretch"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 3034
            from: 0
            to: 3034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_12.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            keyframeSource: "animations/body_rotation_12.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_12.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_12.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_12.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_12.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_12.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_12.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_12.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_12.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_12.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_12.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_12.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_12.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_12.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_12.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_12.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_12.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_12.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_12.qad"
        }
    }
    Timeline {
        id: thinking_timeline
        objectName: "thinking"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 4034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 4034
            from: 0
            to: 4034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_13.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.177817, 0.725042, -0.0384141, -0.664244)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.90875e-09, 0.390288, -1.14793e-08)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.329708, 0.4014, -0.570891, 0.63581)
            }
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.998135, 0, 0, -0.0610486)
            }
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_13.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.00325e-07, 0.390288, 1.16921e-07)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.46208e-08, 0.526403, 1.21274e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.60369e-07, 0.808518, 1.85929e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.27108e-08, 0.526403, 3.85065e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_13.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(5.31583e-08, 0.808518, -1.21403e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_13.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_13.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_13.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_13.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_13.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_13.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_13.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_13.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_13.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_13.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_13.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_13.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_13.qad"
        }
    }
    Timeline {
        id: walk_timeline
        objectName: "walk"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 2034
            from: 0
            to: 2034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_14.qad"
        }
        KeyframeGroup {
            target: body
            property: "rotation"
            Keyframe {
                frame: 33.3333
                value: Qt.quaternion(0.996195, -0.0871557, 0, 0)
            }
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_14.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(3.27862e-08, 0.390288, -1.53639e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_14.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_14.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_14.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(3.14062e-08, 0.390288, -3.7175e-08)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(8.68812e-08, 0.526403, -6.35731e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.63339e-07, 0.808518, -1.12256e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-8.68812e-08, 0.526403, -6.35731e-08)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_14.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.63339e-07, 0.808518, -1.12256e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_14.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_14.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_14.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_14.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_14.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_14.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_14.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_14.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_14.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_14.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_14.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_14.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_14.qad"
        }
    }
    Timeline {
        id: wave_timeline
        objectName: "wave"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2034
        currentFrame: 0
        enabled: true
        animations: TimelineAnimation {
            duration: 2034
            from: 0
            to: 2034
            running: true
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: root201
            property: "position"
            keyframeSource: "animations/root201_position_15.qad"
        }
        KeyframeGroup {
            target: arm_L
            property: "rotation"
            keyframeSource: "animations/arm_L_rotation_15.qad"
        }
        KeyframeGroup {
            target: forearm_L
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_L
            property: "rotation"
            keyframeSource: "animations/forearm_L_rotation_15.qad"
        }
        KeyframeGroup {
            target: head
            property: "rotation"
            keyframeSource: "animations/head_rotation_15.qad"
        }
        KeyframeGroup {
            target: arm_R
            property: "rotation"
            keyframeSource: "animations/arm_R_rotation_15.qad"
        }
        KeyframeGroup {
            target: forearm_R
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.33248e-08, 0.390288, -1.35928e-09)
            }
        }
        KeyframeGroup {
            target: forearm_R
            property: "rotation"
            keyframeSource: "animations/forearm_R_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_L_0
            property: "rotation"
            keyframeSource: "animations/ribbon_L_0_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_1
            property: "rotation"
            keyframeSource: "animations/ribbon_L_1_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_L_2
            property: "rotation"
            keyframeSource: "animations/ribbon_L_2_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_R_0
            property: "rotation"
            keyframeSource: "animations/ribbon_R_0_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(-1.38447e-07, 0.526403, -1.08299e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_1
            property: "rotation"
            keyframeSource: "animations/ribbon_R_1_rotation_15.qad"
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "position"
            Keyframe {
                frame: 33.3333
                value: Qt.vector3d(2.48738e-08, 0.808517, -1.20133e-07)
            }
        }
        KeyframeGroup {
            target: ribbon_R_2
            property: "rotation"
            keyframeSource: "animations/ribbon_R_2_rotation_15.qad"
        }
        KeyframeGroup {
            target: tail
            property: "rotation"
            keyframeSource: "animations/tail_rotation_15.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget
            property: "weight"
            keyframeSource: "animations/curious_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget
            property: "weight"
            keyframeSource: "animations/happy_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget
            property: "weight"
            keyframeSource: "animations/confused_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: curious_morphtarget14
            property: "weight"
            keyframeSource: "animations/curious_morphtarget14_weight_15.qad"
        }
        KeyframeGroup {
            target: thinking_morphtarget15
            property: "weight"
            keyframeSource: "animations/thinking_morphtarget15_weight_15.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget16
            property: "weight"
            keyframeSource: "animations/happy_morphtarget16_weight_15.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget17
            property: "weight"
            keyframeSource: "animations/confused_morphtarget17_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget
            property: "weight"
            keyframeSource: "animations/blink_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget32
            property: "weight"
            keyframeSource: "animations/blink_morphtarget32_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget33
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget33_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget34
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget34_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget35
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget35_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget36
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget36_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget37
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget37_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget38
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget38_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget42
            property: "weight"
            keyframeSource: "animations/blink_morphtarget42_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget43
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget43_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget44
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget44_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget45
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget45_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget46
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget46_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget47
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget47_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget48
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget48_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget52
            property: "weight"
            keyframeSource: "animations/blink_morphtarget52_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget53
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget53_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget54
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget54_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget55
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget55_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget56
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget56_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget57
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget57_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget58
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget58_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget63
            property: "weight"
            keyframeSource: "animations/blink_morphtarget63_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget64
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget64_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget65
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget65_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget66
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget66_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget67
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget67_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget68
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget68_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget69
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget69_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget73
            property: "weight"
            keyframeSource: "animations/blink_morphtarget73_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget74
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget74_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget75
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget75_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget76
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget76_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget77
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget77_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget78
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget78_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget79
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget79_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget84
            property: "weight"
            keyframeSource: "animations/blink_morphtarget84_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget85
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget85_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget86
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget86_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget87
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget87_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget88
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget88_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget89
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget89_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget90
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget90_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget94
            property: "weight"
            keyframeSource: "animations/blink_morphtarget94_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget95
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget95_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget96
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget96_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget97
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget97_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget98
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget98_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget99
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget99_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget100
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget100_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget105
            property: "weight"
            keyframeSource: "animations/blink_morphtarget105_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget106
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget106_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget107
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget107_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget108
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget108_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget109
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget109_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget110
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget110_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget111
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget111_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget115
            property: "weight"
            keyframeSource: "animations/blink_morphtarget115_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget116
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget116_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget117
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget117_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget118
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget118_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget119
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget119_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget120
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget120_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget121
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget121_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget125
            property: "weight"
            keyframeSource: "animations/blink_morphtarget125_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget126
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget126_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget127
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget127_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget128
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget128_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget129
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget129_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget130
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget130_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget131
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget131_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget135
            property: "weight"
            keyframeSource: "animations/blink_morphtarget135_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget136
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget136_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget137
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget137_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget138
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget138_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget139
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget139_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget140
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget140_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget141
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget141_weight_15.qad"
        }
        KeyframeGroup {
            target: happy_morphtarget178
            property: "weight"
            keyframeSource: "animations/happy_morphtarget178_weight_15.qad"
        }
        KeyframeGroup {
            target: confused_morphtarget179
            property: "weight"
            keyframeSource: "animations/confused_morphtarget179_weight_15.qad"
        }
        KeyframeGroup {
            target: mouthOpen_morphtarget
            property: "weight"
            keyframeSource: "animations/mouthOpen_morphtarget_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget184
            property: "weight"
            keyframeSource: "animations/blink_morphtarget184_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget185
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget185_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget186
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget186_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget187
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget187_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget188
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget188_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget189
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget189_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget190
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget190_weight_15.qad"
        }
        KeyframeGroup {
            target: blink_morphtarget194
            property: "weight"
            keyframeSource: "animations/blink_morphtarget194_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeSmile_morphtarget195
            property: "weight"
            keyframeSource: "animations/eyeSmile_morphtarget195_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeWidth_morphtarget196
            property: "weight"
            keyframeSource: "animations/eyeWidth_morphtarget196_weight_15.qad"
        }
        KeyframeGroup {
            target: eyeHeight_morphtarget197
            property: "weight"
            keyframeSource: "animations/eyeHeight_morphtarget197_weight_15.qad"
        }
        KeyframeGroup {
            target: irisScale_morphtarget198
            property: "weight"
            keyframeSource: "animations/irisScale_morphtarget198_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeX_morphtarget199
            property: "weight"
            keyframeSource: "animations/gazeX_morphtarget199_weight_15.qad"
        }
        KeyframeGroup {
            target: gazeY_morphtarget200
            property: "weight"
            keyframeSource: "animations/gazeY_morphtarget200_weight_15.qad"
        }
    }
}
