/**
 * Publishes OpenRouter account spend to the "or-spend" status key so powerline
 * (via powerline.customItems) can show it: "or $0.19 used · $49.79 left".
 * Data: GET https://openrouter.ai/api/v1/key (all-time usage + key credit left).
 */
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_KEY = "or-spend";
const INTERVAL_MS = 10 * 60 * 1000;

function usd(n: number): string {
	return `$${n.toFixed(2)}`;
}

async function spendLine(ctx: ExtensionContext): Promise<string | undefined> {
	const key = await ctx.modelRegistry.getApiKeyForProvider("openrouter");
	if (!key) return undefined;
	try {
		const res = await fetch("https://openrouter.ai/api/v1/key", {
			headers: { Authorization: `Bearer ${key}` },
			signal: AbortSignal.timeout(15000),
		});
		if (!res.ok) return undefined;
		const body = (await res.json()) as { data?: { usage?: number; limit_remaining?: number } };
		const data = body.data;
		if (!data || typeof data.usage !== "number") return undefined;
		// Spend only; balance was dropped from the bar (see powerline layout).
		return `${usd(data.usage)} used`;
	} catch {
		return undefined;
	}
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