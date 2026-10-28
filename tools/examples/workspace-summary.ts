import { readdir } from "node:fs/promises";
import { z } from "zod";
import { defineTool } from "../../src/tools/contract.ts";

/** Copy to tools/workspace-summary.ts and change the import to ../src/tools/contract.ts. */
export default defineTool({
  name: "workspace_summary",
  description: "只读列出当前工作区顶层文件和目录名称；不读取文件正文。需要查看已有产物或工作区结构时调用。",
  input: { limit: z.number().int().min(1).max(200).default(50) },
  readOnly: true,
  confirmation: false,
  async run({ limit }, { services, signal }) {
    signal.throwIfAborted();
    const entries = await readdir(services.workspace, { withFileTypes: true });
    return { items: entries.slice(0, limit).map(entry => ({ name: entry.name, directory: entry.isDirectory() })), hasMore: entries.length > limit };
  },
});
