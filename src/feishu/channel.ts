import { WSClient, EventDispatcher, Domain, LoggerLevel } from "@larksuiteoapi/node-sdk";
import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { randomUUID } from "node:crypto";
import { basename, extname } from "node:path";
import type { Config } from "../config.ts";
import type { Channel, Prompt, PromptResult, ReplyTarget } from "../app/ports.ts";
import { InboundNormalizer } from "./normalizer.ts";
import { promptCard } from "./prompt-card.ts";
import { errorMessage, log } from "../shared/log.ts";
import { parseCommand } from "../app/commands.ts";
import { statusMarkdown, streamingCard } from "./reply-card.ts";
import type { SessionFiles } from "../services/session-files.ts";

export interface IncomingMessage {
  message_id: string; chat_id: string; chat_type: string; message_type: string;
  content: string; parent_id?: string; mentions?: Array<{ key?: string; name?: string; id?: { open_id?: string } }>;
  senderId: string;
}
export interface CardAnswer { token: string; value: string; owner: string; chatId?: string; messageId?: string; }

function card(text: string, title?: string, elements: unknown[] = []) {
  return { schema: "2.0", config: { update_multi: true },
    ...(title ? { header: { title: { tag: "plain_text", content: title } } } : {}),
    body: { elements: [{ tag: "markdown", content: text.slice(0, 16_000) }, ...elements] } };
}

function isSupportedSlashMessage(message: { message_type?: string; content?: string }): boolean {
  if (message.message_type !== "text" || typeof message.content !== "string") return false;
  try {
    const content: unknown = JSON.parse(message.content);
    return !!content && typeof content === "object" && "text" in content
      && typeof content.text === "string" && !!parseCommand(content.text);
  } catch { return false; }
}

/** Bot application identity only. Neither transport nor normalization calls a local CLI. */
export class FeishuChannel implements Channel {
  private _normalizer?: InboundNormalizer;
  get normalizer(): InboundNormalizer {
    return this._normalizer ??= new InboundNormalizer({
      appId: this.config.appId, appSecret: this.config.appSecret,
      dataDir: this.config.dataDir, domain: this.config.domain,
      sessionDirectory: chatId => this.files.inbound(`chat:${chatId}`),
    });
  }
  private ws?: WSClient;
  onMessage?: (message: IncomingMessage) => Promise<void>;
  onAnswer?: (answer: CardAnswer) => boolean;
  constructor(private readonly config: Config, private readonly files: SessionFiles) {}
  async start(): Promise<void> {
    await this.normalizer.initialize();
    const dispatcher = new EventDispatcher({}).register({
      "im.message.receive_v1": async (event: any) => {
        const owner = event.sender?.sender_id?.open_id, message = event.message;
        if (owner !== this.config.owner || event.sender?.sender_type !== "user" || !message?.chat_id) return;
        const mentioned = message.mentions?.some((mention: any) => mention.id?.open_id === this.normalizer.botOpenId);
        // A command selected from the native / menu can arrive without an @ mention.
        // The sender was already checked against the configured owner above.
        if (message.chat_type === "group" && !mentioned && !isSupportedSlashMessage(message)) return;
        void this.onMessage?.({ ...message, senderId: owner }).catch(error => log.error(`接收消息失败：${errorMessage(error)}`));
      },
      "card.action.trigger": async (event: any) => {
        const value = event.action?.value;
        const accepted = value?.gpt_claw_token && this.onAnswer?.({ token: String(value.gpt_claw_token), value: String(value.answer), owner: event.operator?.open_id || "", chatId: event.context?.open_chat_id, messageId: event.context?.open_message_id });
        return { toast: { type: accepted ? "success" : "error", content: accepted ? "已收到你的选择" : "请求已结束或没有操作权限" } };
      },
    });
    this.ws = new WSClient({ appId: this.config.appId, appSecret: this.config.appSecret, domain: this.config.domain === "lark" ? Domain.Lark : Domain.Feishu, loggerLevel: LoggerLevel.error });
    await this.ws.start({ eventDispatcher: dispatcher });
  }
  async send(chatId: string, text: string): Promise<string> {
    let first = "";
    const chunks = splitMessage(text || "没有返回正文");
    for (const chunk of chunks) {
      const result = await this.normalizer.client.im.v1.message.create({ params: { receive_id_type: "chat_id" }, data: { receive_id: chatId, msg_type: "interactive", content: JSON.stringify(card(chunk)) } });
      if (result.code !== 0 || !result.data?.message_id) throw new Error(`飞书发送失败：${result.code} ${result.msg || ""}`);
      first ||= result.data.message_id;
    }
    return first;
  }
  async update(messageId: string, text: string, title?: string): Promise<void> {
    const result = await this.normalizer.client.im.v1.message.patch({ path: { message_id: messageId }, data: { content: JSON.stringify(card(text, title)) } });
    if (result.code !== 0) throw new Error(`飞书卡片更新失败：${result.code} ${result.msg || ""}`);
  }
  async startReply(chatId: string, sourceMessageId: string, content: string, status: string): Promise<ReplyTarget> {
    const client = this.normalizer.client;
    try {
      const created = await client.cardkit.v1.card.create({ data: { type: "card_json", data: JSON.stringify(streamingCard(content, status)) } });
      if (created.code !== 0 || !created.data?.card_id) throw new Error(`CardKit 创建失败：${created.code} ${created.msg || ""}`);
      const cardId = created.data.card_id;
      const sent = await client.im.v1.message.reply({ path: { message_id: sourceMessageId }, data: { msg_type: "interactive", content: JSON.stringify({ type: "card", data: { card_id: cardId } }) } });
      if (sent.code !== 0 || !sent.data?.message_id) throw new Error(`CardKit 回复失败：${sent.code} ${sent.msg || ""}`);
      return { messageId: sent.data.message_id, cardId, sequence: 0 };
    } catch (error) {
      log.warn(`流式卡片不可用，改用普通卡片：${errorMessage(error)}`);
      const sent = await client.im.v1.message.reply({ path: { message_id: sourceMessageId }, data: { msg_type: "interactive", content: JSON.stringify(card(content, undefined, [{ tag: "markdown", content: statusMarkdown(status), text_size: "notation" }])) } });
      if (sent.code === 0 && sent.data?.message_id) return { messageId: sent.data.message_id, sequence: 0 };
      return { messageId: await this.send(chatId, content), sequence: 0 };
    }
  }
  async updateReply(target: ReplyTarget, content: string, sequence: number): Promise<void> {
    if (!target.cardId) return this.update(target.messageId, content);
    const result = await this.normalizer.client.cardkit.v1.cardElement.content({ path: { card_id: target.cardId, element_id: "stream_md" }, data: { content, sequence } });
    if (result.code !== 0) throw new Error(`CardKit 内容更新失败：${result.code} ${result.msg || ""}`);
  }
  async updateReplyStatus(target: ReplyTarget, status: string, sequence: number): Promise<void> {
    if (!target.cardId) return;
    const result = await this.normalizer.client.cardkit.v1.cardElement.content({ path: { card_id: target.cardId, element_id: "stats_md" }, data: { content: statusMarkdown(status), sequence } });
    if (result.code !== 0) throw new Error(`CardKit 状态更新失败：${result.code} ${result.msg || ""}`);
  }
  async finishReply(target: ReplyTarget, content: string, status: string | undefined, attempt: number): Promise<void> {
    if (!target.cardId) {
      const result = await this.normalizer.client.im.v1.message.patch({ path: { message_id: target.messageId }, data: { content: JSON.stringify(card(content, undefined, status ? [{ tag: "markdown", content: statusMarkdown(status), text_size: "notation" }] : [])) } });
      if (result.code !== 0) throw new Error(`飞书卡片更新失败：${result.code} ${result.msg || ""}`);
      return;
    }
    const sequence = target.sequence + attempt + 1;
    const result = await this.normalizer.client.request({ method: "PUT", url: `/open-apis/cardkit/v1/cards/${encodeURIComponent(target.cardId)}`, data: {
      card: { type: "card_json", data: JSON.stringify(streamingCard(content, status, false)) }, sequence, uuid: randomUUID(),
    } }) as { code?: number; msg?: string };
    if (result.code !== 0) throw new Error(`CardKit 最终更新失败：${result.code} ${result.msg || ""}`);
  }
  async prompt(chatId: string, token: string, prompt: Prompt): Promise<string> {
    const result = await this.normalizer.client.im.v1.message.create({ params: { receive_id_type: "chat_id" }, data: { receive_id: chatId, msg_type: "interactive", content: JSON.stringify(promptCard(prompt, token)) } });
    if (result.code !== 0 || !result.data?.message_id) throw new Error(`飞书确认卡发送失败：${result.code} ${result.msg || ""}`);
    return result.data.message_id;
  }
  async finishPrompt(messageId: string, prompt: Prompt, outcome: PromptResult): Promise<void> {
    const result = await this.normalizer.client.im.v1.message.patch({ path: { message_id: messageId }, data: { content: JSON.stringify(promptCard(prompt, undefined, outcome)) } });
    if (result.code !== 0) throw new Error(`飞书确认卡更新失败：${result.code} ${result.msg || ""}`);
  }
  async sendFile(chatId: string, path: string): Promise<string> {
    const size = (await stat(path)).size;
    if (!size || size > 30_000_000) throw new Error("飞书文件必须非空且不超过 30 MB");
    // Larger images remain deliverable as files when they exceed the image API limit.
    const image = size <= 10_000_000 && [".png", ".jpg", ".jpeg", ".webp", ".gif"].includes(extname(path).toLowerCase());
    let content: Record<string, string>;
    if (image) {
      const response = await this.normalizer.client.im.v1.image.create({ data: { image_type: "message", image: createReadStream(path) } });
      if (!response?.image_key) throw new Error("图片上传未返回 image_key");
      content = { image_key: response.image_key };
    } else {
      const response = await this.normalizer.client.im.v1.file.create({ data: { file_type: "stream", file_name: basename(path), file: createReadStream(path) } });
      if (!response?.file_key) throw new Error("文件上传未返回 file_key");
      content = { file_key: response.file_key };
    }
    const result = await this.normalizer.client.im.v1.message.create({ params: { receive_id_type: "chat_id" }, data: { receive_id: chatId, msg_type: image ? "image" : "file", content: JSON.stringify(content) } });
    if (result.code !== 0 || !result.data?.message_id) throw new Error(`文件投递失败：${result.code} ${result.msg || "未返回消息 ID"}`);
    return result.data.message_id;
  }
  async close(): Promise<void> { this.ws?.close({ force: true }); }
}

function splitMessage(text: string): string[] {
  const chunks: string[] = [];
  while (text.length > 15_000) { const newline = text.lastIndexOf("\n", 15_000); const at = newline > 7500 ? newline : 15_000; chunks.push(text.slice(0, at)); text = text.slice(at); }
  if (text) chunks.push(text);
  return chunks;
}
