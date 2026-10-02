/**
 * Names the current Pi session after the user picks a short label.
 * Jev decides whether a later turn changed the goal. Flash writes names only when the picker opens.
 */
import { Type } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { normalize, splitAsk } from "./name.ts";

const STATUS = "session-name";
const BASE = "session-name-base";
const GATE = 0.8;
// ponytail: tail cap, raise if a long session makes Jev miss an early goal
const CAP = 24_000;
const WRITER = { provider: "openrouter", id: "deepseek/deepseek-v4.1-flash" };

type Entry = {
	type: string;
	customType?: string;
	summary?: string;
	data?: { excerpt?: string };
	message?: { role?: string; content?: unknown };
};

export default function (pi: ExtensionAPI) {
	let base: string | undefined;
	let told = false;
	let busy = false;
	let skip = false;

	function publish(ctx: ExtensionContext, name?: string): void {
		if (!ctx.hasUI) return;
		const shown = name ?? pi.getSessionName();
		ctx.ui.setStatus(STATUS, shown || undefined);
	}

	function load(ctx: ExtensionContext): void {
		base = undefined;
		for (const entry of ctx.sessionManager.buildContextEntries() as Entry[]) {
			if (entry.type !== "custom" || entry.customType !== BASE) continue;
			if (typeof entry.data?.excerpt === "string") base = entry.data.excerpt;
		}
	}

	function save(excerpt: string): void {
		base = excerpt;
		pi.appendEntry(BASE, { excerpt });
	}

	function textOf(content: unknown): string {
		if (typeof content === "string") return content.trim();
		if (!Array.isArray(content)) return "";

		const bits: string[] = [];
		for (const part of content) {
			if (!part || typeof part !== "object") continue;
			const block = part as { type?: string; text?: string };
			if (block.type === "text" && block.text) bits.push(block.text);
		}
		return bits.join("\n").trim();
	}

	// User text and assistant final replies. No tool output. Compaction summary stands in for dropped history.
	function excerptOf(ctx: ExtensionContext): string {
		const parts: string[] = [];
		for (const entry of ctx.sessionManager.buildContextEntries() as Entry[]) {
			if (entry.type === "compaction" && entry.summary) {
				parts.push(entry.summary);
				continue;
			}
			if (entry.type !== "message") continue;
			const role = entry.message?.role;
			if (role !== "user" && role !== "assistant") continue;
			const bit = textOf(entry.message?.content);
			if (bit) parts.push(bit);
		}
		const text = parts.join("\n").trim();
		return text.length > CAP ? text.slice(-CAP) : text;
	}

	function fail(ctx: ExtensionContext, message: string): void {
		if (told || !ctx.hasUI) return;
		told = true;
		ctx.ui.notify(message, "warning");
	}

	async function written(ctx: ExtensionContext, excerpt: string): Promise<string[] | null> {
		const model = ctx.modelRegistry.find(WRITER.provider, WRITER.id);
		if (!model || !ctx.modelRegistry.hasConfiguredAuth(model)) return null;

		try {
			const response = await ctx.modelRegistry.complete(model, {
				messages: [
					{
						role: "user",
						content: [
							{
								type: "text",
								text: [
									"Name the user's current goal.",
									"Return 3 different wordings, one per line.",
									"Lowercase words, spaces, no punctuation, max 4 words, max 32 characters.",
									"No numbers, no explanation.",
									"",
									excerpt,
								].join("\n"),
							},
						],
						timestamp: Date.now(),
					},
				],
			});
			if (response.stopReason === "error" || response.stopReason === "aborted") return null;

			const raw = response.content
				.filter((block) => block.type === "text")
				.map((block) => block.text)
				.join("\n");
			const seen = new Set<string>();
			const out: string[] = [];
			for (const line of raw.split("\n")) {
				const name = normalize(line.replace(/^\d+[.)]\s*/, ""));
				if (!name || seen.has(name)) continue;
				if (name === "keep current" || name === "leave unnamed" || name === "type my own") continue;
				seen.add(name);
				out.push(name);
				if (out.length === 3) break;
			}
			return out;
		} catch {
			return null;
		}
	}

	async function typed(ctx: ExtensionContext): Promise<string | undefined> {
		for (;;) {
			const raw = await ctx.ui.input("Type a session name", "4 words, 32 characters");
			if (raw === undefined) return undefined;
			const name = normalize(raw);
			if (name) return name;
			ctx.ui.notify("use 4 words, 32 characters", "warning");
		}
	}

	function apply(ctx: ExtensionContext, name: string, excerpt: string): void {
		pi.setSessionName(name);
		publish(ctx, name);
		if (excerpt) save(excerpt);
		ctx.ui.notify(`Session named: ${name}`, "info");
	}

	async function pick(ctx: ExtensionContext): Promise<void> {
		if (!ctx.hasUI || busy) return;
		busy = true;
		try {
			const excerpt = excerptOf(ctx);
			const named = pi.getSessionName();
			let choices: string[] = [];
			let failed = false;
			if (excerpt) {
				ctx.ui.notify("naming session", "info");
				const got = await written(ctx, excerpt);
				failed = got === null;
				if (got) choices = got;
			}

			const keep = named ? "Keep current" : "Leave unnamed";
			const title = failed ? "name writer failed" : "Session name";
			const choice = await ctx.ui.select(title, [...choices, keep, "Type my own"]);
			if (!choice || choice === keep) {
				if (excerpt) save(excerpt);
				return;
			}
			if (choice === "Type my own") {
				const name = await typed(ctx);
				if (!name) {
					if (excerpt) save(excerpt);
					return;
				}
				apply(ctx, name, excerpt);
				return;
			}
			apply(ctx, choice, excerpt);
		} finally {
			busy = false;
		}
	}

	async function changed(ctx: ExtensionContext, prior: string, current: string): Promise<boolean | null> {
		const jev = ctx.modelRegistry.findOfType("classifier", "typesafe", "jev-latest");
		if (!jev) return null;

		const result = await ctx.modelRegistry.classify(jev, {
			state: { baseline: prior, current },
			questions: {
				changed: {
					type: "bool",
					instructions:
						"Does `current` pursue a different user goal from `baseline`? A follow-up, a test, or a clarification of the same task is not a new goal.",
					criteria: {
						true: "The user switched to a different task",
						false: "The same task continues",
					},
				},
			},
		});
		if (result.stopReason !== "stop") return null;
		const answer = result.answers.changed;
		if (!answer || answer.type !== "bool") return null;
		told = false;
		return answer.probability >= GATE;
	}

	async function maybeAsk(ctx: ExtensionContext): Promise<void> {
		if (!ctx.hasUI || busy) return;
		const excerpt = excerptOf(ctx);
		if (!excerpt) return;

		const named = pi.getSessionName();
		if (!base && !named) {
			await pick(ctx);
			return;
		}
		if (!base) {
			save(excerpt);
			return;
		}
		if (excerpt === base) return;

		const next = await changed(ctx, base, excerpt);
		if (next === null) {
			fail(ctx, "session name check failed");
			return;
		}
		if (!next) return;
		await pick(ctx);
	}

	pi.on("session_start", (_event, ctx) => {
		load(ctx);
		told = false;
		publish(ctx);
	});

	pi.on("session_info_changed", (event, ctx) => {
		publish(ctx, event.name);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.hasUI) ctx.ui.setStatus(STATUS, undefined);
	});

	pi.on("input", async (event, ctx) => {
		if (event.source === "extension" || event.streamingBehavior) return { action: "continue" };
		const ask = splitAsk(event.text);
		if (ask.kind === "none") return { action: "continue" };

		if (ask.kind === "rest") skip = true;
		await pick(ctx);
		if (ask.kind === "rest") return { action: "transform", text: ask.rest };
		return { action: "handled" };
	});

	pi.registerCommand("session-name", {
		description: "Open the session name picker",
		handler: async (_args, ctx) => {
			if (!ctx.hasUI) return;
			if (!ctx.isIdle()) {
				ctx.ui.notify("wait until the turn finishes", "warning");
				return;
			}
			await pick(ctx);
		},
	});

	pi.registerTool({
		name: "session_name",
		label: "Session name",
		description:
			"Open the session name picker. Use only when the user asks to name or rename this session. Do not invent a name.",
		parameters: Type.Object({}),
		async execute(_id, _params, _signal, _onUpdate, ctx) {
			skip = true;
			const ui = ctx as ExtensionContext | undefined;
			if (!ui?.hasUI) {
				return {
					content: [{ type: "text", text: "No UI. Ask the user to run /session-name." }],
					details: {},
				};
			}
			await pick(ui);
			const name = pi.getSessionName();
			return {
				content: [{ type: "text", text: name ? `Session name: ${name}` : "Session left unnamed." }],
				details: { name },
			};
		},
	});

	pi.on("agent_settled", async (_event, ctx) => {
		publish(ctx);
		if (skip) {
			skip = false;
			const excerpt = excerptOf(ctx);
			if (excerpt) save(excerpt);
			return;
		}
		await maybeAsk(ctx);
	});
}
