import { Cron } from "croner";
import { randomUUID } from "node:crypto";
import { Store } from "../storage.ts";
import { Jobs } from "./jobs.ts";
import { errorMessage, log } from "../shared/log.ts";

export interface Schedule {
  id: string; chatId: string; name: string; prompt: string; enabled: boolean;
  kind: "at" | "every" | "cron"; expression: string; timezone: string; nextAt: number;
}

/** Local timers do not call the model. Only an explicitly created, due schedule starts an agent job. */
export class Schedules {
  private timer?: NodeJS.Timeout;
  constructor(private readonly store: Store, private readonly jobs: Jobs) {}
  create(input: Omit<Schedule, "id" | "enabled" | "nextAt">): Schedule {
    const now = Date.now(), nextAt = this.next(input, now);
    if (!nextAt || nextAt <= now) throw new Error("定时时间必须在未来");
    const schedule: Schedule = { ...input, id: randomUUID(), enabled: true, nextAt };
    this.store.set("schedules", schedule.id, schedule); return schedule;
  }
  list(chatId: string): Schedule[] { return this.store.values<Schedule>("schedules").filter(item => item.chatId === chatId); }
  cancel(chatId: string, id: string): void {
    const schedule = this.store.get<Schedule>("schedules", id);
    if (!schedule || schedule.chatId !== chatId) throw new Error("定时任务不存在于当前聊天");
    this.store.set("schedules", id, { ...schedule, enabled: false });
  }
  private next(schedule: Pick<Schedule, "kind" | "expression" | "timezone">, after: number): number | undefined {
    if (schedule.kind === "at") {
      // Require an explicit offset so a machine's locale never changes the requested time.
      if (!/(Z|[+-]\d{2}:\d{2})$/i.test(schedule.expression)) throw new Error("at 时间必须是带时区的 ISO 时间");
      const timestamp = Date.parse(schedule.expression);
      if (!Number.isFinite(timestamp)) throw new Error("at 时间无效");
      return timestamp;
    }
    if (schedule.kind === "every") {
      const seconds = Number(schedule.expression);
      if (!Number.isInteger(seconds) || seconds < 60 || seconds > 31_536_000) throw new Error("every 必须是 60–31536000 秒的整数");
      return after + seconds * 1000;
    }
    const cron = new Cron(schedule.expression, { timezone: schedule.timezone, paused: true });
    try {
      const next = cron.nextRun(new Date(after))?.getTime();
      const following = next ? cron.nextRun(new Date(next))?.getTime() : undefined;
      if (next && following && following - next < 60_000) throw new Error("MVP 定时任务间隔至少一分钟");
      return next;
    } finally { cron.stop(); }
  }
  start(): void { this.timer = setInterval(() => this.tick(), 1000); this.tick(); }
  private tick(): void {
    const now = Date.now();
    for (const item of this.store.values<Schedule>("schedules").filter(schedule => schedule.enabled && schedule.nextAt <= now)) {
      try {
        // One occurrence + cursor update in one SQLite transaction. Skip a backlog of missed repeats.
        const nextAt = item.kind === "at" ? undefined : this.next(item, now);
        this.store.transaction(() => {
          this.jobs.create(item.chatId, `[定时任务：${item.name}]\n${item.prompt}`, `schedule:${item.id}:${item.nextAt}`);
          this.store.set("schedules", item.id, { ...item, enabled: !!nextAt, nextAt: nextAt ?? item.nextAt });
        });
      } catch (error) {
        this.store.set("schedules", item.id, { ...item, enabled: false });
        log.error(`定时任务 ${item.id} 已停用：${errorMessage(error)}`);
      }
    }
  }
  stop(): void { clearInterval(this.timer); }
}
