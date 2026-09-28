/**
 * Publishes the actually-used model to the "active-model" status key so
 * powerline (via powerline.customItems) can show it. Resolves openrouter/auto
 * etc. via AssistantMessage.responseModel, which providers return when they
 * respond with a different model than requested (routing / fallback).
 * Only shows when the model provider wins the widget gate (i.e. not grok/opencode).
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { widgetFor } from "./shared/widget-gate.ts";

const KEY = "active-model";

export default function (pi: ExtensionAPI) {
	let provider: string | undefined;

	function show(ctx: ExtensionContext, model: string | undefined): void {
		if (!ctx.hasUI) return;
		if (widgetFor(provider) !== "model" || !model) {
			ctx.ui.setStatus(KEY, undefined);
			return;
		}
		ctx.ui.setStatus(KEY, model);
	}

	// Reset to the requested model when user switches (before first response lands)
	pi.on("model_select", async (_event, ctx) => {
		provider = _event.model.provider;
		show(ctx, `${_event.model.provider}/${_event.model.id}`);
	});

	pi.on("message_end", async (event, ctx) => {
		const msg = event.message as any;
		if (msg.role !== "assistant") return;
		provider = msg.provider ?? (String(msg.model ?? "").split("/")[0] || undefined);
		const used = msg.responseModel || msg.model;
		if (!used) return;
		show(ctx, used);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.hasUI) ctx.ui.setStatus(KEY, undefined);
	});
}