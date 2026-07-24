# Repository synchronization

`script/,sync.py` manages multiple Git repositories in either automatic
or manual mode.

## Automatic mode

Run without `--manual` to fetch repositories and automatically push, merge, or
report repositories that need attention:

```bash
script/,sync.py
```

Automatic mode follows each branch's configured upstream instead of assuming
an `origin` remote or matching branch name. Its behavior is deliberately
conservative:

- Ahead-only branches are pushed to their configured upstream.
- Behind-only branches are updated with a fast-forward-only merge; no push is
  needed.
- Dirty, detached, unconfigured, diverged, or non-fast-forwardable branches
  open in `lazygit` for manual handling.
- Failed Git operations produce a nonzero exit status instead of being treated
  as successful synchronization.

Git commands are noninteractive and time out after 60 seconds. The program
returns `0` for success, `1` for failures, and `2` when manual attention is
needed.

## Manual mode

Use `--manual` (or `-m`) to open every discovered Git repository in `lazygit`.
Manual mode does not fetch, merge, or push on the user's behalf:

```bash
script/,sync.py --manual
```

By default, the script reads `~/dot_local/list_of_repos.txt` and recursively
scans `~/repos`. To handle only repositories from the list file, run:

```bash
script/,sync.py --manual --file ~/dot_local/list_of_repos.txt
```

Repository sources can also be selected with repeatable `--file` and `--dir`
arguments. Supplying either argument disables the default sources. Paths from
list files support `~` and environment variables; relative paths are resolved
from the list file's directory.

## Ignoring repositories

Repositories can be skipped in three ways:

- `--ignore PATTERN` (or `-i`), a repeatable path or glob pattern.
- `ignore:` lines inside any `--file` list file.
- `~/dot_local/list_of_ignores.txt`, a personal, untracked skip list with one
  path or glob pattern per line (`#` comments and blank lines are ignored).
  This local list is **always** applied, even when `--file` or `--dir` overrides
  the default sources.

A plain path skips that repository and anything beneath it, so a single entry
such as `~/repos/felis-block-diagram/block_diagram/build/_deps` silences every
vendored build dependency under it. Glob patterns like `*/build/_deps/*` match
by shell-style wildcard.
