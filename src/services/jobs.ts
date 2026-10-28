import { randomUUID } from "node:crypto";
import { Store } from "../storage.ts";
import type { AgentResult, SessionContext } from "../app/ports.ts";
import { errorMessage, log } from "../shared/log.ts";
import { describeResult } from "../app/result.ts";

export interface Job {
  id: string; chatId: string; prompt: string;
  status: "queued" | "running" | "completed" | "failed" | "cancelled" | "interrupted";
  createdAt: number; finishedAt?: number; result?: string; error?: string;
}
type Runner = (context: SessionContext, prompt: string, signal: AbortSignal) => Promise<AgentResult>;

/** Durable agent jobs. Never automatically re-execute an interrupted job with possible effects. */
export class Jobs {
  private readonly active = new Map<string, { controller: AbortController; promise: Promise<void> }>();
  private timer?: NodeJS.Timeout;
  private stopping = false;
  constructor(private readonly store: Store, private readonly concurrency: number, private readonly run: Runner) {
    for (const job of store.jobsByStatus<Job>("running", -1)) this.complete({ ...job, status: "interrupted", error: "服务重启，任务未自动重放" });
  }
  create(chatId: string, prompt: string, id: string = randomUUID()): Job {
    const existing = this.store.get<Job>("jobs", id);
    if (existing) return existing;
    const job: Job = { id, chatId, prompt, status: "queued", createdAt: Date.now() };
    this.store.set("jobs", id, job); return job;
  }
  list(chatId: string): Job[] { return this.store.jobsForChat<Job>(chatId, 30); }
  get(chatId: string, id: string): Job {
    const job = this.store.get<Job>("jobs", id);
    if (!job || job.chatId !== chatId) throw new Error("任务不存在于当前聊天");
    return job;
  }
  cancel(chatId: string, id: string): Job {
    const job = this.get(chatId, id);
    if (!["queued", "running"].includes(job.status)) return job;
    this.store.set("jobs", id, { ...job, status: "cancelled", finishedAt: Date.now() });
    this.active.get(id)?.controller.abort(); return this.get(chatId, id);
  }
  start(): void { this.timer = setInterval(() => this.pump(), 1000); this.pump(); }
  private pump(): void {
    if (this.stopping) return;
    const available = this.concurrency - this.active.size;
    if (available <= 0) return;
    for (const job of this.store.jobsByStatus<Job>("queued", available)) {
      const controller = new AbortController();
      this.store.set("jobs", job.id, { ...job, status: "running" });
      const promise = this.execute(job, controller)
        .catch(error => log.error(`后台任务 ${job.id} 状态保存失败：${errorMessage(error)}`))
        .finally(() => this.active.delete(job.id));
      this.active.set(job.id, { controller, promise });
    }
  }
  private async execute(job: Job, controller: AbortController): Promise<void> {
    let finished: Job;
    try {
      const result = await this.run({ chatId: job.chatId, sessionKey: `job:${job.id}` }, job.prompt, controller.signal);
      const outcome = describeResult(result);
      const status = controller.signal.aborted || result.status === "interrupted" ? "interrupted" : outcome.deliveryFailed ? "failed" : "completed";
      finished = { ...job, status, result: outcome.text };
    } catch (error) {
      const status = controller.signal.aborted ? "interrupted" : "failed";
      finished = { ...job, status, error: errorMessage(error) };
    }
    if (this.get(job.chatId, job.id).status !== "cancelled") this.complete(finished);
  }
  private complete(job: Job): void {
    const label = job.status === "completed" ? "已完成" : job.status === "interrupted" ? "已中断" : job.error !== undefined ? "执行失败" : "交付失败";
    this.store.transaction(() => {
      this.store.set("jobs", job.id, { ...job, finishedAt: Date.now() });
      this.store.enqueue(job.chatId, `后台任务 ${job.id}：${label}\n${job.result ?? job.error ?? ""}`);
    });
  }
  stop(): void { this.stopping = true; clearInterval(this.timer); for (const item of this.active.values()) item.controller.abort(); }
  async drain(): Promise<void> { await Promise.allSettled([...this.active.values()].map(item => item.promise)); }
}
