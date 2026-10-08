---
id: "efjqj8kgt2"
title: "Sync global skills through native Pi paths"
state: "done"
due: ""
priority: ""
tag: ["pi"]
repeat: ""
effort: ""
postpone: 0
created: "2026-09-29"
closed: "2026-09-29T18:00"
---

Implement script/,agent_config.py: preview default, explicit --apply, scan dot and
repos for metadata.scope global, preserve manual config, prune owned paths,
reject duplicate names, and migrate matching shared symlinks only after
native registration succeeds. Verify tests, initial seven registrations,
unrelated settings preservation, and an idempotent second run.
Verified temporary-directory tests, Pi native loader (seven skills, zero
diagnostics), exact backup, seven migrated links, and no-op second apply.
GPT-5.5 review: added directory fsync after atomic replacement; retained
deliberate rule that manually rewritten entries become user-owned.
Usage and ownership rules: docs/agent_config.md. Renamed from ,skills.py
since it also exports shared Pi settings.
Follow-up: readable tree output; live Pi settings untracked and gitignored.
Shared settings.example.json excludes provider/model, skill paths, and
changelog state. Verified live settings byte-identical and two tests pass.
