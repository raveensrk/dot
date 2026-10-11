---
id: "4ym6rxchd8"
title: "Make the symlink rule deterministic"
state: "done"
due: ""
priority: ""
tag: ["symlinks"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-06"
closed: "2026-10-11T19:28"
---

Make the symlink rule fully deterministic. The prose rule (common.md Working style): "Symlinks: never create one, never commit one. Warn me first and name the alternative you chose instead."

Done already (2026-10-06, this machine):

- `~/repos/agent1/harness/checks/no_symlinks.py` - scans the working tree (links just created, the shape of the 8-link incident in dot) and the git index (links committed), shared SKIP_DIRS with nested_git_repo.py, no allowlist. Population clean across every repo under ~/repos.
- Prose rule in common.md, cross-referenced from repos.md.

Missing deterministic halves:

- Creation-time guard: `ln -s` still runs unguarded. Add it to `harness/extensions/command_guard.ts` (same pattern as the recursive-grep block: refuse and print the replacement command - copy, package declaration, or real path). Its test goes in `harness/tests/test_command_guard.ts`.
- Optional judgment half: when a symlink is genuinely justified, Jev could score the justification instead of prose hedging (see typesafe-ai skill).

Verify like the rest of the harness: node test for the guard, `lint.py --check no_symlinks` on a scratch repo with a created link, `timeout 120 pi -p "reply with just: ok"` clean after extension edits. Ties into "pi: replace remaining symlinks with packages" on this board - that migration must land on both computers: volt and atlas.

## Log

- done 2026-10-11 19:28: command_guard.ts blocks ln -s/--symbolic with the copy/package/real-path alternatives (agent1 47bc2ee); test 40 blocked 47 allowed; live hook blocked a scratch ln -s; no_symlinks flagged a scratch link; pi ok in 5 s. Jev judgment half left out (optional)
