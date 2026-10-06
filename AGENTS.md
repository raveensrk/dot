# AGENTS.md

## Common rules

At session start, read `~/repos/agent1/common.md` and follow it.

## Goal

The goal for this repo is to hold all my dotfiles and configs.

## Layout

- Docs: [docs/index.md](docs/index.md) is the wiki index.
- Scripts live in `script/` (not `scripts/`); it is on `PATH` via `config/bashrc`. Machine-local scripts and secrets live in `~/dot_local/script/` (also on `PATH`), replacing the old `~/script/`.
- Tests are `unittest` suites in `tests/`, run with `python3 -m pytest tests/`. A test that imports an extensionless script from `script/` uses `importlib.machinery.SourceFileLoader`, because `spec_from_file_location` returns None for a path with no `.py` suffix.
- Per-tool install notes live in `packages/`.
- Pi config lives in `config/pi/` and is stowed into `~/.pi/agent/` by `script/install.py` (dry-run by default; see [installer docs](script/install.py) or `script/install.py --help`). Live state (`auth.json`, `sessions/`, `npm/`, `models-store.json`, ...) stays in `~/.pi/agent/` and is never committed.
- Global skills install from the agent1 repo: `~/repos/agent1/install.py` symlinks `skills/*` into `~/.agents/skills/` (plus `~/.claude/skills/`, `~/.codex/skills/`), and Pi reads `~/.agents/skills/`. No symlinks are committed in this repo - a repo never contains symlinks (global rule).
- Pi extensions load two ways: dot-owned extensions are real files in `config/pi/extensions/` (stowed dir link), and agent1's `harness/extensions/*.ts` load live from the pi package `~/repos/agent1` declared in `config/pi/settings.json` `packages`. agent1 owns its code; this repo owns the declaration.
- A question about a tool's config starts in this repo: read `config/<tool>/` (the stow source) before searching `~/.config`. `~/.config` also holds app bundles, so a broad search buries the answer in their noise.
