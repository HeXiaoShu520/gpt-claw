import type { TokenCounts, UsageReport } from "../app/ports.ts";

/** The reply surface is independent of transport and Codex event handling. */
export function compactMarkdown(text: string): string {
  const lines: string[] = [];
  let fence = false;
  for (const line of text.replace(/\r\n?/g, "\n").split("\n")) {
    if (/^\s*(```|~~~)/.test(line)) fence = !fence;
    if (fence || line.trim() || (lines.at(-1)?.trim() && !line.trim())) lines.push(line.trimEnd());
  }
  return lines.join("\n").trim();
}

export const STATS_PLACEHOLDER = "\u2800";

export function statusMarkdown(text: string): string {
  return text ? `<font color='grey'>${text}</font>` : STATS_PLACEHOLDER;
}

export function streamingCard(content: string, status = "", streaming = true) {
  return {
    schema: "2.0",
    config: { update_multi: true, streaming_mode: streaming, ...(streaming ? { streaming_config: { print_frequency_ms: { default: 30 }, print_step: { default: 3 }, print_strategy: "fast" } } : {}) },
    body: { elements: [
      { tag: "markdown", element_id: "stream_md", content: content || " " },
      { tag: "markdown", element_id: "stats_md", content: statusMarkdown(status), text_size: "notation" },
    ] },
  };
}

function compactTokens(value: number): string {
  return value >= 1_000_000 ? `${(value / 1_000_000).toFixed(2)}M`
    : value >= 1_000 ? `${(value / 1_000).toFixed(1)}K` : String(value);
}

function consumption(label: string, counts: TokenCounts): string {
  const parts = [
    counts.inputTokens === undefined ? undefined : `入${compactTokens(counts.inputTokens)}`,
    counts.outputTokens === undefined ? undefined : `出${compactTokens(counts.outputTokens)}`,
  ].filter(Boolean);
  const details = [
    counts.cachedInputTokens ? `缓存${compactTokens(counts.cachedInputTokens)}` : undefined,
    counts.cacheWriteInputTokens ? `写缓存${compactTokens(counts.cacheWriteInputTokens)}` : undefined,
    counts.reasoningOutputTokens ? `思考${compactTokens(counts.reasoningOutputTokens)}` : undefined,
  ].filter(Boolean);
  if (!parts.length && counts.totalTokens !== undefined) parts.push(`共${compactTokens(counts.totalTokens)}`);
  return `${label}${parts.join(" ")}${details.length ? `（${details.join("，")}）` : ""}`;
}

export function finalReply(text: string, elapsedMs: number, usage?: UsageReport, model?: string): { body: string; stats: string } {
  const segments = [model || "Codex"];
  if (!usage?.reported) segments.push("Token 未上报");
  else {
    if (usage.turn) segments.push(consumption("本轮", usage.turn));
    else if (usage.last) segments.push(consumption("最近请求", usage.last));
    if (usage.session?.totalTokens !== undefined) segments.push(`累计${compactTokens(usage.session.totalTokens)}`);
  }
  if (usage?.contextWindow) {
    const occupied = usage.reported ? usage.last?.totalTokens ?? usage.last?.inputTokens : undefined;
    segments.push(occupied === undefined
      ? `窗口${compactTokens(usage.contextWindow)}`
      : `上下文约${compactTokens(occupied)}/${compactTokens(usage.contextWindow)}（${(occupied / usage.contextWindow * 100).toFixed(0)}%）`);
  }
  segments.push(`${(elapsedMs / 1000).toFixed(1)}s`);
  return { body: compactMarkdown(text), stats: segments.join(" · ") };
}
