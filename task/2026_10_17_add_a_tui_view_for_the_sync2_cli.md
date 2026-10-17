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

Decided 2026-10-18: keep the CLI; the TUI only replaces the y/n/i/q prompt (triage of attention repos). Built in script/sync2_rs/src/tui.rs (ratatui 0.30): enter/y lazygit then re-sync, r re-sync, i ignore, q done. --plain or NO_COLOR keeps the old prompt. Left: try it on a real run, then commit.
