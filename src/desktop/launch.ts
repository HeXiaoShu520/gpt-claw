import { spawn, type ChildProcess } from "node:child_process";
import { existsSync, watch, type FSWatcher } from "node:fs";
import { readFile, writeFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import WebSocket from "ws";
import { errorMessage, log } from "../shared/log.ts";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const python = join(root, "desktop/.venv/Scripts/python.exe");
const dependenciesReady = join(root, "desktop/.venv/.gpt-claw-ready");
const discovery = join(root, "data/desktop-connection.json");

function finished(child: ChildProcess): Promise<number> {
  if (child.exitCode !== null || child.signalCode !== null)
    return Promise.resolve(child.exitCode ?? 1);
  return new Promise((done, reject) => {
    child.once("error", reject);
    child.once("exit", (code, signal) => done(code ?? (signal ? 1 : 0)));
  });
}

async function run(command: string, args: string[], signal: AbortSignal): Promise<void> {
  const code = await finished(spawn(command, args, { cwd: root, stdio: "inherit", windowsHide: true, signal }));
  if (code !== 0) throw new Error(`${command} 退出码 ${code}`);
}

async function gatewayReady(): Promise<boolean> {
  let endpoint: unknown;
  try { endpoint = JSON.parse(await readFile(discovery, "utf8")); }
  catch { return false; }
  if (!endpoint || typeof endpoint !== "object") return false;
  const { url, token } = endpoint as { url?: unknown; token?: unknown };
  if (typeof url !== "string" || typeof token !== "string"
    || !/^ws:\/\/127\.0\.0\.1:\d+\/ws\/minipet$/.test(url) || !/^[a-f\d]{64}$/.test(token)) return false;
  return new Promise(resolveReady => {
    const socket = new WebSocket(url, { headers: { Authorization: `Bearer ${token}` }, handshakeTimeout: 800 });
    const timer = setTimeout(() => { socket.terminate(); resolveReady(false); }, 1000);
    socket.once("open", () => { clearTimeout(timer); socket.close(); resolveReady(true); });
    socket.once("error", () => { clearTimeout(timer); resolveReady(false); });
  });
}

async function waitForGateway(backend: ChildProcess, failure: () => Error | undefined, signal: AbortSignal): Promise<void> {
  // 首次启动可能依次等待飞书应用注册和用户授权扫码。
  const deadline = Date.now() + 25 * 60_000;
  while (Date.now() < deadline) {
    signal.throwIfAborted();
    if (failure() || !backend.pid || backend.exitCode !== null || backend.signalCode !== null)
      throw new Error("gpt-claw 启动失败，请看上方日志");
    if (await gatewayReady()) return;
    await new Promise(done => setTimeout(done, 500));
  }
  throw new Error("等待 gpt-claw 桌面通道超时，请看上方日志");
}

async function stopBackend(backend: ChildProcess): Promise<void> {
  if (!backend.pid || backend.exitCode !== null || backend.signalCode !== null) return;
  log.info("正在停止本次启动的 gpt-claw 服务……");
  const exited = finished(backend).catch(() => 1);
  if (backend.connected) backend.send("stop", error => { if (error) backend.kill(); });
  else backend.kill();
  const timeout = setTimeout(() => backend.kill(), 30_000);
  await exited;
  clearTimeout(timeout);
  log.info("本次启动的 gpt-claw 服务已停止。");
}

/** Keep the Qt process alive while gracefully restarting only our own service. */
function watchService(restart: () => Promise<void>, signal: AbortSignal): () => Promise<void> {
  const watchers: FSWatcher[] = [];
  let timer: NodeJS.Timeout | undefined;
  let restarting: Promise<void> | undefined;
  let dirty = false, closed = false;
  const drain = async () => {
    while (dirty && !closed && !signal.aborted) {
      dirty = false;
      try { await restart(); }
      catch (error) { if (!signal.aborted) log.error(`开发服务重启失败：${errorMessage(error)}；修正源码后会再次启动。`); }
    }
  };
  try {
    for (const directory of ["src", "tools"]) {
      const watcher = watch(join(root, directory), { recursive: true }, (_event, filename) => {
        if (closed || signal.aborted) return;
        const path = filename?.toString().replace(/\\/g, "/");
        // The launcher itself is already running; changes to it need a new command.
        if (path && (!/\.(?:[cm]?ts|json)$/.test(path) || directory === "src" && path === "desktop/launch.ts")) return;
        if (timer) clearTimeout(timer);
        timer = setTimeout(() => {
          dirty = true;
          restarting ??= drain().finally(() => { restarting = undefined; });
        }, 300);
      });
      watcher.on("error", error => log.error(`开发源码监听失败：${errorMessage(error)}；请重新运行开发指令。`));
      watchers.push(watcher);
    }
  } catch (error) { for (const watcher of watchers) watcher.close(); throw error; }
  log.info("开发监听已开启：src/、tools/ 的 TS/JSON 改动会重启本次启动的服务。");
  return async () => {
    closed = true;
    if (timer) clearTimeout(timer);
    for (const watcher of watchers) watcher.close();
    await restarting;
  };
}

async function main(): Promise<void> {
  const serviceOnly = process.argv.includes("--service-only");
  const withService = serviceOnly || process.argv.includes("--with-service");
  const development = process.argv.includes("--dev");
  const shutdown = new AbortController();
  let backend: ChildProcess | undefined;
  let backendFailure: Error | undefined;
  let ui: ChildProcess | undefined;
  let stopWatching: (() => Promise<void>) | undefined;
  const stoppingChildren = new WeakSet<ChildProcess>();
  const stop = () => { shutdown.abort(); ui?.kill(); };
  process.once("SIGINT", stop); process.once("SIGTERM", stop); process.once("disconnect", stop);
  const startBackend = () => {
    shutdown.signal.throwIfAborted();
    backendFailure = undefined;
    log.info("启动 gpt-claw 服务：Codex 内核、飞书、桌面通道……");
    const child = spawn(process.execPath, ["--import", "tsx", join(root, "src/main.ts")], {
      cwd: root, stdio: ["inherit", "inherit", "inherit", "ipc"], windowsHide: true,
    });
    child.on("error", error => { backendFailure = error; log.error(`gpt-claw 启动失败：${error.message}`); });
    child.once("exit", (code, signal) => {
      if (!stoppingChildren.has(child) && !shutdown.signal.aborted)
        log.warn(`gpt-claw 服务已退出（${signal || `退出码 ${code}`}）${development ? "；修改源码后会再次启动。" : "。"}`);
    });
    return child;
  };
  const stopOwnedBackend = async () => {
    if (backend) { stoppingChildren.add(backend); await stopBackend(backend); }
  };
  try {
    log.info(`启动模式：${development ? "开发" : "常规"}；${serviceOnly ? "仅 gpt-claw 服务" : withService ? "gpt-claw 服务 + 桌宠界面" : "仅桌宠界面"}。`);
    if (!serviceOnly) {
      log.info("检查桌宠 Python 环境……");
      if (!existsSync(python)) {
        log.info("首次启动：创建桌宠 Python 环境……");
        await run("python", ["-m", "venv", join(root, "desktop/.venv")], shutdown.signal);
      }
      if (!existsSync(dependenciesReady)) {
        log.info("安装桌宠桌面依赖，首次下载可能较慢……");
        await run(python, ["-m", "pip", "install", "-r", join(root, "desktop/requirements.txt")], shutdown.signal);
        await writeFile(dependenciesReady, "ready\n");
      }
      log.info("桌宠 Python 环境已就绪。");
    }
    shutdown.signal.throwIfAborted();
    if (withService && !await gatewayReady()) {
      backend = startBackend();
      log.info("等待 gpt-claw 服务就绪；首次运行请在终端完成飞书认证……");
      await waitForGateway(backend, () => backendFailure, shutdown.signal);
      if (development) stopWatching = watchService(async () => {
        log.info("服务源码已变化，正在重启 gpt-claw……");
        await stopOwnedBackend();
        if (shutdown.signal.aborted) return;
        backend = startBackend();
        await waitForGateway(backend, () => backendFailure, shutdown.signal);
        log.info(serviceOnly ? "开发服务已重新就绪。" : "开发服务已重新就绪，桌宠会自动重连；共享屏幕需重新开启。");
      }, shutdown.signal);
    } else if (withService) {
      log.info("复用正在运行的 gpt-claw 服务；后端日志在原启动终端，本次退出不会停止它。");
      if (development) log.warn("现有服务未启用本次源码监听；需要监听时，先在原终端停止服务，再运行开发指令。");
    } else log.info("单独启动桌宠；gpt-claw 服务可用后会自动连接。");
    shutdown.signal.throwIfAborted();
    if (serviceOnly) {
      if (!backend) return;
      await new Promise<void>(done => shutdown.signal.addEventListener("abort", () => done(), { once: true }));
      return;
    }
    log.info("正在启动桌宠界面……");
    ui = spawn(python, ["-u", join(root, "desktop/main.py")], {
      cwd: root, stdio: "inherit", windowsHide: true,
      env: { ...process.env, PYTHONIOENCODING: "utf-8" },
    });
    ui.once("spawn", () => log.info("桌宠进程已启动；界面和连接状态会继续打印在此终端。"));
    const code = await finished(ui);
    log.info(`桌宠进程已退出（退出码 ${code}）。`);
    if (code !== 0 && !shutdown.signal.aborted) process.exitCode = code;
  } catch (error) {
    if (!shutdown.signal.aborted) throw error;
  } finally {
    shutdown.abort();
    if (ui?.pid && ui.exitCode === null && ui.signalCode === null) ui.kill();
    await stopWatching?.();
    await stopOwnedBackend();
    process.off("SIGINT", stop); process.off("SIGTERM", stop); process.off("disconnect", stop);
  }
}

main().catch(error => { log.error(errorMessage(error)); process.exitCode = 1; });
