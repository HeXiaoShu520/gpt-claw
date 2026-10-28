import { access, readFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { spawn } from "node:child_process";
import { projectRoot, readConfig } from "./config.ts";
import { cliExecutable } from "./feishu/cli.ts";

/** Local diagnostics only: no bot connection, browser launch or model request. */
async function doctor() {
  console.log(`Node：${process.version}`);
  let valid = true;
  let apiKind: string | undefined;
  try {
    const config = readConfig();
    apiKind = config.api?.kind;
    const bot = config.appId && config.appSecret ? "已配置" : "未配置（首次启动将进入 device 认证模式）";
    console.log(`配置：有效；${config.domain}；机器人${bot}；Codex 工作目录 ${config.root}；附件目录 ${config.workspace}`);
    console.log(`内置 lark-cli：${existsSync(cliExecutable(projectRoot)) ? "已安装" : "未安装（npm install 后才能 device 认证）"}`);
  }
  catch (error) { valid = false; console.log(`配置：${(error as Error).message}`); }
  for (const path of [".codex/config.toml", "AGENTS.md"]) {
    try { await access(join(projectRoot, path)); console.log(`${path}：存在`); }
    catch { valid = false; console.log(`${path}：缺失`); }
  }
  let credentialsAvailable = !!apiKind;
  if (apiKind) {
    console.log(`Codex 认证：已配置 ${apiKind} API；尚未验证服务、Key 的可用性或额度`);
  } else {
    const command = process.execPath;
    const args = [join(projectRoot, "node_modules/@openai/codex/bin/codex.js")];
    const env = { ...process.env };
    for (const key of Object.keys(env)) if (/^(?:OPENAI_|MODEL_|DEEPSEEK_|GPT_CLAW_PROVIDER_)/i.test(key)) delete env[key];
    const result = await new Promise<{ code: number | null; output: string }>((resolve, reject) => {
      const child = spawn(command, [...args, "login", "status"], { cwd: projectRoot, env, windowsHide: true });
      let output = ""; child.stdout.on("data", data => { output += String(data); }); child.stderr.on("data", data => { output += String(data); });
      child.on("error", reject); child.on("close", code => resolve({ code, output }));
      const timer = setTimeout(() => child.kill(), 15_000); child.on("close", () => clearTimeout(timer));
    });
    credentialsAvailable = result.code === 0;
    console.log(`Codex 登录：${credentialsAvailable ? (/ChatGPT/i.test(result.output) ? "ChatGPT 账号" : "已登录，请以原生 status 确认计费方式") : "未登录，可执行 npm run codex:login；如改用 API 则填写 MODEL_API_KEY 或 DEEPSEEK_API_KEY"}`);
  }
  try { const packageInfo = JSON.parse(await readFile(join(projectRoot, "node_modules/@openai/codex/package.json"), "utf8")); console.log(`工程 Codex：${packageInfo.version}`); } catch { valid = false; }
  if (!valid || !credentialsAvailable) process.exitCode = 1;
}
doctor().catch(error => { console.error((error as Error).message); process.exitCode = 1; });
