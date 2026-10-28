import type { Client } from "@larksuiteoapi/node-sdk";
import { retiredCommands, type CommandDefinition } from "../app/commands.ts";

const endpoint = "/open-apis/application/v7/app_slash_commands";
interface Description { default_value: string; i18n?: Record<string, string>; }
interface RegisteredCommand { command_id: string; command: string; description: Description; }
interface Response { code?: number; data?: { items?: RegisteredCommand[] }; }
export interface CommandSyncResult { created: number; updated: number; unchanged: number; removed: number; }

/** Synchronize active commands and remove retired menu entries with the bot SDK. */
export async function syncSlashCommands(client: Client, commands: readonly CommandDefinition[], signal?: AbortSignal): Promise<CommandSyncResult> {
  async function request(method: "GET" | "POST" | "PATCH" | "DELETE", url: string, data?: unknown): Promise<Response> {
    signal?.throwIfAborted();
    let response: Response;
    try { response = await client.request<Response>({ method, url, data, signal, timeout: 15_000 }); }
    catch { signal?.throwIfAborted(); throw new Error("飞书 / 面板接口请求失败；请检查应用凭证和网络"); }
    if (response.code !== 0) throw new Error(`飞书 / 面板接口返回错误码 ${response.code ?? "未知"}`);
    return response;
  }
  const list = await request("GET", endpoint);
  if (!Array.isArray(list.data?.items)) throw new Error("飞书 / 面板列表格式不可读，未继续注册");
  const existing = new Map<string, RegisteredCommand>();
  for (const item of list.data.items) {
    if (typeof item.command !== "string" || typeof item.command_id !== "string" || !item.command_id) throw new Error("飞书 / 面板返回无效命令，未继续注册");
    existing.set(item.command, item);
  }
  const result: CommandSyncResult = { created: 0, updated: 0, unchanged: 0, removed: 0 };
  for (const command of commands) {
    const current = existing.get(command.name);
    const description: Description = { default_value: command.description,
      i18n: { ...current?.description?.i18n, zh_cn: command.description, en_us: command.english } };
    if (!current) {
      await request("POST", endpoint, { command: command.name, description }); result.created++;
    } else if (current.description?.default_value !== description.default_value
      || current.description.i18n?.zh_cn !== description.i18n!.zh_cn || current.description.i18n?.en_us !== description.i18n!.en_us) {
      await request("PATCH", `${endpoint}/${encodeURIComponent(current.command_id)}`, { description }); result.updated++;
    } else result.unchanged++;
  }
  for (const name of retiredCommands) {
    const old = existing.get(name);
    if (!old) continue;
    await request("DELETE", `${endpoint}/${encodeURIComponent(old.command_id)}`);
    result.removed++;
  }
  return result;
}
