import { createServer, type Server } from "node:http";
import { randomBytes } from "node:crypto";
import { z } from "zod";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import type { SessionContext } from "../app/ports.ts";
import { Prompts } from "../app/prompts.ts";
import type { Services, ToolSpec } from "./contract.ts";
import { isMediaResult } from "./contract.ts";
import { errorMessage } from "../shared/log.ts";
import { approvalToolPreview } from "../app/redact.ts";

/** Loopback MCP, standard SDK transport. Each unguessable route binds a trusted chat/session. */
export class ToolHost {
  private server?: Server;
  private port = 0;
  private readonly routes = new Map<string, SessionContext>();
  private readonly keys = new Map<string, string>();
  private readonly transports = new Set<StreamableHTTPServerTransport>();
  constructor(private readonly tools: ToolSpec<any>[], private readonly services: Services, private readonly prompts: Prompts) {}
  url(context: SessionContext): string {
    let key = this.keys.get(context.sessionKey);
    if (!key) { key = randomBytes(32).toString("hex"); this.keys.set(context.sessionKey, key); this.routes.set(`/mcp/${key}`, Object.freeze({ ...context })); }
    return `http://127.0.0.1:${this.port}/mcp/${key}`;
  }
  async start(): Promise<void> {
    this.server = createServer((req, res) => {
      void (async () => {
        const session = this.routes.get(req.url || "");
        if (!session || req.headers.origin || req.headers.host !== `127.0.0.1:${this.port}`) { res.writeHead(403).end(); return; }
        if (req.method !== "POST") { res.writeHead(405).end(); return; }
        let size = 0; const chunks: Buffer[] = [];
        for await (const chunk of req) { size += chunk.length; if (size > 512 * 1024) { res.writeHead(413).end(); return; } chunks.push(Buffer.from(chunk)); }
        const body = JSON.parse(Buffer.concat(chunks).toString("utf8"));
        const mcp = new McpServer({ name: "gpt-claw-personal", version: "0.1.0" });
        for (const tool of this.tools) {
          mcp.registerTool(tool.name, { description: tool.description, inputSchema: z.object(tool.input).strict(), annotations: { readOnlyHint: !!tool.readOnly, destructiveHint: !tool.readOnly, openWorldHint: !tool.readOnly } }, async (args, extra) => {
            try {
              extra.signal.throwIfAborted();
              const required = typeof tool.confirmation === "function" ? tool.confirmation(args) : tool.confirmation;
              if (required && await this.prompts.ask(session.chatId, {
                title: `确认操作：${tool.name}`, detail: "此工具将按以下参数执行。敏感字段的值已隐藏。",
                fields: [{ label: "工具参数", value: JSON.stringify(approvalToolPreview(args), null, 2), code: true }],
                choices: [{ label: "允许一次", value: "allow" }, { label: "拒绝", value: "deny" }],
              }, extra.signal, session.sessionKey) !== "allow") return { isError: true, content: [{ type: "text", text: "本人拒绝、取消或未及时确认，操作未执行" }] };
              extra.signal.throwIfAborted();
              const result = await tool.run(args, { session, services: this.services, signal: extra.signal });
              if (isMediaResult(result)) return result.result;
              return { content: [{ type: "text", text: typeof result === "string" ? result.slice(0, 50_000) : JSON.stringify(result ?? null).slice(0, 50_000) }] };
            } catch (error) { return { isError: true, content: [{ type: "text", text: errorMessage(error) }] }; }
          });
        }
        const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined, enableJsonResponse: true });
        this.transports.add(transport);
        res.once("close", () => { this.transports.delete(transport); void mcp.close().catch(() => {}); });
        await mcp.connect(transport); await transport.handleRequest(req, res, body);
      })().catch(() => { if (!res.headersSent) res.writeHead(400).end("Invalid MCP request"); else res.end(); });
    });
    this.server.requestTimeout = 10_000; this.server.headersTimeout = 10_000;
    await new Promise<void>((resolve, reject) => { this.server!.once("error", reject); this.server!.listen(0, "127.0.0.1", () => resolve()); });
    const address = this.server.address();
    if (!address || typeof address === "string") throw new Error("无法启动 MCP 本机服务");
    this.port = address.port;
  }
  async close(): Promise<void> {
    await Promise.allSettled([...this.transports].map(transport => transport.close()));
    const server = this.server;
    if (server) { const closed = new Promise<void>(resolve => server.close(() => resolve())); server.closeAllConnections(); await closed; }
  }
}
