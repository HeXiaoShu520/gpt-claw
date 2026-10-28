import { access } from "node:fs/promises";
import { execFile } from "node:child_process";
import { join } from "node:path";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { z } from "zod";

const bounds = z.object({ x: z.number().int(), y: z.number().int(), width: z.number().int().positive(), height: z.number().int().positive() });
const snapshotSchema = z.object({
  schema_version: z.literal(1), backend_version: z.literal("0.8.8"), truncated: z.boolean(),
  elements: z.array(z.object({
    window_id: z.number().int().positive(), identity: z.string().max(256).nullable(), name: z.string().max(300), role: z.string().max(80), bounds,
    actionable: z.boolean(), enabled: z.boolean(), focused: z.boolean(), toggle: z.string().max(20),
  })).max(256),
});
export type SemanticSnapshot = z.infer<typeof snapshotSchema>;
export type SemanticElement = SemanticSnapshot["elements"][number];
export interface WindowTarget { window_id: number; pid: number; }

/** Internal read-only MCP child. ScreenShare authorizes callers before this service is used. */
export class WindowsMcp {
  private connection?: { client: Client; transport: StdioClientTransport };
  private busy = false;
  private stopped = false;
  private disconnecting?: Promise<void>;
  constructor(private readonly root: string) {}

  async observe(windows: WindowTarget[], signal: AbortSignal, timeoutMs = 12_000): Promise<SemanticSnapshot> {
    signal.throwIfAborted();
    if (this.stopped) throw new Error("Windows 观察服务已关闭");
    if (this.busy) throw new Error("Windows 观察服务正在处理另一请求");
    if (process.platform !== "win32") throw new Error("语义观察目前仅支持 Windows");
    this.busy = true;
    const cancel = () => { void this.disconnect(); };
    signal.addEventListener("abort", cancel, { once: true });
    try {
      const client = await this.connect(signal);
      const result = await client.callTool({ name: "ObserveWindow", arguments: { windows } }, undefined, { signal, timeout: timeoutMs });
      signal.throwIfAborted();
      if (result.isError) throw new Error("UIA 无法读取目标窗口，请重新观察或使用 screenshot");
      // FastMCP dict results are structuredContent. No parsing of human-readable trees.
      const parsed = snapshotSchema.safeParse(result.structuredContent);
      if (!parsed.success || parsed.data.elements.some(element => !windows.some(window => window.window_id === element.window_id)))
        throw new Error("Windows 观察接口不兼容，请运行 npm run computer:setup");
      return parsed.data;
    } catch (error) {
      await this.disconnect();
      signal.throwIfAborted();
      throw error;
    } finally {
      signal.removeEventListener("abort", cancel);
      this.busy = false;
    }
  }

  private async connect(signal: AbortSignal): Promise<Client> {
    await this.disconnecting;
    signal.throwIfAborted();
    if (this.stopped) throw new Error("Windows 观察服务已关闭");
    if (this.connection) return this.connection.client;
    const directory = join(this.root, "integrations", "windows-mcp");
    const python = join(directory, ".venv", "Scripts", "python.exe");
    await access(python).catch(() => { throw new Error("语义观察依赖尚未安装，请在工程目录运行 npm run computer:setup；screenshot 仍可用"); });
    signal.throwIfAborted();
    if (this.stopped) throw new Error("Windows 观察服务已关闭");
    const transport = new StdioClientTransport({
      command: python, args: ["-u", join(directory, "observer.py")], cwd: directory, stderr: "pipe",
      env: { PYTHONUTF8: "1", ANONYMIZED_TELEMETRY: "false", WINDOWS_MCP_MAX_TREE_ELEMENTS: "400" },
    });
    // Drain provider logs, which may include private window titles. Do not forward them.
    transport.stderr?.on("data", () => {});
    const client = new Client({ name: "gpt-claw", version: "0.1.0" });
    const connection = { client, transport };
    this.connection = connection;
    client.onclose = () => { if (this.connection === connection) this.connection = undefined; };
    await client.connect(transport, { signal, timeout: 20_000 });
    return client;
  }

  private disconnect(): Promise<void> {
    if (this.disconnecting) return this.disconnecting;
    const connection = this.connection;
    this.connection = undefined;
    if (!connection) return Promise.resolve();
    this.disconnecting = (async () => {
      // Windows venv launchers can own an interpreter child. Stop the known
      // process tree before closing the transport, including a blocked UIA call.
      const pid = connection.transport.pid;
      if (process.platform === "win32" && pid) await new Promise<void>(resolve => {
        execFile("taskkill.exe", ["/PID", String(pid), "/T", "/F"], { windowsHide: true, timeout: 5_000 }, () => resolve());
      });
      await connection.client.close().catch(() => {});
    })().finally(() => { this.disconnecting = undefined; });
    return this.disconnecting;
  }

  async close(): Promise<void> { this.stopped = true; await this.disconnect(); }
}
