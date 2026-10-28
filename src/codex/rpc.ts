import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { EventEmitter } from "node:events";
import { createInterface } from "node:readline";
import { join } from "node:path";
import type { Config } from "../config.ts";
import { log } from "../shared/log.ts";
import { cliEnvironment, cliShellBindings } from "../feishu/cli.ts";
import { providerProcess } from "./provider.ts";

export type Params = Record<string, any>;
export interface ServerRequest { id: string | number; method: string; params: Params; signal: AbortSignal; }
type RequestHandler = (request: ServerRequest) => Promise<unknown>;
export class CodexRpcTimeoutError extends Error {}

/** Only this module knows stdio framing, request IDs and process lifetime. */
export class CodexRpc extends EventEmitter {
  private child?: ChildProcessWithoutNullStreams;
  private sequence = 0;
  private readonly pending = new Map<number, { resolve(value: any): void; reject(error: Error): void; timer: NodeJS.Timeout }>();
  private readonly incoming = new Map<string | number, AbortController>();
  onRequest?: RequestHandler;
  constructor(private readonly config: Config) { super(); }
  async start(): Promise<void> {
    if (this.child) throw new Error("Codex 已经启动");
    const command = process.execPath;
    const args = [join(this.config.root, "node_modules/@openai/codex/bin/codex.js")];
    // Keep native Codex auth/config; bind CLI version/account and remove injected secrets.
    const provider = providerProcess(this.config, this.config.root);
    const env = { ...cliEnvironment(this.config), ...provider.env };
    // Native shell policy can trim inherited variables: also declare the project bindings there.
    const shellArgs = Object.entries(cliShellBindings(this.config)).flatMap(([key, value]) => ["-c", `shell_environment_policy.set.${key}=${JSON.stringify(value)}`]);
    this.child = spawn(command, [...args, ...provider.args, ...shellArgs, "-c", 'project_root_markers=[".codex"]', "app-server", "--listen", "stdio://"], { cwd: this.config.root, env, windowsHide: true, stdio: "pipe" });
    const lines = createInterface({ input: this.child.stdout });
    lines.on("line", line => {
      try { this.receive(JSON.parse(line)); }
      catch { log.warn("忽略无法解析的 Codex 协议消息"); }
    });
    // Consume diagnostics without exposing local credentials or URLs in application logs.
    this.child.stderr.on("data", () => {});
    this.child.stdin.on("error", error => this.disconnected(error));
    this.child.on("error", error => this.disconnected(error));
    this.child.on("close", code => { lines.close(); this.child = undefined; this.disconnected(new Error(`Codex 进程已退出（${code ?? "signal"}）`)); });
    await this.request("initialize", { clientInfo: { name: "gpt_claw", title: "gpt-claw", version: "0.1.0" } });
    this.notify("initialized", {});
    if (this.config.api?.kind === "openai") {
      try {
        const result = await this.request("account/login/start", { type: "apiKey", apiKey: this.config.api.key });
        if (result.type !== "apiKey") throw new Error("Unexpected authentication mode");
      } catch {
        // Native authentication errors must not echo supplied credentials into logs.
        throw new Error("Codex API Key 模式初始化失败，请检查原生认证配置；启动已终止");
      }
    }
  }
  request<T = any>(method: string, params: Params, timeoutMs = 60_000): Promise<T> {
    const id = ++this.sequence;
    return new Promise<T>((resolve, reject) => {
      const timer = setTimeout(() => { this.pending.delete(id); reject(new CodexRpcTimeoutError(`Codex ${method} 请求超时`)); }, timeoutMs);
      this.pending.set(id, { resolve, reject, timer });
      try { this.send({ id, method, params }); }
      catch (error) { clearTimeout(timer); this.pending.delete(id); reject(error); }
    });
  }
  notify(method: string, params: Params): void { this.send({ method, params }); }
  private send(message: unknown): void {
    if (!this.child || this.child.killed || !this.child.stdin.writable) throw new Error("Codex 未连接");
    this.child.stdin.write(`${JSON.stringify(message)}\n`);
  }
  private receive(message: Params): void {
    if (typeof message.method === "string") {
      if (message.id !== undefined) {
        const controller = new AbortController(); this.incoming.set(message.id, controller);
        void (async () => {
          try {
            if (!this.onRequest) throw new Error("未配置审批处理器");
            const result = await this.onRequest({ id: message.id, method: message.method, params: message.params || {}, signal: controller.signal });
            if (!controller.signal.aborted) this.send({ id: message.id, result });
          } catch {
            if (!controller.signal.aborted && this.child) {
              try { this.send({ id: message.id, error: { code: -32601, message: "客户端无法处理此请求，操作未获批准" } }); } catch { /* Connection already closed. */ }
            }
          } finally { this.incoming.delete(message.id); }
        })();
      } else {
        if (message.method === "serverRequest/resolved") this.incoming.get(message.params?.requestId)?.abort();
        this.emit("notification", message.method, message.params || {});
      }
      return;
    }
    const pending = this.pending.get(message.id);
    if (!pending) return;
    clearTimeout(pending.timer); this.pending.delete(message.id);
    if (message.error) pending.reject(new Error(`${message.error.code}: ${message.error.message}`));
    else pending.resolve(message.result);
  }
  private disconnected(error: Error): void {
    for (const item of this.pending.values()) { clearTimeout(item.timer); item.reject(error); }
    this.pending.clear();
    for (const controller of this.incoming.values()) controller.abort();
    this.incoming.clear(); this.emit("disconnected", error);
  }
  async close(): Promise<void> {
    const child = this.child;
    if (!child) return;
    const closed = new Promise<void>(resolve => child.once("close", () => resolve()));
    child.stdin.end();
    const timer = setTimeout(() => {
      // The bundled JS launcher owns a native child. Terminate its tree on Windows.
      if (process.platform === "win32" && child.pid) {
        const killer = spawn("taskkill.exe", ["/PID", String(child.pid), "/T", "/F"], { windowsHide: true, stdio: "ignore" });
        killer.on("error", () => child.kill());
      } else child.kill("SIGKILL");
    }, 3000);
    await closed; clearTimeout(timer);
  }
}
