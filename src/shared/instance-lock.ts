import { open, readFile, unlink } from "node:fs/promises";
import { randomUUID } from "node:crypto";

export async function instanceLock(path: string): Promise<() => Promise<void>> {
  const token = randomUUID();
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const file = await open(path, "wx");
      await file.writeFile(JSON.stringify({ pid: process.pid, token })); await file.close();
      return async () => { const current = JSON.parse(await readFile(path, "utf8")); if (current.token === token) await unlink(path); };
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== "EEXIST") throw error;
      const previous = JSON.parse(await readFile(path, "utf8"));
      try { process.kill(previous.pid, 0); }
      catch (probe) { if ((probe as NodeJS.ErrnoException).code === "ESRCH") { await unlink(path); continue; } }
      throw new Error("已有 gpt-claw 使用这个数据目录，请先停止旧进程");
    }
  }
  throw new Error("无法获取实例锁");
}
