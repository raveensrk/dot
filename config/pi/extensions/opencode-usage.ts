/**
 * Publishes opencode Go plan windows and the Zen wallet balance to the
 * "oc-usage" status key so powerline (via powerline.customItems) can show it
 * on the secondary row.
 * Data: python3 ~/dot/script/opencode_usage.py
 */
import { execFile } from "node:child_process";
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "opencode_usage.py");
const FLAG = join(homedir(), ".local/share/opencode_usage/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "oc-usage";

function opencodeOn(): boolean {
	return !existsSync(FLAG);
}

function setOpencodeOn(value: boolean): void {
	if (value) {
		if (existsSync(FLAG)) {
			unlinkSync(FLAG);
		}
		return;
	}
	mkdirSync(join(homedir(), ".local/share/opencode_usage"), { recursive: true });
	writeFileSync(FLAG, "");
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;

	async function line(): Promise<string | undefined> {
		if (!opencodeOn()) {
			return undefined;
		}
		try {
			const { stdout } = await execFileAsync("python3", [BIN], {
				timeout: 20000,
			});
			const text = stdout.trim();
			return text || undefined;
		} catch {
			return undefined;
		}
	}

	async function refresh(ctx: ExtensionContext): Promise<void> {
		if (!ctx.hasUI) {
			return;
		}
		ctx.ui.setStatus(KEY, await line());
	}

	function start(ctx: ExtensionContext): void {
		if (timer) {
			clearInterval(timer);
		}
		timer = setInterval(() => {
			void refresh(ctx);
		}, INTERVAL_MS);
		timer.unref?.();
	}

	function stop(): void {
		if (!timer) {
			return;
		}
		clearInterval(timer);
		timer = undefined;
	}

	pi.registerCommand("opencode-usage", {
		description: "Enable or disable opencode Go and Zen usage on the powerline",
		getArgumentCompletions: (prefix) => {
			return ["on", "off"]
				.filter((value) => value.startsWith(prefix))
				.map((value) => ({ value, label: value }));
		},
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			if (arg !== "on" && arg !== "off") {
				ctx.ui.notify("Usage: /opencode-usage on|off", "error");
				return;
			}
			const on = arg === "on";
			setOpencodeOn(on);
			await refresh(ctx);
			if (on) {
				start(ctx);
				ctx.ui.notify("opencode powerline on", "info");
				return;
			}
			stop();
			ctx.ui.notify("opencode powerline off", "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		await refresh(ctx);
		if (opencodeOn()) {
			start(ctx);
		}
	});

	pi.on("session_shutdown", (_event, ctx) => {
		stop();
		if (ctx.hasUI) {
			ctx.ui.setStatus(KEY, undefined);
		}
	});
}
