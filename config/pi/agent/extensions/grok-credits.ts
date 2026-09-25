import { execFile } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const execFileAsync = promisify(execFile);
const BIN = join(homedir(), "dot", "script", "grok_credits.py");
const EXTRA = join(homedir(), "dot", "config", "pi", "agent", "status_widget.txt");
const FLAG = join(homedir(), ".local/share/grok_credits/disabled");
const INTERVAL_MS = 5 * 60 * 1000;
const KEY = "status-widget";
const DAY_MS = 86400000;
const PACE_SLACK = 1;

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

function left(iso: string | undefined): string {
	if (!iso) {
		return "";
	}
	const end = Date.parse(iso);
	if (Number.isNaN(end)) {
		return "";
	}
	const ms = end - Date.now();
	if (ms <= 0) {
		return " · 0 days left";
	}
	const days = Math.ceil(ms / DAY_MS);
	const unit = days === 1 ? "day" : "days";
	return ` · ${days} ${unit} left`;
}

function pace(actual: number, startIso: string | undefined, endIso: string | undefined): string {
	if (!startIso || !endIso) {
		return "";
	}
	const start = Date.parse(startIso);
	const end = Date.parse(endIso);
	const span = end - start;
	if (!(span > 0) || Number.isNaN(start) || Number.isNaN(end)) {
		return "";
	}
	const expected = Math.max(0, Math.min(100, ((Date.now() - start) / span) * 100));
	let tag = "on track";
	if (actual > expected + PACE_SLACK) {
		tag = "over";
	}
	if (actual < expected - PACE_SLACK) {
		tag = "under";
	}
	return ` · even ${Math.round(expected)}% · ${tag}`;
}

function extra(): string[] {
	if (!existsSync(EXTRA)) {
		return [];
	}
	const text = readFileSync(EXTRA, "utf8");
	return text.split(/\r?\n/).filter((line) => {
		const trimmed = line.trim();
		return trimmed.length > 0 && !trimmed.startsWith("#");
	});
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
	const lines = extra();
	if (grok) {
		lines.unshift(grok);
	}
	if (lines.length === 0) {
		hide(ctx);
		return;
	}
	ctx.ui.setWidget(KEY, lines, { placement: "belowEditor" });
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
			const { stdout } = await execFileAsync("python3", [BIN, "--json"], {
				timeout: 20000,
			});
			const report = JSON.parse(stdout) as {
				credit_usage_percent?: number;
				credit_usage_display?: string;
				reset_display?: string;
				billing_period_start?: { iso_utc?: string };
				billing_period_end?: { iso_utc?: string };
			};
			const used = String(report.credit_usage_display || "").replace(" used", "");
			if (!used) {
				return undefined;
			}
			const reset = report.reset_display ? ` · Resets ${report.reset_display}` : "";
			const startIso = report.billing_period_start?.iso_utc;
			const endIso = report.billing_period_end?.iso_utc;
			const actual = Number(report.credit_usage_percent) || 0;
			return `Grok ${used}${reset}${left(endIso)}${pace(actual, startIso, endIso)}`;
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
			const known = new Set(["", "on", "off", "enable", "disable", "toggle"]);
			if (!known.has(arg)) {
				ctx.ui.notify("Usage: /grok-credits [on|off]", "error");
				return;
			}
			let value = grokOn();
			if (arg === "on" || arg === "enable") {
				value = true;
			}
			if (arg === "off" || arg === "disable") {
				value = false;
			}
			if (arg === "" || arg === "toggle") {
				value = !value;
			}

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
