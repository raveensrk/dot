import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

function showName(ctx: ExtensionContext, name: string | undefined) {
	if (!ctx.hasUI) return;
	ctx.ui.setWidget("session-name", [name ?? "(unnamed)"], { placement: "belowEditor" });
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (event, ctx) => {
		if (ctx.hasUI && (event.reason === "startup" || event.reason === "new") && !pi.getSessionName()) {
			for (;;) {
				const raw = await ctx.ui.input("Name this session", "required");
				if (raw === undefined) {
					ctx.shutdown();
					return;
				}
				const name = raw.trim();
				if (name) {
					pi.setSessionName(name);
					break;
				}
				ctx.ui.notify("Session name required", "warning");
			}
		}
		showName(ctx, pi.getSessionName());
	});

	pi.on("session_info_changed", (event, ctx) => {
		showName(ctx, event.name);
	});
}
