import { existsSync } from "node:fs";
import { delimiter, dirname, join } from "node:path";
import type { Config } from "../config.ts";

type CliConfig = Pick<Config, "root" | "dataDir" | "domain">;
const credentialKeys = new Set([
  "FEISHU_APP_ID", "FEISHU_APP_SECRET", "FEISHU_ADMIN",
  "LARKSUITE_CLI_APP_ID", "LARKSUITE_CLI_APP_SECRET",
  "LARKSUITE_CLI_USER_ACCESS_TOKEN", "LARKSUITE_CLI_TENANT_ACCESS_TOKEN",
]);

export function cliExecutable(root: string): string {
  return join(root, "node_modules", "@larksuite", "cli", "bin", process.platform === "win32" ? "lark-cli.exe" : "lark-cli");
}

/** Safe values shared by startup authentication and native agent commands. */
export function cliShellBindings(config: CliConfig, source: NodeJS.ProcessEnv = process.env): Record<string, string> {
  const pathKey = Object.keys(source).find(key => key.toUpperCase() === "PATH");
  const inheritedPath = pathKey ? source[pathKey] : undefined;
  // MSIX PowerShell under WindowsApps resolves as pwsh.exe but cannot start inside
  // the native Windows sandbox. Let Codex discover the system PowerShell instead.
  const usablePath = process.platform === "win32"
    ? inheritedPath?.split(delimiter).filter(path => !/(?:^|[\\/])WindowsApps(?:[\\/]|$)/i.test(path)).join(delimiter)
    : inheritedPath;
  return {
    PATH: [dirname(cliExecutable(config.root)), join(config.root, "node_modules", ".bin"), usablePath].filter(Boolean).join(delimiter),
    LARKSUITE_CLI_CONFIG_DIR: join(config.dataDir, "lark-cli"),
    LARKSUITE_CLI_BRAND: config.domain,
    LARKSUITE_CLI_NO_UPDATE_NOTIFIER: "1",
    LARKSUITE_CLI_NO_SKILLS_NOTIFIER: "1",
  };
}

/** Prefer the pinned executable and project account independently of the launch method. */
export function cliEnvironment(config: CliConfig, source: NodeJS.ProcessEnv = process.env): NodeJS.ProcessEnv {
  if (!existsSync(cliExecutable(config.root))) throw new Error("内置 lark-cli 未安装：请在工程目录执行 npm install");
  const bindings = cliShellBindings(config, source), env = { ...source };
  for (const key of Object.keys(env)) {
    const canonical = key.toUpperCase();
    if (credentialKeys.has(canonical) || /^(?:OPENAI_|MODEL_|DEEPSEEK_|GPT_CLAW_PROVIDER_)/.test(canonical) || canonical === "PATH" || canonical in bindings) delete env[key];
  }
  return { ...env, ...bindings };
}
