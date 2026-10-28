import type { ZodRawShape, ZodObject, infer as Infer } from "zod";
import type { SessionContext } from "../app/ports.ts";
import type { Browser } from "../services/browser.ts";
import type { Jobs } from "../services/jobs.ts";
import type { Schedules } from "../services/schedules.ts";
import type { Store } from "../storage.ts";
import type { FeishuChannel } from "../feishu/channel.ts";
import type { Channel } from "../app/ports.ts";
import type { SessionFiles } from "../services/session-files.ts";
import type { ScreenShare } from "../services/screen-share.ts";
import type { WindowsMcp } from "../services/windows-mcp.ts";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";

export interface Services { browser: Browser; jobs: Jobs; schedules: Schedules; store: Store; channel: Channel; feishu: FeishuChannel; files: SessionFiles; screenShare: ScreenShare; windowsMcp: WindowsMcp; workspace: string; }
export interface MediaToolResult { readonly kind: "mcp-content"; readonly result: CallToolResult; }
export function mediaResult(result: CallToolResult): MediaToolResult { return { kind: "mcp-content", result }; }
export function isMediaResult(value: unknown): value is MediaToolResult {
  return !!value && typeof value === "object" && "kind" in value && value.kind === "mcp-content" && "result" in value;
}
export interface ToolContext { readonly session: SessionContext; readonly services: Services; readonly signal: AbortSignal; }
export interface ToolSpec<Shape extends ZodRawShape = ZodRawShape> {
  name: string; description: string; input: Shape;
  readOnly?: boolean;
  confirmation?: boolean | ((params: Infer<ZodObject<Shape>>) => boolean);
  run(params: Infer<ZodObject<Shape>>, context: ToolContext): Promise<unknown>;
}
export function defineTool<Shape extends ZodRawShape>(tool: ToolSpec<Shape>): ToolSpec<Shape> { return tool; }
