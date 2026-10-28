import type { Config } from "../config.ts";
import type { AgentResult, ImageDelivery, SessionContext, UsageReport } from "../app/ports.ts";
import { Store } from "../storage.ts";
import { CodexRpc, CodexRpcTimeoutError, type Params } from "./rpc.ts";
import { resolve } from "node:path";
import { errorMessage, log } from "../shared/log.ts";
import { projectConfig } from "./project-config.ts";
import { turnUsage, usageSnapshot } from "./usage.ts";
import type { SessionFiles } from "../services/session-files.ts";

export interface AgentInput { prompt: string; images?: { path: string }[]; }
interface ActiveTurn {
  turnId?: string; messages: Map<string, string>; phases: Map<string, string>; final: string; startedAt: number; model?: string;
  imageDeliveries: Promise<ImageDelivery>[]; previousUsage: UsageReport; usageUpdated: boolean;
  resolve(result: AgentResult): void; reject(error: Error): void; onText?: (text: string) => void; onProgress?: (status: string) => void;
  onCommentary?: (text: string) => void;
  stopping: boolean; terminal: boolean; interruptSentFor?: string;
}
export interface CommandResult { command: string; output: string; exitCode: number | null; }

/** Session persistence belongs here; Codex owns conversation history and the agent loop. */
export class CodexRuntime {
  private readonly contexts = new Map<string, SessionContext>();
  private readonly loaded = new Map<string, string>();
  private readonly models = new Map<string, string>();
  private readonly efforts = new Map<string, string>();
  private defaultModel?: string;
  private defaultEffort?: string;
  private connected = false;
  private connecting?: Promise<void>;
  private closing = false;
  private readonly loading = new Map<string, Promise<string>>();
  private readonly active = new Map<string, ActiveTurn>();
  constructor(readonly rpc: CodexRpc, private readonly store: Store, private readonly config: Config, private readonly files: SessionFiles, private readonly mcpUrl: (context: SessionContext) => string, private readonly onCommandResult?: (context: SessionContext, result: CommandResult) => void, private readonly onGeneratedImage?: (context: SessionContext, path: string) => Promise<string>) {
    rpc.on("notification", (method: string, params: Params) => this.notification(method, params));
    rpc.on("disconnected", (error: Error) => {
      this.connected = false;
      this.loaded.clear(); this.contexts.clear(); this.models.clear(); this.efforts.clear();
      for (const turn of this.active.values()) turn.reject(error);
      this.active.clear();
      if (!this.closing) log.warn(`Codex 连接中断，下次任务将重新连接：${errorMessage(error)}`);
    });
  }
  context(threadId: string): SessionContext | undefined { return this.contexts.get(threadId); }
  async start(): Promise<void> {
    await this.ensureConnected();
  }
  private ensureConnected(): Promise<void> {
    if (this.closing) return Promise.reject(new Error("Codex 正在退出"));
    if (this.connected) return Promise.resolve();
    this.connecting ??= this.connect().finally(() => { this.connecting = undefined; });
    return this.connecting;
  }
  private async connect(): Promise<void> {
    await this.rpc.close();
    await this.rpc.start();
    await this.rpc.request("skills/extraRoots/set", { extraRoots: [resolve(this.config.root, ".agents/skills")] });
    const policy = await projectConfig(this.rpc, this.config);
    this.defaultModel = typeof policy.model === "string" && policy.model.trim() ? policy.model.trim() : this.config.model;
    this.defaultEffort = typeof policy.model_reasoning_effort === "string" && policy.model_reasoning_effort.trim() ? policy.model_reasoning_effort.trim() : undefined;
    if (policy.approval_policy !== "on-request" || policy.approvals_reviewer !== "user" || policy.sandbox_mode !== "workspace-write") {
      throw new Error("Codex 实际权限配置与 MVP 约定不一致，需要 on-request / user / workspace-write；请检查项目或受管配置");
    }
    if (this.config.api && policy.model_provider !== this.config.api.providerId) throw new Error("Codex 实际模型服务与 API 配置不一致，启动已终止");
    log.info("Codex 已加载工程配置；on-request / user / workspace-write");
    if (!this.config.api || this.config.api.kind === "openai") {
      const result = await this.rpc.request("account/read", { refreshToken: false });
      if (this.config.api && result.account?.type !== "apiKey") throw new Error("Codex 未启用配置的 API Key 模式，启动已终止");
      if (result.requiresOpenaiAuth && !result.account) throw new Error("Codex 未登录，请在 .env 配置 API 服务，或执行 npm run codex:login");
    }
    log.info(this.config.api ? `Codex 使用 ${this.config.api.kind} Responses API；按所选服务 API 用量计费` : "Codex 使用原生登录凭证");
    log.info(`Codex 当前模型：${this.config.model ?? this.defaultModel ?? "模型默认"}；推理档位：${this.config.effort ?? this.defaultEffort ?? "模型默认"}`);
    this.connected = true;
  }
  private async thread(context: SessionContext): Promise<string> {
    await this.ensureConnected();
    this.files.id(context.sessionKey);
    const loaded = this.loaded.get(context.sessionKey);
    if (loaded) return loaded;
    const loading = this.loading.get(context.sessionKey);
    if (loading) return loading;
    const operation = (async () => {
      const saved = this.store.get<{ threadId: string }>("sessions", context.sessionKey);
      const params = {
        cwd: this.config.root, model: this.config.model, modelProvider: this.config.api?.providerId,
        config: { "mcp_servers.personal": { url: this.mcpUrl(context), enabled: true, required: true, startup_timeout_sec: 30, tool_timeout_sec: this.config.approvalTimeoutMs / 1000 + 120 } },
      };
      // Resume errors remain visible; never silently replace a user's conversation.
      const result = await this.rpc.request(saved ? "thread/resume" : "thread/start", { ...params, ...(saved ? { threadId: saved.threadId } : {}) }, 120_000);
      const threadId: string = result.thread.id;
      const model = typeof result.model === "string" && result.model.trim() ? result.model.trim() : this.config.model;
      const effort = typeof result.reasoningEffort === "string" && result.reasoningEffort.trim() ? result.reasoningEffort.trim() : undefined;
      const status = await this.rpc.request("mcpServerStatus/list", { threadId, detail: "toolsAndAuthOnly", limit: 100 });
      const personal = status.data?.find((server: { name: string }) => server.name === "personal");
      if (personal?.runtimeStatus !== "connected" || !Object.keys(personal.tools || {}).length) {
        throw new Error(`个人工具未接入 Codex（状态：${personal?.runtimeStatus || "未注册"}；${personal?.toolsError || "未发现工具"}）`);
      }
      log.info(`Codex 个人工具已连接：${Object.keys(personal.tools).join("、")}`);
      this.store.set("sessions", context.sessionKey, { threadId, updatedAt: Date.now() });
      if (model) this.models.set(threadId, model);
      if (effort) this.efforts.set(threadId, effort);
      this.loaded.set(context.sessionKey, threadId); this.contexts.set(threadId, context);
      return threadId;
    })().finally(() => {
      if (this.loading.get(context.sessionKey) === operation) this.loading.delete(context.sessionKey);
    });
    this.loading.set(context.sessionKey, operation);
    return operation;
  }
  /** Reconnect the latest chat after startup, before its first incoming message. No model turn is started. */
  async warmRecentChat(): Promise<void> {
    const latest = this.store.entries<{ threadId: string; updatedAt: number }>("sessions")
      .filter(item => item.key.startsWith("chat:") && item.value.threadId)
      .sort((a, b) => (b.value.updatedAt || 0) - (a.value.updatedAt || 0))[0];
    if (!latest) return;
    const startedAt = Date.now();
    await this.thread({ sessionKey: latest.key, chatId: latest.key.slice(5) });
    log.info(`Codex 最近聊天会话已预热：${((Date.now() - startedAt) / 1000).toFixed(1)}s`);
  }
  async run(context: SessionContext, input: AgentInput, signal?: AbortSignal, onText?: (text: string) => void, onProgress?: (status: string) => void, onCommentary?: (text: string) => void): Promise<AgentResult> {
    const requestedAt = Date.now();
    signal?.throwIfAborted();
    const threadId = await this.thread(context);
    const preparedAt = Date.now();
    signal?.throwIfAborted();
    if (this.active.has(threadId)) throw new Error(this.active.get(threadId)?.stopping ? "该会话正在停止，等待 Codex 确认结束后再发送消息" : "该会话正在执行，请等待或 /stop");
    let resolve!: ActiveTurn["resolve"], reject!: ActiveTurn["reject"];
    const completion = new Promise<AgentResult>((yes, no) => { resolve = yes; reject = no; });
    // Install before turn/start: notifications can arrive before its RPC response.
    const turn: ActiveTurn = { messages: new Map(), phases: new Map(), final: "", startedAt: Date.now(), model: this.models.get(threadId), imageDeliveries: [], previousUsage: usageSnapshot(this.store.get("usage", threadId)), usageUpdated: false, stopping: false, terminal: false, resolve, reject, onText, onProgress, onCommentary };
    this.active.set(threadId, turn);
    const interrupt = () => {
      void this.interrupt(threadId, turn).catch(error => log.warn(`Codex 中断请求失败：${errorMessage(error)}`));
    };
    signal?.addEventListener("abort", interrupt, { once: true });
    const timer = setTimeout(() => { interrupt(); reject(new Error("任务超过本轮时间上限，已请求中断")); }, this.config.turnTimeoutMs);
    try {
      // Handle turn/start and completion concurrently to prevent an unhandled early rejection.
      const start = this.rpc.request("turn/start", {
        threadId, input: [{ type: "text", text: input.prompt, text_elements: [] }, ...(input.images || []).map(image => ({ type: "localImage", path: image.path }))],
        ...(this.config.effort ? { effort: this.config.effort } : {}),
      }).then(result => {
        turn.turnId = result.turn.id;
        if (turn.stopping || signal?.aborted) interrupt();
      }).catch(error => {
        if (!(error instanceof CodexRpcTimeoutError) && !turn.turnId) {
          turn.terminal = true;
          if (this.active.get(threadId) === turn) this.active.delete(threadId);
        } else if (!turn.terminal) interrupt();
        throw error;
      });
      const [, result] = await Promise.all([start, completion]);
      result.imageDeliveries = await Promise.all(turn.imageDeliveries);
      const used = result.usage?.turn ?? result.usage?.last;
      log.info(`Codex 本轮耗时：会话准备 ${((preparedAt - requestedAt) / 1000).toFixed(1)}s，模型执行 ${((Date.now() - preparedAt) / 1000).toFixed(1)}s；输入 ${used?.inputTokens ?? "未知"} tokens，缓存 ${used?.cachedInputTokens ?? "未知"} tokens，推理 ${used?.reasoningOutputTokens ?? "未知"} tokens`);
      return result;
    } finally {
      clearTimeout(timer); signal?.removeEventListener("abort", interrupt);
      if (turn.terminal && this.active.get(threadId) === turn) this.active.delete(threadId);
      // A timeout is not a terminal Codex event. Keep the guard, but detach this reply's UI.
      turn.onText = undefined; turn.onProgress = undefined; turn.onCommentary = undefined;
    }
  }
  async steer(context: SessionContext, input: AgentInput): Promise<boolean> {
    const threadId = this.loaded.get(context.sessionKey), turn = threadId ? this.active.get(threadId) : undefined;
    if (!threadId || !turn?.turnId || turn.stopping) return false;
    await this.rpc.request("turn/steer", { threadId, expectedTurnId: turn.turnId, input: [{ type: "text", text: input.prompt, text_elements: [] }, ...(input.images || []).map(image => ({ type: "localImage", path: image.path }))] });
    return true;
  }
  async stop(sessionKey: string): Promise<void> {
    const id = this.loaded.get(sessionKey), turn = id ? this.active.get(id) : undefined;
    if (id && turn) await this.interrupt(id, turn);
  }
  private async interrupt(threadId: string, turn: ActiveTurn): Promise<void> {
    if (turn.terminal) return;
    turn.stopping = true;
    const turnId = turn.turnId;
    if (!turnId || turn.interruptSentFor === turnId) return;
    turn.interruptSentFor = turnId;
    try { await this.rpc.request("turn/interrupt", { threadId, turnId }); }
    catch (error) { turn.interruptSentFor = undefined; throw error; }
  }
  async reset(sessionKey: string): Promise<void> {
    const id = this.loaded.get(sessionKey);
    if (id && this.active.has(id)) throw new Error("请先 /stop，等待当前任务结束后再 /new");
    if (this.loading.has(sessionKey)) throw new Error("会话正在连接，请稍后再 /new");
    if (id) { this.contexts.delete(id); this.models.delete(id); this.efforts.delete(id); }
    this.loaded.delete(sessionKey); this.store.remove("sessions", sessionKey); this.files.reset(sessionKey);
  }
  async compact(context: SessionContext): Promise<void> {
    const id = await this.thread(context);
    if (this.active.has(id)) throw new Error("执行中不能压缩会话");
    await this.rpc.request("thread/compact/start", { threadId: id });
  }
  status(sessionKey: string): unknown {
    const threadId = this.loaded.get(sessionKey) || this.store.get<{ threadId: string }>("sessions", sessionKey)?.threadId;
    const turn = threadId ? this.active.get(threadId) : undefined;
    const info = this.modelInfo(sessionKey);
    return { threadId, fileSessionId: this.files.id(sessionKey), ...info, running: !!turn, stopping: turn?.stopping ?? false, turnId: turn?.turnId, elapsedSeconds: turn ? Math.floor((Date.now() - turn.startedAt) / 1000) : 0 };
  }
  modelInfo(sessionKey: string): { model?: string; effort?: string; provider: string } {
    const threadId = this.loaded.get(sessionKey);
    return {
      model: (threadId ? this.active.get(threadId)?.model ?? this.models.get(threadId) : undefined) ?? this.defaultModel,
      effort: this.config.effort ?? (threadId ? this.efforts.get(threadId) : undefined) ?? this.defaultEffort,
      provider: this.config.api?.kind ?? "Codex 原生登录",
    };
  }
  awaitingApproval(threadId: string): void { this.active.get(threadId)?.onProgress?.("等待授权"); }
  private notification(method: string, params: Params): void {
    if (method === "thread/tokenUsage/updated" && typeof params.threadId === "string") {
      this.store.set("usage", params.threadId, params.tokenUsage);
      const active = this.active.get(params.threadId);
      if (active) active.usageUpdated = true;
      return;
    }
    const turn = this.active.get(params.threadId);
    if (!turn) return;
    if (method === "turn/started") {
      if (turn.turnId && turn.turnId !== params.turn.id) return;
      turn.turnId = params.turn.id;
      if (turn.stopping) void this.interrupt(params.threadId, turn).catch(error => log.warn(`Codex 中断请求失败：${errorMessage(error)}`));
      turn.onProgress?.(turn.stopping ? "正在停止" : "思考中");
    }
    if (params.turnId && turn.turnId && params.turnId !== turn.turnId) return;
    if (method === "model/rerouted" && typeof params.toModel === "string" && params.toModel.trim()) turn.model = params.toModel.trim();
    if (method === "item/started") {
      const status: Record<string, string> = { commandExecution: "正在执行命令", fileChange: "正在修改文件", mcpToolCall: "正在调用工具", imageGeneration: "正在生成图片", webSearch: "正在搜索", contextCompaction: "正在整理长会话，完成后回答" };
      if (params.item?.type === "agentMessage" && params.item.id) turn.phases.set(params.item.id, params.item.phase || "");
      turn.onProgress?.(status[params.item?.type] || "思考中");
    }
    if (method === "item/agentMessage/delta") {
      const text = (turn.messages.get(params.itemId) || "") + params.delta;
      turn.messages.set(params.itemId, text);
      if (turn.phases.get(params.itemId) === "commentary") turn.onCommentary?.(text);
      else { turn.onText?.(text); turn.onProgress?.("正在回答"); }
    }
    if (method === "item/completed" && params.item?.type !== "agentMessage") turn.onProgress?.("思考中");
    if (method === "item/completed" && params.item?.type === "commandExecution") {
      const context = this.contexts.get(params.threadId);
      if (context) this.onCommandResult?.(context, {
        command: String(params.item.command || ""), output: String(params.item.aggregatedOutput || ""), exitCode: params.item.exitCode ?? null,
      });
    }
    if (method === "item/completed" && params.item?.type === "imageGeneration" && params.item.status === "completed" && typeof params.item.savedPath === "string") {
      const path = params.item.savedPath;
      const context = this.contexts.get(params.threadId);
      if (context && this.onGeneratedImage) {
        turn.onProgress?.("正在发送图片");
        const delivery = Promise.resolve().then(() => this.onGeneratedImage!(context, path))
          .then(messageId => {
            turn.onProgress?.("图片已发送，正在完成回复");
            log.info(`生成图片已发送到当前会话：${messageId}`);
            return { path, messageId };
          }, error => {
            const reason = errorMessage(error);
            turn.onProgress?.("图片发送失败，正在完成回复");
            log.warn(`生成图片交付失败：${reason}`);
            return { path, error: reason };
          });
        turn.imageDeliveries.push(delivery);
      }
    }
    if (method === "item/completed" && params.item?.type === "agentMessage") {
      if (params.item.id) turn.phases.set(params.item.id, params.item.phase || "");
      const previous = params.item.id ? turn.messages.get(params.item.id) : undefined;
      turn.messages.set(params.item.id, params.item.text);
      if (params.item.phase === "commentary") turn.onCommentary?.(params.item.text);
      if (params.item.phase === "final_answer" || !params.item.phase) {
        turn.final = params.item.text;
        // Short answers can arrive only as a completed item, without any delta.
        if (params.item.text !== previous) { turn.onText?.(params.item.text); turn.onProgress?.("正在回答"); }
      }
    }
    if (method === "turn/completed") {
      const final = params.turn;
      if (turn.turnId && final.id !== turn.turnId) return;
      turn.terminal = true;
      if (this.active.get(params.threadId) === turn) this.active.delete(params.threadId);
      if (final.status === "failed") turn.reject(new Error(final.error?.message || "Codex 执行失败"));
      else turn.resolve({ text: turn.final || [...turn.messages.values()].at(-1) || "", status: final.status, usage: turnUsage(turn.previousUsage, this.store.get("usage", params.threadId), turn.usageUpdated), model: turn.model });
    }
  }
  async close(): Promise<void> {
    this.closing = true;
    await Promise.allSettled([...this.active.keys()].map(threadId => { const turn = this.active.get(threadId)!; return turn.turnId ? this.rpc.request("turn/interrupt", { threadId, turnId: turn.turnId }, 5000) : Promise.resolve(); }));
    await this.rpc.close();
  }
}
