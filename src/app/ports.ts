export interface Choice { label: string; value: string; }
export interface PromptField { label: string; value: string; code?: boolean; }
export interface Prompt { title: string; detail: string; fields?: PromptField[]; choices?: Choice[]; allowText?: boolean; }
export interface PromptResult { text: string; tone: "success" | "danger" | "neutral"; }
export interface ReplyTarget { messageId: string; cardId?: string; sequence: number; chatId?: string; failed?: boolean; resetHistory?: boolean; outcome?: "completed" | "failed" | "interrupted"; }
export interface Channel {
  send(chatId: string, text: string, deliveryId?: string): Promise<string>;
  update(messageId: string, text: string): Promise<void>;
  startReply(chatId: string, sourceMessageId: string, content: string, status: string): Promise<ReplyTarget>;
  updateReply(target: ReplyTarget, content: string, sequence: number, kind?: "progress" | "final"): Promise<void>;
  updateReplyStatus(target: ReplyTarget, status: string, sequence: number): Promise<void>;
  finishReply(target: ReplyTarget, content: string, status: string | undefined, attempt: number, deliveryId?: string): Promise<void>;
  prompt(chatId: string, token: string, prompt: Prompt): Promise<string>;
  finishPrompt(messageId: string, prompt: Prompt, result: PromptResult): Promise<void>;
  sendFile(chatId: string, path: string): Promise<string>;
}
export interface SessionContext { chatId: string; sessionKey: string; }
export interface TokenCounts { totalTokens?: number; inputTokens?: number; cachedInputTokens?: number; cacheWriteInputTokens?: number; outputTokens?: number; reasoningOutputTokens?: number; }
export interface UsageReport { turn?: TokenCounts; session?: TokenCounts; last?: TokenCounts; contextWindow?: number; reported: boolean; }
export interface ImageDelivery { path: string; messageId?: string; error?: string; }
export interface AgentResult { text: string; status: string; usage?: UsageReport; model?: string; imageDeliveries?: ImageDelivery[]; }
