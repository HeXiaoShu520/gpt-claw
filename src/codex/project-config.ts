import { realpathSync } from "node:fs";
import { isAbsolute, relative, resolve, sep } from "node:path";
import type { Config } from "../config.ts";
import { log } from "../shared/log.ts";
import type { CodexRpc, Params } from "./rpc.ts";

interface ConfigLayer {
  name: { type: string; dotCodexFolder?: string; file?: string; profile?: string | null };
  config: Params; version: string; disabledReason?: string | null;
}
interface EffectiveConfig { config: Params; layers?: ConfigLayer[]; }
const canonical = (path: string) => process.platform === "win32" ? resolve(path).toLowerCase() : resolve(path);
function contains(parent: string, path: string): boolean {
  const child = relative(canonical(parent), canonical(path));
  return !child || (!isAbsolute(child) && child !== ".." && !child.startsWith(`..${sep}`));
}

/** Native project discovery and trust; execution policies stay in the project's TOML. */
export async function projectConfig(rpc: CodexRpc, config: Config): Promise<Params> {
  const read = () => rpc.request<EffectiveConfig>("config/read", { cwd: config.root, includeLayers: true });
  const ownLayer = (result: EffectiveConfig) => result.layers?.find(layer => layer.name.type === "project"
    && layer.name.dotCodexFolder && canonical(layer.name.dotCodexFolder) === canonical(resolve(config.root, ".codex")));
  let effective = await read();
  let project = ownLayer(effective);
  if (!project) throw new Error("Codex 未发现工程 .codex/config.toml；请检查项目配置文件和工程根目录");
  if (project.disabledReason) {
    if (!project.disabledReason.includes("as a trusted project")) throw new Error("Codex 禁用了工程配置；请检查原生配置与受管策略");
    // Trust is read from persisted user config, not -c session overrides (Codex 0.157.1).
    const user = effective.layers?.find(layer => layer.name.type === "user" && !layer.name.profile);
    if (!user?.name.file || !user.version) throw new Error("无法读取 Codex 用户配置版本，未更改工程信任");
    for (const layer of effective.layers || []) {
      if (layer.name.type === "project" || layer.name.type === "sessionFlags") continue;
      for (const [path, settings] of Object.entries(layer.config.projects || {})) {
        if ((settings as Params)?.trust_level === "untrusted" && contains(path, config.root)) {
          throw new Error("工程已被原生配置标记为 untrusted；请在 Codex 中明确调整信任后再启动");
        }
      }
    }
    const root = canonical(realpathSync(config.root));
    const projects = user.config.projects || {};
    // Preserve other project entries; expectedVersion prevents overwriting concurrent edits.
    await rpc.request("config/value/write", {
      filePath: user.name.file, expectedVersion: user.version, keyPath: "projects", mergeStrategy: "upsert",
      value: { ...projects, [root]: { ...projects[root], trust_level: "trusted" } },
    });
    effective = await read(); project = ownLayer(effective);
    if (!project || project.disabledReason) throw new Error("Codex 工程信任已写入，但工程配置仍未启用；启动已终止");
    log.info("已通过 Codex 原生配置接口记录本工程信任");
  }
  return effective.config;
}
