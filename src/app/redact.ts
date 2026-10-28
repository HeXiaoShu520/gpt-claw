const secretKey = /(?:password|passwd|secret|token|api[_-]?key|authorization|cookie|credential|private[_-]?key)/i;

/** A free-form value has no reliable secret detector. Never echo it into a Feishu approval card. */
export function approvalCommandPreview(command: unknown): string {
  const raw = typeof command === "string" ? command : "";
  const shell = /(?:^|[\\/\s"'])(powershell|pwsh|cmd|bash|sh)(?:\.exe)?(?:["'\s]|$)/i.exec(raw)?.[1];
  return `${shell || "命令"}（正文及参数已隐藏；请结合请求说明确认）`;
}

export function approvalToolPreview(args: Record<string, unknown>): unknown {
  const hidden = new Set(["text", "prompt", "content", "body", "input", "value"]);
  return Object.fromEntries(Object.entries(args).map(([key, value]) => [key,
    hidden.has(key.toLowerCase()) && typeof value === "string"
      ? `已隐藏（${value.length} 字符）`
      : redactSecrets(value),
  ]));
}

/** Hide secret values in previews. The original arguments still reach the tool after approval. */
export function redactSecrets(value: unknown, depth = 0): unknown {
  if (depth > 8) return "…";
  if (Array.isArray(value)) return value.slice(0, 30).map(item => redactSecrets(item, depth + 1));
  if (value && typeof value === "object") {
    return Object.fromEntries(Object.entries(value).slice(0, 50).map(([key, item]) => [key, secretKey.test(key) ? "***" : redactSecrets(item, depth + 1)]));
  }
  return value;
}
