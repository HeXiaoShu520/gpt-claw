import { join } from "node:path";

type ApiKind = "openai" | "deepseek" | "custom";
export interface ApiConfig { kind: ApiKind; key: string; baseUrl: string; providerId: string; }
export interface ModelConfig { model?: string; api?: ApiConfig; }
const providerKeyEnv = "GPT_CLAW_PROVIDER_API_KEY";

/** Environment convenience settings; Codex still owns inference and provider authentication. */
export function modelConfig(env: NodeJS.ProcessEnv): ModelConfig {
  const model = env.MODEL_NAME?.trim() || undefined;
  const genericKey = env.MODEL_API_KEY?.trim() || "";
  const deepseekKey = env.DEEPSEEK_API_KEY?.trim() || "";
  const address = env.MODEL_BASE_URL?.trim() || "";
  if (genericKey && deepseekKey) throw new Error("MODEL_API_KEY 与 DEEPSEEK_API_KEY 只能填写一个");
  if (!genericKey && !deepseekKey && !address) return { model };
  const key = deepseekKey || genericKey;
  if (!key) throw new Error("API 模式需要 MODEL_API_KEY 或 DEEPSEEK_API_KEY");
  let url: URL;
  try { url = new URL(address || (deepseekKey ? "https://api.deepseek.com" : "https://api.openai.com/v1")); }
  catch { throw new Error("MODEL_BASE_URL 必须是有效的 HTTP(S) API 根地址"); }
  if (!["https:", "http:"].includes(url.protocol) || url.username || url.password || url.search || url.hash) {
    throw new Error("MODEL_BASE_URL 需为 HTTP(S) API 根地址，不包含账号、查询参数或片段");
  }
  if (/\/(responses|chat\/completions)\/?$/.test(url.pathname)) throw new Error("MODEL_BASE_URL 请填写 API 根地址，不要包含 /responses 或 /chat/completions");
  const inferred = url.hostname === "api.deepseek.com" ? "deepseek" : url.hostname === "api.openai.com" ? "openai" : "custom";
  const kind: ApiKind = deepseekKey ? "deepseek" : inferred;
  if (kind === "custom" && !model) throw new Error("第三方 API 模式需要 MODEL_NAME（服务端的模型名称）");
  return {
    model: model || (kind === "deepseek" ? "deepseek-flash" : undefined),
    api: { kind, key, baseUrl: url.toString().replace(/\/+$/, ""), providerId: kind === "openai" ? "openai" : "gpt_claw_api" },
  };
}

/** Session overrides carry no secrets; custom-provider keys live only in the Codex process. */
export function providerProcess(config: ModelConfig, root: string): { args: string[]; env: NodeJS.ProcessEnv } {
  const api = config.api;
  if (!api) return { args: [], env: {} };
  const values: Record<string, string | boolean> = { model_provider: api.providerId, cli_auth_credentials_store: "ephemeral" };
  const env: NodeJS.ProcessEnv = {};
  if (api.kind === "openai") values.openai_base_url = api.baseUrl;
  else {
    const prefix = `model_providers.${api.providerId}`;
    Object.assign(values, {
      [`${prefix}.name`]: api.kind === "deepseek" ? "DeepSeek" : "Custom Responses API",
      [`${prefix}.base_url`]: api.baseUrl, [`${prefix}.wire_api`]: "responses",
      [`${prefix}.env_key`]: providerKeyEnv, [`${prefix}.requires_openai_auth`]: false,
      [`${prefix}.supports_websockets`]: false, web_search: "disabled",
      // Remove the provider key from native tool subprocesses, even with inherit=all.
      [`shell_environment_policy.set.${providerKeyEnv}`]: "",
    });
    env[providerKeyEnv] = api.key;
    if (api.kind === "deepseek") {
      values.model_catalog_json = join(root, ".codex/models/deepseek.json");
      values.model_supports_reasoning_summaries = true;
      values["features.code_mode.enabled"] = false;
    }
  }
  if (config.model) values.model = config.model;
  return { args: Object.entries(values).flatMap(([key, value]) => ["-c", `${key}=${JSON.stringify(value)}`]), env };
}
