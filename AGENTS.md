# AGENTS.md

## Common rules

At session start, read `~/repos/agent1/common.md` and follow it.

## Goal

The goal for this repo is to hold all my dotfiles and configs.

## Layout

- Docs: [docs/index.md](docs/index.md) is the wiki index.
- Scripts live in `script/` (not `scripts/`); it is on `PATH` via `config/bashrc`. Machine-local scripts and secrets live in `~/dot_local/script/` (also on `PATH`), replacing the old `~/script/`.
- Tests are `unittest` suites in `tests/`, run with `python3 -m pytest tests/`.
- Per-tool install notes live in `packages/`.
- Pi config lives in `config/pi/` and is stowed into `~/.pi/agent/` by `script/install.py` (dry-run by default; see [stow](docs/dotfiles-stow.md)). Live state (`auth.json`, `sessions/`, `npm/`, `models-store.json`, ...) stays in `~/.pi/agent/` and is never committed.
- Global skills are committed symlinks under `config/pi/skills/` pointing at source repos with relative paths; stow links them to `~/.pi/agent/skills/` and Pi auto-discovers them. Add or remove a skill by adding or removing its symlink.
- A question about a tool's config starts in this repo: read `config/<tool>/` (the stow source) before searching `~/.config`. `~/.config` also holds app bundles, so a broad search buries the answer in their noise.

