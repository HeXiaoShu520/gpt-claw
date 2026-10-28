import { mkdirSync } from "node:fs";
import { randomUUID } from "node:crypto";
import { join } from "node:path";
import { DatabaseSync } from "node:sqlite";
import type { ReplyTarget } from "./app/ports.ts";

export interface Delivery { id: number; deliveryId: string; chatId: string; text: string; stats?: string; attempts: number; target?: ReplyTarget; }
export interface DeliveryStatus {
  counts: { status: string; count: number }[];
  failed: { id: number; attempts: number }[];
  failedHasMore: boolean;
}

/** A single writer in the application process. Services never open their own database. */
export class Store {
  private readonly db: DatabaseSync;
  constructor(dataDir: string) {
    mkdirSync(dataDir, { recursive: true });
    this.db = new DatabaseSync(join(dataDir, "state.sqlite"));
    this.db.exec(`
      PRAGMA journal_mode=WAL;
      PRAGMA busy_timeout=5000;
      CREATE TABLE IF NOT EXISTS kv (namespace TEXT, key TEXT, value TEXT NOT NULL, PRIMARY KEY(namespace,key));
      CREATE TABLE IF NOT EXISTS inbox (id TEXT PRIMARY KEY, chat_id TEXT, status TEXT, updated_at INTEGER);
      CREATE TABLE IF NOT EXISTS outbox (id INTEGER PRIMARY KEY, chat_id TEXT, text TEXT, message_id TEXT, attempts INTEGER DEFAULT 0, next_at INTEGER DEFAULT 0, status TEXT DEFAULT 'pending', error TEXT);
      CREATE INDEX IF NOT EXISTS jobs_status_created ON kv(json_extract(value,'$.status'),json_extract(value,'$.createdAt'),key) WHERE namespace='jobs';
      CREATE INDEX IF NOT EXISTS jobs_chat_created ON kv(json_extract(value,'$.chatId'),json_extract(value,'$.createdAt') DESC,key) WHERE namespace='jobs';
      CREATE INDEX IF NOT EXISTS outbox_pending ON outbox(next_at,id) WHERE status='pending';
      CREATE INDEX IF NOT EXISTS outbox_chat_status ON outbox(chat_id,status,id);
    `);
    const outboxColumns = this.db.prepare("PRAGMA table_info(outbox)").all().map(row => String(row.name));
    if (!outboxColumns.includes("target_json")) this.db.exec("ALTER TABLE outbox ADD COLUMN target_json TEXT");
    if (!outboxColumns.includes("stats_text")) this.db.exec("ALTER TABLE outbox ADD COLUMN stats_text TEXT");
    if (!outboxColumns.includes("delivery_id")) this.db.exec("ALTER TABLE outbox ADD COLUMN delivery_id TEXT");
    if (!outboxColumns.includes("sent_at")) this.db.exec("ALTER TABLE outbox ADD COLUMN sent_at INTEGER");
    // Legacy sent rows have no confirmation time; give them a full retention period after upgrade.
    this.db.prepare("UPDATE outbox SET sent_at=? WHERE status='sent' AND sent_at IS NULL").run(Date.now());
    const assignDeliveryId = this.db.prepare("UPDATE outbox SET delivery_id=? WHERE id=?");
    for (const row of this.db.prepare("SELECT id FROM outbox WHERE delivery_id IS NULL").all()) assignDeliveryId.run(randomUUID(), row.id);
    this.db.exec("CREATE UNIQUE INDEX IF NOT EXISTS outbox_delivery_id ON outbox(delivery_id)");
    this.db.exec("CREATE INDEX IF NOT EXISTS outbox_sent_payload ON outbox(sent_at,id) WHERE status='sent' AND (text IS NOT NULL OR stats_text IS NOT NULL OR target_json IS NOT NULL OR error IS NOT NULL)");
    const inboxColumns = this.db.prepare("PRAGMA table_info(inbox)").all().map(row => String(row.name));
    if (!inboxColumns.includes("payload_json")) this.db.exec("ALTER TABLE inbox ADD COLUMN payload_json TEXT");
    // Only messages not yet dispatched to a command or model may be replayed.
    this.db.prepare("UPDATE inbox SET status='interrupted',payload_json=NULL WHERE status IN ('dispatching','running') OR (status IN ('received','queued') AND payload_json IS NULL)").run();
  }
  get<T>(namespace: string, key: string): T | undefined {
    const row = this.db.prepare("SELECT value FROM kv WHERE namespace=? AND key=?").get(namespace, key);
    return row ? JSON.parse(String(row.value)) as T : undefined;
  }
  set(namespace: string, key: string, value: unknown): void {
    this.db.prepare("INSERT INTO kv VALUES(?,?,?) ON CONFLICT(namespace,key) DO UPDATE SET value=excluded.value").run(namespace, key, JSON.stringify(value));
  }
  remove(namespace: string, key: string): void {
    this.db.prepare("DELETE FROM kv WHERE namespace=? AND key=?").run(namespace, key);
  }
  values<T>(namespace: string): T[] {
    return this.db.prepare("SELECT value FROM kv WHERE namespace=? ORDER BY key").all(namespace).map(row => JSON.parse(String(row.value)) as T);
  }
  entries<T>(namespace: string): { key: string; value: T }[] {
    return this.db.prepare("SELECT key,value FROM kv WHERE namespace=?").all(namespace)
      .map(row => ({ key: String(row.key), value: JSON.parse(String(row.value)) as T }));
  }
  jobsByStatus<T>(status: string, limit: number): T[] {
    if (limit === 0) return [];
    return this.db.prepare("SELECT value FROM kv WHERE namespace='jobs' AND json_extract(value,'$.status')=? ORDER BY json_extract(value,'$.createdAt'),key LIMIT ?")
      .all(status, limit).map(row => JSON.parse(String(row.value)) as T);
  }
  jobsForChat<T>(chatId: string, limit: number): T[] {
    return this.db.prepare("SELECT value FROM kv WHERE namespace='jobs' AND json_extract(value,'$.chatId')=? ORDER BY json_extract(value,'$.createdAt') DESC,key LIMIT ?")
      .all(chatId, limit).map(row => JSON.parse(String(row.value)) as T);
  }
  transaction<T>(operation: () => T): T {
    this.db.exec("BEGIN IMMEDIATE");
    try { const result = operation(); this.db.exec("COMMIT"); return result; }
    catch (error) { this.db.exec("ROLLBACK"); throw error; }
  }
  receive(id: string, chatId: string, payload: unknown): boolean {
    return Number(this.db.prepare("INSERT OR IGNORE INTO inbox(id,chat_id,status,updated_at,payload_json) VALUES(?,?,'received',?,?)")
      .run(id, chatId, Date.now(), JSON.stringify(payload)).changes) > 0;
  }
  pendingMessages<T>(): T[] {
    return this.db.prepare("SELECT payload_json FROM inbox WHERE status IN ('received','queued') AND payload_json IS NOT NULL ORDER BY updated_at,id")
      .all().map(row => JSON.parse(String(row.payload_json)) as T);
  }
  messageStatus(id: string, status: string): void {
    const finished = ["completed", "failed", "interrupted"].includes(status);
    this.db.prepare("UPDATE inbox SET status=?,updated_at=?,payload_json=CASE WHEN ? THEN NULL ELSE payload_json END WHERE id=?")
      .run(status, Date.now(), finished ? 1 : 0, id);
  }
  enqueue(chatId: string, text: string, target?: ReplyTarget, stats?: string): number {
    return Number(this.db.prepare("INSERT INTO outbox(chat_id,text,message_id,target_json,stats_text,delivery_id) VALUES(?,?,?,?,?,?)").run(chatId, text, target?.messageId ?? null, target ? JSON.stringify(target) : null, stats ?? null, randomUUID()).lastInsertRowid);
  }
  deliveries(): Delivery[] {
    return this.db.prepare("SELECT id,delivery_id,chat_id,text,stats_text,attempts,message_id,target_json FROM outbox WHERE status='pending' AND next_at<=? ORDER BY id LIMIT 10").all(Date.now()).map(row => ({ id: Number(row.id), deliveryId: String(row.delivery_id), chatId: String(row.chat_id), text: String(row.text), stats: row.stats_text ? String(row.stats_text) : undefined, attempts: Number(row.attempts), target: row.target_json ? JSON.parse(String(row.target_json)) as ReplyTarget : row.message_id ? { messageId: String(row.message_id), sequence: 0 } : undefined }));
  }
  delivered(id: number, messageId: string): void {
    this.db.prepare("UPDATE outbox SET status='sent',message_id=?,sent_at=COALESCE(sent_at,?),error=NULL WHERE id=? AND status='pending'").run(messageId, Date.now(), id);
  }
  /** A desktop receipt can arrive after the current attempt or all retries have timed out. */
  acknowledgeDelivery(chatId: string, deliveryId: string, messageId: string): void {
    this.db.prepare("UPDATE outbox SET status='sent',message_id=?,sent_at=COALESCE(sent_at,?),error=NULL WHERE chat_id=? AND delivery_id=? AND status IN ('pending','failed') AND (message_id IS NULL OR message_id=?)")
      .run(messageId, Date.now(), chatId, deliveryId, messageId);
  }
  deliveryPending(id: number): boolean {
    return !!this.db.prepare("SELECT 1 FROM outbox WHERE id=? AND status='pending'").get(id);
  }
  /** Keep delivery receipts while expiring only payloads confirmed as sent. */
  clearSentPayloads(cutoff: number): number {
    return Number(this.db.prepare("UPDATE outbox SET text=NULL,stats_text=NULL,target_json=NULL,error=NULL WHERE status='sent' AND sent_at<=? AND (text IS NOT NULL OR stats_text IS NOT NULL OR target_json IS NOT NULL OR error IS NOT NULL)")
      .run(cutoff).changes);
  }
  /** A failed card update or a long reply's second phase continues as a plain message. */
  deliverAsMessage(id: number, reason?: string): void {
    this.db.prepare("UPDATE outbox SET message_id=NULL,target_json=NULL,attempts=0,next_at=0,status='pending',error=? WHERE id=?")
      .run(reason?.slice(0, 1000) ?? null, id);
  }
  retry(item: Delivery, error: string): "pending" | "failed" | undefined {
    const attempts = item.attempts + 1;
    const status = attempts >= 8 ? "failed" : "pending";
    const changed = Number(this.db.prepare("UPDATE outbox SET attempts=?,next_at=?,status=?,error=? WHERE id=? AND status='pending'").run(attempts, Date.now() + Math.min(300_000, 2000 * 2 ** attempts), status, error.slice(0, 1000), item.id).changes) > 0;
    return changed ? status : undefined;
  }
  deliveryStatus(chatId: string): DeliveryStatus {
    const counts = this.db.prepare("SELECT status,COUNT(*) AS count FROM outbox WHERE chat_id=? GROUP BY status").all(chatId)
      .map(row => ({ status: String(row.status), count: Number(row.count) }));
    const failed = this.db.prepare("SELECT id,attempts FROM outbox WHERE chat_id=? AND status='failed' ORDER BY id LIMIT 20").all(chatId)
      .map(row => ({ id: Number(row.id), attempts: Number(row.attempts) }));
    return { counts, failed, failedHasMore: (counts.find(row => row.status === "failed")?.count ?? 0) > failed.length };
  }
  retryFailedDelivery(chatId: string, id: number): boolean {
    return Number(this.db.prepare("UPDATE outbox SET status='pending',attempts=0,next_at=0,error=NULL WHERE id=? AND chat_id=? AND status='failed'")
      .run(id, chatId).changes) > 0;
  }
  close(): void { this.db.close(); }
}
