import type { Prompt, PromptResult } from "../app/ports.ts";

const plain = (value: string) => value.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const markdown = (content: string) => ({ tag: "markdown", content });

function field(label: string, value: string, code: boolean) {
  const limited = value.length > 5000 ? `${value.slice(0, 5000)}\n…（内容过长，已截断显示）` : value;
  const safe = plain(limited);
  return markdown(`**${plain(label)}**\n${code ? `\`\`\`text\n${safe.replace(/`/g, "&#96;")}\n\`\`\`` : safe}`);
}

function choiceRows(prompt: Prompt, token: string) {
  const choices = (prompt.choices || []).slice(0, 12);
  const rows = [];
  for (let index = 0; index < choices.length; index += 2) {
    rows.push({
      tag: "column_set", flex_mode: "none", horizontal_spacing: "8px",
      columns: choices.slice(index, index + 2).map((choice, offset) => ({
        tag: "column", width: "weighted", weight: 1,
        elements: [{
          tag: "button", text: { tag: "plain_text", content: choice.label.slice(0, 60) },
          type: index + offset === 0 ? "primary_filled" : ["拒绝", "取消"].includes(choice.label) ? "danger" : "default",
          width: "fill",
          behaviors: [{ type: "callback", value: { gpt_claw_token: token, answer: choice.value } }],
        }],
      })),
    });
  }
  return rows;
}

/** Card 2.0 approval layout. Keep the request visible after the decision, but remove its buttons. */
export function promptCard(prompt: Prompt, token?: string, result?: PromptResult) {
  const elements: unknown[] = [];
  elements.push(markdown(`${prompt.fields?.length ? "**请求说明**\n" : ""}${plain(prompt.detail.slice(0, 3000))}`));
  if (prompt.fields?.length) {
    elements.push({ tag: "hr" });
    elements.push({
      tag: "column_set", flex_mode: "none",
      columns: [{
        tag: "column", width: "weighted", weight: 1, background_style: "grey-50", padding: "12px", vertical_spacing: "8px",
        elements: prompt.fields.map(item => field(item.label, item.value, !!item.code)),
      }],
    });
  }
  if (token && prompt.choices?.some(choice => ["accept", "allow"].includes(choice.value))) {
    elements.push(markdown("<font color='grey'>请核对操作内容和授权范围；拒绝或超时不会放行。</font>"));
  }
  if (token && prompt.allowText) elements.push(markdown(`也可以发送：\`/answer ${token} 你的回答\``));
  if (token) elements.push(...choiceRows(prompt, token));

  return {
    schema: "2.0",
    config: { update_multi: true, width_mode: "default", summary: { content: result ? result.text : `需要确认：${prompt.title}` } },
    header: {
      title: { tag: "plain_text", content: prompt.title.slice(0, 80) },
      subtitle: { tag: "plain_text", content: result?.text || "等待你的决定" },
      template: result ? ({ success: "green", danger: "red", neutral: "grey" } as const)[result.tone] : prompt.fields?.length ? "orange" : "blue",
      icon: { tag: "standard_icon", token: prompt.fields?.length ? "approval_colorful" : "ai-common_colorful" },
    },
    body: { direction: "vertical", padding: "12px 12px 20px 12px", vertical_spacing: "12px", elements },
  };
}
