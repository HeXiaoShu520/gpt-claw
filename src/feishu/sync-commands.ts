import { readConfig } from "../config.ts";
import { commands } from "../app/commands.ts";
import { botClient } from "./client.ts";
import { syncSlashCommands } from "./slash-commands.ts";
import { errorMessage, log } from "../shared/log.ts";

/** Explicit menu synchronization without starting the gateway or requesting a model. */
async function main(): Promise<void> {
  const config = readConfig();
  if (!config.appId || !config.appSecret) throw new Error("请先配置飞书机器人，再同步 / 面板");
  const result = await syncSlashCommands(botClient(config), commands);
  log.info(`飞书 / 面板同步完成：新增 ${result.created}，更新 ${result.updated}，移除旧命令 ${result.removed}，一致 ${result.unchanged}；客户端可能需约 5 分钟刷新`);
}
main().catch(error => {
  log.error(`${errorMessage(error)}；请确认 application:app_slash_command:read / write 权限已开通并发布`);
  process.exitCode = 1;
});
