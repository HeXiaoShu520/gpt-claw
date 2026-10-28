import type { AgentResult } from "./ports.ts";

/** A completed model turn is not a completed image task until delivery succeeds. */
export function describeResult(result: AgentResult): { text: string; deliveryFailed: boolean } {
  const deliveries = result.imageDeliveries ?? [];
  const sent = deliveries.filter(item => item.messageId).length;
  const failure = deliveries.find(item => item.error)?.error;
  if (failure) return {
    text: sent ? `图片已发送 ${sent} 张，另有图片发送未成功：${failure}` : `图片已生成，但发送到飞书未成功：${failure}`,
    deliveryFailed: true,
  };
  if (sent) return { text: `图片已生成并发送到当前飞书聊天（${sent} 张）。`, deliveryFailed: false };
  if (result.status === "interrupted") return { text: `任务已中断。\n${result.text}`, deliveryFailed: false };
  return { text: result.text || "任务结束，没有返回正文。", deliveryFailed: false };
}
