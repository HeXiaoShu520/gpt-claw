import { randomUUID } from "node:crypto";
import { copyFile, mkdir, realpath } from "node:fs/promises";
import { basename, isAbsolute, join, relative } from "node:path";
import { sanitizeFileName } from "../shared/paths.ts";
import type { Store } from "../storage.ts";

/** One stable file directory per active conversation or background job. */
export class SessionFiles {
  constructor(readonly workspace: string, private readonly store: Store) {}

  id(sessionKey: string): string {
    const saved = this.store.get<{ id: string }>("file-sessions", sessionKey)?.id;
    if (saved) return saved;
    const id = randomUUID();
    this.store.set("file-sessions", sessionKey, { id });
    return id;
  }

  directory(sessionKey: string): string { return join(this.workspace, this.id(sessionKey)); }
  artifacts(sessionKey: string): string { return join(this.directory(sessionKey), "artifacts"); }
  inbound(sessionKey: string): string { return join(this.directory(sessionKey), "inbound"); }
  reset(sessionKey: string): void { this.store.remove("file-sessions", sessionKey); }

  /** Keep a delivered file in the session that sent it, without changing its source. */
  async stage(sessionKey: string, path: string): Promise<string> {
    const source = await realpath(path);
    const directory = this.artifacts(sessionKey);
    const rel = relative(directory, source);
    if (rel && !rel.startsWith("..") && !isAbsolute(rel)) return source;
    await mkdir(directory, { recursive: true });
    const target = join(directory, `${randomUUID()}-${sanitizeFileName(basename(source))}`);
    await copyFile(source, target);
    return target;
  }
}
