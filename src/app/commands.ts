/** The implemented command catalog, shared by dispatch, help and channel menus. */
export const commands = [
  { name: "help", description: "查看使用说明和全部命令", english: "Show help and available commands", arguments: "" },
  { name: "status", description: "查看当前会话、队列、投递状态和失败投递编号", english: "Show session, queue, delivery status and failed delivery IDs", arguments: "" },
  { name: "model", description: "立即查看当前模型和推理档位，不调用模型", english: "Show active model and reasoning effort without a model call", arguments: "" },
  { name: "retry", description: "手动重投失败回复（需投递编号；不会重跑任务）", english: "Retry a failed reply delivery by ID, without rerunning its task", arguments: "投递编号" },
  { name: "stop", description: "中断当前对话任务并清空队列", english: "Stop the current conversation task and clear its queue", arguments: "" },
  { name: "new", description: "开始新会话，保留旧会话历史", english: "Start a new conversation while keeping previous history", arguments: "" },
  { name: "compact", description: "压缩当前会话上下文", english: "Compact the current conversation context", arguments: "" },
  { name: "steer", description: "给正在执行的任务追加指令（需补充内容）", english: "Add instructions to the running task; provide instruction text", arguments: "补充内容" },
  { name: "jobs", description: "查看本聊天的后台任务", english: "List background jobs for this chat", arguments: "" },
  { name: "schedules", description: "查看本聊天的定时任务", english: "List scheduled tasks for this chat", arguments: "" },
  { name: "answer", description: "回答确认卡问题（需请求编号和回答）", english: "Answer a pending question; provide request ID and answer", arguments: "请求编号 回答" },
] as const;

/** Legacy menu entries owned by this project; remove them during the next sync. */
export const retiredCommands = ["learn", "reflect", "recovery"] as const;

export type CommandDefinition = typeof commands[number];
export type CommandName = CommandDefinition["name"] | typeof retiredCommands[number];
export function parseCommand(text: string): { name: CommandName; arguments: string } | undefined {
  const match = /^\/([a-z]+)(?:\s+([\s\S]*))?$/.exec(text.trim());
  if (!match) return undefined;
  const definition = commands.find(command => command.name === match[1]);
  if (definition) return { name: definition.name, arguments: match[2]?.trim() || "" };
  return retiredCommands.some(name => name === match[1])
    ? { name: match[1] as typeof retiredCommands[number], arguments: match[2]?.trim() || "" } : undefined;
}
export function commandUsage(name: CommandDefinition["name"]): string {
  const command = commands.find(command => command.name === name)!;
  return `/${command.name}${command.arguments ? ` ${command.arguments}` : ""}`;
}
export function commandHelp(): string {
  return commands.map(command => `${commandUsage(command.name)}：${command.description}`).join("\n")
    + "\n\n普通消息按聊天排队；群聊普通消息需要 @机器人。后台和定时任务可以直接用自然语言要求创建。";
}
