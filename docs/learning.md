# 记忆与跨会话历史

gpt-claw 的 Agent 后端使用 Codex 原生线程和本地记忆，不再为检索或学习额外写入 `history`、`learning_episodes` 或 Markdown 记忆。项目 `.codex/config.toml` 开启 `features.memories`。这与 ChatGPT 网页版记忆是两套存储；原生记忆由 Codex 在空闲时整理，不保证刚说过的话立刻成为记忆，也不是完整聊天备份。[Codex 记忆说明](https://learn.chatgpt.com/docs/customization/memories)

## 如何使用

- 同一聊天继续发送消息：gpt-claw 恢复该聊天对应的 Codex 线程，沿用原生上下文；`/new` 才切换新线程，旧线程由 Codex 保留。
- 新会话复用过去的偏好：Codex 原生记忆可能在空闲时从旧对话提炼并在后续会话引用；是否生成、何时引用由 Codex 控制。它不会让新会话看到每句旧消息，也不能用于逐字检索。[Codex 记忆说明](https://learn.chatgpt.com/docs/customization/memories)
- 需要逐字查看旧的 Codex 对话：在 Codex 原生客户端中打开保存的线程。gpt-claw 不提供跨线程正文搜索工具；`/new` 不删除旧线程。[App-server 线程接口](https://learn.chatgpt.com/docs/app-server)
- 查飞书中没有进入模型的原始消息、卡片或他人发言：使用 `personal.feishu_history`。原生线程不等于完整飞书聊天记录。
- 需要始终遵守的性格、偏好和工作规则：直接编辑工程 `AGENTS.md`，重启服务后用 `/new` 开始新会话。原生记忆适合自动提炼可复用信息，不适合作为必须立即生效的配置。

桌宠在 `desktop/data/chat/` 保存界面展示用的 JSONL、搜索索引和投递收据；gpt-claw 的 `data/state.sqlite` 保存收件去重、发件重试和会话 ID 映射。完整模型对话与上下文管理交给 Codex 原生线程，桌宠展示记录不逐轮重新拼入模型上下文。这些界面与投递状态不会自动成为 Codex 记忆。

## 已发送队列正文的保留期限

发件队列用于可靠投递，不作为聊天记录库。飞书接口返回成功、或桌宠保存回复并返回 `surface.ack` 后，服务才标记为已发送，并记录成功时间。从该时间起默认保留正文 7 天；可在 `.env` 设置 `OUTBOX_SENT_RETENTION_DAYS=7`，范围为 1–365 天，重启服务生效。

服务持续运行并保留最终回复卡片时，桌宠重连后返回的迟到确认也会回写队列，包括已经耗尽重试的记录；重复确认不重置成功时间。服务重启后，已耗尽重试的记录需要手动重试。在原聊天发送 `/status`，查看 `delivery.failed[].id` 中的投递编号，再发送 `/retry 编号`，只重投原回复，不重新执行任务。状态查询仅统计当前聊天，最多列出最早 20 条失败记录及失败次数；有更多时会提示，重投后再次查询可查看后续记录。

服务启动时及运行期间每小时检查一次，清除到期已发送记录的正文、统计文字、投递参数和错误内容，保留消息编号、目标聊天、投递 ID、远端消息 ID、重试次数、成功时间与状态。待发送及失败记录保留原文，继续支持重试；桌宠展示记录和 Codex 原生线程不受影响。升级前没有成功时间的旧记录从升级后首次启动起算，享有完整保留期限。

这是队列表字段的逻辑清理，不承诺 SQLite 文件立即缩小或磁盘数据安全擦除，也不清除其他位置的日志与备份。

## 本轮上下文

新消息不再每轮附带会话目录和共享屏幕长提示。文件目录与本轮电脑状态改由只读 `personal.session_info` 按需查询，结果仍会进入原生工具历史；真实附件、引用与人物提及继续保留必要上下文。旧会话已有的前缀不回写删除，`/new` 只是换新线程，并不会清理历史。

## ChatGPT 桌面端与本地任务历史

ChatGPT 桌面端可以展示本地 Work/Codex 任务；因此不能把“使用 Codex 的历史在 ChatGPT 中一律看不到”作为结论。桌面端本地任务与普通云端聊天的同步范围不同：云端 Work 会话可以跨网页、移动端与桌面端同步，本地任务保留在当前电脑。参见[官方桌面历史说明](https://learn.chatgpt.com/docs/whats-new#keep-work-conversations-and-projects-together-on-desktop)及[桌面模式比较](https://learn.chatgpt.com/docs/use-chatgpt#compare-chatgpt-work-and-codex-on-desktop)。

gpt-claw 通过官方 app-server 创建和恢复 Codex 原生线程，当前启动代码没有单独设置 `CODEX_HOME`，会继承启动环境中的原生存储位置。这说明它没有另建一份完整模型历史，但不能单凭存储共用就保证桌面端会展示每个线程：客户端还可能按线程来源、模型服务或项目筛选；官方 `thread/list` 接口本身也有来源与模型服务过滤项。参见[线程接口](https://learn.chatgpt.com/docs/app-server#threads)。

截至 2026-10-19，本轮只核对了启动代码和官方说明，尚未在桌面端定位一条由 gpt-claw 实际创建的线程。用户已确认自己能在 ChatGPT 桌面端看到 Codex 历史，这与上述区分一致；不能进一步声称 gpt-claw 的所有线程已自动显示，也不能把桌宠 JSONL、业务 SQLite 或记忆提炼称为 ChatGPT 聊天同步。

## 旧数据

此前 `data/state.sqlite` 中的 `history`、`learning_episodes`、`learning_candidates` 表和 `data/memory/` 文件保持原样，避免删除本人资料。新代码不再写入或读取这些旧表，也不会自动把它们伪装成 Codex 原生记忆。旧的 `/learn`、`/reflect` 只返回迁移提示；它们会从飞书命令面板移除。需要迁出旧记录时，应单独审核内容后再写入 `AGENTS.md` 或交给 Codex。

原生记忆提炼可能产生额外模型用量；本工程不另加心跳或定时反思。记忆是否生成、何时引用由 Codex 控制，第三方模型服务的实际表现需要在对应服务下观察。[配置参考](https://learn.chatgpt.com/docs/config-file/config-reference)
