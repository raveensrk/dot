import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync, realpathSync } from "node:fs";
import { dirname, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Same marker the installer writes into the bundle chunk Pi actually loads.
const MARK = "function formatTimeout(";
const CMD = "install_pi_timeout_label.py";

function bundleHasPatch(): boolean {
	let cli: string;
	try {
		const bin = execFileSync("which", ["pi"], { encoding: "utf8" }).trim();
		cli = realpathSync(bin);
	} catch {
		return true;
	}

	const chunks = join(dirname(cli), "chunks");
	let names: string[];
	try {
		names = readdirSync(chunks);
	} catch {
		return true;
	}

	for (const name of names) {
		if (!name.endsWith(".js")) continue;
		if (readFileSync(join(chunks, name), "utf8").includes(MARK)) return true;
	}
	return false;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (!ctx.hasUI) return;
		if (bundleHasPatch()) return;
		const line = `Pi upgrade dropped the timeout label patch. Run ${CMD}`;
		ctx.ui.notify(line, "warning");
		ctx.ui.setWidget("pi-timeout-patch", [line], { placement: "aboveEditor" });
	});
}
