/**
 * Global Pi policy: use provider-advertised maximum context, never guessed limits.
 * Other providers retain Pi's catalog maxima. Codex's larger opt-in maxima come
 * from its authenticated catalog and survive offline startup in models-store.
 * Session start (including resume/reload) refreshes metadata before the first run.
 * Streaming, auth, output limits, and compaction response headroom stay unchanged.
 * shortcut: CLI model listings precede session_start; move registration to the
 * factory when Pi exposes its configured model registry there.
 */
import { createHash } from "node:crypto";
import type { AnyModel, Provider } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const CODEX = "openai-codex";
const BASE = "https://chatgpt.com/backend-api";
// Endpoint/version verified 2026-10-09: one live lookup, 0.798 s.
const CATALOG = `${BASE}/codex/models?client_version=1.1.0`;
const TIMEOUT = 10000;

type Entry = AnyModel & {
	context_base?: number;
	context_max?: number;
	context_account?: string;
};
type Limit = { context: number; maximum: number };
const valid = (value: unknown): value is number =>
	typeof value === "number" && Number.isSafeInteger(value) && value > 0;

export function maximize(base: Provider, warn: (message: string) => void): Provider {
	let limits = new Map<string, Limit>();
	let account: string | undefined;
	const project = (model: Entry, maxima = limits, key = account): AnyModel => {
		if (model.type && model.type !== "chat") return model;
		if (model.baseUrl && model.baseUrl !== BASE) return model;
		const { context_base, context_max, context_account, ...plain } = model;
		const limit = maxima.get(model.id);
		const baseline = limit?.context ?? (valid(context_base) ? context_base : model.contextWindow);
		if (!limit) return context_base ? { ...plain, contextWindow: baseline } : model;
		return {
			...plain, contextWindow: limit.maximum, context_base: baseline,
			context_max: limit.maximum, context_account: key,
		} as Entry;
	};
	return {
		...base,
		getModels: () => base.getModels().map(model => project(model) as ReturnType<Provider["getModels"]>[number]),
		getAllModels: () => (base.getAllModels?.() ?? base.getModels()).map(model => project(model)),
		refreshModels: async context => {
			if (context.signal.aborted) return;
			const credential = context.credential;
			const id = credential?.type === "oauth" && typeof credential.accountId === "string"
				? credential.accountId : undefined;
			const key = id ? createHash("sha256").update(id).digest("hex") : undefined;
			let next = new Map<string, Limit>();
			let stored = context.stored;
			for (const model of (stored?.models ?? []) as readonly Entry[]) {
				if (key && model.context_account === key && valid(model.context_max) &&
					valid(model.context_base) && model.context_max >= model.context_base) {
					next.set(model.id, { context: model.context_base, maximum: model.context_max });
				}
			}
			try {
				await base.refreshModels?.({
					...context,
					publish: async publication => {
						const accepted = await context.publish(publication);
						if (accepted && publication.persist !== undefined) stored = publication.persist ?? undefined;
						return accepted;
					},
				});
			} catch {
				if (!context.signal.aborted) warn("Codex catalog refresh failed; cached catalog retained. Retry with /reload.");
			}
			if (context.signal.aborted) return;
			if (!context.allowNetwork) {
				if (next.size === 0) warn("Codex maximum-context cache empty; catalog limits retained during cache-only refresh.");
			} else if (!id || credential?.type !== "oauth" || !credential.access) {
				warn("Codex maximum-context lookup needs OAuth; catalog limits retained. Use /login openai-codex.");
			} else {
				let reason = "lookup failed";
				try {
					const response = await fetch(CATALOG, {
						headers: { Authorization: `Bearer ${credential.access}`, "ChatGPT-Account-ID": id },
						signal: AbortSignal.any([context.signal, AbortSignal.timeout(TIMEOUT)]),
					});
					if (!response.ok) {
						reason = `lookup returned HTTP ${response.status}`;
						throw new Error(reason);
					}
					const body = await response.json();
					if (!body || !Array.isArray(body.models)) throw new Error("Invalid model catalog");
					const maxima = new Map<string, Limit>();
					for (const model of body.models) {
						const maximum = model?.max_context_window ?? model?.context_window;
						if (typeof model?.slug !== "string" || !model.slug || maxima.has(model.slug) ||
							!valid(model.context_window) || !valid(maximum) || maximum < model.context_window) {
							throw new Error("Invalid model context limit");
						}
						maxima.set(model.slug, { context: model.context_window, maximum });
					}
					next = maxima;
				} catch {
					if (context.signal.aborted) return;
					warn(`Codex maximum-context ${reason}; cached or catalog limits retained. Retry with /reload.`);
				}
			}
			if (context.signal.aborted) return;
			const models = (base.getAllModels?.() ?? base.getModels()).map(model => project(model, next, key));
			await context.publish({
				persist: { ...stored, models },
				update: () => { limits = next; account = key; },
			});
		},
	};
}

export default function (pi: ExtensionAPI) {
	let previous: Provider | undefined;
	pi.on("session_start", async (_event, ctx) => {
		const warn = (message: string) => ctx.hasUI ? ctx.ui.notify(message, "warning") : console.warn(message);
		previous ??= ctx.modelRegistry.getProvider(CODEX);
		if (!previous) return;
		if (previous.baseUrl !== BASE) {
			warn("Codex maximum-context policy cannot verify this gateway; its catalog limits remain unchanged.");
			previous = undefined;
			return;
		}
		pi.registerProvider(maximize(previous, warn));
		const result = await ctx.modelRegistry.refresh({ providers: [CODEX] });
		if (result.errors.has(CODEX)) warn("Codex refresh failed; cached or catalog limits retained. Retry with /reload.");
		if (ctx.model?.provider !== CODEX) return;
		const model = ctx.modelRegistry.find(CODEX, ctx.model.id);
		if (model) await pi.setModel(model);
	});
	pi.on("session_shutdown", () => {
		if (previous) pi.registerProvider(previous);
		previous = undefined;
	});
}
