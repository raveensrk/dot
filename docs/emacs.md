# Emacs

The restored config lives in [config/emacs/init.el](../config/emacs/init.el).
The local Emacs init file loads it; package downloads and runtime state remain
outside this repository. Installation: [packages/emacs.sh](../packages/emacs.sh).

## Agenda discovery

[org_agenda.el](../config/emacs/org_agenda.el) populates `org-agenda-files`
recursively from `~/dot` and `~/repos` before Org builds an agenda. This also
covers direct agenda commands and rebuilds (`g` in the agenda).

1. Include `.org` files at every depth, including hidden and gitignored files.
2. Skip `.git` directories and do not traverse directory symlinks.
3. Resolve file symlinks and remove duplicates from overlapping roots.
4. Warn about missing roots instead of silently retaining stale files.
5. Leave `.org_archive` files out of the normal agenda. Use Org's archive mode
   (`v A` in the agenda) to include archive files when needed.

Existing sticky agenda buffers remain cached until rebuilt. Run
`M-x dot-org-refresh` to refresh the file list explicitly. Override
`dot-org-roots` if the repository locations change.

Discovery does not migrate tasks, modify Org files, validate the task schema,
or change the Markdown scanner.

## Capture

The `c` capture template writes a raw heading to `inbox.org` at the root of
the current buffer's Git repository. It uses the nearest `.git` marker,
including worktree and submodule markers, and creates the inbox if needed.
Outside a repository, capture stops with an error instead of choosing a fallback.
Open a buffer in the intended repository before capturing from an agenda.

Entries remain raw headings, not `TODO` tasks, until triaged. Existing inbox
content is retained. The Org ID cache lives under `user-emacs-directory`, not
in a repository or the old `org` directory.

## First run and packages

`init.el` bootstraps [straight.el](https://github.com/radian-software/straight.el)
from the network, then clones and builds every `use-package` form (59 direct
forms, 89 repositories, 90 builds as of this writing). Run this once after
installing Emacs:

```sh
emacs --batch -l ~/.emacs.d/init.el --eval '(princ "\n=== INIT OK ===\n")'
```

Expect a clean exit and `=== INIT OK ===`. First run takes several minutes and
needs network access; later runs reuse `~/.emacs.d/straight` and finish in
seconds.

`custom.el` was pruned of two dead historical entries: `custom-enabled-themes
'(cyberpunk)`, which failed because `custom.el` loads before straight clones
the theme, and an `org-capture-templates` pointing at the old `~/org/capture`.
Both were superseded by `init.el` and [org_agenda.el](../config/emacs/org_agenda.el).
The only remaining first-run message is `Failed to restore scratch buffers`,
which clears after the first scratch save.

## Verification

Run the isolated discovery and agenda integration tests without loading the
full config or downloading packages:

```sh
python3 -m unittest discover -s tests -p test_emacs_org.py
```

The Python test runs Emacs ERT tests under `emacs -Q --batch`.
