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
- Agent harness config (pi, Claude Code, Codex) lives in `config/pi/`, `config/claude/` and `config/agents/` (shared: global `AGENTS.md`, `mcp.json`, the `~/.agents` plugin manifest). `script/install.py` installs it with no symlinks: key merges into the live settings files, real-file copies, and `config/pi` as a local pi package; then it runs agent1's installer. Dry-run by default; `--check` reports drift; see `script/install.py --help`. Live state (`auth.json`, `sessions/`, `npm/`, `models-store.json`, ...) stays in the harness dirs and is never committed.
- agent1 (skills, commands, guards, lint) loads in place: a pi package (`~/repos/agent1` in `config/pi/settings.json` `packages`) and the Claude plugin `agents@raveen-agents`, registered by `~/repos/agent1/install.py`. agent1 owns its code; this repo owns the declaration.
- Pi extensions: dot-owned ones are real files in `config/pi/extensions/`, loaded from the local pi package `~/dot/config/pi` (`config/pi/package.json`).
- A question about a tool's config starts in this repo: read `config/<tool>/` (the source) before searching `~/.config`. `~/.config` also holds app bundles, so a broad search buries the answer in their noise.
