import { randomUUID } from "node:crypto";
import type { SessionContext } from "../app/ports.ts";

export interface ScreenBounds { x: number; y: number; width: number; height: number; }
export interface ScreenImage { data: string; mimeType: "image/jpeg"; }
export interface ScreenGuide {
  target: ScreenBounds;
  windowId: number;
  windowPid: number;
  windowBounds: ScreenBounds;
  transientWindowIds: readonly number[];
  monitor: ScreenBounds;
  label: string;
  durationMs: number;
}
export interface ScreenGuideResult { status: "arrived" | "indicator_only" | "cleared"; }
export interface ScreenLease {
  readonly id: string;
  readonly chatId: string;
  readonly owner: object;
  readonly pid: number;
  readonly signal: AbortSignal;
  capture(bounds: ScreenBounds, signal: AbortSignal): Promise<ScreenImage>;
  guide?: (target: ScreenGuide | null, signal: AbortSignal) => Promise<ScreenGuideResult>;
}
interface Lease extends ScreenLease { controller: AbortController; }
interface Grant { id: string; lease: Lease; controller: AbortController; signal: AbortSignal; active: boolean; }

/** A live UI connection and an exact foreground turn must both authorize desktop access. */
export class ScreenShare {
  onRevoked?: (chatId: string) => void;
  onControl?: (chatId: string, shareId: string, active: boolean) => void;
  private lease?: Lease;
  private readonly grants = new Map<string, Grant>();
  private busy = false;
  private browserBusy = false;

  enable(chatId: string, owner: object, pid: number, capture: ScreenLease["capture"], guide?: ScreenLease["guide"]): ScreenLease {
    if (!chatId.startsWith("desktop:") || !Number.isSafeInteger(pid) || pid <= 0) throw new Error("共享屏幕会话或进程无效");
    if (this.lease) {
      if (this.lease.chatId === chatId && this.lease.owner === owner && this.lease.pid === pid) return this.lease;
      throw new Error("另一桌宠窗口正在共享屏幕，请先关闭它的共享");
    }
    const controller = new AbortController();
    this.lease = { id: randomUUID(), chatId, owner, pid, capture, guide, controller, signal: controller.signal };
    return this.lease;
  }
  disable(owner: object, chatId?: string): void {
    if (this.lease?.owner !== owner || (chatId && this.lease.chatId !== chatId)) return;
    this.lease.controller.abort(new Error("共享屏幕已关闭或连接断开"));
    this.onControl?.(this.lease.chatId, this.lease.id, false);
    this.lease = undefined;
  }
  /** A successful conversation reset revokes access and updates the connected UI. */
  revoke(chatId: string): void {
    if (this.lease?.chatId === chatId) this.disable(this.lease.owner, chatId);
    this.onRevoked?.(chatId);
  }
  messageLease(chatId: string, owner: object): string | undefined {
    return this.lease?.chatId === chatId && this.lease.owner === owner ? this.lease.id : undefined;
  }
  beginTurn(context: SessionContext, leaseId: string | undefined, signal: AbortSignal): { close(): void } {
    const lease = this.lease;
    const allowed = !!leaseId && lease?.id === leaseId && lease.chatId === context.chatId && context.sessionKey === `chat:${context.chatId}`;
    const controller = new AbortController();
    const grant: Grant | undefined = allowed ? { id: randomUUID(), lease: lease!, controller, signal: AbortSignal.any([signal, lease!.signal, controller.signal]), active: false } : undefined;
    if (grant) this.grants.set(context.sessionKey, grant);
    return {
      close: () => {
        controller.abort(new Error("当前桌面轮次已结束"));
        if (grant && this.grants.get(context.sessionKey) === grant) {
          this.grants.delete(context.sessionKey);
          this.onControl?.(grant.lease.chatId, grant.lease.id, false);
        }
      },
    };
  }
  private authorizedGrant(context: SessionContext): Grant | undefined {
    const grant = this.grants.get(context.sessionKey);
    return grant && grant.lease === this.lease && context.chatId === grant.lease.chatId
      && context.sessionKey === `chat:${context.chatId}` && !grant.signal.aborted ? grant : undefined;
  }
  available(context: SessionContext): boolean { return !!this.authorizedGrant(context); }
  async run<T>(context: SessionContext, signal: AbortSignal, action: (lease: ScreenLease, signal: AbortSignal, turnId: string) => Promise<T>): Promise<T> {
    const grant = this.authorizedGrant(context);
    if (!grant)
      throw new Error("当前轮次未获共享屏幕权限；请在桌宠菜单开启共享后发送新请求");
    const combined = AbortSignal.any([signal, grant.signal]);
    combined.throwIfAborted();
    if (this.busy || this.browserBusy) throw new Error("电脑或浏览器正在执行另一操作，请等待该操作完成后重新观察");
    this.busy = true;
    try {
      grant.active = true;
      this.onControl?.(grant.lease.chatId, grant.lease.id, true);
      return await action(grant.lease, combined, grant.id);
    }
    finally { this.busy = false; }
  }

  async withBrowser<T>(sessionKey: string, signal: AbortSignal, action: (signal: AbortSignal) => Promise<T>): Promise<T> {
    signal.throwIfAborted();
    const anotherTask = [...this.grants].some(([key, grant]) => key !== sessionKey && grant.active && !grant.signal.aborted);
    if (this.busy || this.browserBusy || anotherTask) throw new Error("电脑正在操作，请等待完成后再操作浏览器");
    const own = this.grants.get(sessionKey);
    const combined = own?.active ? AbortSignal.any([signal, own.signal]) : signal;
    combined.throwIfAborted();
    this.browserBusy = true;
    try { const result = await action(combined); combined.throwIfAborted(); return result; }
    finally { this.browserBusy = false; }
  }
}
