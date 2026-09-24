# Docs

Wiki index for this dotfiles repo. Every doc under `docs/` is listed here.

## Contents

| Doc | What it covers |
|---|---|
| [Emacs](emacs.md) | Restored config, repository agenda discovery, isolated tests |
| [Lazygit](lazygit.md) | Config path, `C` = commit message via pi |
| [Newsboat](newsboat.md) | RSS reader: the "Chrome Teal" theme, config reference, and the traps found while building it |
| [Repository sync](repository-sync.md) | `script/,sync.py`, which manages multiple Git repos |
| [Todo schema](~/repos/ai/docs/agents/todo_schema.org) | Canonical todo item format used across projects |
| [Todo script](todo-script.md) | `script/,todo.py`, the Markdown task scanner |
| [Todo in Vim](todo-vim.md) | Markdown todo plugins: state cycling, due-date shifting and filtering |
| [Vim colorscheme](vim-colorscheme.md) | Current scheme, eye-comfort research, and how pathogen plugins are installed |
| [WireGuard VPN on Vultr](how-to-set-up-wireguard-vpn-in-vultr-instance.md) | Personal VPN setup with iOS and macOS clients |

## Where things live

| Path | Holds |
|---|---|
| `config/` | Application configs, symlinked or sourced from `$DOT` |
| `script/` | Executables on `PATH` (see `config/bashrc`) |
| `tests/` | `unittest` suites, run with `pytest` |
| `packages/` | Per-tool install notes |
| `docs/` | This wiki |

## Conventions

- Common rules for this repo live in [common.md](~/repos/ai/docs/agents/common.md),
  referenced from [AGENTS.md](../AGENTS.md).
- Scripts go in `script/`, not `scripts/`. This predates the shared rule and is
  wired into `PATH` in `config/bashrc`.

## Known drift

Tracked so it is not rediscovered every session.

- Existing doc filenames are kebab-case, but the shared naming rule asks for
  `snake_case`. The todo schema now lives in
  [todo_schema.org](~/repos/ai/docs/agents/todo_schema.org). Remaining kebab-case
  names in this wiki are local.
- The shared rules ask for a [Divio](https://docs.divio.com/documentation-system/)
  layout (`tutorials/`, `how-to/`, `reference/`, `explanation/`). This `docs/`
  is still flat. Migrating means updating the same external reference above.
