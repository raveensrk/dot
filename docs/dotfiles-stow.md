# Stow

`script/install.py` and `script/uninstall.py` manage symlinks from this repo
into `$HOME` with GNU Stow. Dry-run is the default; nothing changes without
`--apply`.

## Usage

```sh
script/install.py                 # show the plan
script/install.py --apply         # stow
script/install.py pi --apply      # one package (default: all)
script/uninstall.py               # show what would be removed
script/uninstall.py --apply       # remove stow links
```

| Flag | Effect |
|---|---|
| `--apply` | write changes (default is dry-run) |
| `--backup` | rename conflicting targets to `*.bak.<timestamp>`, then stow |
| `--adopt` | pass `--adopt` to stow, importing existing target files into the package |

Conflicts abort before anything is written unless `--backup` or `--adopt` is
given. The two flags are mutually exclusive.

## Packages

Mappings live in `script/dot_stow.py` as `PACKAGES`: package name ->
(source dir in the repo, target dir in `$HOME`). Stow runs as
`stow -d <source parent> -t <target> <source name>`, so every entry of the
source dir (files included) lands in the target dir.

| Package | Source | Target |
|---|---|---|
| `pi` | `config/pi/` | `~/.pi/agent/` |

Add a package by adding one line to `PACKAGES`; both CLIs pick it up.

## Ignores

`config/pi/.stow-local-ignore` excludes `agent/` (frozen pre-stow state) and
macOS metadata. A local ignore file **replaces** stow's built-in ignore list,
so the defaults are copied into it; `dot_stow.DEFAULT_IGNORE` mirrors that list
for the planner.

## Install behavior

1. Absolute symlinks that already point into the package are removed so stow
   can replace them with relative links it owns.
2. Real files or directories at target paths are conflicts: abort by default,
   `--backup` renames them, `--adopt` imports them.
3. `stow -R` links the package and cleans stale links.

`uninstall.py` removes every symlink under the target that resolves into the
package, then runs `stow -D`. Real files and the target directory itself are
never touched.

## Tests

`tests/test_dot_stow.py` runs install/uninstall against temp directories:

```sh
python3 -m pytest tests/test_dot_stow.py
```

## History

Pi used to keep its whole agent dir in this repo via
`PI_CODING_AGENT_DIR=~/dot/config/pi/agent`. That variable was removed from
`config/bashrc` and `~/.zshrc`; live state now lives in `~/.pi/agent/` and only
the config entries are stowed from `config/pi/`.
