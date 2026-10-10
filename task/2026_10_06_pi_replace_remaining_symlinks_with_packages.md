---
id: "m9kaqhcv2x"
title: "pi: replace remaining symlinks with packages"
state: "todo"
due: ""
priority: "C"
tag: ["pi"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-06"
closed: ""
---

Finish the pi package migration: pi must load everything from packages, not from symlinked dirs. Done already (2026-10-06): agent1 is a live local package - `~/repos/agent1/package.json` declares `harness/extensions/*.ts`, `~/dot/config/pi/settings.json` lists `"~/repos/agent1"` in `packages`; the 8 installer symlinks in `config/pi/extensions/` were deleted and agent1's `install.py` lost its pi-extension target. Global rule: no git repo contains symlinks; live-state links outside repos are allowed but are being retired for pi too.

Remaining symlinked loading paths to convert:

- `~/.pi/agent/extensions -> ../../dot/config/pi/extensions` (dir stow link). Dot-owned extensions (delete-quit, flash-models, grok-credits, openai_usage_gate, opencode-usage, openrouter-spend, powerline-footer, session-name, shared, show-model, timeout-label-patch) load through it. Make dot a pi package too: add a `package.json` with a `pi` manifest (extensions: `config/pi/extensions/*`), declare it in `settings.json` `packages` as `"~/dot"`, then remove the dir symlink and have dot's `script/install.py` stop stowing it.
- `~/.agents/skills/*` links to `~/repos/agent1/skills/*` (agent1 `install.py`, manifest-managed). Move agent1's skills into the agent1 package manifest (`pi.skills`), drop the `("skills/*/SKILL.md", "~/.agents/skills", ["pi"])` target, prune those manifest entries; keep `~/.claude/skills` + `~/.codex/skills` installer targets. Beware name collisions: pi dedupes by name with a warning - remove the old links in the same change.
- Stow links for `AGENTS.md`, `settings.json`, `patches` are plain config-file stow, not extension/skill loading - out of scope unless decided otherwise.

Verify each step the way the agent1 package was verified: `timeout 120 pi -p "reply with just: ok"` clean, a positive load probe (session custom entries from the extensions), `pi list` resolves the package paths, and no skill-collision warnings at startup.
Must land on both computers: volt and atlas. On each machine: run the same migration (dot package + agent1 skills into the package), then verify - timeout 120 pi -p "reply with just: ok" clean, pi list resolves both packages, no symlink left under ~/.pi/agent for loading, git status clean in both repos.

Atlas verified 2026-10-10: dot extensions load from the ~/dot/config/pi package, agent1 skills from the agent1 package (pi.skills), ~/.pi/agent/extensions is a real dir, no symlinks under ~/.pi/agent; pi -p ok with no collision warnings; pi list resolves both packages; dot git clean. Remaining: volt - run the same checks there, then finish this task.
