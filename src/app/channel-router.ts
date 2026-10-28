import type { Channel, Prompt, PromptResult, ReplyTarget } from "./ports.ts";

/** Delivery follows the conversation's origin. The agent runtime stays shared. */
export class ChannelRouter implements Channel {
  constructor(private readonly feishu: Channel, private readonly desktop: Channel) {}
  private forChat(chatId: string): Channel { return chatId.startsWith("desktop:") ? this.desktop : this.feishu; }
  private forMessage(messageId: string): Channel { return messageId.startsWith("desktop:") ? this.desktop : this.feishu; }
  send(chatId: string, text: string, deliveryId?: string): Promise<string> { return this.forChat(chatId).send(chatId, text, deliveryId); }
  update(messageId: string, text: string): Promise<void> { return this.forMessage(messageId).update(messageId, text); }
  startReply(chatId: string, sourceMessageId: string, content: string, status: string): Promise<ReplyTarget> { return this.forChat(chatId).startReply(chatId, sourceMessageId, content, status); }
  updateReply(target: ReplyTarget, content: string, sequence: number, kind?: "progress" | "final"): Promise<void> { return this.forMessage(target.messageId).updateReply(target, content, sequence, kind); }
  updateReplyStatus(target: ReplyTarget, status: string, sequence: number): Promise<void> { return this.forMessage(target.messageId).updateReplyStatus(target, status, sequence); }
  finishReply(target: ReplyTarget, content: string, status: string | undefined, attempt: number, deliveryId?: string): Promise<void> { return this.forMessage(target.messageId).finishReply(target, content, status, attempt, deliveryId); }
  prompt(chatId: string, token: string, prompt: Prompt): Promise<string> { return this.forChat(chatId).prompt(chatId, token, prompt); }
  finishPrompt(messageId: string, prompt: Prompt, result: PromptResult): Promise<void> { return this.forMessage(messageId).finishPrompt(messageId, prompt, result); }
  sendFile(chatId: string, path: string): Promise<string> { return this.forChat(chatId).sendFile(chatId, path); }
}
