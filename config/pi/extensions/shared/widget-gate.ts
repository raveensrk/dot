/**
 * Exactly one below-editor widget shows at a time. The winner is picked by the
 * current model's provider:
 *   xai / grok (grok subscription) -> "grok"     (no widget; credits are on powerline)
 *   opencode / opencode-go (Go, Zen) -> "opencode" (opencode-usage oc-usage)
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