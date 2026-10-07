/**
 * /list-skills - prints every skill loaded in this pi session.
 * -v adds the description per skill.
 * Source of truth is ctx.getSystemPrompt(): pi lists loaded skills in its
 * <available_skills> block (user, project, and package skills), so the list
 * always matches what the model sees.
 */
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";

interface LoadedSkill {
	name: string;
	description: string;
}

// XML-escaped values in the prompt block; &amp; last so double escapes survive.
function unescapeXml(text: string): string {
	return text
		.replace(/&lt;/g, "<")
		.replace(/&gt;/g, ">")
		.replace(/&quot;/g, '"')
		.replace(/&apos;/g, "'")
		.replace(/&amp;/g, "&");
}

function parseSkills(prompt: string): LoadedSkill[] {
	const block = /<available_skills>([\s\S]*?)<\/available_skills>/.exec(prompt);
	if (!block) return [];

	return [...block[1].matchAll(/<skill>([\s\S]*?)<\/skill>/g)].map((m) => {
		const field = (tag: string) =>
			unescapeXml(new RegExp(`<${tag}>([\\s\\S]*?)</${tag}>`).exec(m[1])?.[1]?.trim() ?? "");
		return { name: field("name"), description: field("description") };
	});
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("list-skills", {
		description: "List all skills loaded in this session",
		handler: async (args: string, ctx: ExtensionCommandContext) => {
			const skills = parseSkills(ctx.getSystemPrompt());
			if (skills.length === 0) {
				ctx.ui.notify("no skills loaded", "warning");
				return;
			}

			// -v adds the description per skill.
			const verbose = args.split(/\s+/).includes("-v");
			const lines = skills
				.sort((a, b) => a.name.localeCompare(b.name))
				.map((s) => (verbose ? `${s.name} - ${s.description}` : s.name));
			ctx.ui.notify(`Skills (${skills.length}):\n${lines.join("\n")}`, "info");
		},
	});
}
