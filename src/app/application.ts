import type { IncomingMessage } from "../feishu/channel.ts";
import { FeishuChannel } from "../feishu/channel.ts";
import type { DesktopMessage } from "../desktop/types.ts";
import { ReplyStream } from "../feishu/stream.ts";
import { finalReply } from "../feishu/reply-card.ts";
import { CodexRuntime, type AgentInput } from "../codex/runtime.ts";
import { Prompts } from "./prompts.ts";
import { Outbox } from "./outbox.ts";
import type { Channel, ReplyTarget, SessionContext } from "./ports.ts";
import type { Config } from "../config.ts";
import { Store } from "../storage.ts";
import { Jobs } from "../services/jobs.ts";
import { Schedules } from "../services/schedules.ts";
import { errorMessage, log } from "../shared/log.ts";
import { commandHelp, commandUsage, parseCommand } from "./commands.ts";
import { describeResult } from "./result.ts";
import { ScreenShare } from "../services/screen-share.ts";

interface QueuedMessage { id: string; context: SessionContext; input: AgentInput; screenShareId?: string; }
type InputMessage = IncomingMessage | DesktopMessage;
interface ChatQueue { messages: QueuedMessage[]; running?: Promise<void>; controller?: AbortController; }
function asksCurrentModel(text: string): boolean {
  const question = text.replace(/[\s?？。！!，,]/g, "");
  return /^(?:你|小助手)?(?:现在|当前)?(?:用|使用|跑|运行)?(?:的)?(?:是)?(?:什么|啥|哪个)模型(?:呢|呀)?$|^(?:你|小助手)?(?:现在|当前)?模型(?:是|为)?(?:什么|啥|哪个)(?:呢|呀)?$/.test(question);
}

export class Application {
  private readonly queues = new Map<string, ChatQueue>();
  private readonly incoming = new Map<string, Promise<void>>();
  private readonly buffered: InputMessage[] = [];
  private recovering = true;
  private closing = false;
  constructor(private readonly config: Config, private readonly feishu: FeishuChannel, private readonly channel: Channel, private readonly runtime: CodexRuntime, private readonly prompts: Prompts, private readonly outbox: Outbox, private readonly store: Store, private readonly jobs: Jobs, private readonly schedules: Schedules, private readonly screenShare: ScreenShare) {}
  receive(message: IncomingMessage): Promise<void> {
    if (message.senderId !== this.config.owner) return Promise.resolve();
    return this.accept(message);
  }
  async receiveDesktop(message: DesktopMessage): Promise<void> {
    if (this.closing) throw new Error("服务正在停止，暂不接收新消息");
    // accept writes the inbox synchronously; execution continues in the tracked chat queue.
    void this.accept(message).catch(error => log.error(`桌面消息处理失败：${errorMessage(error)}`));
  }
  async resetDesktop(chatId: string): Promise<void> {
    if (!chatId.startsWith("desktop:") || this.recovering || this.closing) throw new Error("桌面会话暂不可重置");
    if (this.incoming.has(chatId)) throw new Error("请等待当前消息进入队列后再新建对话");
    await this.resetChat({ chatId, sessionKey: `chat:${chatId}` });
  }
  private async resetChat(context: SessionContext): Promise<void> {
    const queue = this.queues.get(context.sessionKey);
    if (queue?.running || queue?.messages.length) throw new Error("请先 /stop，等待当前任务结束后再 /new");
    await this.runtime.reset(context.sessionKey);
    if (context.chatId.startsWith("desktop:")) this.screenShare.revoke(context.chatId);
  }
  private accept(message: InputMessage): Promise<void> {
    if (this.closing || !this.store.receive(message.message_id, message.chat_id, message)) return Promise.resolve();
    if (this.recovering) { this.buffered.push(message); return Promise.resolve(); }
    return this.enqueue(message);
  }
  async recoverPending(desktopOnly = false): Promise<void> {
    const pending = this.store.pendingMessages<InputMessage>().filter(message => !desktopOnly || "source" in message);
    if (pending.length) log.warn(`恢复 ${pending.length} 条尚未执行的消息`);
    const seen = new Set(pending.map(message => message.message_id));
    const operations = pending.map(message => this.enqueue(message));
    this.recovering = false;
    for (const message of this.buffered.splice(0)) if (!seen.has(message.message_id)) operations.push(this.enqueue(message));
    await Promise.allSettled(operations);
  }
  private enqueue(message: InputMessage): Promise<void> {
    // Normalize in arrival order per chat, independently of the long-running agent queue.
    const operation = (this.incoming.get(message.chat_id) || Promise.resolve()).then(() => this.process(message)).finally(() => {
      if (this.incoming.get(message.chat_id) === operation) this.incoming.delete(message.chat_id);
    });
    this.incoming.set(message.chat_id, operation);
    return operation;
  }
  private async process(message: InputMessage): Promise<void> {
    try {
      if (this.closing) return;
      const normalized = "source" in message
        ? { text: message.text,
            prompt: [message.text || (message.images.length ? "请查看这张图片。" : "请处理附件。"),
              ...(message.files || []).map(file => `本机附件：${file.path}`)].join("\n"),
            images: message.images }
        : await this.feishu.normalizer.normalize(message);
      if (this.closing) return;
      const text = normalized.text.trim(), context = { chatId: message.chat_id, sessionKey: `chat:${message.chat_id}` };
      const commandLabel = /^\/[a-z]+\b/i.exec(text)?.[0];
      log.conversation("本人", `${commandLabel ? `${commandLabel} [参数已隐藏]` : text || "[无文字内容]"}${normalized.images.length ? ` [图片 ${normalized.images.length} 张]` : ""}${"files" in message && message.files?.length ? ` [附件 ${message.files.length} 个]` : ""}`);
      // Only commands that can have effects leave the replayable state here.
      const command = parseCommand(text);
      if (command) this.store.messageStatus(message.message_id, "dispatching");
      if (await this.command(text, context, message)) { this.store.messageStatus(message.message_id, "completed"); return; }
      if (asksCurrentModel(text)) {
        this.store.messageStatus(message.message_id, "dispatching");
        const reply = this.modelReply(context);
        this.replyTo(message, reply);
        return;
      }
      const input = { prompt: normalized.prompt, images: normalized.images };
      const queue = this.queues.get(context.sessionKey) || { messages: [] };
      this.queues.set(context.sessionKey, queue);
      if (queue.messages.length >= 20) throw new Error("待处理消息太多，请等待或 /stop");
      // The model has not started yet, so a queued message is safe to replay.
      this.store.messageStatus(message.message_id, "queued");
      queue.messages.push({ id: message.message_id, context, input, screenShareId: "source" in message ? message.screenShareId : undefined });
      if (!queue.running) queue.running = this.drain(queue).finally(() => { queue.running = undefined; });
    } catch (error) {
      this.replyTo(message, `处理失败：${errorMessage(error)}`, true);
    }
  }
  private replyTo(message: InputMessage, text: string, failed = false, resetHistory = false): void {
    const target: ReplyTarget | undefined = "source" in message
      ? { messageId: message.message_id, chatId: message.chat_id, sequence: 0, failed, resetHistory }
      : undefined;
    this.outbox.complete(message.message_id, failed ? "failed" : "completed", message.chat_id, text, target);
  }
  private async command(text: string, context: SessionContext, message: InputMessage): Promise<boolean> {
    const command = parseCommand(text);
    if (!command) return false;
    const reply = (body: string) => this.replyTo(message, body);
    switch (command.name) {
    case "answer": {
      if (!command.arguments) { reply(`用法：${commandUsage("answer")}\n请求编号见需要回答的确认卡。`); break; }
      const match = /^([a-f0-9]{24})\s+([\s\S]+)$/.exec(command.arguments);
      if (!match || !this.prompts.answer(match[1], match[2], this.config.owner, context.chatId)) throw new Error("回答格式不正确或问题已过期");
      reply("已提交回答。");
      break;
    }
    case "help": reply(commandHelp()); break;
    case "model": reply(this.modelReply(context)); break;
    case "stop": {
      const queue = this.queues.get(context.sessionKey);
      for (const item of queue?.messages.splice(0) || []) {
        this.outbox.complete(item.id, "interrupted", item.context.chatId, "任务已中断，未开始执行。",
          item.context.chatId.startsWith("desktop:")
            ? { messageId: item.id, chatId: item.context.chatId, sequence: 0 }
            : undefined);
      }
      queue?.controller?.abort(); this.prompts.cancelSession(context.sessionKey);
      await this.runtime.stop(context.sessionKey);
      reply("已请求中断并清空当前聊天队列。后台任务需单独取消；已发生的操作不会回滚。");
      break;
    }
    case "new": {
      await this.resetChat(context);
      this.replyTo(message, "已创建新的会话入口，下一条消息会启动新线程。", false, true);
      break;
    }
    case "compact":
      await this.runtime.compact(context); reply("已提交原生上下文压缩请求。");
      break;
    case "steer": {
      const prompt = command.arguments;
      if (!prompt) { reply(`用法：${commandUsage("steer")}\n例如：/steer 先检查配置，暂时不要修改文件`); break; }
      if (!await this.runtime.steer(context, { prompt })) throw new Error("当前没有可追加指令的运行任务，请直接发送普通消息");
      reply("已把指令追加到当前任务。");
      break;
    }
    case "status": {
      const delivery = this.store.deliveryStatus(context.chatId);
      const retryHelp = delivery.failed.length
        ? `\n使用 /retry 投递编号 重投 delivery.failed 中的回复；不会重新执行原任务。${delivery.failedHasMore ? "当前列出最早 20 条，重投后再次 /status 可查看后续记录。" : ""}`
        : "";
      reply(`状态：\n\`\`\`json\n${JSON.stringify({ ...this.runtime.status(context.sessionKey) as object, queued: this.queues.get(context.sessionKey)?.messages.length || 0, delivery }, null, 2)}\n\`\`\`${retryHelp}`);
      break;
    }
    case "recovery":
      reply("/recovery 已移除。当前队列和投递状态可用 /status 查看；中断的操作不会自动重跑。");
      break;
    case "retry": {
      const id = Number(command.arguments);
      if (!Number.isSafeInteger(id) || id <= 0) throw new Error(`用法：${commandUsage("retry")}；用 /status 查看当前聊天的失败投递编号`);
      if (!this.outbox.retryFailed(context.chatId, id)) throw new Error("当前聊天没有这个投递失败的回复；用 /status 查看当前可重投的编号");
      reply(`已重新排队投递回复 ${id}；不会重新执行原任务。`);
      break;
    }
    case "jobs": {
      const jobs = this.jobs.list(context.chatId);
      reply(jobs.map(job => `${job.id}：${job.status}\n${job.prompt.slice(0, 100)}`).join("\n\n") || "没有后台任务。");
      break;
    }
    case "learn": case "reflect":
      reply("经验候选功能已停用。现在使用 Codex 原生记忆和会话历史；长期且必须遵守的偏好请写入工程 AGENTS.md。");
      break;
    case "schedules":
      reply(this.schedules.list(context.chatId).map(item => `${item.name} (${item.id})\n${item.enabled ? "启用" : "停用"}；下一次：${new Date(item.nextAt).toISOString()}`).join("\n\n") || "没有定时任务。");
      break;
    default: { const unhandled: never = command.name; throw new Error(`未实现命令：${unhandled}`); }
    }
    return true;
  }
  private modelReply(context: SessionContext): string {
    const info = this.runtime.modelInfo(context.sessionKey);
    return `当前模型：${info.model ?? "Codex 尚未报告"}\n推理档位：${info.effort ?? "模型默认"}\n模型服务：${info.provider}`;
  }
  private async drain(queue: ChatQueue): Promise<void> {
    while (queue.messages.length && !this.closing) {
      const item = queue.messages.shift()!;
      const fallbackTarget: ReplyTarget | undefined = item.context.chatId.startsWith("desktop:")
        ? { messageId: item.id, chatId: item.context.chatId, sequence: 0 }
        : undefined;
      const controller = new AbortController(); queue.controller = controller;
      const screenTurn = this.screenShare.beginTurn(item.context, item.screenShareId, controller.signal);
      let target: ReplyTarget | undefined, stream: ReplyStream | undefined;
      let opening: Promise<ReplyStream | undefined> | undefined;
      let latestText = "", latestStatus = "思考中", latestCommentary = "";
      const beginReply = () => {
        // Open the visible reply before thread setup or a long-running tool can stall.
        opening ??= ReplyStream.start(this.channel, item.context.chatId, item.id)
          .then(reply => {
            stream = reply;
            if (latestText) reply.update(latestText);
            reply.progress(latestStatus);
            if (latestCommentary) reply.note(latestCommentary);
            return reply;
          })
          .catch(() => undefined); // The durable final reply can still be sent as a normal message.
      };
      const startedAt = Date.now();
      this.store.messageStatus(item.id, "running");
      beginReply();
      try {
        const result = await this.runtime.run(item.context, item.input, controller.signal,
          text => { latestText = text; if (stream) stream.update(text); else beginReply(); },
          status => { latestStatus = status; if (stream) stream.progress(status); else beginReply(); },
          text => { latestCommentary = text; if (stream) stream.note(text); else beginReply(); });
        const { text, deliveryFailed } = describeResult(result);
        await opening;
        target = await stream?.close(text) || fallbackTarget;
        const reply = finalReply(text, Date.now() - startedAt, result.usage, result.model);
        this.outbox.complete(item.id, result.status === "interrupted" ? "interrupted" : deliveryFailed ? "failed" : "completed", item.context.chatId, reply.body,
          target && (result.status !== "completed" || deliveryFailed) ? { ...target, failed: true } : target,
          reply.stats);
      } catch (error) {
        const failure = `${controller.signal.aborted ? "任务已中断" : "任务失败"}：${errorMessage(error)}`;
        await opening;
        target = await stream?.close(failure) || fallbackTarget;
        this.outbox.complete(item.id, controller.signal.aborted ? "interrupted" : "failed", item.context.chatId, failure, target && { ...target, failed: true });
      } finally { screenTurn.close(); queue.controller = undefined; }
    }
  }
  stop(): void {
    this.closing = true;
    for (const queue of this.queues.values()) {
      queue.controller?.abort();
      // Queued messages have not called the model and can resume on next start.
      queue.messages.length = 0;
    }
  }
  async drainAll(): Promise<void> {
    await Promise.allSettled([...this.incoming.values()]);
    await Promise.allSettled([...this.queues.values()].map(queue => queue.running));
  }
}
