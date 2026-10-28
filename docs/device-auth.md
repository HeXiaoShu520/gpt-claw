# 启动认证与 AI 交接记录

更新：2026-09-28。保留另一位 AI 新增的 device 引导、内置 CLI 及常用权限；本次复核修正身份、配置判定和退出清理。以下以当前代码为准。

## 1. 启动流程

以下流程用于 `npm run start:claw` 启动的 gpt-claw 服务（飞书和桌面通道）。`npm run start` 组合启动同一服务和桌宠，也执行此认证流程；`npm run start:pet` 只启动桌宠界面。

1. 读环境参数、建立工作区与实例锁，并安装退出信号处理。
2. 缺完整 `FEISHU_APP_ID / FEISHU_APP_SECRET` 时：终端发起应用注册 Device Flow，显示二维码/链接；扫码创建或绑定 PersonalAgent 应用，凭证写回工程 `.env`。
3. 应用注册返回本人 open_id 且 `FEISHU_ADMIN` 为空时写回本人；否则继续 CLI 授权来确认本人。
4. 检查内置 CLI 的应用绑定和 `auth status --json --verify`。应用未绑定则用 `config init --app-secret-stdin` 初始化，再核对绑定是否生效。
5. 本人已登录则继续；登录者与已配置本人不同则退出该登录，立即进入重新扫码流程。未登录时使用 `--no-wait --json` 展示 Device Flow 链接，再以 `--device-code --json` 等待完成。
6. 授权结束后重新 verify，并核对 App ID 与 open_id；无本人配置时绑定本次登录者。不是本人的账号会退出，不接受为当前身份。
7. 启动 personal MCP、Codex 和飞书通道。Codex 启动检查工程配置加载层与实际权限。
8. 使用机器人 SDK 同步当前命令清单到原生 `/` 面板，然后恢复已排队任务及定时任务。面板同步失败会提示所需权限，普通聊天仍继续。

应用向导失败时无法继续。CLI 未完成认证时，**已配置本人的机器人**可以警告后继续；尚未绑定本人时启动失败。状态校验的未知错误不会当成“未登录”来重置账号。Ctrl+C 会取消注册请求/轮询/CLI 子进程，释放实例锁。

国际版 `FEISHU_DOMAIN=lark` 当前没有应用注册向导，需手填应用凭证；项目 CLI 仍按对应 brand 认证。

## 2. 应用 Device Flow

协议按工程安装的飞书 SDK 注册实现核对：

- POST `https://accounts.feishu.cn/oauth/v1/app/registration`；
- begin 表单：`action=begin`、`archetype=PersonalAgent`、`auth_method=client_secret`、`request_user_info=open_id`；
- 完成链接加 source 与 `addons=base64url(gzip(JSON))`；已有 App ID 用 `clientID` 表示更新/绑定目标；
- poll 表单：`action=poll`、`device_code`；成功接收 `client_id / client_secret / user_info.open_id`；
- 处理 pending、slow_down、拒绝和过期。单次网络请求有 20 秒超时；轮询可取消，总期限来自服务器；
- Secret 写回工程 `.env`，不写进进程参数或日志。终端可显示 App ID 与授权 URL，不能显示 Secret/token。

### 官方默认模板与追加权限

注册配置显式设置 `addons.preset=true`：**保留飞书官方默认模板，在其上追加 11 项 tenant scope / 23 项 user scope**。原实现未设置 `preset`，按官方协议同样默认保留模板；这次显式声明该行为，并修正终端只展示 tenant 追加项的问题。

11 / 23 是代码中的追加项数量，**不是应用完整权限数量**。平台合并模板和追加项并去重；默认模板由飞书维护，代码不硬编码其内容或总数。下表只列追加项。完整请求以扫码确认页为准，实际开通以应用审批和后台为准。[官方注册模板与 addons 说明](https://github.com/larksuite/node-sdk#custom-scopeseventscallbacks-addons-and-updating-an-existing-app)

| 类别 | Scope |
|---|---|
| 机器人消息 | `im:message`、`im:message.send_as_bot`、`im:message.group_msg`、`im:message.reactions:write_only` |
| 会话/资源 | `im:chat`、`im:resource` |
| 机器人通讯录 | `contact:user.base:readonly`、`contact:contact.base:readonly`、`contact:department.base:readonly` |
| 斜杠命令 | `application:app_slash_command:read`、`application:app_slash_command:write` |
| 用户文档 | `docs:doc:readonly`、`docx:document`、`docs:document.comment:write_only` |
| 云盘 | `drive:drive`、`drive:file:upload` |
| 表格/多维表格 | `sheets:spreadsheet`、`bitable:app` |
| 日历/任务 | `calendar:calendar`、`task:task:read`、`task:task:write` |
| 邮箱 | `mail:user_mailbox:readonly`、`mail:user_mailbox.message:readonly`、`mail:user_mailbox.message:send` |
| 知识库/OKR/审批 | `wiki:node:read`、`wiki:node:create`、`okr:okr:readonly`、`approval:approval:readonly` |
| 会议/妙记 | `vc:meeting:readonly`、`minutes:minutes:readonly` |
| 幻灯片 | `slides:presentation:read`、`slides:presentation:write_only` |
| 用户通讯录 | `contact:user.base:readonly`、`contact:user.email:readonly` |

事件预置 `im.message.receive_v1`；卡片回调 `card.action.trigger`。码长度不是授权有效性证明。

原 AI 从 CLI 内嵌目录核对了名称；这只能支持名称存在，不能取代实时接口权限要求和后台开通情况。

### 原生 `/` 面板注册

申请清单中的 `application:app_slash_command:read` / `write` 已接入启动注册流程，使用机器人应用身份访问 `/open-apis/application/v7/app_slash_commands`。命令定义取自 `src/app/commands.ts`，当前为 `help`、`status`、`stop`、`new`、`compact`、`steer`、`jobs`、`schedules`、`answer`；该清单同时用于消息分发和 `/help`，增加清单项但没有实现处理分支会在类型检查中报错。

先查询已注册项，仅创建缺失命令、更新变化的描述；更新保持 command_id、图标及其他语言描述，保留不属于当前清单的命令。重复启动不会重复创建。操作参数与接口形状核对自内置 CLI 的 `application +slash-command-*` 帮助及官方源码 `shortcuts/application/`。

注册与聊天传输均使用 SDK 的机器人凭证，不调用用户 CLI、不读取个人账号令牌。选中命令后沿用普通消息处理入口；没有新增 slash 回调事件。命令仍只接受本人操作；群聊普通消息需要 @机器人。若飞书投递无 @ 的已支持 `/` 命令，入口会放行并分发；群聊客户端是否展示和投递原生面板命令尚未实测。

已配置的旧应用如果缺少 read/write 权限，需要在飞书后台开通并发布，然后执行 `npm run feishu:commands` 或重启服务。注册本身不会改变应用权限。客户端有约 5 分钟缓存；应区分服务端同步完成与客户端已经刷新。

2026-09-29 已读取当前机器人的服务端清单，恰好包含以上 9 条命令；随后用机器人应用身份对 `/help` 做了保持描述不变的更新，确认读写权限均可用。没有发送聊天消息或手动验证客户端点选。

## 3. 工程内飞书 CLI

- 固定依赖 `@larksuite/cli@1.0.95`，Windows 可执行文件是 `node_modules/@larksuite/cli/bin/lark-cli.exe`。
- 所有启动认证调用都设 `LARKSUITE_CLI_CONFIG_DIR=<dataDir>/lark-cli`；不读取全局默认登录配置。原生命令子进程也默认继承此项目目录和 brand。
- `feishu/cli.ts` 统一内置程序路径、PATH 与项目身份环境。启动认证用绝对路径；Codex 进程和原生 Shell 的 PATH 将内置目录置于首位，后接工程 `.bin`。内置程序缺失就报错，不依赖全局版本补位。PATH 优先级不拦截显式其他路径、别名或环境重写，详见扩展文档。
- 移除继承的 `LARKSUITE_CLI_APP_ID / APP_SECRET / USER_ACCESS_TOKEN / TENANT_ACCESS_TOKEN`，以免外部凭证模式屏蔽认证管理命令或选择另一身份。
- 应用 Secret 由 stdin 传给 config init。用户 token 由 CLI 在工程数据目录自管，项目没有另建 token vault；不能说“工程数据里没有用户 token”。
- 状态解析兼容裸 JSON 与 `ok/data/error` 信封。退出码、明确失败、available/ready 和真实 open_id 一起用于判定；不以字符串“ok”当失败，也不单用 `code===0` 判断 CLI 业务成功。
- 启动用户登录统一使用 CLI 原生 `--recommend`，不再提供额外授权域环境配置。1.0.95 的实际帮助说明 `--recommend` 等同 `--domain all`，不是更小的权限集合。旧实现额外追加邮件及表格 scope，本次已移除，授权选择交给 CLI 原生策略。
- 登录失败只记录退出码，不把原始 stdout/stderr（可能含认证数据）写入日志。退出码 3 也可能表示登录成功但部分 scope 未授予；只有结构化结果明确为 `authorization_complete`、包含本人 open_id 和 `missing_scope` 警告，且后续 verify 通过身份及应用核对，才按部分授权处理。其他退出码 3 仍视为授权未完成。
- 启动完成后没有定期 auth status 轮询。这次认证代码没有新增通用 CLI 业务 Tool；消息、历史、文件发送仍使用机器人 SDK 身份。
- 单人方案没有借用其他管理员账号。项目 CLI 账号就是终端确认的本人，任何 user 业务能力仍需本人的相应授权。

### 手动维护此项目登录（PowerShell）

下面命令只管理项目 CLI，不使用全局默认账号：

```powershell
Set-Location 'E:\源丶工程\gpt-claw'
$env:LARKSUITE_CLI_CONFIG_DIR = Join-Path (Get-Location) 'data/lark-cli'
$env:LARKSUITE_CLI_BRAND = 'feishu'
& '.\node_modules\@larksuite\cli\bin\lark-cli.exe' auth status --json --verify
& '.\node_modules\@larksuite\cli\bin\lark-cli.exe' auth logout
```

自定义 dataDir 时替换对应目录。不要在保留其他项目身份的终端中长期复用这组变量；认证管理命令不能继承外部 APP/token 注入。

已有应用的新增权限先在应用后台开通，再对项目 CLI 进行增量 `auth login --scope "<具体 scope>"`。重启只检查身份，不会自动重新申请所有已登录账号缺少的 scope；实际 CLI 命令返回可识别的 `missing_scope` 或缺权限信息，且命令明确标记 `--as user` / `--as bot` 时，服务会发送对应授权入口。无法识别身份或具体用户 scope 时不猜测授权范围。机器人身份缺权限时提供开发者后台链接，不对机器人执行用户登录。应用 Secret 轮换后需同步项目 CLI 绑定；换 App ID 时，本人 open_id 也可能变化，不能照搬另一应用的 ID。

## 4. 本次复核改了什么

| 文件 | 调整 |
|---|---|
| `device-auth.ts` | verify、结构化结果、超时/取消、首次本人绑定、身份不匹配退出及错误降噪 |
| `config.ts / .env.example` | 本人可留空，从终端认证绑定；旧示例占位值不算真实 ID |
| `main.ts` | 引导进入统一启动异常处理，信号取消与实例锁释放；退出等待业务收尾 |
| `codex/rpc.ts` | 明确项目根标记；项目 CLI 环境；Windows 原生子进程退出 |
| `codex/project-config.ts` | 原生项目配置读取、信任登记及加载检查 |
| `codex/runtime.ts` | config/read 检查工程加载层和有效权限；原生 Skill extra roots；同一聊天从原生线程恢复 |
| `feishu/channel.ts` | 上传按 SDK 真实平铺的 image_key/file_key 读取，去掉掩盖返回值错误的 as any |
| `app/application.ts / prompts.ts` | 同聊天归一化按到达顺序处理；前台停止只取消对应会话的确认 |
| `services/schedules.ts` | 判断两次 cron 触发之间的间隔，不把“距离下一次不足一分钟”当作无效 |
| `package.json` 等 | 固定 CLI 版本；TS 工具示例也进入类型检查；补架构/扩展/规划文档 |

原 AI 对 jobs.create 的 ID 显式标注 string 已保留。

## 5. 纠正“工程配置完全无效”的结论

旧记录把“doctor 显示家目录配置路径”推断为“Codex 0.157.1 永远不读取项目 TOML”。这个推断不能成立。官方明确支持**可信项目**的 `.codex/config.toml`，其加载还依赖项目发现、cwd 和配置层。[官方配置层说明](https://learn.chatgpt.com/docs/config-file/config-basic)

当前做法：

1. 在启动参数中用 `.codex` 作为项目根标记。0.157.1 的 `-c projects...trust_level` 不能代替持久化的工程信任；已通过实际配置读取确认。
2. 调用原生 `config/read`，传入工程根目录与 includeLayers=true。
3. 必须出现启用的工程 project 层，实际 policy 必须是 `on-request / user / workspace-write`；否则报错，不默默继承更宽松权限。
4. 如果工程层明确因缺少信任而禁用，通过原生 `config/value/write` 在用户级配置中记录本工程根的信任，带 `expectedVersion` 防止覆盖并发改动，再重新读取。保留其他项目和设置，不自动覆盖已有适用的 `untrusted` 决定。
5. **工程权限与 MCP 配置不迁到家目录，不迁移 CODEX_HOME**。仅信任元数据按原生机制持久化，保留本人的原生登录和会话存储。

模型默认使用 Codex 原生登录。OpenAI API 只需 `MODEL_API_KEY`，DeepSeek API 只需 `DEEPSEEK_API_KEY`；第三方 Responses 服务再配置 `MODEL_BASE_URL` 和 `MODEL_NAME`。OpenAI 通过原生 `account/login/start` 使用进程内凭证；DeepSeek 和自定义服务使用原生 provider 的 `env_key`，Key 仅注入 Codex 进程，工具 Shell 中同名变量为空，飞书 CLI 不继承。启动核对实际 provider；自定义服务不要求 ChatGPT 登录，也不会将第三方 Key 当作 OpenAI Key 登录。[配置与边界](model-providers.md)

“project 文件存在”“全局 doctor 输出某路径”都不是项目配置已生效的证据；以实际 config/read 层和值为准。2026-09-28 通过内置 0.157.1 的原生配置接口确认：本机工程层已启用，实际 policy 为 `on-request / user / workspace-write`；没有执行模型轮次或飞书扫码会话。

原 AI 报告过本机用户级 MCP 缺变量及废弃选项，那是当时本机环境观察，不能作为所有安装必填项。信任登记只处理本工程元数据；不重置用户级配置或认证。

## 6. SDK / app-server 的接法

本工程目前依赖 `@openai/codex` 的固定 CLI，自己实现很薄的 stdio JSON-RPC 客户端。**不是** `@openai/codex-sdk` TypeScript SDK，也不是直接调用 OpenAI Responses API。

选择 app-server 是为了原生审批反向请求、会话控制及执行中交互。官方将自定义审批/历史/事件客户端指向 app-server；Python Codex SDK 同样基于该协议，不能笼统说“SDK 不能做这些”。[官方 SDK 定位](https://learn.chatgpt.com/docs/codex-sdk)

另一位 AI 所说“SDK 无法过滤环境变量”也不是 API 本质限制：支持传 env 的入口可以传过滤后的对象。本工程已有自己的 RPC 进程边界，因此在这里实现过滤。

官方目前说明 app-server 命令仍具实验性质；本工程固定版本，并将协议变化限制在 `src/codex/`。升级前核对目标版本 schema，不能承诺跨版本兼容。[官方协议与成熟度](https://learn.chatgpt.com/docs/app-server)

## 7. 验证状态及下一步

本次执行静态 `npm run check` 与构建，并使用原生配置接口排查工程层加载；没有运行测试或启动额外的真人授权/机器人/模型会话。原 AI 的 doctor、空配置探测和临时凭证记录属于其当时报告，未在本次重复。服务日志使用本机时区，格式为 `YYYY-MM-DD HH:mm:ss`；持久化时间仍使用时间戳或 UTC。

需要本人实际完成的链路：

- 应用扫码及 CLI 扫码完成，凭证/本人写回；随后 verify 的账号与本人一致。
- Codex 启动显示已加载工程配置。
- 私聊/群提及能收消息；普通文字、图片图文、语音已有转写、引用及卡片历史人物信息一致。
- 真正的原生权限请求转成卡片；允许、拒绝、超时、中断均正确。
- 浏览器观察与操作、发送产物、后台结果及定时投递。
- 服务退出再启动后，已执行副作用不自动重放；运行中任务标记中断。

实例锁通过 PID 检查陈旧状态；强杀后下次启动可恢复。没有为整个系统新增定时模型心跳。
