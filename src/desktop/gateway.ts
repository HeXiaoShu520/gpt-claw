import { randomBytes, randomUUID, timingSafeEqual } from "node:crypto";
import { createServer, type Server } from "node:http";
import { mkdir, readFile, stat, unlink, writeFile } from "node:fs/promises";
import { basename, extname, join, resolve } from "node:path";
import { WebSocket, WebSocketServer } from "ws";
import type { Channel, Prompt, PromptResult, ReplyTarget } from "../app/ports.ts";
import type { DesktopMessage } from "./types.ts";
import { errorMessage, log } from "../shared/log.ts";
import type { SessionFiles } from "../services/session-files.ts";
import type { ScreenShare, ScreenBounds, ScreenImage, ScreenGuide, ScreenGuideResult } from "../services/screen-share.ts";

type Envelope = { version: "1.0"; type: string; payload: Record<string, unknown>; request_id?: string };
type Peer = { socket: WebSocket; sessions: Set<string>; capabilities: Set<string> };
const sessionPattern = /^[A-Za-z0-9_-]{1,100}$/;
const imageTypes: Record<string, string> = { "image/png": ".png", "image/jpeg": ".jpg", "image/webp": ".webp", "image/gif": ".gif" };

function value(payload: Record<string, unknown>, key: string): string {
  const field = payload[key];
  return typeof field === "string" ? field : "";
}

/** Authenticated loopback transport for the desktop UI. No model or permission logic lives here. */
export class DesktopGateway implements Channel {
  onInput?: (message: DesktopMessage) => Promise<void>;
  onReset?: (chatId: string) => Promise<void>;
  onAnswer?: (token: string, value: string, chatId: string, messageId?: string) => boolean;
  onDeliveryAck?: (chatId: string, deliveryId: string, surfaceId: string) => void;
  private server?: Server;
  private webSocketServer?: WebSocketServer;
  private readonly peers = new Set<Peer>();
  private readonly messages = new Map<string, string>();
  private readonly activeSurfaces = new Map<string, Map<string, Record<string, unknown>>>();
  private readonly pendingDeliveries = new Map<string, { chatId: string; surfaceId: string; finish: (error?: Error) => void }>();
  private readonly token = randomBytes(32).toString("hex");
  private readonly captures = new Map<string, { peer: Peer; chatId: string; shareId: string; finish: (image?: ScreenImage, error?: Error) => void }>();
  private readonly guides = new Map<string, { peer: Peer; chatId: string; shareId: string; finish: (result?: ScreenGuideResult, error?: Error) => void }>();
  private readonly discovery: string;
  constructor(private readonly dataDir: string, private readonly files: SessionFiles, private readonly screenShare: ScreenShare) {
    this.discovery = join(dataDir, "desktop-connection.json");
    screenShare.onControl = (chatId, shareId, active) => this.publish(chatId, "screen.control.state", {
      session_id: chatId.slice(8), share_id: shareId, active,
    }, false);
    screenShare.onRevoked = chatId => this.publish(chatId, "screen.share.state", {
      session_id: chatId.slice(8), enabled: false, share_id: "",
    }, false);
  }
  async start(): Promise<void> {
    const webSocketServer = new WebSocketServer({ noServer: true, maxPayload: 40 * 1024 * 1024, perMessageDeflate: false });
    const server = createServer((_req, res) => res.writeHead(404).end());
    server.on("upgrade", (request, socket, head) => {
      const supplied = request.headers.authorization?.replace(/^Bearer /i, "") || "";
      const expected = Buffer.from(this.token);
      const actual = Buffer.from(supplied);
      const address = request.socket.remoteAddress;
      if (request.url !== "/ws/minipet" || request.headers.origin ||
          !["127.0.0.1", "::1", "::ffff:127.0.0.1"].includes(address || "") ||
          actual.length !== expected.length || !timingSafeEqual(actual, expected)) {
        socket.write("HTTP/1.1 403 Forbidden\r\nConnection: close\r\n\r\n"); socket.destroy(); return;
      }
      webSocketServer.handleUpgrade(request, socket, head, ws => this.accept(ws));
    });
    await new Promise<void>((resolve, reject) => { server.once("error", reject); server.listen(0, "127.0.0.1", resolve); });
    const address = server.address();
    if (!address || typeof address === "string") throw new Error("桌面通道未获得本机端口");
    this.server = server; this.webSocketServer = webSocketServer;
    await mkdir(this.dataDir, { recursive: true });
    await writeFile(this.discovery, JSON.stringify({ protocol: "minipet.v1", url: `ws://127.0.0.1:${address.port}/ws/minipet`, token: this.token }), { mode: 0o600 });
    log.info("桌面通道已就绪，等待桌宠界面连接");
  }
  private accept(socket: WebSocket): void {
    const peer: Peer = { socket, sessions: new Set(), capabilities: new Set() };
    this.peers.add(peer);
    socket.on("close", () => {
      this.screenShare.disable(peer);
      if (peer.sessions.size) log.info("桌宠已断开连接，共享屏幕授权已撤销");
      this.peers.delete(peer);
      for (const capture of this.captures.values()) if (capture.peer === peer) capture.finish(undefined, new Error("桌宠已断开连接"));
    });
    socket.on("message", data => { const raw = data.toString(); void this.handle(peer, raw).catch(error => {
      log.warn(`桌面消息处理失败：${errorMessage(error)}`);
      let envelope: Partial<Envelope> = {};
      try { envelope = JSON.parse(raw) as Partial<Envelope>; } catch { /* malformed input */ }
      const failure = {
        message: errorMessage(error),
        failed_event: envelope.type,
        turn_id: value(envelope.payload || {}, "turn_id"),
        session_id: value(envelope.payload || {}, "session_id"),
      };
      const chatId = `desktop:${failure.session_id || "main"}`;
      if (envelope.type === "user.input" && peer.socket.readyState !== WebSocket.OPEN && peer.sessions.has(chatId))
        this.publish(chatId, "error", failure, false, envelope.request_id);
      else this.emit(peer, "error", failure, envelope.request_id);
    }); });
  }
  private emit(peer: Peer, type: string, payload: Record<string, unknown>, requestId?: string): void {
    if (peer.socket.readyState === WebSocket.OPEN)
      peer.socket.send(JSON.stringify({ version: "1.0", type, payload, ...(requestId ? { request_id: requestId } : {}) }));
  }
  private publish(chatId: string, type: string, payload: Record<string, unknown>, requirePeer = true, requestId?: string): void {
    const targets = [...this.peers].filter(peer => peer.sessions.has(chatId) && peer.socket.readyState === WebSocket.OPEN);
    for (const peer of targets) this.emit(peer, type, payload, requestId);
    if (!targets.length && requirePeer) throw new Error("桌宠未连接到当前桌面会话");
  }
  private capture(peer: Peer, chatId: string, shareId: string, bounds: ScreenBounds, signal: AbortSignal): Promise<ScreenImage> {
    signal.throwIfAborted();
    if (peer.socket.readyState !== WebSocket.OPEN || this.screenShare.messageLease(chatId, peer) !== shareId)
      throw new Error("共享屏幕已关闭或连接断开");
    return new Promise((resolve, reject) => {
      const id = randomUUID();
      const finish = (image?: ScreenImage, error?: Error) => {
        if (!this.captures.delete(id)) return;
        clearTimeout(timer); signal.removeEventListener("abort", abort);
        if (image) resolve(image); else reject(error || new Error("截图失败"));
      };
      const abort = () => finish(undefined, new Error("截图已取消"));
      const timer = setTimeout(() => finish(undefined, new Error("桌宠截图超时")), 10_000);
      this.captures.set(id, { peer, chatId, shareId, finish });
      signal.addEventListener("abort", abort, { once: true });
      this.emit(peer, "screen.capture.request", { session_id: chatId.slice(8), share_id: shareId, bounds }, id);
      if (signal.aborted) abort();
    });
  }
  private clearGuides(peer: Peer, chatId: string, shareId: string): void {
    this.emit(peer, "pet.guide.request", { session_id: chatId.slice(8), share_id: shareId, target: null });
    for (const guide of this.guides.values())
      if (guide.peer === peer && guide.chatId === chatId) guide.finish(undefined, new Error("宠物引导已取消"));
  }
  private guide(peer: Peer, chatId: string, shareId: string, target: ScreenGuide | null, signal: AbortSignal): Promise<ScreenGuideResult> {
    signal.throwIfAborted();
    if (peer.socket.readyState !== WebSocket.OPEN || this.screenShare.messageLease(chatId, peer) !== shareId)
      throw new Error("共享屏幕已关闭或连接断开");
    return new Promise((resolve, reject) => {
      const id = randomUUID();
      const finish = (result?: ScreenGuideResult, error?: Error) => {
        if (!this.guides.delete(id)) return;
        clearTimeout(timer); signal.removeEventListener("abort", abort);
        if (result) resolve(result); else {
          this.emit(peer, "pet.guide.request", { session_id: chatId.slice(8), share_id: shareId, target: null, guidance_id: id });
          reject(error || new Error("宠物引导失败"));
        }
      };
      const abort = () => finish(undefined, new Error("宠物引导已取消"));
      const timer = setTimeout(() => finish(undefined, new Error("桌宠引导到位确认超时")), 8_000);
      this.guides.set(id, { peer, chatId, shareId, finish });
      signal.addEventListener("abort", abort, { once: true });
      this.emit(peer, "pet.guide.request", { session_id: chatId.slice(8), share_id: shareId, target }, id);
      if (signal.aborted) abort();
    });
  }
  private async handle(peer: Peer, raw: string): Promise<void> {
    let envelope: Envelope;
    try { envelope = JSON.parse(raw) as Envelope; } catch { throw new Error("桌面协议消息不是 JSON"); }
    if (envelope.version !== "1.0" || !envelope.payload || typeof envelope.payload !== "object" || Array.isArray(envelope.payload)) throw new Error("桌面协议版本或消息结构无效");
    const payload = envelope.payload;
    if (envelope.type === "session.hello" || envelope.type === "session.probe") {
      let chatId = "";
      if (envelope.type === "session.hello") {
        const sessionId = value(payload, "session_id");
        if (!sessionPattern.test(sessionId)) throw new Error("桌面会话 ID 无效");
        chatId = `desktop:${sessionId}`;
        if (!peer.sessions.size) log.info("桌宠已连接到 gpt-claw，共享屏幕默认关闭");
        peer.sessions.add(chatId);
        peer.capabilities = new Set(Array.isArray(payload.capabilities) ? payload.capabilities.filter((item): item is string => typeof item === "string") : []);
      }
      this.emit(peer, envelope.type === "session.hello" ? "session.ready" : "session.probe.result", {
        protocol: "minipet.v1", server: { name: "gpt-claw", version: "0.1.0" },
        capabilities: ["user.input", "user.cancel", "user.approval", "session.reset", "session.reset.result", "surface.show", "surface.update", "surface.close", "surface.ack", "input.accepted", "screen.share.set", "screen.control.state", "screen.capture.request", "pet.guide.request"],
        ...(chatId ? { active_turn_ids: [...(this.activeSurfaces.get(chatId)?.values() || [])]
          .filter(surface => surface.status !== "done" && surface.status !== "failed").map(surface => surface.turn_id) } : {}),
      }, envelope.request_id);
      if (chatId) {
        for (const surface of this.activeSurfaces.get(chatId)?.values() || []) {
          const inputRequestId = value(surface, "input_request_id");
          if (inputRequestId) this.emit(peer, "input.accepted", {
            session_id: surface.session_id, turn_id: surface.turn_id,
          }, inputRequestId);
          if (surface.delivery_id && !peer.capabilities.has("surface.ack")) continue;
          this.emit(peer, "surface.show", surface);
        }
      }
      return;
    }
    if (envelope.type === "surface.ack") {
      const chatId = `desktop:${value(payload, "session_id")}`;
      const surfaceId = value(payload, "surface_id"), deliveryId = value(payload, "delivery_id");
      if (!peer.sessions.has(chatId) || !peer.capabilities.has("surface.ack") || !deliveryId) return;
      const surface = this.activeSurfaces.get(chatId)?.get(surfaceId);
      if (surface?.delivery_id !== deliveryId || !["done", "failed"].includes(String(surface.status))) return;
      // Persist even a late receipt before dropping the replayable surface or resolving an active send.
      this.onDeliveryAck?.(chatId, deliveryId, surfaceId);
      this.forgetSurface(chatId, surfaceId);
      const pending = this.pendingDeliveries.get(deliveryId);
      if (pending?.chatId === chatId && pending.surfaceId === surfaceId) pending.finish();
      return;
    }
    if (envelope.type === "screen.share.set") {
      const sessionId = value(payload, "session_id"), chatId = `desktop:${sessionId}`;
      if (!sessionPattern.test(sessionId) || !peer.sessions.has(chatId)) throw new Error("桌面会话未就绪");
      if (typeof payload.enabled !== "boolean") throw new Error("共享屏幕开关无效");
      if (payload.enabled) {
        let shareId = "";
        const previous = this.screenShare.messageLease(chatId, peer);
        const lease = this.screenShare.enable(chatId, peer, Number(payload.pid),
          (bounds, signal) => this.capture(peer, chatId, shareId, bounds, signal),
          peer.capabilities.has("pet.guide.request") ? (target, signal) => this.guide(peer, chatId, shareId, target, signal) : undefined);
        shareId = lease.id;
        if (!previous) lease.signal.addEventListener("abort", () => this.clearGuides(peer, chatId, shareId), { once: true });
      } else this.screenShare.disable(peer, chatId);
      this.emit(peer, "screen.share.state", { session_id: sessionId, enabled: !!this.screenShare.messageLease(chatId, peer), share_id: this.screenShare.messageLease(chatId, peer) || "" }, envelope.request_id);
      return;
    }
    if (envelope.type === "pet.guide.result") {
      const guide = this.guides.get(envelope.request_id || "");
      if (!guide || guide.peer !== peer || guide.chatId !== `desktop:${value(payload, "session_id")}` || guide.shareId !== value(payload, "share_id")) return;
      const status = value(payload, "status");
      if (status === "arrived" || status === "indicator_only" || status === "cleared") guide.finish({ status });
      else guide.finish(undefined, new Error(value(payload, "error") || "桌宠引导失败"));
      return;
    }
    if (envelope.type === "screen.capture.result") {
      const capture = this.captures.get(envelope.request_id || "");
      if (!capture || capture.peer !== peer || capture.chatId !== `desktop:${value(payload, "session_id")}` || capture.shareId !== value(payload, "share_id")) return;
      const dataUrl = value(payload, "data_url");
      const match = /^data:image\/jpeg;base64,([A-Za-z0-9+/]+={0,2})$/.exec(dataUrl);
      if (!match || match[1]!.length > 12 * 1024 * 1024) capture.finish(undefined, new Error(value(payload, "error") || "桌宠截图数据无效"));
      else capture.finish({ data: match[1]!, mimeType: "image/jpeg" });
      return;
    }
    if (envelope.type === "user.input") {
      const sessionId = value(payload, "session_id") || "main";
      if (!sessionPattern.test(sessionId)) throw new Error("桌面会话 ID 无效");
      const chatId = `desktop:${sessionId}`;
      const screenShareId = this.screenShare.messageLease(chatId, peer);
      const turnId = value(payload, "turn_id") || randomUUID();
      if (!sessionPattern.test(turnId)) throw new Error("桌面轮次 ID 无效");
      const text = value(payload, "text").slice(0, 50_000);
      const { images, files } = await this.attachments(payload.attachments, sessionId);
      if (!text.trim() && !images.length && !files.length) throw new Error("桌面消息没有文字或附件");
      peer.sessions.add(chatId);
      const messageId = `desktop:${turnId}`;
      if (!this.onInput) throw new Error("桌面输入处理器尚未就绪");
      this.messages.set(messageId, chatId);
      this.surface(chatId, messageId, "", "streaming", "surface.show", {
        progress: "等待处理", content_kind: "progress", tts_eligible: false,
      }, true, false);
      try {
        await this.onInput({ source: "desktop", message_id: messageId, chat_id: chatId, text, images, files, screenShareId });
      } catch (error) {
        this.messages.delete(messageId);
        this.forgetSurface(chatId, messageId);
        throw error;
      }
      if (this.activeSurfaces.get(chatId)?.has(messageId))
        this.rememberSurface(chatId, messageId, { input_request_id: envelope.request_id });
      this.publish(chatId, "input.accepted", { session_id: sessionId, turn_id: turnId }, false, envelope.request_id);
      return;
    }
    if (envelope.type === "session.reset") {
      const sessionId = value(payload, "session_id");
      if (!sessionPattern.test(sessionId)) throw new Error("桌面会话 ID 无效");
      const chatId = `desktop:${sessionId}`;
      if (!peer.sessions.has(chatId) || !this.onReset) throw new Error("桌面会话未就绪");
      try {
        await this.onReset(chatId);
        this.emit(peer, "session.reset.result", { session_id: sessionId, accepted: true }, envelope.request_id);
      } catch (error) {
        this.emit(peer, "session.reset.result", { session_id: sessionId, accepted: false, message: errorMessage(error) }, envelope.request_id);
      }
      return;
    }
    if (envelope.type === "user.cancel") {
      const sessionId = value(payload, "session_id") || "main";
      if (!sessionPattern.test(sessionId)) return;
      if (!peer.sessions.has(`desktop:${sessionId}`)) throw new Error("桌面会话未就绪");
      this.clearGuides(peer, `desktop:${sessionId}`, this.screenShare.messageLease(`desktop:${sessionId}`, peer) || "");
      await this.onInput?.({ source: "desktop", message_id: `desktop:${randomUUID()}`, chat_id: `desktop:${sessionId}`, text: "/stop", images: [], files: [] });
      return;
    }
    if (envelope.type === "user.approval") {
      const token = value(payload, "token"), decision = value(payload, "decision");
      const sessionId = value(payload, "session_id") || "main", chatId = `desktop:${sessionId}`;
      if (!sessionPattern.test(sessionId)) return;
      if (!peer.sessions.has(chatId)) throw new Error("桌面会话未就绪");
      const accepted = this.onAnswer?.(token, decision === "allow_once" ? "allow" : decision, chatId, value(payload, "message_id")) || false;
      this.emit(peer, "approval.result", { accepted, token });
    }
  }
  private async attachments(raw: unknown, sessionId: string): Promise<{ images: { path: string }[]; files: { path: string }[] }> {
    const images: { path: string }[] = [], files: { path: string }[] = [];
    if (!Array.isArray(raw)) return { images, files };
    if (raw.length > 8) throw new Error("一次最多发送 8 个附件");
    const directory = join(this.files.inbound(`chat:desktop:${sessionId}`), "desktop");
    let totalBytes = 0;
    for (const item of raw) {
      if (!item || typeof item !== "object" || !["image", "file"].includes(item.type) || item.encoding !== "base64" || typeof item.data !== "string") continue;
      const data = Buffer.from(item.data, "base64");
      totalBytes += data.length;
      if (!data.length || data.length > 20 * 1024 * 1024 || totalBytes > 28 * 1024 * 1024) throw new Error("桌面附件总大小不能超过 28 MB，单个不能超过 20 MB");
      const extension = item.type === "image" ? imageTypes[item.mime_type as string] : extname(basename(String(item.name || ""))).slice(0, 12);
      if (item.type === "image" && !extension) throw new Error("桌面图片格式不支持");
      await mkdir(directory, { recursive: true });
      const path = join(directory, `${randomUUID()}${extension || ""}`);
      await writeFile(path, data);
      (item.type === "image" ? images : files).push({ path });
    }
    return { images, files };
  }
  private rememberSurface(chatId: string, messageId: string, patch: Record<string, unknown>): void {
    let surfaces = this.activeSurfaces.get(chatId);
    if (!surfaces) { surfaces = new Map(); this.activeSurfaces.set(chatId, surfaces); }
    surfaces.set(messageId, { ...surfaces.get(messageId), ...patch });
  }
  private forgetSurface(chatId: string, messageId: string): void {
    const surfaces = this.activeSurfaces.get(chatId);
    surfaces?.delete(messageId);
    if (surfaces?.size === 0) this.activeSurfaces.delete(chatId);
  }
  private surface(chatId: string, messageId: string, content: string, status: string, type: string, extra: Record<string, unknown> = {}, active = false, requirePeer = true): void {
    const turnId = messageId.startsWith("desktop:") ? messageId.slice(8) : messageId;
    const payload = { session_id: chatId.slice(8), turn_id: turnId, surface_id: messageId, content, status, source_label: "gpt-claw", ...extra };
    if (active) this.rememberSurface(chatId, messageId, payload);
    this.publish(chatId, type, payload, requirePeer);
  }
  private async deliverSurface(chatId: string, surfaceId: string, content: string, status: string, type: string, extra: Record<string, unknown>, deliveryId: string): Promise<void> {
    const payload = { session_id: chatId.slice(8), turn_id: surfaceId.slice(8), surface_id: surfaceId,
      content, status, source_label: "gpt-claw", ...extra, delivery_id: deliveryId };
    this.rememberSurface(chatId, surfaceId, payload);
    const targets = [...this.peers].filter(peer => peer.sessions.has(chatId) && peer.socket.readyState === WebSocket.OPEN && peer.capabilities.has("surface.ack"));
    if (!targets.length) throw new Error("桌宠未连接或不支持保存确认，请启动新版桌宠界面");
    await new Promise<void>((resolve, reject) => {
      const finish = (error?: Error) => {
        if (!this.pendingDeliveries.delete(deliveryId)) return;
        clearTimeout(timer);
        if (error) reject(error); else resolve();
      };
      const timer = setTimeout(() => finish(new Error("桌宠尚未确认保存回复")), 12_000);
      this.pendingDeliveries.set(deliveryId, { chatId, surfaceId, finish });
      try { for (const peer of targets) this.emit(peer, type, payload); }
      catch (error) { finish(new Error(errorMessage(error))); }
    });
  }
  async send(chatId: string, text: string, deliveryId = randomUUID()): Promise<string> {
    const id = `desktop:delivery-${deliveryId}`;
    await this.deliverSurface(chatId, id, text, "done", "surface.show", {}, deliveryId);
    return id;
  }
  async update(messageId: string, text: string): Promise<void> {
    await this.updateReply({ messageId, sequence: 0 }, text, 0);
  }
  async startReply(chatId: string, sourceMessageId: string, _content: string, status: string): Promise<ReplyTarget> {
    this.messages.set(sourceMessageId, chatId);
    try {
      this.surface(chatId, sourceMessageId, "", "streaming", "surface.show", { progress: status, content_kind: "progress", tts_eligible: false }, true, false);
    } catch (error) {
      this.messages.delete(sourceMessageId);
      this.forgetSurface(chatId, sourceMessageId);
      throw error;
    }
    return { messageId: sourceMessageId, cardId: sourceMessageId, sequence: 0, chatId };
  }
  async updateReply(target: ReplyTarget, content: string, _sequence: number, kind: "progress" | "final" = "final"): Promise<void> {
    if (kind === "progress") return this.updateReplyStatus(target, content, _sequence);
    const chatId = this.messages.get(target.messageId); if (!chatId) throw new Error("桌面消息不存在");
    this.surface(chatId, target.messageId, content, "streaming", "surface.update", { content_kind: "final", tts_eligible: false }, true, false);
  }
  async updateReplyStatus(target: ReplyTarget, status: string, _sequence: number): Promise<void> {
    const chatId = this.messages.get(target.messageId); if (!chatId) throw new Error("桌面消息不存在");
    const payload = { session_id: chatId.slice(8), turn_id: target.messageId.slice(8), surface_id: target.messageId,
      status: "streaming", progress: status, content_kind: "progress", tts_eligible: false };
    this.rememberSurface(chatId, target.messageId, payload);
    this.publish(chatId, "surface.update", payload, false);
  }
  async finishReply(target: ReplyTarget, content: string, status: string | undefined, _attempt: number, deliveryId = randomUUID()): Promise<void> {
    const existing = this.messages.get(target.messageId);
    const chatId = existing || target.chatId;
    if (!chatId) throw new Error("桌面消息不存在");
    this.messages.delete(target.messageId);
    await this.deliverSurface(chatId, target.messageId, content, target.failed ? "failed" : "done", existing ? "surface.update" : "surface.show", {
      footer_text: status || "", ...(target.resetHistory ? { session_reset: true } : {}),
      ...(target.outcome ? { task_outcome: target.outcome } : {}),
    }, deliveryId);
  }
  async prompt(chatId: string, token: string, prompt: Prompt): Promise<string> {
    const id = `desktop:${randomUUID()}`; this.messages.set(id, chatId);
    const detail = [prompt.title, prompt.detail, ...(prompt.fields || []).map(field => `${field.label}：\n${field.value}`)].join("\n\n");
    const actions = (prompt.choices || []).map(choice => ({ id: choice.value, label: choice.label, action_type: "approval", approval_id: token, token, decision: choice.value === "allow" ? "allow_once" : choice.value, keep_open: true }));
    if (prompt.allowText) actions.push({ id: "submit", label: "提交回答", action_type: "approval", approval_id: token, token, decision: "text", keep_open: true });
    try {
      this.surface(chatId, id, detail, "waiting", "surface.show", {
        approval_id: token, approval_message_id: id,
        controls: prompt.allowText ? [{ type: "text", id: "answer", label: "你的回答" }] : [],
        actions,
      }, true, false);
    } catch (error) {
      this.messages.delete(id);
      this.forgetSurface(chatId, id);
      throw error;
    }
    return id;
  }
  async finishPrompt(messageId: string, _prompt: Prompt, result: PromptResult): Promise<void> {
    const chatId = this.messages.get(messageId); if (!chatId) return;
    const payload = { ...this.activeSurfaces.get(chatId)?.get(messageId), content: result.text, status: "done", actions: [], controls: [] };
    this.rememberSurface(chatId, messageId, payload);
    this.messages.delete(messageId);
    this.publish(chatId, "surface.update", payload);
    this.forgetSurface(chatId, messageId);
  }
  async sendFile(chatId: string, path: string): Promise<string> {
    const filePath = resolve(path);
    const file = await stat(filePath);
    if (!file.isFile() || !file.size || file.size > 20 * 1024 * 1024) throw new Error("桌面文件必须非空且不超过 20 MB");
    const id = `desktop:${randomUUID()}`;
    const mime = { ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".gif": "image/gif" }[extname(filePath).toLowerCase()];
    const dataUrl = mime ? `data:${mime};base64,${(await readFile(filePath)).toString("base64")}` : undefined;
    this.surface(chatId, id, mime ? "图片已生成" : `文件已生成：${basename(filePath)}`, "done", "surface.show", {
      ...(dataUrl ? { image_data_url: dataUrl, file_path: filePath } : {
        file_path: filePath,
        actions: [{ id: "open_file", label: "打开文件", action_type: "open_local_file", path: filePath }],
      }),
    });
    return id;
  }
  async close(): Promise<void> {
    for (const delivery of this.pendingDeliveries.values()) delivery.finish(new Error("桌面通道已关闭"));
    for (const peer of this.peers) { this.screenShare.disable(peer); peer.socket.close(); }
    this.webSocketServer?.close();
    const server = this.server;
    if (server) await new Promise<void>(resolve => server.close(() => resolve()));
    await unlink(this.discovery).catch(() => {});
  }
}
