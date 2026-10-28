import { spawn } from "node:child_process";
import { mkdir } from "node:fs/promises";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { gzipSync } from "node:zlib";
import { setTimeout as delay } from "node:timers/promises";
import qr from "qrcode-terminal";
import { readConfig, type Config } from "../config.ts";
import { errorMessage, log } from "../shared/log.ts";
import { cliEnvironment, cliExecutable } from "./cli.ts";

/**
 * 启动引导（device 认证模式），两条路径都以终端为交互面：
 *
 * 1. 机器人未配置（.env 缺 FEISHU_APP_ID/FEISHU_APP_SECRET）：
 *    走 registerApp 的 Device Flow（RFC 8628，对齐 @larksuiteoapi/node-sdk 与
 *    mini-claw 的线协议）扫码创建/绑定应用，预置权限与事件，凭证写回 .env。
 * 2. 机器人已配置：驱动内置 lark-cli（node_modules/@larksuite/cli，配置目录固定在
 *    data/lark-cli，与本机全局默认账号完全隔离）完成用户身份的 Device Flow 登录，
 *    令牌由 CLI 自管；登录者需与 FEISHU_ADMIN 一致，否则退出该登录。
 *
 * 本工程单人使用：不做 mini-claw 的多用户凭证库与身份代理，仅此而已。
 */
const REGISTRATION_URL = "https://accounts.feishu.cn/oauth/v1/app/registration";
const str = (value: unknown): string => (typeof value === "string" ? value : "");
const num = (value: unknown): number => (typeof value === "number" && Number.isFinite(value) ? value : 0);
const record = (value: unknown): Record<string, unknown> => value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};

/**
 * 在飞书官方默认模板之上追加的权限与事件，不是应用的完整权限清单。
 * preset=true 保留默认模板；追加项在扫码确认页合并，重复项由平台去重。
 * scope 名称全部经过内置 lark-cli 二进制内的 scope 目录核对，不要凭记忆增删。
 * - tenant：机器人身份（消息收发、群与会话管理、资源下载、通讯录只读、斜杠命令）。
 * - user：本人身份的常用业务域读写（文档、云盘、表格、多维表格、日历、任务、邮件、
 *   知识库、OKR、审批、会议、妙记、幻灯片、通讯录），供 CLI 用户授权请求匹配。
 */
const ADDITIONAL_TENANT_SCOPES = [
  "im:message",
  "im:message.send_as_bot",
  "im:message.group_msg",
  "im:message.reactions:write_only",
  "im:chat",
  "im:resource",
  "contact:user.base:readonly",
  "contact:contact.base:readonly",
  "contact:department.base:readonly",
  "application:app_slash_command:read",
  "application:app_slash_command:write",
];
const ADDITIONAL_USER_SCOPES = [
  "docs:doc:readonly",
  "docx:document",
  "docs:document.comment:write_only",
  "drive:drive",
  "drive:file:upload",
  "sheets:spreadsheet",
  "bitable:app",
  "calendar:calendar",
  "task:task:read",
  "task:task:write",
  "mail:user_mailbox:readonly",
  "mail:user_mailbox.message:readonly",
  "mail:user_mailbox.message:send",
  "wiki:node:read",
  "wiki:node:create",
  "okr:okr:readonly",
  "approval:approval:readonly",
  "vc:meeting:readonly",
  "minutes:minutes:readonly",
  "slides:presentation:read",
  "slides:presentation:write_only",
  "contact:user.base:readonly",
  "contact:user.email:readonly",
];

function buildAddons(): Record<string, unknown> {
  return {
    preset: true,
    scopes: { tenant: ADDITIONAL_TENANT_SCOPES, user: ADDITIONAL_USER_SCOPES },
    events: { items: { tenant: ["im.message.receive_v1"] } },
    callbacks: { items: ["card.action.trigger"] },
  };
}

/** base64url(gzip(addons))，与官方 SDK 的 encodeAddons 一致 */
function encodeAddons(addons: Record<string, unknown>): string {
  return gzipSync(Buffer.from(JSON.stringify(addons), "utf8")).toString("base64").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function buildQrLink(verificationUri: string, addons: Record<string, unknown>, existingAppId?: string): string {
  const url = new URL(verificationUri);
  url.searchParams.set("from", "sdk");
  url.searchParams.set("source", "node-sdk/gpt-claw");
  url.searchParams.set("tp", "sdk");
  url.searchParams.set("addons", encodeAddons(addons));
  if (existingAppId) url.searchParams.set("clientID", existingAppId);
  return url.toString();
}

async function postForm(url: string, form: Record<string, string>, signal?: AbortSignal): Promise<Record<string, unknown>> {
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded", Accept: "application/json" },
    body: new URLSearchParams(form).toString(),
    signal: signal ? AbortSignal.any([signal, AbortSignal.timeout(20_000)]) : AbortSignal.timeout(20_000),
  });
  const data = (await response.json().catch(() => ({}))) as Record<string, unknown>;
  if (!response.ok && !data.error) throw new Error(`请求失败：HTTP ${response.status}`);
  return data;
}

function writeOwner(config: Config, owner: string): Config {
  if (!/^ou_[A-Za-z0-9_-]+$/.test(owner)) throw new Error("扫码没有返回有效 open_id，请手动设置 FEISHU_ADMIN");
  const path = join(config.root, ".env"), content = existsSync(path) ? readFileSync(path, "utf8") : "";
  const line = `FEISHU_ADMIN=${owner}`;
  writeFileSync(path, /^FEISHU_ADMIN=.*$/m.test(content) ? content.replace(/^FEISHU_ADMIN=.*$/m, line) : `${content}\n${line}\n`, "utf8");
  process.env.FEISHU_ADMIN = owner;
  return readConfig();
}

function showLink(link: string, title: string): void {
  console.log(`\n${title}\n${link}\n`);
  try { qr.generate(link, { small: true }); } catch { /* 终端无法渲染时仅展示链接 */ }
}

/** 把 appId/appSecret 写入 .env：已有键原位替换，缺失键补到末尾；其他键原样保留。 */
function writeEnvCredentials(envFile: string, appId: string, appSecret: string): void {
  const update = (content: string): string => {
    let replacedId = false, replacedSecret = false;
    const lines = content.split("\n").map(line => {
      if (line.startsWith("FEISHU_APP_ID=")) { replacedId = true; return `FEISHU_APP_ID=${appId}`; }
      if (line.startsWith("FEISHU_APP_SECRET=")) { replacedSecret = true; return `FEISHU_APP_SECRET=${appSecret}`; }
      return line;
    });
    if (!replacedId) lines.push(`FEISHU_APP_ID=${appId}`);
    if (!replacedSecret) lines.push(`FEISHU_APP_SECRET=${appSecret}`);
    return lines.join("\n");
  };
  const existing = existsSync(envFile) ? readFileSync(envFile, "utf8") : "";
  writeFileSync(envFile, update(existing).replace(/\n*$/, "\n"), "utf8");
}

/** registerApp Device Flow：展示二维码 → 轮询换取凭证 → 写入 .env。凭证不回显。 */
async function registerFeishuApp(envFile: string, existingAppId?: string, signal?: AbortSignal): Promise<{ appId: string; appSecret: string; openId?: string }> {
  const begin = await postForm(REGISTRATION_URL, { action: "begin", archetype: "PersonalAgent", auth_method: "client_secret", request_user_info: "open_id" }, signal);
  const deviceCode = str(begin.device_code);
  const rawLink = str(begin.verification_uri_complete) || str(begin.verification_uri);
  if (!deviceCode || !rawLink) throw new Error(str(begin.error_description) || str(begin.error) || "发起注册失败：未返回 device_code");
  const addons = buildAddons();
  const link = buildQrLink(rawLink, addons, existingAppId);
  console.log("\n🔐 请用飞书扫描二维码完成授权（或打开下方链接）：");
  console.log(`\n将${existingAppId ? "更新已有应用" : "创建新的 PersonalAgent 应用"}，保留飞书官方默认权限模板，并合并以下追加权限：`);
  console.log(`\n机器人身份追加项（${ADDITIONAL_TENANT_SCOPES.length} 项）：\n  ${ADDITIONAL_TENANT_SCOPES.join("\n  ")}`);
  console.log(`\n用户身份追加项（${ADDITIONAL_USER_SCOPES.length} 项）：\n  ${ADDITIONAL_USER_SCOPES.join("\n  ")}`);
  console.log("\n上述数量只统计追加项，不包含默认模板；合并后的请求以飞书确认页为准，实际开通以应用后台为准。");
  console.log("事件订阅：im.message.receive_v1；卡片回调：card.action.trigger\n");
  try { qr.generate(link, { small: true }); } catch { /* 仅展示链接 */ }
  console.log(link, "\n");
  console.log(`⏱️  约 ${Math.round((num(begin.expires_in) || 600) / 60)} 分钟内有效；权限确认页请点击同意。\n`);

  const intervalMs = (num(begin.interval) || 5) * 1000;
  const deadline = Date.now() + (num(begin.expires_in) || 600) * 1000;
  let waitMs = intervalMs;
  while (Date.now() < deadline) {
    await delay(waitMs, undefined, { signal });
    let poll: Record<string, unknown>;
    try { poll = await postForm(REGISTRATION_URL, { action: "poll", device_code: deviceCode }, signal); }
    catch (error) { signal?.throwIfAborted(); log.warn(`注册轮询暂时失败，继续等待：${errorMessage(error)}`); continue; }
    const appId = str(poll.client_id), appSecret = str(poll.client_secret);
    if (appId && appSecret) {
      writeEnvCredentials(envFile, appId, appSecret);
      console.log("\n✅ 完成！凭证已写入 .env：");
      console.log(`   FEISHU_APP_ID=${appId}`);
      console.log("   FEISHU_APP_SECRET=***（已写入，不回显）");
      const userInfo = poll.user_info as Record<string, unknown> | undefined;
      return { appId, appSecret, openId: str(userInfo?.open_id) || undefined };
    }
    switch (str(poll.error)) {
      case "authorization_pending": process.stdout.write("⏳ 等待扫码授权…\r"); break;
      case "slow_down": waitMs += 5000; break;
      case "access_denied":
      case "expired_token": throw new Error(str(poll.error_description) || `授权失败：${str(poll.error)}`);
      default: if (poll.error) throw new Error(str(poll.error_description) || `授权失败：${str(poll.error)}`);
    }
  }
  throw new Error("等待授权超时（二维码已过期），请重新启动");
}

export interface CliRun { code: number; stdout: string; stderr: string; }

/** 运行内置 lark-cli。认证管理命令要求 CLI 自管凭证，因此不注入 LARKSUITE_CLI_APP_* 环境变量。 */
export async function runCli(config: Config, args: string[], options: { secretStdin?: string; timeoutMs?: number; signal?: AbortSignal } = {}): Promise<CliRun> {
  options.signal?.throwIfAborted();
  const executable = cliExecutable(config.root);
  const env = cliEnvironment(config);
  return await new Promise<CliRun>((resolve, reject) => {
    const child = spawn(executable, args, { cwd: config.root, env, windowsHide: true, stdio: ["pipe", "pipe", "pipe"] });
    const timer = setTimeout(() => child.kill(), options.timeoutMs ?? 120_000);
    const cancel = () => child.kill();
    options.signal?.addEventListener("abort", cancel, { once: true });
    let stdout = "", stderr = "";
    child.stdout.on("data", data => { if (stdout.length < 512 * 1024) stdout += data.toString("utf8"); });
    child.stderr.on("data", data => { if (stderr.length < 512 * 1024) stderr += data.toString("utf8"); });
    if (options.secretStdin !== undefined) { child.stdin.write(`${options.secretStdin}\n`); }
    child.stdin.end();
    const cleanup = () => { clearTimeout(timer); options.signal?.removeEventListener("abort", cancel); };
    child.stdin.on("error", error => { cleanup(); child.kill(); reject(error); });
    child.on("error", error => { cleanup(); reject(error); });
    child.on("close", code => { cleanup(); if (options.signal?.aborted) reject(options.signal.reason); else resolve({ code: code ?? 1, stdout, stderr }); });
  });
}

/** CLI 输出中提取 JSON：优先整体解析，兼容前后混入提示行的情况。 */
export function parseCliJson(text: string): Record<string, unknown> | undefined {
  const trimmed = text.trim();
  try { const value = JSON.parse(trimmed); return value && typeof value === "object" ? value as Record<string, unknown> : undefined; } catch { /* 继续截取 */ }
  for (const line of trimmed.split(/\r?\n/).reverse()) {
    const at = line.indexOf("{");
    if (at < 0) continue;
    try { const value = JSON.parse(line.slice(at)); if (value && typeof value === "object") return value as Record<string, unknown>; } catch { /* 继续尝试 */ }
  }
  const start = trimmed.indexOf("{"), end = trimmed.lastIndexOf("}");
  if (start >= 0 && end > start) {
    try { const value = JSON.parse(trimmed.slice(start, end + 1)); return value && typeof value === "object" ? value as Record<string, unknown> : undefined; } catch { return undefined; }
  }
  return undefined;
}

export interface CliStatus { appId?: string; userAvailable: boolean; userOpenId?: string; userScopes: string[]; }

export async function cliStatus(config: Config, signal?: AbortSignal): Promise<CliStatus> {
  const result = await runCli(config, ["auth", "status", "--json", "--verify"], { signal });
  const envelope = parseCliJson(result.stdout) || parseCliJson(result.stderr);
  if (!envelope) throw new Error(`内置 lark-cli 状态不可读，退出码 ${result.code}`);
  const failure = record(envelope.error);
  if ((result.code !== 0 || envelope.ok === false) && failure.subtype !== "not_configured") {
    throw new Error(`内置 CLI 状态校验失败（退出码 ${result.code}），不会据此重置登录`);
  }
  const parsed = envelope.data && typeof envelope.data === "object" ? record(envelope.data) : envelope;
  const user = record(record(parsed.identities).user);
  return {
    appId: str(parsed.appId) || undefined,
    userAvailable: result.code === 0 && envelope.ok !== false && (user.available === true || user.status === "ready"),
    userOpenId: str(user.openId) || undefined,
    userScopes: str(user.scope).split(/\s+/).filter(Boolean),
  };
}

/** 内置 lark-cli：绑定应用（幂等）→ 检查用户登录 → 未登录则走 device 认证并校验登录者。 */
async function ensureCliLogin(config: Config, signal?: AbortSignal): Promise<Config> {
  let status = await cliStatus(config, signal);
  if (status.appId !== config.appId) {
    await mkdir(join(config.dataDir, "lark-cli"), { recursive: true });
    // 密钥经 stdin 传入，不进进程参数列表；config init 会覆盖旧绑定
    const init = await runCli(config, ["config", "init", "--app-id", config.appId, "--app-secret-stdin", "--brand", config.domain === "lark" ? "lark" : "feishu"], { secretStdin: config.appSecret, signal });
    if (init.code !== 0) throw new Error(`内置 lark-cli 绑定应用失败，退出码 ${init.code}`);
    log.info(`内置 lark-cli 已绑定应用 ${config.appId}`);
    status = await cliStatus(config, signal);
    if (status.appId !== config.appId) throw new Error("内置 CLI 应用绑定未生效，未继续用户授权");
  }
  if (status.userAvailable && status.userOpenId) {
    if (config.owner && status.userOpenId !== config.owner) {
      log.warn("内置 CLI 登录者与 FEISHU_ADMIN 不一致，退出旧登录后由本人重新扫码");
      const logout = await runCli(config, ["auth", "logout"], { signal });
      if (logout.code !== 0) throw new Error("退出不匹配的 CLI 身份失败，未继续授权");
    } else {
      if (!config.owner) config = writeOwner(config, status.userOpenId);
      log.info("内置 lark-cli 用户身份已就绪");
      return config;
    }
  }

  log.info("内置 lark-cli 未登录：进入 device 认证模式");
  const loginArgs = ["auth", "login", "--recommend", "--no-wait", "--json"];
  const begin = await runCli(config, loginArgs, { signal });
  const envelope = parseCliJson(begin.stdout) || parseCliJson(begin.stderr);
  const parsed = (envelope?.data && typeof envelope.data === "object" ? envelope.data : envelope) as Record<string, unknown> | undefined;
  const link = str(parsed?.verification_uri_complete) || str(parsed?.verification_url) || str(parsed?.verification_uri);
  const deviceCode = str(parsed?.device_code);
  if (begin.code !== 0 || !link || !deviceCode) {
    const failure = parsed?.error as { message?: unknown } | undefined;
    throw new Error(`发起用户授权失败：${str(failure?.message) || str(parsed?.message) || `退出码 ${begin.code}`}`);
  }
  showLink(link, "🔐 请用飞书完成内置 lark-cli 的用户授权（机器人聊天的本人身份）：");
  console.log("授权范围：CLI 原生推荐（--recommend）；授权后此终端会自动继续。\n");

  const done = await runCli(config, ["auth", "login", "--device-code", deviceCode, "--json"], { timeoutMs: 11 * 60_000, signal });
  const result = parseCliJson(done.stdout) || parseCliJson(done.stderr);
  const authorization = result?.data && typeof result.data === "object" ? record(result.data) : record(result);
  // Exit 3 also means successful login with incomplete scopes; never infer success from the code alone.
  const partial = done.code === 3 && result?.ok !== false && authorization.event === "authorization_complete"
    && !!str(authorization.user_open_id) && record(authorization.warning).type === "missing_scope";
  if (done.code !== 0 && !partial) {
    log.warn(`内置 CLI 用户授权未完成（退出码 ${done.code}）；请重启后重新授权`);
    return config;
  }
  const after = await cliStatus(config, signal);
  if (after.appId !== config.appId || !after.userAvailable || !after.userOpenId) throw new Error("CLI 未返回当前应用下可验证的用户身份，不能确认授权完成");
  if (partial && authorization.user_open_id !== after.userOpenId) throw new Error("CLI 授权结果与当前登录身份不一致，不能确认授权完成");
  if (config.owner && after.userOpenId !== config.owner) {
    log.warn(`本次扫码账号（${after.userOpenId}）不是 FEISHU_ADMIN 本人，已退出该登录；请重启后由本人扫码`);
    await runCli(config, ["auth", "logout"], { signal });
    return config;
  }
  if (!config.owner) config = writeOwner(config, after.userOpenId);
  if (partial) log.warn("内置 lark-cli 本人登录已验证，但部分推荐权限未授予；相关操作仍受飞书权限限制");
  else log.info("内置 lark-cli 用户授权完成");
  return config;
}

/**
 * 启动引导总入口：先保证机器人凭证（缺则 registerApp 扫码），再保证内置 lark-cli
 * 的本人登录。凭证写入 .env 与进程环境后返回重读的配置。
 */
export async function ensureFeishuAuth(config: Config, signal?: AbortSignal): Promise<Config> {
  if (!config.appId || !config.appSecret) {
    if (config.domain !== "feishu") throw new Error("国际版 Lark 暂不支持扫码开通，请手动填写 FEISHU_APP_ID / FEISHU_APP_SECRET");
    log.info("飞书机器人未配置：进入 device 认证模式（扫码创建/绑定应用）");
    const registered = await registerFeishuApp(join(config.root, ".env"), config.appId || undefined, signal);
    process.env.FEISHU_APP_ID = registered.appId;
    process.env.FEISHU_APP_SECRET = registered.appSecret;
    config = readConfig();
    if (!config.owner && registered.openId) config = writeOwner(config, registered.openId);
  }
  try { config = await ensureCliLogin(config, signal); }
  catch (error) { signal?.throwIfAborted(); log.warn(`内置 CLI 授权未就绪：${errorMessage(error)}；已配置本人的机器人仍可继续启动`); }
  if (!config.owner) throw new Error("无法绑定本人，请完成终端扫码或填写 FEISHU_ADMIN 后重启");
  return config;
}
