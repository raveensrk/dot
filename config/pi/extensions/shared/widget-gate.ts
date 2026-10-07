/**
 * Picks which provider owns the below-editor status slot. Grok credits and
 * opencode usage moved to powerline items, so the mapping only gates
 * show-model's active-model status now:
 *   xai / grok (grok subscription) -> "grok"
 *   opencode / opencode-go (Go, Zen) -> "opencode"
 *   everything else (e.g. openrouter/auto) -> "model" (show-model active-model)
 */
export type WidgetId = "grok" | "opencode" | "model";

export function widgetFor(provider: string | undefined): WidgetId | undefined {
	if (!provider) return undefined;
	const p = provider.toLowerCase();
	if (p === "xai" || p === "grok") return "grok";
	if (p.startsWith("opencode")) return "opencode";
	return "model";
}