import { randomBytes } from "node:crypto";
import type { Channel, Prompt, PromptResult } from "./ports.ts";

interface Pending {
  chatId: string; sessionKey?: string; messageId?: string; prompt: Prompt;
  resolve: (value: string | undefined) => void; timer: NodeJS.Timeout; cleanup?: () => void;
}

/** Owner-only interaction broker shared by native approvals, questions and business confirmations. */
export class Prompts {
  private readonly pending = new Map<string, Pending>();
  constructor(private readonly channel: Channel, private readonly owner: string, private readonly timeoutMs: number) {}
  async ask(chatId: string, prompt: Prompt, signal?: AbortSignal, sessionKey?: string): Promise<string | undefined> {
    if (signal?.aborted) return undefined;
    const token = randomBytes(12).toString("hex");
    let resolve!: Pending["resolve"];
    const answer = new Promise<string | undefined>(done => { resolve = done; });
    const timer = setTimeout(() => this.settle(token, undefined, "已超时，未授权执行"), this.timeoutMs);
    const item: Pending = { chatId, sessionKey, prompt, resolve, timer };
    this.pending.set(token, item);
    const cancel = () => this.settle(token, undefined, "请求已取消");
    signal?.addEventListener("abort", cancel, { once: true });
    item.cleanup = () => signal?.removeEventListener("abort", cancel);
    try {
      item.messageId = await this.channel.prompt(chatId, token, prompt);
      if (!this.pending.has(token)) void this.channel.finishPrompt(item.messageId, item.prompt, { text: "请求已结束", tone: "neutral" }).catch(() => {});
    }
    catch (error) { this.settle(token, undefined, "确认卡发送失败"); throw error; }
    return answer;
  }
  async confirm(chatId: string, title: string, detail: string, signal?: AbortSignal, sessionKey?: string): Promise<boolean> {
    return await this.ask(chatId, { title, detail, choices: [{ label: "允许一次", value: "allow" }, { label: "拒绝", value: "deny" }] }, signal, sessionKey) === "allow";
  }
  answer(token: string, value: string, owner: string, chatId?: string, messageId?: string): boolean {
    const item = this.pending.get(token);
    if (!item || owner !== this.owner || (chatId && item.chatId !== chatId) || (messageId && item.messageId && item.messageId !== messageId)) return false;
    if (!item.prompt.allowText && !item.prompt.choices?.some(choice => choice.value === value)) return false;
    const declined = ["deny", "decline", "cancel"].includes(value);
    const label = item.prompt.choices?.find(choice => choice.value === value)?.label;
    const outcome = declined ? value === "cancel" ? "已取消" : "已拒绝" : ["accept", "allow"].includes(value) && label ? `已${label}` : label ? `已选择：${label}` : "已提交回答";
    this.settle(token, value, outcome, declined ? "danger" : "success");
    return true;
  }
  cancelSession(sessionKey: string): void { for (const [token, item] of this.pending) if (item.sessionKey === sessionKey) this.settle(token, undefined, "已取消"); }
  cancelAll(): void { for (const token of [...this.pending.keys()]) this.settle(token, undefined, "服务已停止，未授权执行"); }
  private settle(token: string, value: string | undefined, text: string, tone: PromptResult["tone"] = "neutral"): void {
    const item = this.pending.get(token);
    if (!item) return;
    this.pending.delete(token); clearTimeout(item.timer); item.cleanup?.(); item.resolve(value);
    if (item.messageId) void this.channel.finishPrompt(item.messageId, item.prompt, { text, tone }).catch(() => {});
  }
}
