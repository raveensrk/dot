// TODO Understand and improve this

import { unlinkSync } from "node:fs";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("delete-quit", {
		description: "Delete current session file and quit pi",
		handler: async (_name, ctx) => {
			const file = ctx.sessionManager.getSessionFile();
			try {
				unlinkSync(file);
			} catch (err) {
				ctx.ui.notify(`Delete failed: ${String(err)}`, "error");
				return;
			}
			ctx.shutdown();
		},
	});
}
