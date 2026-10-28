import { randomUUID } from "node:crypto";
import { mkdir, unlink } from "node:fs/promises";
import { join } from "node:path";
import type { Config } from "../config.ts";
import { log } from "../shared/log.ts";
import type { FeishuChannel } from "./channel.ts";
import { cliStatus, parseCliJson, runCli } from "./device-auth.ts";

interface CommandResult { command: string; output: string; exitCode: number | null; }
interface MissingPermission { identity: "user" | "bot"; scope?: string; consoleUrl?: string; }
const scopeName = /^[A-Za-z][A-Za-z0-9_.:-]{2,120}$/;
const scopeMarker = /missing[_\s-]?scopes?|缺少[^\r\n]{0,20}权限|权限不足/i;
const record = (value: unknown): Record<string, unknown> => value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};

function httpsUrl(value: unknown): string | undefined {
  if (typeof value !== "string") return;
  try {
    const url = new URL(value);
    return url.protocol === "https:" && /^(?:open\.)?(?:feishu\.cn|larksuite\.com|larkoffice\.com)$/i.test(url.hostname) ? url.href : undefined;
  }
  catch { return undefined; }
}

function missingPermission(result: CommandResult): MissingPermission | undefined {
  if (result.exitCode === 0 || !/\blark-cli(?:\.exe)?\b/i.test(result.command)) return;
  const output = result.output.slice(0, 64_000).replace(/\x1b\[[0-9;]*m/g, "");
  const envelope = parseCliJson(output);
  const details = record(envelope?.error);
  const explicitIdentity = envelope?.identity;
  const commandIdentity = /(?:^|\s)--as(?:=|\s+)(user|bot)(?=\s|["']|$)/i.exec(result.command)?.[1]?.toLowerCase();
  const identity = explicitIdentity === "user" || explicitIdentity === "bot" ? explicitIdentity : commandIdentity;
  if (identity !== "user" && identity !== "bot") return;
  if (envelope?.ok === true) return;
  const scopes = Array.isArray(details.missing_scopes) ? details.missing_scopes : [];
  const listed = scopes.find(value => typeof value === "string" && scopeName.test(value)) as string | undefined;
  const plainScope = /missing[_\s-]?scopes?\s*[:=]\s*[\["']?([A-Za-z][A-Za-z0-9_.:-]{2,120})/i.exec(output)?.[1];
  const scope = listed || (plainScope && scopeName.test(plainScope) ? plainScope : undefined);
  const plainUrl = /https:\/\/open\.(?:feishu\.cn|larksuite\.com|larkoffice\.com)\/[^\s"'<>]+/i.exec(output)?.[0];
  const consoleUrl = httpsUrl(details.console_url) || httpsUrl(plainUrl);
  if (details.subtype !== "missing_scope" && !scopeMarker.test(output)) return;
  if (!scope && !consoleUrl) return;
  return { identity, scope, consoleUrl };
}

/** Converts a native CLI missing-scope result into a link sent to the bound owner chat. */
export class FeishuPermissionLinks {
  private readonly recent = new Map<string, number>();
  private readonly active = new Set<AbortController>();
  constructor(private readonly config: Config, private readonly channel: FeishuChannel) {}

  inspect(chatId: string, result: CommandResult): void {
    const missing = missingPermission(result);
    if (!missing) return;
    const key = `${chatId}:${missing.identity}:${missing.scope || missing.consoleUrl}`;
    if ((this.recent.get(key) || 0) > Date.now()) return;
    this.recent.set(key, Date.now() + 10 * 60_000);
    void (missing.identity === "bot" ? this.bot(chatId, missing) : this.user(chatId, missing))
      .catch(async () => {
        this.recent.delete(key);
        log.warn("飞书补授权流程未完成");
        await this.channel.send(chatId, "飞书补授权流程未完成，请查看当前 CLI 错误并重试。授权链接已过期时会重新生成。").catch(() => {});
      });
  }

  private async bot(chatId: string, missing: MissingPermission): Promise<void> {
    const link = missing.consoleUrl || "https://open.feishu.cn/app";
    await this.channel.send(chatId, `机器人应用缺少权限${missing.scope ? ` ${missing.scope}` : ""}。请在飞书开发者后台开通并发布应用：\n${link}\n开通后重新发送刚才的请求。`);
    await this.qr(chatId, link);
  }

  private async user(chatId: string, missing: MissingPermission): Promise<void> {
    if (!missing.scope) {
      if (missing.consoleUrl) {
        await this.channel.send(chatId, `飞书用户操作缺少应用权限。请先在开发者后台开通并发布：\n${missing.consoleUrl}\n然后重新授权本人账号并重试。`);
        await this.qr(chatId, missing.consoleUrl);
      }
      return;
    }
    const controller = new AbortController();
    this.active.add(controller);
    try {
      const begin = await runCli(this.config, ["auth", "login", "--scope", missing.scope, "--no-wait", "--json"], { signal: controller.signal });
      const envelope = parseCliJson(begin.stdout) || parseCliJson(begin.stderr);
      const data = envelope?.data && typeof envelope.data === "object" ? envelope.data as Record<string, unknown> : envelope;
      const link = httpsUrl(data?.verification_uri_complete) || httpsUrl(data?.verification_url) || httpsUrl(data?.verification_uri);
      const code = typeof data?.device_code === "string" ? data.device_code : "";
      if (begin.code !== 0 || !link || !code) {
        await this.channel.send(chatId, `飞书用户权限 ${missing.scope} 未能发起补授权。${missing.consoleUrl ? `请先在开发者后台开通应用权限：\n${missing.consoleUrl}` : "请检查应用权限配置。"}`);
        if (missing.consoleUrl) await this.qr(chatId, missing.consoleUrl);
        return;
      }
      await this.channel.send(chatId, `飞书用户权限 ${missing.scope} 需要补授权。请用本人账号打开链接：\n${link}\n授权完成后会自动验证；然后重新发送刚才的请求。${missing.consoleUrl ? `\n若页面提示应用未开通权限，请先访问：\n${missing.consoleUrl}` : ""}`);
      await this.qr(chatId, link);
      const done = await runCli(this.config, ["auth", "login", "--device-code", code, "--json"], { timeoutMs: 11 * 60_000, signal: controller.signal });
      const status = await cliStatus(this.config, controller.signal);
      if (status.userOpenId && status.userOpenId !== this.config.owner) {
        await runCli(this.config, ["auth", "logout"], { signal: controller.signal });
        await this.channel.send(chatId, "扫码账号不是当前助理的本人账号，已退出该 CLI 登录；请由本人重新授权。");
      } else if (done.code === 0 && status.userAvailable && status.userOpenId === this.config.owner && status.userScopes.includes(missing.scope)) {
        await this.channel.send(chatId, `飞书用户权限 ${missing.scope} 已完成授权。请重新发送刚才的请求。`);
      } else {
        await this.channel.send(chatId, `飞书用户权限 ${missing.scope} 尚未完成授权或未获应用许可。${missing.consoleUrl ? `请检查开发者后台：\n${missing.consoleUrl}` : "请检查飞书授权页面。"}`);
      }
    } finally { this.active.delete(controller); }
  }

  private async qr(chatId: string, link: string): Promise<void> {
    const folder = join(this.config.root, "data", "permission-qr");
    const fileName = `${randomUUID()}.png`;
    const file = join(folder, fileName);
    try {
      await mkdir(folder, { recursive: true });
      const created = await runCli(this.config, ["auth", "qrcode", link, "--output", `data/permission-qr/${fileName}`]);
      if (created.code === 0) await this.channel.sendFile(chatId, file);
    } catch { /* The link was already delivered; QR is a convenience. */ }
    finally { await unlink(file).catch(() => {}); }
  }

  stop(): void { for (const controller of this.active) controller.abort(); }
}
