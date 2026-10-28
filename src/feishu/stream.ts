import type { Channel, ReplyTarget } from "../app/ports.ts";
import { log } from "../shared/log.ts";
import { Spinner } from "./spinner.ts";
import { compactMarkdown } from "./reply-card.ts";

const graphemes = new Intl.Segmenter("zh", { granularity: "grapheme" });

/** Keep Markdown tags intact; plain text can have a few server-paced opening frames. */
function openingFrames(text: string): string[] {
  if (/[<>`\[\]*_~#]/.test(text)) return [];
  const characters = [...graphemes.segment(text)].map(part => part.segment);
  if (characters.length <= 8) return [];
  return [characters.slice(0, 4).join(""), ...(characters.length > 28 ? [characters.slice(0, 12).join("")] : [])];
}

/** One in-flight CardKit write at a time; body and the small status row share its sequence. */
export class ReplyStream {
  private timer: NodeJS.Timeout;
  private sending?: Promise<void>;
  private closed = false;
  private failed = false;
  private text = "";
  private commentary = "";
  private status = "思考中";
  private renderedBody: string;
  private realBodySeen = false;
  private lastBodyWriteAt = 0;
  private lastBodyRevealMs = 0;
  private lastWasBody = false;
  private sequence = 0;
  readonly startedAt = Date.now();

  private constructor(private readonly channel: Channel, private readonly target: ReplyTarget, private readonly spinner: Spinner, initialBody: string) {
    this.renderedBody = initialBody;
    this.timer = setInterval(() => this.flush(), 500);
  }

  static async start(channel: Channel, chatId: string, sourceMessageId: string): Promise<ReplyStream> {
    const spinner = new Spinner();
    spinner.withPrefix("思考中");
    // The first visible card frame is already a thinking animation, even if
    // the model emits a complete short answer before the next timer tick.
    const firstFrame = spinner.next();
    const target = await channel.startReply(chatId, sourceMessageId, firstFrame, spinner.next());
    return new ReplyStream(channel, target, spinner, firstFrame);
  }

  update(text: string): void {
    if (this.closed) return;
    this.text = text;
    if (text) { this.status = "正在回答"; this.commentary = ""; }
  }

  progress(status: string): void {
    if (!this.closed) { this.status = status; this.spinner.withPrefix(status); }
  }

  note(text: string): void {
    if (!this.closed && !this.text) this.commentary = compactMarkdown(text).slice(0, 1_500);
  }

  private flush(): void {
    if (this.closed || this.failed || this.sending) return;
    const realBody = compactMarkdown(this.text || this.commentary).slice(0, 14_000);
    const body = realBody ? this.realBodySeen ? realBody : openingFrames(realBody)[0] || realBody : this.spinner.next();
    const writeBody = body !== this.renderedBody && (!this.lastWasBody || !this.target.cardId);
    const sequence = ++this.sequence;
    if (writeBody) {
      this.lastWasBody = true;
      this.sending = this.channel.updateReply(this.target, body, sequence, this.text ? "final" : "progress")
        .then(() => this.bodyWritten(body, !!realBody));
    } else if (this.target.cardId) {
      this.lastWasBody = false;
      this.spinner.withPrefix(this.status);
      const elapsed = Math.floor((Date.now() - this.startedAt) / 1000);
      const duration = elapsed < 60 ? `${elapsed} 秒` : `${Math.floor(elapsed / 60)} 分 ${elapsed % 60} 秒`;
      const status = `${this.spinner.next()}${elapsed ? ` · 已运行 ${duration}` : ""}`;
      this.sending = this.channel.updateReplyStatus(this.target, status, sequence);
    } else {
      this.sequence--;
      return;
    }
    void this.sending.catch(() => {
      this.failed = true;
      log.warn("过程卡片更新失败，最终回复仍会尝试投递");
    }).finally(() => { this.sending = undefined; });
  }

  private bodyWritten(body: string, real: boolean): void {
    const previousLength = this.realBodySeen ? Array.from(this.renderedBody).length : 0;
    this.renderedBody = body;
    if (!real) return;
    this.realBodySeen = true;
    this.lastBodyWriteAt = Date.now();
    // CardKit prints three characters every 30ms. Hold the final whole-card
    // replacement briefly so it cannot erase the first streamed text frame.
    this.lastBodyRevealMs = Math.min(1_200, Math.max(400, (Array.from(body).length - previousLength) * 10));
  }

  async close(finalText: string): Promise<ReplyTarget> {
    this.closed = true;
    clearInterval(this.timer);
    await this.sending?.catch(() => {});
    const finalBody = compactMarkdown(finalText).slice(0, 14_000) || " ";
    const canContinueOpening = !this.realBodySeen || finalBody.startsWith(this.renderedBody);
    if (!this.failed && this.target.cardId && canContinueOpening) {
      for (const frame of openingFrames(finalBody)) {
        if (this.realBodySeen && frame.length <= this.renderedBody.length) continue;
        try {
          await this.channel.updateReply(this.target, frame, ++this.sequence);
          this.bodyWritten(frame, true);
          await new Promise(resolve => setTimeout(resolve, 150));
        } catch {
          this.failed = true;
          log.warn("首段流式正文更新失败，最终卡片仍会尝试投递");
          break;
        }
      }
    }
    if (!this.failed && finalBody !== this.renderedBody) {
      try {
        await this.channel.updateReply(this.target, finalBody, ++this.sequence);
        this.bodyWritten(finalBody, true);
      } catch {
        this.failed = true;
        log.warn("最终流式正文更新失败，最终卡片仍会尝试投递");
      }
    }
    if (!this.failed && this.target.cardId && this.realBodySeen) {
      const remaining = this.lastBodyRevealMs - (Date.now() - this.lastBodyWriteAt);
      if (remaining > 0) await new Promise(resolve => setTimeout(resolve, remaining));
    }
    return { ...this.target, sequence: this.sequence };
  }
}
