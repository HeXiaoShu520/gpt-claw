# 浮灵正式运行与验收记录

更新日期：2026-10-25。

MiniPet 的正式角色固定为浮灵。运行入口使用 `desktop/res/role/浮灵/CharacterSpirit.qml`，不再从旧图片角色目录选择角色，也不再轮换模型。界面、动作和指引由本地 Qt 控制；任务执行继续使用 gpt-claw 的同一 Codex 会话。

## 资源和控制入口

| 位置 | 用途 |
| --- | --- |
| `desktop/res/role/浮灵/CharacterSpirit.qml` | 正式 Qt 角色入口 |
| `desktop/res/role/浮灵/assets/` | Blender 导出的正式 Qt 资源，已含下半身比例、肩肘蒙皮与圆润实心月牙修正 |
| `desktop/src/pet/spirit_model.py` | 固定角色、基础尺寸和动作清单 |
| `desktop/src/pet/spirit_view.py` | Qt 加载、动作切换、视线与手部投影 |
| `desktop/src/pet/companion.py` | 本地陪伴节奏与动作优先级 |
| `desktop/src/pet/guidance.py` | 目标校验、靠近、指引与返回 |
| `desktop/preview_spirit.py` | 正式资源的 Qt 截图与脚本验收入口 |

当前可编辑源文件为 [DreamSpirit_sides.blend](../data/development/pet-arms-at-sides-20261025/DreamSpirit_sides.blend)，对应导出为 [DreamSpirit_sides.glb](../data/development/pet-arms-at-sides-20261025/DreamSpirit_sides.glb)。独立圆润肩根与分离蒙皮已接入正式Qt资源；肩根移至身体两侧，待机手臂取消默认前摆，保持15个骨骼关节、16段基础动画。源脚本、连续动作复拍和正式资源对照详见 [行为实施与验收记录](pet-behavior-implementation-2026-10-23.md)。散步、睡觉和动作过渡继续由正式运行时控制。此前的 [独立肩臂版本](../data/development/pet-shoulder-pivots-20261025/DreamSpirit_structured.blend)、[手臂睡眠版本](../data/development/pet-arms-sleep-20261020/arms-v2/DreamSpirit_softarms.blend)、[实心月牙版本](../data/development/spirit-solid-moon/DreamSpirit_solid_moon.blend)、[下半身比例版本](../data/development/spirit-body-balance/DreamSpirit_balanced.blend)、[腹部蒙皮版本](../data/development/spirit-body-smooth/DreamSpirit_smooth.blend) 和 [圆润关节版本](../data/development/spirit-rounded-joints/DreamSpirit_rounded.blend) 作为阶段备份保留。原始v18 Blender / GLB仍保留在 `workspace/design-preview/artifacts/spirit-animation-v18/`。运行时从正式资源目录加载。

已移除正式目录中的流浪者、流萤、小呆、ChrisKitty，以及旧图片动画加载器 `animation.py`、`pet_assets.py` 和旧 `pet_conf.json`。删除清单见 [removed-resources.json](../artifacts/spirit-only/removed-resources.json)。猫耳模型的既有备份仍保留在 [cat-ear-20261018-174649](../artifacts/model-backups/cat-ear-20261018-174649/)。

### 实心月牙修正（2026-10-18）

原月牙材质本身不透明，但网格沿轮廓形成一圈管状边框，中间未填充，45° 时能透出背景。此次在 Blender 中重建前后表面和连接侧壁，并给边缘增加小幅倒角，得到有厚度的实心月牙。保持原有紫色材质、位置和 Moon 骨骼绑定。

正式资源新增 `meshes/crescent_solid_mesh.mesh`，`DreamSpirit.qml` 和实际加载的 `DreamSpiritRuntime.qml` 均指向新网格；这两份 QML 仅修改月牙网格引用。其余正式网格与动画文件的 SHA-256 均与修改前一致，原始 Blender 和 GLB 文件也未改写。导出前后 15 根骨骼、绑定矩阵及 16 个动作匹配。

使用正式入口 `CharacterSpirit.qml` 固定待机姿态、时间、睁眼值、相机和光照，重新拍摄 0°、45°、90°、180°，Qt 加载状态为 Ready。四个角度确认月牙填实且侧面有厚度。新网格无开放边、无非流形边。证据见 [月牙前后对比](../data/development/spirit-solid-moon/moon-comparison.png)、[修正后四视图](../data/development/spirit-solid-moon/four-angles.png)、[网格记录](../data/development/spirit-solid-moon/mesh-report.json) 和 [接入与文件校验](../data/development/spirit-solid-moon/integration.json)。

本次仅复拍待机四视图，未重新逐段播放全部动作；16 个动作资源及现有控制逻辑保持不变。已运行的桌宠窗口需重新启动后加载新资源。

### 下半身比例微调（2026-10-18）

针对头宽与身体下段收窄形成的视觉落差，在 Blender 中平滑扩大胸腹下段：局部宽度最多增加 14%，前后厚度最多增加 6%，向胸口、手臂和尾尖逐渐收回原尺寸。头部、外侧手臂与圆润小手保持原尺寸，顶点高度不变，尾尖没有加长。身体与双臂的闭合网格体积合计增加约 9.7%。

新身体仍为 5,751 个顶点、11,498 个面，没有开放边或非流形边。保留 15 根骨骼、四个肩部形变和 16 个动作；导出前后身体索引、骨骼权重及绑定矩阵一致。正式资源新增 `meshes/spirit_Body_balanced_mesh.mesh`，两份 `DreamSpirit*.qml` 只更换身体网格引用；其余 2,026 个已有文件的 SHA-256 与本轮调整前一致。旧身体网格与修改前 QML 已保留。

通过正式入口重新拍摄固定待机的 0°、45°、90°、180°，并抽查挥手 0.65 秒、伸展 1.2 秒、指引 1.5 秒在正面和 45° 的姿态。Qt 均为 Ready，活动动作名称匹配。四视图中胸腹下段更饱满、侧面仍较薄，尾部连续收尖；动作抽查中未见下半身新增破面，伸展肩根仍能看到既有细褶，不能据此宣称肩部造型已全部验收。此次没有重新播放全部 16 个动作的完整时段。

证据见 [调整前后](../data/development/spirit-body-balance/body-comparison.png)、[调整后四视图](../data/development/spirit-body-balance/four-angles.png)、[三个动作的姿态抽查](../data/development/spirit-body-balance/pose-samples.png)、[网格记录](../data/development/spirit-body-balance/mesh-report.json)、[接入与文件校验](../data/development/spirit-body-balance/integration.json) 和 [姿态采样记录](../data/development/spirit-body-balance/pose-capture.json)。已运行的桌宠窗口仍需重启以加载此次资源。

### 腹部、肩肘与圆润月牙（2026-10-19）

本轮沿用下半身加宽后的比例，修正其运动时的转折。腹部阶段将 1,920 个顶点中不应随手臂运动的部分权重平滑转回 Body；随后将肘部上臂到前臂的混合范围由模型横坐标绝对值 0.605–0.795 放宽至 0.50–0.98，并改用五次平滑曲线，涉及 3,434 次顶点与侧别的权重分配。保留每侧 Arm / Forearm 的合计权重，不改变身体基础拓扑、小手尺寸，也不增加手腕。

此前四个肩部修正形态键的偏移与当前身体、运行时姿态不再匹配，会在抬臂时挤出局部褶皱。本轮将其顶点偏移归零，保留原名称、顺序及动画通道，避免影响现有资源控制。身体仍为 5,751 顶点、11,498 面，15 根骨骼和 16 个动作保持兼容。

月牙从前后平面加侧壁的实体重建为连续椭圆截面的圆润实体，厚度向两尖平滑收束；保留紫色材质、悬浮位置与 Moon 绑定。身体和月牙均无开放边或非流形边。正式两份 `DreamSpirit*.qml` 更换身体与月牙的网格引用，新增两个网格；其他 2,028 个已有资源文件的 SHA-256 与本轮修改前一致，原 QML 与网格已备份。

使用正式入口 `CharacterSpirit.qml` 固定相机、灯光、时钟和睁眼状态，重新拍摄 0°、45°、90°、180°，并采集 236 张动作画面：16 动作的 192 个姿态采样、八方向指引在两个角度的 16 个采样，以及四次动作切换各七个时点的 28 个采样。挥手、伸展、整理衣帽和玩耍额外覆盖正面、45°、90°；四次切换记录均从进度 0 到 1，Qt 为 Ready，活动动作名匹配。

画面复核中，伸展肩根的尖锐折线与弯肘时多道挤褶明显减轻，腹部轮廓连续；极限弯曲内侧仍有浅凹，帽壳轮廓及完整动作自然度未因此全部验收。236 张是离散姿态采样，不能替代真实业务、语音和长期运行验收。已运行的桌宠窗口没有重启，重新启动后才加载本轮资源。

证据与源文件：

- [同相机前后对比](../data/development/spirit-rounded-joints/joint-comparison.png)、[最新四视图](../data/development/spirit-rounded-joints/four-angles.png)
- [挥手](../data/development/spirit-rounded-joints/motion/wave-joints.png)、[伸展](../data/development/spirit-rounded-joints/motion/stretch-joints.png)、[整理衣帽](../data/development/spirit-rounded-joints/motion/groom-joints.png)、[玩耍](../data/development/spirit-rounded-joints/motion/play-joints.png)、[动作切换](../data/development/spirit-rounded-joints/motion/transitions.png)
- [全部采样记录](../data/development/spirit-rounded-joints/motion/capture.json)、[网格记录](../data/development/spirit-rounded-joints/mesh-report.json)、[接入兼容记录](../data/development/spirit-rounded-joints/integration.json)、[最终文件和采样校验](../data/development/spirit-rounded-joints/final-verification.json)

复拍本轮动作采样及重新汇总证据：

```powershell
desktop/.venv/Scripts/python.exe data/development/spirit-rounded-joints/capture_motion.py
desktop/.venv/Scripts/python.exe data/development/spirit-rounded-joints/finish_review.py
```

本轮未新增或运行测试，也未重跑下方 2026-10-18 的应用装配与工程检查；下面的结果保留原验收日期。

## 18 个动作状态

保留 16 个 Blender 动画资源，运行时另提供“双手搭边”和“睡觉”，并重做散步摆臂。最新肩肘、散步与睡觉的实现及复拍见 [2026-10-20 动作修整记录](pet-motion-refinement-2026-10-20.md)。

| 动作 | 标识 | 单段时长（秒） |
| --- | --- | --- |
| 漂浮待机 | `idle` | 4.034 |
| 休息 | `rest` | 4.034 |
| 挥手 | `wave` | 2.034 |
| 指引 | `guide` | 3.034 |
| 思考 | `thinking` | 4.034 |
| 说话 | `speaking` | 4.034 |
| 倾听 | `listening` | 4.034 |
| 等待确认 | `approval` | 4.034 |
| 下落 | `fall` | 1.034 |
| 被提起 | `drag` | 3.034 |
| 坐下 | `sit` | 4.034 |
| 伸展 | `stretch` | 3.034 |
| 张望 | `look` | 4.034 |
| 玩耍 | `play` | 4.034 |
| 整理衣帽 | `groom` | 3.034 |
| 散步摆臂 | `walk` | 3.2 |
| 双手搭边 | `perch` | 4.034 |
| 睡觉 | `sleep` | 12 |

本地控制器提供 `quiet`、`companion`、`lively`、`rest` 四种模式，调整日常动作的节奏。`rest` 在菜单中显示为“睡觉”，持续保持睡姿；手动选择单次睡觉动作则默认播放 12 秒。重复播放同一个动作会重新开始；工作状态可以中断日常动作，结束后再恢复。动作和视线更新不调用模型、不截屏、不创建另一套会话。

交互优先级由高到低为：拖动、下落、等待确认、倾听、指引、说话、思考、日常动作、休息、待机。语音接听和输入框激活映射倾听，任务处理映射思考，朗读映射说话，待审批任务映射等待确认。默认拖动松开后留在摆放位置；只有启用掉落设置时才下落，落稳后恢复仍在进行的工作状态。

## 指引行为

指引按“注意目标 → 靠近目标旁边 → 稳定后抬手 → 收手 → 返回”的节奏运行。空间不足时只显示目标指示，避免把宠物挡在目标上。标记使用目标光圈、提示文字和从手部位置引出的细曲线；指引本身不点击目标。

生产路径校验目标窗口身份、前台关联和窗口边界，并转换不同 DPI 下的物理坐标与 Qt 逻辑坐标。目标窗口变化会拒绝或结束指引，要求重新观察。正常持有约 2.2 秒后收手，目标标记可以继续保留到指引结束。

## 设置迁移与启动

加载旧配置时只把角色字段改成浮灵，并移除轮换字段，保留原始配置中的其他内容。用户昵称、头像及有效的语音设置继续保留；昵称不等同于模型名称。再次保存时也固定使用浮灵。设置页保留昵称、头像和 50%–200% 大小调整，不再提供模型选择和轮换。

启动契约保持不变：

| 指令 | 内容 |
| --- | --- |
| `npm run start` | gpt-claw 服务与 MiniPet |
| `npm run start:claw` | 仅 gpt-claw 服务 |
| `npm run start:pet` | 仅 MiniPet |

## 既有接入验收证据（2026-10-18）

2026-10-18 使用正式 Qt 资源实际运行和截图，结果如下：

| 检查 | 结果与证据 |
| --- | --- |
| 资源加载与 16 个动作 | Qt 状态为 Ready，16 个动作名称匹配且均有可见画面；[动作图](../artifacts/spirit-only/actions.png)、[数据](../artifacts/spirit-only/runtime.json) |
| 四个角度 | 同一资源复拍 0°、45°、90°、180°；[四视图](../artifacts/spirit-only/angles.png) |
| 八个指引方向 | 已复拍八方向手臂姿态；[方向图](../artifacts/spirit-only/directions.png) |
| 动作切换与恢复 | 重复动作重新开始；工作状态优先级切换正确；拖动、松开下落、落稳后恢复思考均通过 |
| 自然眨眼 | 176 个采样中眨眼值覆盖 0–0.997，确认动态更新 |
| 缩放 | 0.5、1、2 倍均生成非空画面，采样边界在画布内；本机 DPR 为 1.5 |
| 指引几何 | 到达目标旁边、抬手、收手和返回通过；投影目标误差约 0.33 个逻辑像素；[抬手](../artifacts/spirit-only/guidance-point.png)、[收手](../artifacts/spirit-only/guidance-settled.png) |
| 应用装配与设置 | `MiniPetApp` 装配成功、浮灵 Ready、设置页可见；[记录](../artifacts/spirit-only/assembly.json)、[设置截图](../artifacts/spirit-only/assembly-settings.png) |
| 旧配置迁移 | 临时配置中的昵称、有效语音参数和未知嵌套字段在迁移时保留，角色与轮换收敛正确；[记录](../artifacts/spirit-only/migration.json) |
| 工程检查 | Python 源文件编译检查、`npm run check`、`npm run build` 均通过 |

截图和装配检查使用临时设置，未写入用户实际配置，未连接业务事件客户端，未播放启动欢迎语音。

### 复现入口与边界

在工程根目录执行：

```powershell
# 复拍动作、四视图、八方向、缩放与指引几何
desktop/.venv/Scripts/python.exe desktop/preview_spirit.py --geometry-only

# 检查应用装配和设置页
desktop/.venv/Scripts/python.exe desktop/preview_spirit.py --assembly

# 单独检查指引，保留生产路径的前台窗口校验
desktop/.venv/Scripts/python.exe desktop/preview_spirit.py --guidance
```

输出在 `artifacts/spirit-only/`。`--geometry-only` 仅在验收夹具中放宽前台关联检查，仍校验原生窗口身份与几何；正式运行不使用这个豁免。本轮无人值守夹具在严格模式下因目标未保持前台而被拒绝，实际错误见 [guidance-error.json](../artifacts/spirit-only/guidance-error.json)。因此几何通过不能替代真实业务窗口中的前台指引验收。

截至 2026-10-20，尚未完成登录后业务事件、真实语音识别与朗读、跨屏长期运行的端到端验收。四视图和动作图是实际 Qt 画面，但不等同于全部造型标准已经通过；肩肘极限姿态、帽壳轮廓及动作的自然程度仍应按 [设计验收记录](minipet-spirit-b-design.md) 逐项评价。
