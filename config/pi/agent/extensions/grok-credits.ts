import { execFile } from "node:child_process";
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "grok_credits.py");
const FLAG = join(homedir(), ".local/share/grok_credits/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "status-widget";

type Ui = {
	hasUI: boolean;
	ui: {
		setWidget: (
			key: string,
			lines: string[] | undefined,
			opts?: { placement?: "aboveEditor" | "belowEditor" },
		) => void;
		notify: (text: string, level?: string) => void;
	};
};

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

function hide(ctx: Ui): void {
	if (!ctx.hasUI) {
		return;
	}
	ctx.ui.setWidget(KEY, undefined);
}

function paint(ctx: Ui, grok: string | undefined): void {
	if (!ctx.hasUI) {
		return;
	}
	if (!grok) {
		hide(ctx);
		return;
	}
	ctx.ui.setWidget(KEY, [grok], { placement: "belowEditor" });
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;

	function stop(): void {
		if (!timer) {
			return;
		}
		clearInterval(timer);
		timer = undefined;
	}

	function start(ctx: Ui): void {
		stop();
		timer = setInterval(() => {
			void refresh(ctx);
		}, INTERVAL_MS);
		timer.unref?.();
	}

	async function grokLine(): Promise<string | undefined> {
		if (!grokOn()) {
			return undefined;
		}
		try {
			const { stdout } = await execFileAsync("python3", [BIN, "--widget"], {
				timeout: 20000,
			});
			const line = stdout.trim();
			return line || undefined;
		} catch {
			return undefined;
		}
	}

	async function refresh(ctx: Ui): Promise<void> {
		if (!ctx.hasUI) {
			return;
		}
		paint(ctx, await grokLine());
	}

	pi.registerCommand("grok-credits", {
		description: "Enable or disable Grok usage in the status widget",
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
			const value = arg === "on";
			setGrokOn(value);
			await refresh(ctx);
			if (value) {
				start(ctx);
				ctx.ui.notify("Grok widget on", "info");
				return;
			}
			stop();
			ctx.ui.notify("Grok widget off", "info");
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
		hide(ctx);
	});
}
