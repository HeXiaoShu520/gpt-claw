# VRM 骨骼角色集成方案

> 2026-10-18 归档说明：猫耳程序原型及其 QML / VRM 试验资源已备份并撤出活动目录，正式桌宠没有加载本方案。下文为历史研究，路径与接入步骤不代表当前可用状态。参见[备份说明](../artifacts/model-backups/cat-ear-20261018-174649/README.md)。

## 背景

当前宠物角色（`Character.qml`）用程序几何体拼装，与概念图差距较大。
本方案用 VRM 格式的骨骼角色替换程序几何体，骨架完整，可驱动任意姿态。

---

## 已验证的技术链路

### 第一步：VRM → 标准 GLB

脚本：`vrm_to_glb.py`（已完成）

- 输入：`AvatarSample_A.vrm`（VRoid Studio 导出，183 骨骼关节）
- 操作：剥掉 Qt 不认识的扩展（MToon、VRMC_vrm、springBone），把材质转成标准 PBR
- 输出：`AvatarSample_A_qt.glb`（17.6 MB，骨骼完整，材质标准化）

```
python vrm_to_glb.py AvatarSample_A.vrm AvatarSample_A_qt.glb
```

### 第二步：GLB → Qt 原生格式

工具：PySide6 自带的 `balsam.exe`

```
balsam.exe --outputPath desktop/src/pet/qml/avatar AvatarSample_A_qt.glb
```

输出：
- `desktop/src/pet/qml/avatar/Avatar_qt.qml` — Qt Node 树，骨骼用 `objectName` 标识
- `desktop/src/pet/qml/avatar/meshes/` — 3 个 .mesh 文件（face、body、hair）
- `desktop/src/pet/qml/avatar/maps/` — 32 张贴图

> ⚠️ 路径不能含中文，否则 Qt 加载失败。资源需放在纯 ASCII 路径下，或用 Qt resource 系统打包。

### 第三步：Python 驱动骨骼

已验证：通过 `findChild` 按 `objectName` 找到骨骼节点，直接 `setProperty` 驱动旋转。

```python
from PySide6.QtCore import QObject
from PySide6.QtGui import QVector3D

avatar = engine.rootObjects()[0].findChild(QObject, 'Root')
head   = avatar.findChild(QObject, 'J_Bip_C_Head')
head.setProperty('eulerRotation', QVector3D(pitch, yaw, roll))
```

22/22 关键骨骼全部可寻址，`eulerRotation` 可读可写。

---

## 实施步骤（待做）

### 1. `desktop/src/pet/vrm_driver.py`

每帧从 `companion.py` 的状态（pose / clock / lookX / lookY）计算骨骼旋转，
把 `CharacterMotion.js` 的 IK 结果映射到 VRM 骨骼命名，用 QTimer 30fps 驱动。

VRM 骨骼命名对照：

| 部位 | VRM objectName |
|------|----------------|
| 髋部 | J_Bip_C_Hips |
| 脊椎 | J_Bip_C_Spine |
| 胸部 | J_Bip_C_Chest / J_Bip_C_UpperChest |
| 颈部 | J_Bip_C_Neck |
| 头部 | J_Bip_C_Head |
| 眼睛 | J_Adj_L_FaceEye / J_Adj_R_FaceEye |
| 左肩/大臂/小臂/手 | J_Bip_L_Shoulder / L_UpperArm / L_LowerArm / L_Hand |
| 右肩/大臂/小臂/手 | J_Bip_R_Shoulder / R_UpperArm / R_LowerArm / R_Hand |
| 左腿/膝/脚 | J_Bip_L_UpperLeg / L_LowerLeg / L_Foot |
| 右腿/膝/脚 | J_Bip_R_UpperLeg / R_LowerLeg / R_Foot |

### 2. `CharacterVRM.qml`

与 `Character.qml` 相同的对外接口（pose / clock / lookX / lookY / expression 等），
内部加载 `avatar/Avatar_qt.qml`，骨骼由 Python 层驱动，不需要 QML 绑定。

### 3. 接入 `companion.py`

窗口初始化后注入 vrm_driver，替换掉对 `Character.qml` 的引用。

### 4. 验证所有姿态

idle / walk / sit / play / rest / stretch / thinking / listening / wave / groom / guide / drag

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `vrm_to_glb.py` | VRM → 标准 GLB 转换脚本 |
| `AvatarSample_A.vrm` | VRoid 示例角色（棕发粉裙，骨架正确） |
| `AvatarSample_A_qt.glb` | 转换后的标准 GLB |
| `desktop/src/pet/qml/avatar/` | balsam 转换输出目录 |

---

## 换成自己的角色

1. 在 **VRoid Studio** 里调整外观（发色、眼色、服装等）导出 `.vrm`
2. 跑 `vrm_to_glb.py` 转换
3. 跑 `balsam.exe` 重新生成 `Avatar_qt.qml`
4. 其余代码不用改，vrm_driver 自动适配（骨骼命名 VRoid 标准一致）

