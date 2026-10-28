import type { Client } from "@larksuiteoapi/node-sdk";
import { botClient } from "./client.ts";
import { randomUUID } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import { join } from "node:path";
import { UserProfiles } from "./profiles.ts";
import { createHistoryCardReader } from "./history-card-reader.ts";
import { annotatePeople, cardMentionNames, cardVisibleText, expandCardMentions, personLabel, postAttachments, speechText } from "./inbound-content.ts";
import { sanitizeFileName } from "../shared/paths.ts";
interface BotIdentity { appId: string; appSecret: string; dataDir: string; domain: string; }

interface Mention { key?: string; name?: string; id?: string | { open_id?: string }; }
interface Message {
  message_id: string; message_type?: string; msg_type?: string; content?: string;
  body?: { content?: string }; parent_id?: string; mentions?: Mention[];
  upper_message_id?: string;
  sender?: { id?: string; sender_type?: string }; senderId?: string; senderName?: string;
  chat_id?: string; create_time?: string;
}
interface Resource { key: string; type: string; name?: string; messageId?: string; }
function parse(content: string): any {
  try {
    const value = JSON.parse(content);
    return value && typeof value === "object" && !Array.isArray(value) ? value : { text: typeof value === "string" ? value : content };
  } catch { return { text: content }; }
}
const idOf = (mention: Mention) => typeof mention.id === "string" ? mention.id : mention.id?.open_id;

/** Message content, quotes and history share one parser; only referenced messages are fetched. */
export class InboundNormalizer {
  readonly client: Client;
  readonly profiles: UserProfiles;
  botOpenId = "";
  botName = "小助手";
  private readonly missingProfiles = new Set<string>();
  private readCard?: ReturnType<typeof createHistoryCardReader>;
  constructor(private readonly options: BotIdentity & { sessionDirectory: (chatId: string) => string }) {
    this.client = botClient(options);
    this.profiles = new UserProfiles(options.appId, join(options.dataDir, "users"));
  }
  async initialize() {
    const result = await this.client.request({ method: "GET", url: "/open-apis/bot/v3/info/" }) as any;
    if (result.code !== 0 || !result.bot?.open_id) throw new Error(`机器人信息读取失败: ${result.code}`);
    this.botOpenId = result.bot.open_id; this.botName = result.bot.app_name || result.bot.bot_name || "小助手";
  }
  private async name(id: string, fallback?: string) {
    if (id === this.botOpenId || id === this.options.appId) return this.botName;
    const profile = await this.profiles.getUserProfile(id);
    if (profile.name || profile.en_name || fallback) return profile.name || profile.en_name || fallback!;
    if (/^ou_[A-Za-z0-9_-]+$/.test(id) && !this.missingProfiles.has(id)) {
      try {
        // Only a sender/mention/referenced sender reaches here; no roster or team enumeration.
        const result = await this.client.contact.v3.user.get({ path: { user_id: id }, params: { user_id_type: "open_id" } });
        if (result.code === 0 && result.data?.user) {
          const user = result.data.user;
          await this.profiles.putProfile(id, { name: user.name, en_name: user.en_name });
          return user.name || user.en_name || id;
        }
      } catch { /* Keep the actual ID when the app cannot read the profile. */ }
      this.missingProfiles.add(id);
    }
    return id;
  }
  async normalize(message: Message, signal?: AbortSignal) {
    if (!message.chat_id) throw new Error("飞书消息缺少聊天 ID");
    const sender = message.senderId || message.sender?.id || "";
    const folder = join(this.options.sessionDirectory(message.chat_id), sanitizeFileName(message.message_id));
    const result = await this.body(message, signal);
    const quotedResources: Resource[] = [];
    const quote = message.parent_id ? await this.quote(message.parent_id, new Set([message.message_id]), signal, quotedResources) : "";
    const images: Array<{ path: string; mediaType: string }> = [];
    const resources: string[] = [];
    const unique = new Map([...result.resources, ...quotedResources].map((item) => [`${item.messageId || message.message_id}:${item.key}`, item]));
    for (const resource of [...unique.values()].slice(0, 12)) {
      signal?.throwIfAborted();
      try {
        const response = await this.client.im.v1.messageResource.get({ path: { message_id: resource.messageId || message.message_id, file_key: resource.key }, params: { type: resource.type === "image" ? "image" : "file" } });
        const chunks: Buffer[] = []; let size = 0;
        for await (const chunk of response.getReadableStream()) {
          signal?.throwIfAborted(); const bytes = Buffer.from(chunk); size += bytes.length;
          if (size > 25 * 1024 * 1024) throw new Error("附件超过 25 MiB 下载限制");
          chunks.push(bytes);
        }
        const data = Buffer.concat(chunks);
        const path = join(folder, `${randomUUID().slice(0, 8)}-${sanitizeFileName(resource.name || `${resource.key}${resource.type === "image" ? ".png" : ""}`)}`);
        await mkdir(folder, { recursive: true });
        await writeFile(path, data);
        resources.push(`[${resource.type}] 已保存到: ${path}`);
        if (resource.type === "image") {
          const mediaType = data[0] === 0xff && data[1] === 0xd8 ? "image/jpeg" : data.subarray(0, 4).toString() === "RIFF" ? "image/webp" : data.subarray(0, 3).toString() === "GIF" ? "image/gif" : "image/png";
          images.push({ path, mediaType });
        }
      } catch (error) { resources.push(`[附件读取失败] ${String(error)}`); }
    }
    const senderName = await this.name(sender, message.senderName);
    // The channel already accepts only the owner; a missing name needs no ID prefix.
    const speaker = senderName && senderName !== sender ? `${senderName}：` : "";
    const prompt = `${quote}${speaker}${result.text}${resources.length ? `\n${resources.join("\n")}` : ""}`;
    return { text: result.text.trim(), prompt, images, botName: this.botName, botOpenId: this.botOpenId };
  }
  private async body(message: Message, signal?: AbortSignal, depth = 0, forwardedItems?: Message[]): Promise<{ text: string; resources: Resource[] }> {
    signal?.throwIfAborted();
    const type = message.message_type || message.msg_type || "text";
    const content = message.content ?? message.body?.content ?? "{}";
    const json = parse(content);
    const resources: Resource[] = [];
    const people = new Map<string, string>(cardMentionNames(content));
    for (const mention of message.mentions ?? []) {
      const id = idOf(mention);
      if (id && id !== this.botOpenId) {
        const name = await this.name(id, mention.name); people.set(id, name);
        if (mention.name) await this.profiles.putProfile(id, { name: mention.name });
      }
    }
    if (type === "post") {
      const nodes: any[] = [json];
      let visited = 0;
      while (nodes.length && visited++ < 10000) {
        const node = nodes.pop();
        if (Array.isArray(node)) nodes.push(...node);
        else if (node && typeof node === "object") {
          const id = node.tag === "at" ? node.user_id || node.open_id : undefined;
          if (typeof id === "string" && id !== this.botOpenId && /^ou_[A-Za-z0-9_-]+$/.test(id) && !people.has(id)) people.set(id, await this.name(id, node.user_name));
          nodes.push(...Object.values(node));
        }
      }
    }
    let text = "";
    const walk = (node: any): string => {
      if (!node) return "";
      if (Array.isArray(node)) return node.map(walk).join("");
      if (typeof node !== "object") return "";
      if (node.tag === "at") {
        const id = node.user_id || node.open_id;
        if (id === "all") return "@所有人";
        return id === this.botOpenId ? "" : personLabel(people.get(id) || node.user_name, id || "未知用户");
      }
      if (node.tag === "img" && node.image_key) { resources.push({ key: node.image_key, type: "image" }); return "[图片]"; }
      if ((node.tag === "media" || node.tag === "file") && node.file_key) { resources.push({ key: node.file_key, type: node.tag, name: node.file_name }); return `[${node.tag}]`; }
      if (node.tag === "a") return `${node.text || node.href || "链接"}${node.text && node.href ? ` (${node.href})` : ""}`;
      return typeof node.text === "string" ? node.text : walk(node.content);
    };
    if (type === "text") text = json.text || "";
    else if (type === "post") {
      const body = Array.isArray(json.content) ? json : [json.zh_cn, json.en_us, json.ja_jp, ...Object.values(json)].find((value: any) => value && typeof value === "object" && Array.isArray(value.content)) || json;
      text = [body.title || "", ...(body.content || []).map((line: any) => walk(line))].filter(Boolean).join("\n");
      resources.push(...postAttachments(content, type).map((entry) => ({ key: entry.fileKey, type: entry.type, name: entry.fileName })));
    } else if (["interactive", "card", "json_card"].includes(type)) {
      this.readCard ??= createHistoryCardReader({ ...this.options, client: this.client, botOpenId: this.botOpenId, resolveName: (id) => this.name(id) });
      text = await this.readCard(message.message_id).catch(() => undefined) || cardVisibleText(content) || "[卡片原文不可读取：机器人权限不足或卡片没有可见正文]";
    } else if (type === "audio") {
      text = speechText(content, type) || "[语音没有飞书原生转写，已提供音频附件]";
      if (json.file_key) resources.push({ key: json.file_key, type: "audio", name: "voice.ogg" });
    } else if (type === "sticker") text = "[表情贴纸：飞书不支持下载此资源]";
    else if (["image", "file", "media", "video"].includes(type)) {
      text = `[${type}] ${json.file_name || ""}`;
      const image = type === "image";
      const key = image ? json.image_key || json.file_key : json.file_key || json.image_key;
      if (key) resources.push({ key, type: image ? "image" : type, name: json.file_name });
    } else if (type === "merge_forward" && depth < 3) {
      const forwarded = forwardedItems || await this.fetchMessage(message.message_id);
      const nested = forwarded.filter((item) => item.upper_message_id ? item.upper_message_id === message.message_id : item.message_id !== message.message_id).sort((a, b) => Number(a.create_time || 0) - Number(b.create_time || 0));
      const parts: string[] = [];
      for (const item of nested.slice(0, 30)) {
        const parsed = await this.body(item, signal, depth + 1, forwarded);
        // Feishu resource downloads use the enclosing forward's ID, not the sub-item ID.
        resources.push(...parsed.resources.map((resource) => ({ ...resource, messageId: message.message_id })));
        parts.push(`${personLabel(await this.name(item.sender?.id || ""), item.sender?.id || "未知")}：${parsed.text}`);
      }
      if (nested.length > 30) parts.push(`[已省略 ${nested.length - 30} 条转发子消息]`);
      text = parts.join("\n") || "[合并转发没有返回可读取的子消息]";
    } else text = `[${type}] ${json.text || cardVisibleText(content) || "该消息没有可读取的正文"}`;
    const replacements = new Map((message.mentions ?? []).flatMap((mention) => {
      const id = idOf(mention);
      return mention.key && id ? [[mention.key, id === this.botOpenId ? "" : personLabel(people.get(id) || mention.name, id)] as const] : [];
    }));
    if (replacements.size) {
      const pattern = [...replacements.keys()].sort((a, b) => b.length - a.length).map((key) => key.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|");
      text = text.replace(new RegExp(pattern, "g"), (key) => replacements.get(key)!);
    }
    text = expandCardMentions(text, people, this.botOpenId);
    return { text: annotatePeople(text, [...people].map(([openId, name]) => ({ openId, name }))).slice(0, 40000), resources };
  }
  private async fetchMessage(id: string): Promise<Message[]> {
    if (!/^om_[A-Za-z0-9_-]+$/.test(id)) throw new Error("消息 ID 无效");
    const result = await this.client.request({ method: "GET", url: `/open-apis/im/v1/messages/${encodeURIComponent(id)}`, params: { card_msg_content_type: "user_card_content" } }) as any;
    if (result.code !== 0) throw new Error(`消息读取失败: ${result.code} ${result.msg || ""}`);
    return result.data?.items || [];
  }
  private async quote(id: string, seen: Set<string>, signal?: AbortSignal, resources?: Resource[]): Promise<string> {
    if (seen.has(id) || seen.size > 4) return "[更早的引用已省略]\n";
    seen.add(id);
    try {
      const items = await this.fetchMessage(id); const item = items.find((entry) => entry.message_id === id) || items[0];
      if (!item) return "[引用消息已删除或不可访问]\n";
      const result = await this.body(item, signal);
      resources?.push(...result.resources.map((resource) => ({ ...resource, messageId: resource.messageId || item.message_id })));
      const sender = item.sender?.id || "未知";
      const parent = item.parent_id ? await this.quote(item.parent_id, seen, signal, resources) : "";
      return `${parent}[引用 ${id}] ${personLabel(await this.name(sender), sender)}：${result.text}\n`;
    } catch (error) { return `[引用读取失败] ${String(error)}\n`; }
  }
  async history(input: { chatId: string; start?: string; end?: string; pageToken?: string; limit?: number }, signal?: AbortSignal) {
    if (!/^oc_[A-Za-z0-9_-]+$/.test(input.chatId)) throw new Error("chatId 必须是飞书聊天 ID");
    const result = await this.client.request({ method: "GET", url: "/open-apis/im/v1/messages", params: { container_id_type: "chat", container_id: input.chatId, page_size: input.limit || 20, page_token: input.pageToken, start_time: input.start, end_time: input.end, sort_type: "ByCreateTimeDesc", card_msg_content_type: "user_card_content" } }) as any;
    if (result.code !== 0) throw new Error(`历史读取失败: ${result.code} ${result.msg || ""}`);
    const messages = [];
    for (const item of result.data?.items || []) {
      const body = await this.body(item, signal); const sender = item.sender?.id || "未知";
      messages.push({ messageId: item.message_id, sender: personLabel(await this.name(sender), sender), time: item.create_time, text: body.text, quote: item.parent_id ? await this.quote(item.parent_id, new Set([item.message_id]), signal) : undefined, resources: body.resources });
    }
    return { messages, hasMore: result.data?.has_more, pageToken: result.data?.page_token };
  }
}
