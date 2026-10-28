# 模型服务配置

更新：2026-09-29。执行内核仍为工程固定版本 Codex 0.157.1，API 模式使用其原生 Responses 协议。无需安装第二个智能体或修改用户级模型服务配置。

## 日常只需选择一种

| 想使用 | `.env` 中填写 |
| --- | --- |
| 已登录的 Codex | 不填模型变量；未登录时运行 `npm run codex:login` |
| OpenAI API | `MODEL_API_KEY=你的OpenAI密钥` |
| DeepSeek API | `DEEPSEEK_API_KEY=你的DeepSeek密钥` |
| 其他 Responses 兼容 API | `MODEL_API_KEY`、`MODEL_BASE_URL`、`MODEL_NAME` |

两个 Key 只能选一个。`MODEL_BASE_URL` 是 API 根地址，不包含 `/responses` 或 `/chat/completions`；`MODEL_NAME` 是服务端模型 ID。只填 `MODEL_API_KEY` 时使用 OpenAI 默认地址；只填 `DEEPSEEK_API_KEY` 时使用 DeepSeek 默认地址和 `deepseek-flash`。可选的 `MODEL_EFFORT` 留空使用模型默认推理档位。

系统环境变量优先于 `.env`。修改配置需要重启，不自动回退到其他付费服务。

## 使用方式

### 原生登录

`.env` 不写任何模型变量。使用 `npm run codex:login` 登录。此模式保留用户原生 Codex provider、模型和认证设置；登录状态与具体计费方式以原生账号为准。

### OpenAI API

```ini
MODEL_API_KEY=填写OpenAI的Key
```

默认地址为 `https://api.openai.com/v1`。需要指定模型时再写 `MODEL_NAME`；留空使用原生模型设置。认证通过 `account/login/start`，凭证只在当前 Codex 子进程内存保存；不会覆盖已有原生登录。[OpenAI 原生认证](https://learn.chatgpt.com/docs/app-server#2-log-in-with-an-api-key)

### DeepSeek

```ini
DEEPSEEK_API_KEY=填写DeepSeek的Key
```

默认地址为 `https://api.deepseek.com`，默认模型为 `deepseek-flash`；需要时可以用 `MODEL_NAME=deepseek-v4-pro` 改模型。使用 DeepSeek 的代理地址时，可同时写 `MODEL_BASE_URL=代理的API根地址`，仍按 DeepSeek 模型能力处理。DeepSeek 已提供原生 Responses API 与 Codex 接入说明。[DeepSeek Codex 接入](https://api-docs.deepseek.com/quick_start/agent_integrations/codex/) · [Responses API](https://api-docs.deepseek.com/guides/responses_api/)

工程模型目录 `.codex/models/deepseek.json` 声明工具格式、上下文窗口和模型输入能力。Flash 支持文字和图片；V4 Pro 声明为文字输入。目录保留简洁基础指令，个人助理行为仍由工程 `AGENTS.md` 约束。新增 DeepSeek 模型时需要按官方能力更新目录，不能仅修改模型名称就假定所有工具与图片能力相同。

DeepSeek 模式关闭 Codex 原生 web search 和 code mode，使用普通函数工具、原生命令工具及 `apply_patch`。工程的浏览器工具、Skills 和本机 personal MCP 仍由 Codex 提供。DeepSeek 不提供 OpenAI 原生图片生成等全部托管工具，不能因模型 API 接通就假定这些能力可用。[DeepSeek 协议能力](https://api-docs.deepseek.com/guides/responses_api/)

### 其他第三方 / 自建服务

```ini
MODEL_API_KEY=填写服务的Key
MODEL_BASE_URL=https://你的服务地址/v1
MODEL_NAME=服务端的模型ID
```

地址中是否包含 `/v1` 取决于服务本身；Codex 会在根地址下请求 `/responses`。仅支持 `/chat/completions` 的服务无法直接使用，需由该服务或外部网关提供 Responses 兼容。当前 Codex 原生 `wire_api` 只支持 `responses`。[OpenAI provider 配置](https://learn.chatgpt.com/docs/config-file/config-advanced#custom-model-providers) · [配置字段](https://learn.chatgpt.com/docs/config-file/config-reference#configtoml)

通用第三方模式不会猜测服务端的图片、推理或特殊工具能力；需要特殊模型元数据时使用 Codex 原生模型目录配置。第三方模式默认关闭原生 web search，不把后端不支持的搜索当作可用能力。

## 实现与认证边界

- `src/codex/provider.ts` 负责环境配置校验及原生 provider 参数生成；不实现另一套模型循环或协议代理。
- Provider 参数通过子进程 `-c` 覆盖；不会将模型服务设置写入用户级 Codex 配置。工程信任登记仍按原生机制独立处理。
- OpenAI Key 通过原生认证 RPC 传入；第三方 Key 通过专用 `GPT_CLAW_PROVIDER_API_KEY` 环境变量仅注入 Codex 进程，由 native `env_key` 获取。工具 Shell 的同名变量被设置为空，飞书 CLI 子进程也会过滤它。
- Key 不进入命令参数、应用日志、模型提示或模型目录。本人电脑上的进程环境和 `.env` 仍属于本机敏感数据，不构成对本机程序的隔离边界。
- 会话创建/恢复明确传入当前 API provider 和模型，避免恢复旧会话时沿用旧 provider。不会清空历史或把请求自动切回 OpenAI。
- `doctor` 只检查本地配置，不请求模型或验证余额。当前完成类型检查和构建，未运行测试或付费 API 会话；实际 Key、额度、服务端兼容性需要使用时确认。
