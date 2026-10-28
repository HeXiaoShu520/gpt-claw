import { realpath, stat } from "node:fs/promises";
import { isAbsolute, relative, resolve } from "node:path";

export const sanitizeFileName = (name: string) => name.replace(/[<>:"/\\|?*\x00-\x1f]/g, "_").slice(0, 180) || "attachment";

/** Resolve symlinks as well as '..' before delivering a local artifact. */
export async function artifactPath(root: string, value: string): Promise<string> {
  const base = await realpath(root);
  const file = await realpath(resolve(root, value));
  const rel = relative(base, file);
  if (!rel || rel.startsWith("..") || isAbsolute(rel)) throw new Error("文件必须在工作区内");
  if (rel.split(/[\\/]/).some(part => part.startsWith(".") || /^(auth|credentials|secrets)(\.|$)/i.test(part))) throw new Error("不能发送隐藏文件或凭证文件");
  const info = await stat(file);
  if (!info.isFile() || info.size > 25 * 1024 * 1024) throw new Error("只支持发送不超过 25 MiB 的文件");
  return file;
}
