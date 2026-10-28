import { mkdir } from "node:fs/promises";
import { join } from "node:path";
import { readConfig } from "./config.ts";
import { Store } from "./storage.ts";
import { FeishuChannel } from "./feishu/channel.ts";
import { ensureFeishuAuth } from "./feishu/device-auth.ts";
import { Prompts } from "./app/prompts.ts";
import { Outbox } from "./app/outbox.ts";
import { Application } from "./app/application.ts";
import { CodexRpc } from "./codex/rpc.ts";
import { CodexRuntime } from "./codex/runtime.ts";
import { CodexApprovals } from "./codex/approvals.ts";
import { Browser } from "./services/browser.ts";
import { Jobs } from "./services/jobs.ts";
import { Schedules } from "./services/schedules.ts";
import { ToolHost } from "./tools/host.ts";
import { builtins } from "./tools/builtins.ts";
import { loadTools } from "./tools/loader.ts";
import { instanceLock } from "./shared/instance-lock.ts";
import { errorMessage, log } from "./shared/log.ts";
import { commands } from "./app/commands.ts";
import { syncSlashCommands } from "./feishu/slash-commands.ts";
import { FeishuPermissionLinks } from "./feishu/permission-links.ts";
import { deliverGeneratedImage } from "./app/image-delivery.ts";
import { DesktopGateway } from "./desktop/gateway.ts";
import { ChannelRouter } from "./app/channel-router.ts";
import { SessionFiles } from "./services/session-files.ts";
import { ScreenShare } from "./services/screen-share.ts";
import { WindowsMcp } from "./services/windows-mcp.ts";

async function main(): Promise<void> {
  const desktopOnly = process.argv.includes("--desktop-only");
  let config = readConfig();
  await mkdir(config.workspace, { recursive: true }); await mkdir(config.dataDir, { recursive: true });
  const unlock = await instanceLock(join(config.dataDir, "instance.lock"));
  const startup = new AbortController();
  let dispose = async () => {};
  let started = false, stopping: Promise<void> | undefined;
  const stop = () => stopping ??= (async () => {
    startup.abort(); log.info("正在停止 gpt-claw");
    try { await dispose(); } finally { await unlock(); }
  })();
  const requestStop = () => {
    startup.abort();
    if (started) void stop().catch(error => { log.error(errorMessage(error)); process.exitCode = 1; });
  };
  process.once("SIGINT", requestStop); process.once("SIGTERM", requestStop);
  process.on("message", message => { if (message === "stop") requestStop(); });
  process.once("disconnect", requestStop);
  try {
    if (!desktopOnly) config = await ensureFeishuAuth(config, startup.signal);
    startup.signal.throwIfAborted();
    const store = new Store(config.dataDir);
    const files = new SessionFiles(config.workspace, store);
    dispose = async () => store.close();
    const feishu = new FeishuChannel(config, files);
    const screenShare = new ScreenShare();
    const windowsMcp = new WindowsMcp(config.root);
    const desktop = new DesktopGateway(join(config.root, "data"), files, screenShare);
    const channel = new ChannelRouter(feishu, desktop);
    const permissionLinks = new FeishuPermissionLinks(config, feishu);
    const prompts = new Prompts(channel, config.owner, config.approvalTimeoutMs);
    const outbox = new Outbox(store, channel, config.outboxSentRetentionMs);
    const browser = new Browser(join(config.dataDir, "browser"), files, config.browserChannel, screenShare);
    const rpc = new CodexRpc(config);
    let host!: ToolHost;
    const runtime = new CodexRuntime(rpc, store, config, files, context => host.url(context),
      (context, result) => context.chatId.startsWith("desktop:") ? undefined : permissionLinks.inspect(context.chatId, result),
      (context, path) => deliverGeneratedImage(files, channel, context.chatId, context.sessionKey, path));
    const jobs = new Jobs(store, config.jobConcurrency, (context, prompt, signal) => runtime.run(context, { prompt }, signal));
    const schedules = new Schedules(store, jobs);
    const app = new Application(config, feishu, channel, runtime, prompts, outbox, store, jobs, schedules, screenShare);
    const approvals = new CodexApprovals(prompts, threadId => runtime.context(threadId));
    rpc.onRequest = request => { runtime.awaitingApproval(request.params.threadId); return approvals.handle(request); };
    feishu.onMessage = message => app.receive(message);
    feishu.onAnswer = answer => prompts.answer(answer.token, answer.value, answer.owner, answer.chatId, answer.messageId);
    desktop.onInput = message => app.receiveDesktop(message);
    desktop.onReset = chatId => app.resetDesktop(chatId);
    desktop.onAnswer = (token, value, chatId, messageId) => prompts.answer(token, value, config.owner, chatId, messageId);
    desktop.onDeliveryAck = (chatId, deliveryId, surfaceId) => outbox.acknowledgeDesktopDelivery(chatId, deliveryId, surfaceId);
    dispose = async () => {
      app.stop(); schedules.stop(); jobs.stop(); prompts.cancelAll(); permissionLinks.stop();
      const results = await Promise.allSettled([feishu.close(), desktop.close(), runtime.close(), windowsMcp.close()]);
      results.push(...await Promise.allSettled([app.drainAll(), jobs.drain(), host?.close(), browser.close()]));
      for (const result of results) if (result.status === "rejected") log.warn(`退出清理失败：${errorMessage(result.reason)}`);
      try { await outbox.stop(); } finally { store.close(); }
    };
    const tools = await loadTools(join(config.root, "tools"), builtins());
    startup.signal.throwIfAborted();
    host = new ToolHost(tools, { browser, jobs, schedules, store, channel, feishu, files, screenShare, windowsMcp, workspace: config.workspace }, prompts);
    await host.start(); startup.signal.throwIfAborted();
    await runtime.start(); startup.signal.throwIfAborted();
    if (!desktopOnly) await feishu.start(); startup.signal.throwIfAborted();
    await desktop.start(); startup.signal.throwIfAborted();
    await app.recoverPending(desktopOnly); startup.signal.throwIfAborted();
    if (!desktopOnly) {
      try {
        const menu = await syncSlashCommands(feishu.normalizer.client, commands, startup.signal);
        log.info(`飞书 / 面板同步完成：新增 ${menu.created}，更新 ${menu.updated}，移除旧命令 ${menu.removed}，一致 ${menu.unchanged}`);
      } catch (error) {
        startup.signal.throwIfAborted();
        log.warn(`${errorMessage(error)}；请确认 application:app_slash_command:read / write 已开通并发布，然后运行 npm run feishu:commands 重试`);
      }
    }
    startup.signal.throwIfAborted();
    outbox.start(); jobs.start(); schedules.start();
    started = true;
    log.info(`gpt-claw 已启动；本人专用；${tools.length} 个业务工具；无默认模型心跳`);
    log.info(`已加载业务工具：${tools.map(tool => tool.name).join("、")}`);
    if (!desktopOnly) void runtime.warmRecentChat().catch(error => {
      if (!startup.signal.aborted) log.warn(`最近聊天会话预热失败：${errorMessage(error)}`);
    });
  } catch (error) { const cancelled = startup.signal.aborted; await stop(); if (!cancelled) throw error; }
}
main().catch(error => { log.error(errorMessage(error)); process.exitCode = 1; });
