import { execFile } from "node:child_process";
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { widgetFor } from "./shared/widget-gate.ts";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "opencode_usage.py");
const FLAG = join(homedir(), ".local/share/opencode_usage/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "oc-usage";

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

function on(): boolean {
	return !existsSync(FLAG);
}

function setOn(value: boolean): void {
	if (value) {
		if (existsSync(FLAG)) {
			unlinkSync(FLAG);
		}
		return;
	}
	mkdirSync(join(homedir(), ".local/share/opencode_usage"), { recursive: true });
	writeFileSync(FLAG, "");
}

function hide(ctx: Ui): void {
	if (!ctx.hasUI) {
		return;
	}
	ctx.ui.setWidget(KEY, undefined);
}

function paint(ctx: Ui, line: string | undefined): void {
	if (!ctx.hasUI) {
		return;
	}
	if (!line) {
		hide(ctx);
		return;
	}
	ctx.ui.setWidget(KEY, [line], { placement: "aboveEditor" });
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

	async function line(): Promise<string | undefined> {
		if (!on()) {
			return undefined;
		}
		try {
			const { stdout } = await execFileAsync("python3", [BIN], {
				timeout: 20000,
			});
			return stdout.trim() || undefined;
		} catch {
			return undefined;
		}
	}

	async function refresh(ctx: Ui): Promise<void> {
		if (!ctx.hasUI) {
			return;
		}
		if (widgetFor(pi.model?.provider) !== "opencode") {
			hide(ctx);
			return;
		}
		paint(ctx, await line());
	}

	pi.registerCommand("opencode-usage", {
		description: "Enable or disable opencode Go usage in the status widget",
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
			setOn(arg === "on");
			await refresh(ctx);
			if (arg === "on") {
				start(ctx);
				ctx.ui.notify("opencode usage widget on", "info");
				return;
			}
			stop();
			ctx.ui.notify("opencode usage widget off", "info");
		},
	});

	pi.on("model_select", async (event, ctx) => {
		const active = widgetFor(event.model.provider) === "opencode";
		if (!active) {
			stop();
		}
		await refresh(ctx);
		if (active && on() && !timer) {
			start(ctx);
		}
	});

	pi.on("session_start", async (_event, ctx) => {
		await refresh(ctx);
		if (on()) {
			start(ctx);
		}
	});

	pi.on("session_shutdown", (_event, ctx) => {
		stop();
		hide(ctx);
	});
}
