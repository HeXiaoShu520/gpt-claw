import { Client, Domain, LoggerLevel } from "@larksuiteoapi/node-sdk";

/** SDK requests use this bot application's tenant identity. */
export function botClient(config: { appId: string; appSecret: string; domain: string }): Client {
  return new Client({ appId: config.appId, appSecret: config.appSecret, loggerLevel: LoggerLevel.error,
    domain: config.domain === "lark" ? Domain.Lark : Domain.Feishu });
}
