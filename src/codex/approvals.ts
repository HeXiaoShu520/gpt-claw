import type { ServerRequest } from "./rpc.ts";
import { Prompts } from "../app/prompts.ts";
import type { SessionContext } from "../app/ports.ts";
import { approvalCommandPreview, redactSecrets } from "../app/redact.ts";

/** Translate native requests; no command regex rules or model-based reviewer. */
export class CodexApprovals {
  constructor(private readonly prompts: Prompts, private readonly context: (threadId: string) => SessionContext | undefined) {}
  async handle(request: ServerRequest): Promise<unknown> {
    const { method, params, signal } = request;
    const context = this.context(params.threadId);
    if (!context) throw new Error("请求没有绑定到本人的会话");
    if (["item/commandExecution/requestApproval", "item/fileChange/requestApproval"].includes(method)) {
      const command = method.includes("commandExecution");
      const fields = [
        params.command && { label: "命令", value: approvalCommandPreview(params.command) },
        params.cwd && { label: "工作目录", value: String(params.cwd) },
        params.grantRoot && { label: "写入范围", value: String(params.grantRoot) },
        params.networkApprovalContext && { label: "网络", value: "请求访问网络；详细参数已隐藏" },
      ].filter((field): field is { label: string; value: string; code?: boolean } => !!field);
      const allow = await this.prompts.ask(context.chatId, {
        title: command ? "执行命令需确认" : "修改文件需确认",
        detail: command ? "Codex 请求执行一条需要额外权限的命令。命令参数不在飞书展示，避免泄露凭证；请结合当前任务决定。" : "Codex 请求修改沙箱保护的文件；请核对工作目录和写入范围。",
        fields, choices: [{ label: "允许一次", value: "accept" }, { label: "拒绝", value: "decline" }],
      }, signal, context.sessionKey);
      return { decision: allow === "accept" ? "accept" : "decline" };
    }
    if (method === "item/permissions/requestApproval") {
      const answer = await this.prompts.ask(context.chatId, { title: "扩大本轮权限？", detail: params.reason || "这次操作需要扩大当前权限范围。", fields: [{ label: "请求范围", value: JSON.stringify(redactSecrets(params.permissions), null, 2), code: true }], choices: [{ label: "允许本轮", value: "allow" }, { label: "拒绝", value: "deny" }] }, signal, context.sessionKey);
      return { permissions: answer === "allow" ? params.permissions : {}, scope: "turn" };
    }
    if (method === "item/tool/requestUserInput") {
      const answers: Record<string, { answers: string[] }> = {};
      for (const question of params.questions || []) {
        if (question.isSecret) throw new Error("敏感信息请在本机登录或配置，不通过聊天传递");
        const options = question.options || [];
        const answer = await this.prompts.ask(context.chatId, {
          title: question.header || "Codex 需要补充信息", detail: `${question.question}\n${options.map((item: ParamsOption) => `${item.label}：${item.description || ""}`).join("\n")}`,
          choices: options.map((item: ParamsOption, index: number) => ({ label: item.label, value: `choice:${index}` })), allowText: question.isOther || !options.length,
        }, signal, context.sessionKey);
        if (answer === undefined) throw new Error("问题未得到回答");
        const selected = /^choice:(\d+)$/.exec(answer);
        answers[question.id] = { answers: [selected ? options[Number(selected[1])]?.label ?? answer : answer] };
      }
      return { answers };
    }
    if (method === "mcpServer/elicitation/request") return this.elicitation(context, params, signal);
    throw new Error(`不支持的 Codex 请求：${method}`);
  }
  private async elicitation(context: SessionContext, params: Record<string, any>, signal: AbortSignal) {
    if (params.mode === "url") {
      const result = await this.prompts.ask(context.chatId, { title: "MCP 请求你完成授权", detail: `${params.message}\n${params.url}`, choices: [{ label: "我已完成", value: "accept" }, { label: "取消", value: "cancel" }] }, signal, context.sessionKey);
      return { action: result === "accept" ? "accept" : "cancel", content: null, _meta: null };
    }
    const schema = params.requestedSchema;
    const content: Record<string, unknown> = {};
    for (const [name, field] of Object.entries(schema?.properties || {}) as [string, Record<string, any>][]) {
      const choices = field.enum?.map((value: unknown, index: number) => ({ label: String(value), value: `choice:${index}` })) ?? (field.type === "boolean" ? [{ label: "是", value: "true" }, { label: "否", value: "false" }] : undefined);
      if (!choices && field.type !== "string") return { action: "decline", content: null, _meta: null };
      const answer = await this.prompts.ask(context.chatId, { title: "MCP 需要补充信息", detail: `${params.message}\n${field.title || name}：${field.description || ""}`, choices, allowText: !choices }, signal, context.sessionKey);
      if (answer === undefined) return { action: "cancel", content: null, _meta: null };
      content[name] = field.enum ? field.enum[Number(answer.slice("choice:".length))] : field.type === "boolean" ? answer === "true" : answer;
    }
    return { action: "accept", content, _meta: null };
  }
}
interface ParamsOption { label: string; description?: string; }
