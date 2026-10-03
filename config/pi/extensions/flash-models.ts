/**
 * Two slash commands that switch this session to a flash model at max reasoning:
 *   /deepseek-v4.1-flash-max  -> openrouter/deepseek/deepseek-v4.1-flash
 *   /glm-5.3-flash-max        -> openrouter/z-ai/glm-5.3-flash
 * Session only; the configured default model in settings.json is unchanged.
 */
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

const PROVIDER = "openrouter";
const EFFORT = "max";

const COMMANDS: Array<{ name: string; modelId: string }> = [
	{ name: "deepseek-v4.1-flash-max", modelId: "deepseek/deepseek-v4.1-flash" },
	{ name: "glm-5.3-flash-max", modelId: "z-ai/glm-5.3-flash" },
];

export default function (pi: ExtensionAPI) {
	for (const { name, modelId } of COMMANDS) {
		pi.registerCommand(name, {
			description: `Switch to ${PROVIDER}/${modelId} at ${EFFORT} reasoning`,
			handler: async (_args, ctx: ExtensionCommandContext) => {
				const model = ctx.modelRegistry.find(PROVIDER, modelId);
				if (!model) {
					ctx.ui.notify(`Model not found: ${PROVIDER}/${modelId}`, "error");
					return;
				}
				if (!(await pi.setModel(model))) {
					ctx.ui.notify(`No credentials for provider ${PROVIDER}`, "error");
					return;
				}
				pi.setThinkingLevel(EFFORT);
				ctx.ui.notify(`${PROVIDER}/${modelId} at ${pi.getThinkingLevel()}`, "info");
			},
		});
	}
}
