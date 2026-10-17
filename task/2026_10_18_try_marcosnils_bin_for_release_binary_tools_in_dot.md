---
id: "a1hzr82g3m"
title: "Try marcosnils/bin for release-binary tools in dot"
state: "todo"
due: ""
priority: ""
tag: ["dot"]
repeat: ""
effort: ""
postpone: 0
created: "2026-10-18"
closed: ""
---

Source: https://github.com/marcosnils/bin - installs and updates single-binary tools from GitHub/GitLab releases, tracked in a JSON config.

## Plan
- Install bin once per machine (brew on macOS, release binary on Linux).
- Commit its tracking config (~/.config/bin/config.json) as config/bin/config.json; script/install.py copies it.
- Move GitHub-release tools to bin: lazygit (packages/lazygit_ubuntu.sh), verible, and the binaries checked into bin/linux (rg, jq, fzf, direnv, entr, gitui, shellcheck, exa).
- Call `bin update` from the update-tools flow.

## Acceptance
- A fresh Linux box gets those tools from `bin ensure` with no committed binaries.
- bin/linux and the per-tool release scripts are deleted.
