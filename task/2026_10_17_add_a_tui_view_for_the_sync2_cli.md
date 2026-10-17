---
id: "5pd8wj30dw"
title: "Add a TUI view for the sync2 CLI"
state: "todo"
due: ""
priority: ""
tag: ["tui"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-17"
closed: ""
---

Goal locked 2026-10-18 (grill done). ,sync2 becomes a full TUI app.

- TUI only. No TTY -> ",sync2 needs a terminal", exit 1. Drop `list`, `-y`, `--plain`, `manual`, `ignore` subcommands. Keep -j -c -d -f -i.
- Opens at once; scan streams into it. Rows show a spinner until their result lands.
- Layout: left = repo list grouped Synced / Needs attention / Failed; right = detail of selected repo (branch, ahead/behind, dirty files, last commit). Header: progress bar + counts. Footer: keys.
- Keys: j/k move, enter/y lazygit then auto re-sync, r re-sync, i ignore (both ignore files), t cycle theme, ? help overlay, q quit. Finished rows are actionable during the scan; syncing rows are locked. lazygit works on any row.
- Effects (tachyonfx, tasteful): per-row spinners, rows fade/sweep in when results land, brief flash on status change, smooth progress bar, finish effect.
- Themes: Ayu Dark (default) and Gruvbox Dark Hard (palette in today's src/theme.rs). t cycles live; saved as theme = "..." in ~/dot_local/sync2.toml; --theme flag overrides.
- Clean run (nothing needs attention or failed): finish effect, auto-exit after 1.5 s unless a key is pressed, then print the plain report to scrollback.
- Any quit prints the final report to scrollback. Exit codes 0 ok, 1 failure, 2 attention stay.
