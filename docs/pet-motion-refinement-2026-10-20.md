# 浮灵手臂、散步与睡觉改进记录

更新：2026-10-21。修改已接入正式 Qt 角色，已运行的桌宠需重启后加载。

## 本轮变化

- **肩肘形变**：在 Blender 中重新分配身体、上臂和前臂权重，让肩根向躯干的影响平滑收束；增加左右肩抬起、下垂共 4 个形态键，修正肩根局部变形。运行时按手臂朝向消除绕轴扭转，并限制过度弯肘；肩根修正量取自过渡混合后的实际骨骼角度，使切换过程也能得到对应修正。保留圆润小手，不增大手掌、不增加手腕。
- **散步**：以相反相位驱动双臂前后摆动，配合身体轻微转动、起伏和头部反向补偿；陪伴控制按移动速度调整摆幅，接近停下时减弱摆臂。
- **睡觉**：新增独立 `sleep` 状态，闭眼、低头、侧倾、收手、降低身体并缓慢呼吸。进入睡觉用 1.1 秒过渡，睡醒用 0.8 秒过渡；瞌睡和小睡结束后接伸展。
- **搭边**：保留双手搭边的目标位置与双骨骼求解，避免手臂调整后失去接触位置。

当前共 **18 个动作状态**：16 个既有 Blender 动作，加运行时的双手搭边与睡觉。散步使用运行时重建的摆臂循环，不代表新增 18 段 Blender 动画。

菜单中，“陪伴方式 → 睡觉”为持续睡眠；动作菜单的“睡觉”为单次 12 秒。“一起玩”的打瞌睡、小睡分别包含 28 秒、75 秒睡眠及醒来动作。有任务、倾听或拖拽等更高优先级状态时可中断陪伴睡眠，结束后按陪伴模式恢复。

## 资源与实现

| 文件 | 用途 |
| --- | --- |
| [DreamSpirit_softarms.blend](../data/development/pet-arms-sleep-20261020/shoulders-v6/DreamSpirit_softarms.blend) | 当前可编辑 Blender 源文件 |
| [DreamSpirit_softarms.glb](../data/development/pet-arms-sleep-20261020/shoulders-v6/DreamSpirit_softarms.glb) | 对应导出 |
| [接入校验](../data/development/pet-arms-sleep-20261020/shoulders-v6/integration.json) | 身体网格、骨骼、动作和哈希 |
| [肩根修正记录](../data/development/pet-arms-sleep-20261020/shoulders-v6/correctives.json) | 4 个形态键的参考角度、影响顶点及位移 |
| [DreamSpiritRuntime.qml](../desktop/res/role/浮灵/assets/DreamSpiritRuntime.qml) | 手臂朝向、摆臂、睡眠、过渡与搭边 |
| [companion.py](../desktop/src/pet/companion.py) | 移动速度、睡眠模式与行为优先级 |
| [behaviors.py](../desktop/src/pet/behaviors.py) | 打瞌睡、小睡与搭边序列 |
| [spirit_model.py](../desktop/src/pet/spirit_model.py) | 18 个动作状态契约 |

正式身体网格为 `desktop/res/role/浮灵/assets/meshes/spirit_Body_softarms_mesh.mesh`，5,751 个顶点。最终保留 `shoulders-v6`，导出接入时核对了 15 根骨骼、16 个动作、索引、形态键通道、绑定矩阵和权重总和的兼容性；左右肩的 4 个形态键均有实际顶点位移。正式两份 `DreamSpirit*.qml` 均使用新身体网格。

身体网格 SHA-256：

```text
25e39ff40f9802d33df48ca254bec9350c5f72a2e0471c55e4670810cc426333
```

源文件和开发截图保留在本机已忽略的 `data/development/`；正式运行加载的是 `desktop/res/role/浮灵/` 下的 QML 和网格。

## 本轮验证

使用正式 `SpiritView` / `CharacterSpirit.qml` 创建隐藏 Qt 渲染窗口，仅渲染本项目角色，没有读取桌面或其他窗口。Qt 加载状态为 Ready，采样时活动动作名称均与请求一致。

| 检查 | 结果 |
| --- | --- |
| 18 状态固定姿态采样 | 共 144 帧：0°、60°，各取 0.25 / 0.75 / 1.25 / 1.75 秒；生成每个动作的拼图 |
| 连续切换采样 | 336 帧、16 fps、21 秒：散步 4 秒 → 待机 1 秒 → 睡觉 6 秒 → 伸展 3 秒 → 挥手 3 秒 → 整理自己 3 秒 → 待机 1 秒；开启自然动作、眨眼和过渡 |
| Python 语法编译 | `behaviors.py`、`companion.py`、`spirit_model.py`、`pet_menus.py` 通过 |
| `npm run check` | 通过 |
| `npm run build` | 通过 |

本轮未新增或运行测试。

已查看散步、睡觉、挥手、搭边、指示、伸展、整理自己、玩耍和思考的多角度拼图，以及连续切换的中间选帧。散步的双臂前后交替，睡觉有明确的闭眼低头与收手姿态；入睡和睡醒的选帧未见明显姿态突跳，已查看画面未见明显断臂或严重穿插。高抬臂时肩根仍有轻微起伏和局部浅折痕，尚不能认定肩肘已完全圆滑。固定姿态采样没有覆盖全部动作的完整连续时段；本轮也没有重启桌宠主程序，未验证真实会话、语音、完整陪伴调度及长期运行。

证据：

- [连续动作 GIF](../data/development/pet-arms-sleep-20261020/continuous-v6.gif)、[连续动作选帧](../data/development/pet-arms-sleep-20261020/continuous-v6-review.png)、[连续采样记录](../data/development/pet-arms-sleep-20261020/continuous-v6/record.json)
- [散步](../data/development/pet-arms-sleep-20261020/final-v6/walk-sheet.png)、[睡觉](../data/development/pet-arms-sleep-20261020/final-v6/sleep-sheet.png)、[挥手](../data/development/pet-arms-sleep-20261020/final-v6/wave-sheet.png)、[双手搭边](../data/development/pet-arms-sleep-20261020/final-v6/perch-sheet.png)、[全部状态采样记录](../data/development/pet-arms-sleep-20261020/final-v6/record.json)

本机复拍连续动作：

```powershell
desktop/.venv/Scripts/python.exe data/development/pet-arms-sleep-20261020/capture_continuous.py continuous-v6
```

生成 GIF 和选帧需在带 Pillow 的 Python 环境中运行 `data/development/pet-arms-sleep-20261020/assemble_continuous.py continuous-v6`。固定姿态脚本 `capture.py` 接受输出子目录和动作名称列表；本轮记录位于 `final-v6/record.json`。这些开发脚本和图像仅保留在当前电脑的已忽略目录中，普通代码检出不包含它们。
