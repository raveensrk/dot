/**
 * Publishes Gemini / Antigravity subscription quota limits to the
 * "gemini-usage" status key so powerline (via powerline.customItems) can
 * show it on the secondary row.
 * Data: python3 ~/dot/script/gemini_usage.py --widget
 * Auth: Pi Antigravity OAuth from getApiKeyForProvider, passed as
 * PI_ANTIGRAVITY_ACCESS so near-expiry tokens are refreshed before the widget poll.
 */
import { execFile } from "node:child_process";
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "gemini_usage.py");
const FLAG = join(homedir(), ".local/share/gemini_usage/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "gemini-usage";

function geminiOn(): boolean {
	return !existsSync(FLAG);
}

function setGeminiOn(value: boolean): void {
	if (value) {
		if (existsSync(FLAG)) {
			unlinkSync(FLAG);
		}
		return;
	}
	mkdirSync(join(homedir(), ".local/share/gemini_usage"), { recursive: true });
	writeFileSync(FLAG, "");
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;

	async function getAuth(ctx: ExtensionContext): Promise<{ token?: string; projectId?: string }> {
		try {
			const raw = await ctx.modelRegistry.getApiKeyForProvider("antigravity");
			if (raw) {
				const parsed = JSON.parse(raw) as { token?: string; projectId?: string };
				return { token: parsed.token, projectId: parsed.projectId };
			}
		} catch {
			// fall back to reading ~/.pi/agent/auth.json in python
		}
		return {};
	}

	async function line(ctx: ExtensionContext): Promise<string | undefined> {
		if (!geminiOn()) {
			return undefined;
		}
		const auth = await getAuth(ctx);
		const env = { ...process.env };
		if (auth.token) {
			env.PI_ANTIGRAVITY_ACCESS = auth.token;
		}
		if (auth.projectId) {
			env.PI_ANTIGRAVITY_PROJECT = auth.projectId;
		}
		try {
			const { stdout } = await execFileAsync("python3", [BIN, "--widget"], {
				timeout: 20000,
				env,
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
		ctx.ui.setStatus(KEY, await line(ctx));
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

	pi.registerCommand("gemini-usage", {
		description: "Enable or disable Gemini usage limits on the powerline",
		getArgumentCompletions: (prefix) => {
			return ["on", "off"]
				.filter((value) => value.startsWith(prefix))
				.map((value) => ({ value, label: value }));
		},
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			if (arg !== "on" && arg !== "off") {
				ctx.ui.notify("Usage: /gemini-usage on|off", "error");
				return;
			}
			const on = arg === "on";
			setGeminiOn(on);
			await refresh(ctx);
			if (on) {
				start(ctx);
				ctx.ui.notify("Gemini powerline on", "info");
				return;
			}
			stop();
			ctx.ui.notify("Gemini powerline off", "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		await refresh(ctx);
		if (geminiOn()) {
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
