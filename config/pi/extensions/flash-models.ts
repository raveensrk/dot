/**
 * Slash commands that switch this session to a model at a fixed reasoning effort:
 *   /openrouter-deepseek-v4.1-flash-max -> openrouter/deepseek/deepseek-v4.1-flash
 *   /openrouter-glm-5.3-flash-max       -> openrouter/z-ai/glm-5.3-flash
 *   /openai-codex-gpt-6.1-sol-low       -> openai-codex/gpt-6.1-sol
 *   /openai-codex-gpt-6-luna-max        -> openai-codex/gpt-6-luna
 *   /openrouter-opus-5.5-low            -> openrouter/anthropic/claude-opus-5.5
 * Session only; the configured default model in settings.json is unchanged.
 */
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const COMMANDS: Array<{ name: string; provider: string; modelId: string; effort: string }> = [
	{ name: "openrouter-deepseek-v4.1-flash-max", provider: "openrouter", modelId: "deepseek/deepseek-v4.1-flash", effort: "max" },
	{ name: "openrouter-glm-5.3-flash-max", provider: "openrouter", modelId: "z-ai/glm-5.3-flash", effort: "max" },
	{ name: "openai-codex-gpt-6.1-sol-low", provider: "openai-codex", modelId: "gpt-6.1-sol", effort: "low" },
	{ name: "openai-codex-gpt-6-luna-max", provider: "openai-codex", modelId: "gpt-6-luna", effort: "max" },
	{ name: "openrouter-opus-5.5-low", provider: "openrouter", modelId: "anthropic/claude-opus-5.5", effort: "low" },
];

export default function (pi: ExtensionAPI) {
	for (const { name, provider, modelId, effort } of COMMANDS) {
		pi.registerCommand(name, {
			description: `Switch to ${provider}/${modelId} at ${effort} reasoning`,
			handler: async (_args, ctx: ExtensionCommandContext) => {
				const model = ctx.modelRegistry.find(provider, modelId);
				if (!model) {
					ctx.ui.notify(`Model not found: ${provider}/${modelId}`, "error");
					return;
				}
				if (!(await pi.setModel(model))) {
					ctx.ui.notify(`No credentials for provider ${provider}`, "error");
					return;
				}
				pi.setThinkingLevel(effort);
				ctx.ui.notify(`${provider}/${modelId} at ${pi.getThinkingLevel()}`, "info");
			},
		});
	}
}
