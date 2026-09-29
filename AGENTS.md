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
- Pi live `config/pi/agent/settings.json` is machine-local and gitignored. Share defaults through `config/pi/agent/settings.example.json`; never force-add live settings or machine-specific provider/model/skill paths.
- Agent harness config: [agent config](docs/agent_config.md). Run `,agent_config.py` to preview and `,agent_config.py --apply` to sync source paths; `--export` updates the shared settings template. Only `metadata.scope: global` opts in; do not recreate shared skill symlinks.

