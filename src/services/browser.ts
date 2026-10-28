import { chromium, type BrowserContext, type Page } from "playwright-core";
import { mkdir } from "node:fs/promises";
import { join } from "node:path";
import { randomUUID } from "node:crypto";
import type { SessionFiles } from "./session-files.ts";
import type { ScreenShare } from "./screen-share.ts";

export interface BrowserAction { action: "open" | "snapshot" | "click" | "fill" | "press" | "screenshot" | "tabs" | "select_tab" | "close"; url?: string; selector?: string; text?: string; index?: number; }

/** One dedicated persistent profile, started only when requested. Browser mutations are serialized. */
export class Browser {
  private context?: BrowserContext;
  private readonly pages = new Map<string, Page>();
  private readonly sessionTabs = new Map<string, Set<Page>>();
  private queue: Promise<unknown> = Promise.resolve();
  private closing = false;
  private readonly shutdown = new AbortController();
  constructor(private readonly profile: string, private readonly files: SessionFiles, private readonly channel: string, private readonly screenShare: ScreenShare) {}
  execute(sessionKey: string, input: BrowserAction, signal: AbortSignal): Promise<unknown> {
    if (this.closing) return Promise.reject(new Error("浏览器正在退出"));
    const combined = AbortSignal.any([signal, this.shutdown.signal]);
    const result = this.queue.catch(() => {}).then(async () => {
      combined.throwIfAborted();
      const value = await this.screenShare.withBrowser(sessionKey, combined, operationSignal => this.perform(sessionKey, input, operationSignal));
      combined.throwIfAborted();
      return value;
    });
    this.queue = result;
    return result;
  }
  private async current(sessionKey: string, signal: AbortSignal): Promise<Page> {
    signal.throwIfAborted();
    if (!this.context) {
      await mkdir(this.profile, { recursive: true });
      signal.throwIfAborted();
      this.context = await chromium.launchPersistentContext(this.profile, { channel: this.channel, headless: false, timeout: 30_000, acceptDownloads: false });
      this.context.setDefaultTimeout(15_000);
      this.context.on("close", () => { this.context = undefined; this.pages.clear(); this.sessionTabs.clear(); });
    }
    signal.throwIfAborted();
    let page = this.pages.get(sessionKey);
    if (!page || page.isClosed()) {
      page = await this.context.newPage();
      if (signal.aborted) { await page.close().catch(() => {}); signal.throwIfAborted(); }
      this.track(sessionKey, page);
    }
    return page;
  }
  private track(sessionKey: string, page: Page): void {
    const tabs = this.sessionTabs.get(sessionKey) || new Set<Page>();
    tabs.add(page); this.sessionTabs.set(sessionKey, tabs);
    this.pages.set(sessionKey, page);
    page.on("popup", popup => this.track(sessionKey, popup));
  }
  private async perform(sessionKey: string, input: BrowserAction, signal: AbortSignal): Promise<unknown> {
    signal.throwIfAborted();
    if (input.action === "close") {
      const page = this.pages.get(sessionKey);
      if (page && !page.isClosed()) await page.close();
      this.pages.delete(sessionKey);
      if (page) this.sessionTabs.get(sessionKey)?.delete(page);
      return { closed: true };
    }
    const page = await this.current(sessionKey, signal);
    // Closing only the active session page cancels Playwright's pending auto-waits.
    // A request already sent to the site can still complete; never retry it here.
    let cancelling: Promise<void> | undefined;
    const cancel = () => { cancelling ??= page.close().catch(() => {}); };
    signal.addEventListener("abort", cancel, { once: true });
    try {
      signal.throwIfAborted();
      if (input.action === "open") {
        const url = new URL(input.url || "");
        if (!["http:", "https:"].includes(url.protocol)) throw new Error("只允许打开 HTTP/HTTPS 网页");
        await page.goto(url.href, { waitUntil: "domcontentloaded", timeout: 30_000 });
      } else if (input.action === "tabs") return this.tabs(sessionKey).map((tab, index) => ({ index, url: tab.url(), selected: tab === page }));
      else if (input.action === "select_tab") {
        const selected = this.tabs(sessionKey)[input.index ?? -1];
        if (!selected) throw new Error("标签页不存在");
        this.pages.set(sessionKey, selected); await selected.bringToFront(); return { url: selected.url() };
      } else if (input.action === "screenshot") {
        const artifacts = this.files.artifacts(sessionKey);
        await mkdir(artifacts, { recursive: true });
        signal.throwIfAborted();
        const path = join(artifacts, `browser-${randomUUID()}.png`);
        await page.screenshot({ path, fullPage: false }); return { path };
      } else if (["click", "fill", "press"].includes(input.action)) {
        if (!input.selector) throw new Error("需要 selector；先读取快照，不能猜测控件");
        const target = input.selector.startsWith("role=") ? this.roleLocator(page, input.selector) : page.locator(input.selector);
        if (await target.count() !== 1) throw new Error("selector 必须唯一匹配一个控件");
        signal.throwIfAborted();
        if (input.action === "click") await target.click();
        if (input.action === "fill") await target.fill(input.text ?? "");
        if (input.action === "press") await target.press(input.text ?? "Enter");
      }
      signal.throwIfAborted();
      return { url: page.url(), title: await page.title(), snapshot: (await page.locator("body").ariaSnapshot()).slice(0, 24_000) };
    } catch (error) { signal.throwIfAborted(); throw error; }
    finally { signal.removeEventListener("abort", cancel); await cancelling; }
  }
  private tabs(sessionKey: string): Page[] {
    const tabs = this.sessionTabs.get(sessionKey);
    if (!tabs) return [];
    for (const tab of tabs) if (tab.isClosed()) tabs.delete(tab);
    return [...tabs];
  }
  private roleLocator(page: Page, selector: string) {
    const match = /^role=([a-z]+)\[name="(.+)"\]$/.exec(selector);
    if (!match) throw new Error('角色定位格式：role=button[name="提交"]');
    return page.getByRole(match[1] as Parameters<Page["getByRole"]>[0], { name: match[2], exact: true });
  }
  async close(): Promise<void> { this.closing = true; this.shutdown.abort(); await this.queue.catch(() => {}); await this.context?.close(); }
}
