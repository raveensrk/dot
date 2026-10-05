import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const KEY = "openai-usage";

export default function (pi: ExtensionAPI) {
	let restore: (() => void) | undefined;

	pi.on("session_start", (_event, ctx) => {
		restore?.();
		restore = undefined;
		if (!ctx.hasUI) return;

		// Pi shares this UI object across extensions; relay only authenticated OpenAI usage.
		const ui = ctx.ui;
		const set = ui.setStatus;
		const wrapped: typeof set = (key, text) => {
			set.call(ui, key, text);
			if (key !== "usage") return;

			const model = ctx.model;
			// ponytail: upstream text markers; use structured status if pi-usage adds it.
			const value = model &&
				(model.provider === "openai" || model.provider === "openai-codex") &&
				ctx.modelRegistry.isUsingOAuth(model) &&
				text !== "checking" && text !== "auth unavailable" &&
				!text?.startsWith("usage err:") ? text : undefined;
			set.call(ui, KEY, value);
		};
		ui.setStatus = wrapped;
		set.call(ui, KEY, undefined);
		restore = () => {
			set.call(ui, KEY, undefined);
			if (ui.setStatus === wrapped) ui.setStatus = set;
		};
	});

	pi.on("session_shutdown", () => {
		restore?.();
		restore = undefined;
	});
}
