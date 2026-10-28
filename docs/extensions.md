# Skills、TypeScript Tool、MCP

## 选择方式

| 要扩展什么 | 放哪里 | 边界 |
|---|---|---|
| 工作流程、软件操作知识、脚本说明 | `.agents/skills/<name>/SKILL.md` | 模型按需读取；不是权限控制 |
| 本工程自己的确定性操作 | `tools/<name>.ts` | 标准参数、描述与返回值，通过 personal MCP 注册 |
| 跨工程服务/现成工具服务器 | `.codex/config.toml` 的 `mcp_servers` | 使用 Codex 原生 MCP 客户端 |
| 通用身份和口吻 | `AGENTS.md` | 不塞入全部工具用法 |
| Shell 命令权限 | Codex 原生配置/规则 | 本工程不再额外解析命令组合 |

## 1. 原生 Skill

目录示例：

```text
.agents/skills/report-helper/
  SKILL.md
  scripts/
  references/
```

`SKILL.md` 使用 Codex 原生格式：YAML frontmatter 中填写 `name` 与 `description`，正文写触发场景、具体步骤和引用资料。工具调用仍受原生执行权限约束。不要在 Skill 内保存账号密钥或把“不要执行某命令”当成不可绕过的权限规则。

启动通过原生 `skills/extraRoots/set` 加入工程技能目录，因此没有 Git 历史的新工程也有明确的技能入口；其余原生发现和按需加载由 Codex 完成。[官方 Skills 说明](https://learn.chatgpt.com/docs/build-skills)

## 2. TS Tool

将 `tools/examples/workspace-summary.ts` 复制为 `tools/workspace-summary.ts`，把其中契约导入从 `../../src/tools/contract.ts` 改成 `../src/tools/contract.ts` 后重启，即会注册额外工具。示例目录自身不自动加载。

每个顶层 `.ts` / `.js` / `.mjs` 文件默认导出一个 `ToolSpec`：

```ts
import { z } from "zod";
import { defineTool } from "../src/tools/contract.ts";

export default defineTool({
  name: "my_tool",
  description: "具体说明用途、什么时候调用、参数含义和实际返回的结果。",
  input: { query: z.string().min(1).max(200) },
  readOnly: true,
  confirmation: false,
  async run({ query }, { session, services, signal }) {
    signal.throwIfAborted();
    return { query, chatId: session.chatId, workspace: services.workspace };
  },
});
```

- `name` 必须是小写英文开头、只含小写字母/数字/下划线；最长 64；不能与内置工具重复。
- `input` 是 Zod 字段映射。Host 使用 strict object 拒绝未知参数。
- `description` 承担模型使用说明；新增工具不需要修改静态提示。
- 自定义工具省略 `confirmation` 时默认要求确认；可给布尔值或按参数返回布尔值的函数。`readOnly` 仅是 MCP 提示元数据，不决定确认或 OS 权限。
- `session.chatId` 和 `session.sessionKey` 来自服务绑定，不能让模型随意选择发送对象。
- `services` 提供记忆、浏览器、任务、日程、存储、通道和工作区；工具最好调用服务方法，不把复杂业务写进定义文件。
- `signal` 用于协作取消；需要传给支持取消的网络/子进程 API。先检查 signal 不代表后续外部操作可以回滚。
- 返回字符串或 JSON 兼容值。大输出会截断到 50,000 字符；返回产物路径，让 `send_file` 交付。
- TS Tool 是本人安装的可信代码，以服务进程权限运行，不受原生 Codex 文件沙箱自动保护。

`npm run check` 会检查 `src/` 与 `tools/` 的 TS 文件。构建只编译核心；启动时工具仍从工程目录由 tsx 加载。运行热重载不能代替工具类型检查。

## 3. 外部 MCP

在 `.codex/config.toml` 中加原生条目，例如已有本地 stdio 服务：

```toml
[mcp_servers.my_service]
command = "node"
args = ["C:/absolute/path/server.js"]
enabled = true
startup_timeout_sec = 30
tool_timeout_sec = 120
```

HTTP 服务使用对应的 `url` 配置；鉴权引用原生支持的环境变量/登录方式。不要写明文密钥，也不要把 OpenClaw 或 Pi 的 MCP JSON 原样当作 Codex TOML。

`personal` 为本工程保留的 MCP 名称：端口与 capability URL 按会话动态注入，不能手填固定 URL。外部服务的授权范围、确认方式和副作用需要按该服务的原生配置设置；内置业务确认层只包裹 personal 工具。

当前可将原生 MCP URL 授权与简单字符串/布尔/枚举表单转到飞书；复杂表单会拒绝而不是猜答。需要本机浏览器或原生 CLI 的 OAuth 仍由本人完成。

## 4. 飞书 CLI

工程固定安装 `@larksuite/cli@1.0.95`。启动认证与原生命令子进程默认使用 `data/lark-cli`，应用与用户令牌由 CLI 自管。本人账号不是机器人账号：以机器人发消息优先使用本工程通道；业务 CLI 命令必须显式选择 `--as user` 或 `--as bot`。

技能中的裸命令 `lark-cli ...` 按执行环境的 PATH 查找程序。工程将内置二进制目录放在 PATH 首位，随后是工程 `node_modules/.bin`，并通过原生 `shell_environment_policy.set` 显式传入 PATH、项目配置目录和 brand，因此不依赖 `npm start` 自动增加 PATH。内置二进制缺失时启动报错，不自动改用全局版本。启动认证直接调用内置程序的绝对路径。

PATH 优先级是默认命令解析方式，不是禁止运行其他程序的安全边界。显式指定全局程序路径、Shell 别名/函数、重写 PATH 或清除项目配置变量仍可绕过；工程指令禁止助理这样做。Windows 下在 Codex 子进程的 PATH 中排除 WindowsApps 路径，并指示助理用系统 `powershell.exe` 执行只读命令：其中的 MSIX `pwsh.exe` 可能无法在 Codex 原生沙箱中启动。不会修改系统 PATH。原生 Shell 若配置环境变量 include 过滤，还需保留 PATH 与上述 `LARKSUITE_CLI_*` 绑定。[原生环境策略说明](https://learn.chatgpt.com/docs/config-file/config-advanced#shell-environment-policy)

当前没有 `lark_execute` 一类通用业务工具，也不额外实现 Shell 命令代理。需要某项个人飞书能力时，可安装对应 Skill，通过原生命令执行，或封装一个目标明确的 TS Tool；其权限和身份仍必须保持明确。

启动用户授权统一使用 CLI 原生 `--recommend`，无需配置额外环境变量。内置 1.0.95 的 `--recommend` 与 `--domain all` 等价。业务命令应带 `--json` 且明确 `--as user` 或 `--as bot`。运行中若命令返回可识别的缺权限信息，服务会按身份分别发送补授权链接或应用权限后台链接；用户授权会由内置 CLI 在后台轮询完成，之后需要重试原请求。无法辨认身份或 scope 时不会自动发起用户授权。
