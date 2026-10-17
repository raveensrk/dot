---
id: "0wbbze0kz4"
title: "Try czkawka_cli as a litter and empty-folder finder"
state: "todo"
due: "2026-12-18"
priority: ""
tag: ["maintenance"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-18"
closed: ""
---

## Why

Compare it with [,clean_litter.py](~/dot/script/,clean_litter.py) for
finding temporary files and empty folders. Its README says it finds only the
most basic temporary files, so check its exact patterns (`#name#`, `.#name`,
`.DS_Store`, `name~`) and whether it can move items to the Trash.

## Try

1. `brew install czkawka` (or the CLI-only build).
2. Run its temporary-files and empty-folders modes on `~/Documents` as a dry run.
3. Keep `,clean_litter.py`, replace it, or use both.
