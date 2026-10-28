import type { Channel, ReplyTarget } from "./ports.ts";
import { Store } from "../storage.ts";
import { errorMessage, log } from "../shared/log.ts";

export class Outbox {
  private timer?: NodeJS.Timeout;
  private cleanupTimer?: NodeJS.Timeout;
  private running?: Promise<void>;
  constructor(private readonly store: Store, private readonly channel: Channel, private readonly sentRetentionMs: number) {}
  send(chatId: string, text: string, target?: ReplyTarget, stats?: string): void { this.store.enqueue(chatId, text, target, stats); this.flush(); }
  complete(messageId: string, status: "completed" | "failed" | "interrupted", chatId: string, text: string, target?: ReplyTarget, stats?: string): void {
    this.store.transaction(() => {
      this.store.messageStatus(messageId, status);
      this.store.enqueue(chatId, text, target ? { ...target, outcome: status } : target, stats);
    });
    this.flush();
  }
  retryFailed(chatId: string, id: number): boolean {
    const queued = this.store.retryFailedDelivery(chatId, id);
    if (queued) this.flush();
    return queued;
  }
  acknowledgeDesktopDelivery(chatId: string, deliveryId: string, messageId: string): void {
    if (chatId.startsWith("desktop:")) this.store.acknowledgeDelivery(chatId, deliveryId, messageId);
  }
  start(): void {
    if (this.timer) return;
    this.cleanup();
    this.cleanupTimer = setInterval(() => this.cleanup(), 60 * 60_000);
    this.timer = setInterval(() => this.flush(), 2000);
    this.flush();
  }
  async stop(): Promise<void> {
    clearInterval(this.timer);
    clearInterval(this.cleanupTimer);
    this.timer = undefined;
    this.cleanupTimer = undefined;
    await this.running;
  }
  private cleanup(): void {
    try {
      const count = this.store.clearSentPayloads(Date.now() - this.sentRetentionMs);
      if (count) log.info(`已清理 ${count} 条过期的已发送队列正文，投递状态保留`);
    } catch (error) {
      log.error(`已发送队列正文清理失败：${errorMessage(error)}`);
    }
  }
  private flush(): void {
    if (this.running) return;
    this.running = (async () => {
      for (const item of this.store.deliveries()) {
        // A reconnect may have acknowledged another item while the previous send was awaiting its receipt.
        if (!this.store.deliveryPending(item.id)) continue;
        try {
          let messageId: string;
          const deliveryId = item.deliveryId;
          const splitReply = !item.chatId.startsWith("desktop:") && item.text.length > 15_000;
          if (item.target) {
            await this.channel.finishReply(item.target, splitReply ? "已完成，完整结果见后续消息。" : item.text, item.stats, item.attempts, deliveryId);
            if (splitReply) {
              this.store.deliverAsMessage(item.id);
              continue;
            }
            messageId = item.target.messageId;
          } else messageId = await this.channel.send(item.chatId, item.stats ? `${item.text}\n\n<font color='grey'>${item.stats}</font>` : item.text, deliveryId);
          this.store.delivered(item.id, messageId);
          log.conversation("助理", item.text);
        }
        catch (error) {
          const reason = errorMessage(error);
          if (item.target && item.attempts >= 1 && !item.chatId.startsWith("desktop:")) {
            this.store.deliverAsMessage(item.id, `卡片更新失败，改发普通消息：${reason}`);
            log.warn(`回复 ${item.id} 的最终卡片更新连续失败，已转为普通消息投递`);
          } else {
            const status = this.store.retry(item, reason);
            if (status === "failed") log.warn(`回复 ${item.id} 已连续投递失败 ${item.attempts + 1} 次，停止自动重试；可在原聊天用 /retry ${item.id} 重投：${reason}`);
            else if (status === "pending") log.warn(`回复 ${item.id} 投递失败，已记录重试（失败 ${item.attempts + 1} 次）：${reason}`);
          }
        }
      }
    })().catch(error => log.error(`发件队列异常：${errorMessage(error)}`)).finally(() => { this.running = undefined; });
  }
}
