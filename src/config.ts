import { config as loadEnv } from "dotenv";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { modelConfig } from "./codex/provider.ts";

export const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
loadEnv({ path: resolve(projectRoot, ".env"), quiet: true });

function integer(name: string, fallback: number, min: number, max: number): number {
  const value = Number(process.env[name] || fallback);
  if (!Number.isInteger(value) || value < min || value > max) throw new Error(`${name} 必须是 ${min}–${max} 的整数`);
  return value;
}

export function readConfig() {
  const appId = process.env.FEISHU_APP_ID?.trim() || "";
  const appSecret = process.env.FEISHU_APP_SECRET?.trim() || "";
  const configuredOwner = process.env.FEISHU_ADMIN?.trim() || "";
  const owner = configuredOwner === "ou_your_open_id" ? "" : configuredOwner;
  // 机器人凭证缺失不算配置错误：启动时由 device 认证模式扫码创建/绑定（src/feishu/device-auth.ts）。
  if (owner && !/^ou_[A-Za-z0-9_-]+$/.test(owner)) throw new Error("FEISHU_ADMIN 必须填写本人真实 open_id，或留空由终端扫码绑定");
  const domain = process.env.FEISHU_DOMAIN || "feishu";
  if (!["feishu", "lark"].includes(domain)) throw new Error("FEISHU_DOMAIN 必须是 feishu 或 lark");
  const effort = process.env.MODEL_EFFORT?.trim() || undefined;
  if (effort && !["none", "minimal", "low", "medium", "high", "xhigh"].includes(effort)) throw new Error("MODEL_EFFORT 档位无效；支持情况取决于所选模型");
  return {
    root: projectRoot, appId, appSecret, owner, domain,
    workspace: resolve(projectRoot, process.env.GPT_CLAW_WORKSPACE || "workspace"),
    dataDir: resolve(projectRoot, process.env.GPT_CLAW_DATA_DIR || "data"),
    ...modelConfig(process.env), effort,
    browserChannel: process.env.BROWSER_CHANNEL || "msedge",
    jobConcurrency: integer("JOB_CONCURRENCY", 2, 1, 8),
    turnTimeoutMs: integer("TURN_TIMEOUT_MINUTES", 30, 1, 240) * 60_000,
    approvalTimeoutMs: integer("APPROVAL_TIMEOUT_SECONDS", 180, 15, 600) * 1000,
    outboxSentRetentionMs: integer("OUTBOX_SENT_RETENTION_DAYS", 7, 1, 365) * 24 * 60 * 60_000,
  };
}
export type Config = ReturnType<typeof readConfig>;
