import type { TokenCounts, UsageReport } from "../app/ports.ts";

const countNames = ["totalTokens", "inputTokens", "cachedInputTokens", "cacheWriteInputTokens", "outputTokens", "reasoningOutputTokens"] as const;

function record(value: unknown): Record<string, unknown> | undefined {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : undefined;
}

function counts(value: unknown): TokenCounts | undefined {
  const source = record(value);
  if (!source) return undefined;
  const result: TokenCounts = {};
  for (const name of countNames) {
    const number = source[name];
    if (typeof number === "number" && Number.isFinite(number) && number >= 0) result[name] = number;
  }
  return Object.keys(result).length ? result : undefined;
}

/** App-server sends cumulative thread usage, the latest model call, and the model window. */
export function usageSnapshot(raw: unknown): UsageReport {
  const source = record(raw);
  const contextWindow = source?.modelContextWindow;
  return {
    session: counts(source?.total),
    last: counts(source?.last),
    contextWindow: typeof contextWindow === "number" && Number.isFinite(contextWindow) && contextWindow > 0 ? contextWindow : undefined,
    reported: false,
  };
}

export function turnUsage(before: UsageReport, raw: unknown, reported: boolean): UsageReport {
  const current = usageSnapshot(raw);
  if (!reported) return { contextWindow: current.contextWindow, reported: false };
  const turn: TokenCounts = {};
  if (before.session && current.session) {
    for (const name of countNames) {
      const previous = before.session[name], latest = current.session[name];
      if (previous !== undefined && latest !== undefined && latest >= previous) turn[name] = latest - previous;
    }
  }
  return { ...current, turn: Object.keys(turn).length ? turn : undefined, reported: true };
}
