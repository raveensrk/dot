/**
 * Publishes OpenRouter account spend to the "or-spend" status key so powerline
 * (via powerline.customItems) can show it as
 * "openrouter · balance $12.78 · limit $3.65 · used $11.35 · total $12.22".
 * Data: GET /api/v1/key (key all-time usage + credit left) and GET /api/v1/credits
 * (account total_usage = all-time spend, total_credits - total_usage = the "Total
 * available" pay-as-you-go balance).
 * Scope differs per label: "balance" and "total" are the whole account, "limit" and
 * "used" are this API key.
 * Self-check: node --experimental-strip-types openrouter-spend.ts
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "or-spend";
const INTERVAL_MS = 10 * 60 * 1000;

function usd(n: number): string {
	return `$${n.toFixed(2)}`;
}

export function formatSpend(
	data: { usage?: number; limit_remaining?: number },
	credits?: { total_credits?: number; total_usage?: number },
): string | undefined {
	if (typeof data.usage !== "number") return undefined;
	const remaining = typeof data.limit_remaining === "number" ? data.limit_remaining : undefined;
	const spent = typeof credits?.total_usage === "number" ? credits.total_usage : undefined;
	const available =
		typeof credits?.total_credits === "number" && typeof credits.total_usage === "number"
			? credits.total_credits - credits.total_usage
			: remaining !== undefined
				? data.usage + remaining
				: undefined;
	return [
		available !== undefined && `balance ${usd(available)}`,
		remaining !== undefined && `limit ${usd(remaining)}`,
		`used ${usd(data.usage)}`,
		spent !== undefined && `total ${usd(spent)}`,
	]
		.filter(Boolean)
		.join(" · ");
}

async function getJson<T>(url: string, key: string): Promise<T | undefined> {
	try {
		const res = await fetch(url, {
			headers: { Authorization: `Bearer ${key}` },
			signal: AbortSignal.timeout(15000),
		});
		if (!res.ok) return undefined;
		return ((await res.json()) as { data?: T }).data;
	} catch {
		return undefined;
	}
}

async function spendLine(ctx: ExtensionContext): Promise<string | undefined> {
	const key = await ctx.modelRegistry.getApiKeyForProvider("openrouter");
	if (!key) return undefined;
	const [info, credits] = await Promise.all([
		getJson<{ usage?: number; limit_remaining?: number }>("https://openrouter.ai/api/v1/key", key),
		getJson<{ total_credits?: number; total_usage?: number }>("https://openrouter.ai/api/v1/credits", key),
	]);
	return info ? formatSpend(info, credits) : undefined;
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | undefined;

	async function refresh(ctx: ExtensionContext): Promise<void> {
		if (!ctx.hasUI) return;
		ctx.ui.setStatus(STATUS_KEY, await spendLine(ctx));
	}

	function start(ctx: ExtensionContext): void {
		if (timer) clearInterval(timer);
		timer = setInterval(() => void refresh(ctx), INTERVAL_MS);
		timer.unref?.();
	}

	pi.on("session_start", async (_event, ctx) => {
		await refresh(ctx);
		start(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		if (timer) clearInterval(timer);
		timer = undefined;
		if (ctx.hasUI) ctx.ui.setStatus(STATUS_KEY, undefined);
	});
}

if ((import.meta as { main?: boolean }).main) {
	const cases: [Parameters<typeof formatSpend>, string | undefined][] = [
		[
			[{ usage: 11.350662497, limit_remaining: 3.649337503 }, { total_credits: 25, total_usage: 12.220717341 }],
			"balance $12.78 · limit $3.65 · used $11.35 · total $12.22",
		],
		[[{ usage: 1.5, limit_remaining: 0.5 }], "balance $2.00 · limit $0.50 · used $1.50"],
		[[{ usage: 1 }], "used $1.00"],
		[[{ limit_remaining: 1 }], undefined],
	];
	for (const [input, want] of cases) {
		const got = formatSpend(...input);
		if (got !== want) throw new Error(`${JSON.stringify(input)} -> ${got}, want ${want}`);
	}
	console.log("openrouter-spend self-check ok");
}