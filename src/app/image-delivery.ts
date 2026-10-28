import { realpath, stat } from "node:fs/promises";
import { extname } from "node:path";
import type { Channel } from "./ports.ts";
import type { SessionFiles } from "../services/session-files.ts";

/** Archive and deliver a native Codex image as soon as the file exists. */
export async function deliverGeneratedImage(files: SessionFiles, channel: Channel, chatId: string, sessionKey: string, path: string): Promise<string> {
  const source = await realpath(path);
  const extension = extname(source).toLowerCase();
  const file = await stat(source);
  if (![".png", ".jpg", ".jpeg", ".webp"].includes(extension) || !file.isFile()) throw new Error("生成图片的格式不受支持");
  if (file.size > 30_000_000) throw new Error("生成图片超过飞书文件 30 MB 上限");
  const destination = await files.stage(sessionKey, source);
  return channel.sendFile(chatId, destination);
}
