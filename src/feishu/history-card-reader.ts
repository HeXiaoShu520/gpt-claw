import { Client, LoggerLevel } from "@larksuiteoapi/node-sdk";
import { join } from "node:path";
import {
  cardMentionIds,
  cardMentionNames,
  cardReferenceId,
  cardVisibleText,
  expandCardMentions,
} from "./inbound-content.ts";
import { UserProfiles } from "./profiles.ts";

interface MessageItem {
  body?: { content?: string };
  mentions?: Array<{ name?: string; id?: { open_id?: string } | string }>;
}

/** Read cards with this bot's application credentials, never a local CLI user. */
export function createHistoryCardReader(options: {
  dataDir: string;
  appId: string;
  appSecret: string;
  botOpenId?: string;
  client?: Client;
  resolveName?: (openId: string) => Promise<string | undefined>;
}): (messageId: string) => Promise<string | undefined> {
  const botClient = options.client ?? new Client({
        appId: options.appId,
        appSecret: options.appSecret,
        loggerLevel: LoggerLevel.error,
      });
  const profiles = new UserProfiles(
    options.appId,
    join(options.dataDir, "users"),
  );
  const get = async (path: string): Promise<Record<string, unknown>> => {
    return (await botClient.request({ method: "GET", url: path })) as Record<
      string,
      unknown
    >;
  };
  return async (messageId: string) => {
    if (!/^om_[A-Za-z0-9_-]+$/.test(messageId)) return undefined;
    const response = await get(
      `/open-apis/im/v1/messages/${encodeURIComponent(messageId)}?card_msg_content_type=user_card_content`,
    );
    if (response.code !== 0)
      throw new Error(`卡片消息读取失败：${String(response.code)}`);
    const data = response.data as { items?: MessageItem[] } | undefined;
    const item = data?.items?.find((entry) => Boolean(entry.body?.content));
    const content = item?.body?.content;
    if (!content) return undefined;
    let visible = cardVisibleText(content);
    const cardId = cardReferenceId(content);
    if (!visible && cardId && /^[A-Za-z0-9_-]+$/.test(cardId)) {
      const card = await get(
        `/open-apis/cardkit/v1/cards/${encodeURIComponent(cardId)}`,
      );
      if (card.code === 0) {
        const cardData = card.data as { card?: unknown } | undefined;
        visible = cardVisibleText(
          JSON.stringify(cardData?.card ?? cardData ?? {}),
        );
      }
    }
    if (!visible) return undefined;
    const names = cardMentionNames(content);
    for (const mention of item.mentions ?? []) {
      const id =
        typeof mention.id === "string" ? mention.id : mention.id?.open_id;
      if (id && id !== options.botOpenId && mention.name)
        names.set(id, mention.name);
    }
    const ids = cardMentionIds(visible, options.botOpenId);
    await Promise.all(
      ids.map(async (id) => {
        const profile = await profiles.getUserProfile(id);
        if (profile.name || profile.en_name)
          names.set(id, profile.name || profile.en_name || id);
        else if (!names.has(id) && options.resolveName) {
          const name = await options.resolveName(id);
          if (name && name !== id) names.set(id, name);
        }
      }),
    );
    return expandCardMentions(visible, names, options.botOpenId);
  };
}
