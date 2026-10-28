/** Compact wall-clock time in the machine's local timezone. */
function timestamp(): string {
  const now = new Date();
  const pad = (value: number) => String(value).padStart(2, "0");
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
}

export const log = {
  info: (message: string) => console.error(timestamp(), "INFO", message),
  warn: (message: string) => console.error(timestamp(), "WARN", message),
  error: (message: string) => console.error(timestamp(), "ERROR", message),
  conversation: (speaker: "本人" | "助理", content: string) => console.error(timestamp(), "CHAT", `${speaker}：${conversationPreview(content)}`),
};
/** Terminal preview only. Full conversation is kept by the existing local history store. */
function conversationPreview(content: string): string {
  const safe = content
    .replace(/\x1b(?:\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1b\\))/g, "")
    .replace(/-----BEGIN [^-]*PRIVATE KEY-----[\s\S]*?-----END [^-]*PRIVATE KEY-----/g, "[私钥已隐藏]")
    .replace(/https?:\/\/[^\s<>)]+/gi, "[链接已隐藏]")
    .replace(/\bBearer\s+\S+/gi, "Bearer [已隐藏]")
    .replace(/\bsk-[A-Za-z0-9_-]{8,}\b/g, "[密钥已隐藏]")
    .replace(/((?:api[_ -]?key|access[_ -]?key|app[_ -]?secret|client[_ -]?secret|key|password|passwd|token|密码|口令|验证码)\s*(?:[:=：]|是|is)\s*)[^\s,，;；]+/gi, "$1[已隐藏]")
    .replace(/\b[A-Za-z0-9_/-]{32,}\b/g, "[长标识已隐藏]")
    .replace(/[\r\n\t\x00-\x1f\x7f]+/g, " ↵ ")
    .trim();
  return safe.length > 500 ? `${safe.slice(0, 500)}…（${safe.length} 字符）` : safe || "[无文字内容]";
}
export function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
