import { readdir } from "node:fs/promises";
import { join } from "node:path";
import { pathToFileURL } from "node:url";
import type { ToolSpec } from "./contract.ts";

/** Trusted local code, loaded once. No model-controlled path or automatic package execution. */
export async function loadTools(directory: string, base: ToolSpec<any>[]): Promise<ToolSpec<any>[]> {
  const files = await readdir(directory).catch(error => { if (error.code === "ENOENT") return []; throw error; });
  const result = [...base], names = new Set(base.map(tool => tool.name));
  for (const file of files.sort().filter(file => /\.(ts|js|mjs)$/.test(file) && !file.endsWith(".d.ts"))) {
    const module = await import(pathToFileURL(join(directory, file)).href);
    const tool = module.default as ToolSpec<any>;
    if (!tool || !/^[a-z][a-z0-9_]{0,63}$/.test(tool.name) || !tool.description || !tool.input || typeof tool.run !== "function") throw new Error(`工具定义无效：${file}`);
    if (names.has(tool.name)) throw new Error(`工具名称重复：${tool.name}`);
    names.add(tool.name); result.push({ ...tool, confirmation: tool.confirmation ?? true });
  }
  return result;
}
