/**
 * Session name rules. Pure, so `node --experimental-strip-types name.ts` can check them.
 * A stored name is lowercase words, spaces, no punctuation, max 4 words, max 32 characters.
 */
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";

export const MAX_WORDS = 4;
export const MAX_CHARS = 32;

const PHRASES = ["suggest a session name", "rename this session", "name this session", "session name"];

export type Ask = { kind: "none" } | { kind: "only" } | { kind: "rest"; rest: string };

/** Collapse a model or typed string. Null means reject, do not clip. */
export function normalize(raw: string): string | null {
	const words = raw
		.toLowerCase()
		.replace(/[^a-z0-9\s]/g, " ")
		.split(/\s+/)
		.filter(Boolean);
	if (words.length === 0 || words.length > MAX_WORDS) return null;

	const name = words.join(" ");
	if (name.length > MAX_CHARS) return null;
	return name;
}

/** Exact phrase, or a message that starts with one. A later mention does not match. */
export function splitAsk(text: string): Ask {
	const raw = text.trim().replace(/\s+/g, " ");
	const lower = raw
		.toLowerCase()
		.replace(/[.!?]+$/g, "")
		.replace(/,\s*(please|now)$/g, " $1")
		.trim();

	for (const phrase of PHRASES) {
		if (lower === phrase || lower === `${phrase} please` || lower === `${phrase} now`) {
			return { kind: "only" };
		}
		if (!lower.startsWith(`${phrase} `)) continue;

		// Length matches either case, so slice the original, not the lowered copy.
		const rest = raw
			.slice(phrase.length)
			.trim()
			.replace(/^and\s+/i, "");
		return rest ? { kind: "rest", rest } : { kind: "only" };
	}
	return { kind: "none" };
}

function check(): void {
	assert.equal(normalize("Fix Login Bug!"), "fix login bug");
	assert.equal(normalize("login form 500"), "login form 500");
	assert.equal(normalize("fix-login-bug"), "fix login bug");
	assert.equal(normalize("please fix the login bug in auth"), null);
	assert.equal(normalize("abcdefghijklmnopqrstuvwxyzabcdefghij"), null);
	assert.equal(normalize(""), null);

	assert.deepEqual(splitAsk("name this session"), { kind: "only" });
	assert.deepEqual(splitAsk("Name this session please"), { kind: "only" });
	assert.deepEqual(splitAsk("name this session, please"), { kind: "only" });
	assert.deepEqual(splitAsk("rename this session now"), { kind: "only" });
	assert.deepEqual(splitAsk("session name"), { kind: "only" });
	assert.deepEqual(splitAsk("suggest a session name"), { kind: "only" });
	assert.deepEqual(splitAsk("name this session and fix the login bug"), {
		kind: "rest",
		rest: "fix the login bug",
	});
	assert.deepEqual(splitAsk("the session name should appear leftmost"), { kind: "none" });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) check();
