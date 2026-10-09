/**
 * Publishes SuperGrok credit usage to the "grok-credits" status key so
 * powerline (via powerline.customItems) can show it on the secondary row.
 * Data: python3 ~/dot/script/grok_credits.py --widget
 * Auth: Pi xAI OAuth from getProviderAuth, passed as PI_XAI_ACCESS so a
 * near-expiry token is refreshed before the widget poll. Cookie/HAR stays
 * the script fallback when that call has no OAuth bearer.
 */
import { execFile } from "node:child_process";
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "grok_credits.py");
const FLAG = join(homedir(), ".local/share/grok_credits/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "grok-credits";

function grokOn(): boolean {
	return !existsSync(FLAG);
}

function setGrokOn(value: boolean): void {
	if (value) {
		if (existsSync(FLAG)) {
			unlinkSync(FLAG);
		}
		return;
	}
	mkdirSync(join(homedir(), ".local/share/grok_credits"), { recursive: true });
	writeFileSync(FLAG, "");
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;

	async function oauthToken(ctx: ExtensionContext): Promise<string | undefined> {
		try {
			const result = await ctx.modelRegistry.getProviderAuth("xai");
			if (result?.source === "OAuth" && result.auth.apiKey) {
				return result.auth.apiKey;
			}
		} catch {
			return undefined;
		}
		return undefined;
	}

	async function line(ctx: ExtensionContext): Promise<string | undefined> {
		if (!grokOn()) {
			return undefined;
		}
		const token = await oauthToken(ctx);
		const env = { ...process.env };
		if (token) {
			env.PI_XAI_ACCESS = token;
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

	pi.registerCommand("grok-credits", {
		description: "Enable or disable Grok usage on the powerline",
		getArgumentCompletions: (prefix) => {
			return ["on", "off"]
				.filter((value) => value.startsWith(prefix))
				.map((value) => ({ value, label: value }));
		},
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			if (arg !== "on" && arg !== "off") {
				ctx.ui.notify("Usage: /grok-credits on|off", "error");
				return;
			}
			const on = arg === "on";
			setGrokOn(on);
			await refresh(ctx);
			if (on) {
				start(ctx);
				ctx.ui.notify("Grok powerline on", "info");
				return;
			}
			stop();
			ctx.ui.notify("Grok powerline off", "info");
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		await refresh(ctx);
		if (grokOn()) {
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
