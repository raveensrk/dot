---
id: "dencyfm9ca"
title: "Continue the ~/dot/script review"
state: "todo"
due: "2026-10-30"
priority: ""
tag: ["maintenance"]
repeat: ""
effort: ""
postpone: 1
created: "2026-10-14"
closed: ""
---

## Where we stopped (2026-10-14)

One-by-one review of `~/dot/script`, alphabetical. Next item:
`change_permissions_recursive.py` (recommended: delete; hard-coded 777 on a
missing /Users/raveenkumarwork/tmp, not executable). About 94 scripts without a
comma remain after it.

## How each item goes

1. Read the script, count uses in [.bash_history](~/.bash_history), search [dot](~/dot),
   [agent1](~/repos/agent1), [agent2](~/repos/agent2) and [work](~/repos/work)
   for callers.
2. Describe it and ask one question: delete, rename, or keep.
3. Kept scripts get a comma name, a header line, and -h/--help/help.
4. A useful one-liner from a deleted script becomes a note in
   [work/deck](~/repos/work/deck) (one home per note).
5. Commit per item; lint with [lint.py](~/repos/agent1/harness/lint.py).

## Naming rule

[cli.md](~/repos/agent1/cli.md): grammatical English, easy to say, real words; an
abbreviation only where people say it that way (pdf, csv, git).

## Still pending

1. Renames under the naming rule, ask one by one:
   ,ls_comma_cmds -> ,list_comma_commands; ,ls_path_dirs -> ,list_path_folders;
   ,reg_offsets.py -> ,print_register_offsets; ,date_print_iso -> ,print_iso_date;
   ,claude_yolo -> ,claude_without_permission_checks; ,pi_bare -> ,pi_without_extras;
   ,append_date_loop.sh -> ,log_date_every_second; ,yt_watch_later -> ,youtube_watch_later.
2. [unix.md](~/repos/work/deck/unix/unix.md) fails mdformat because of broken
   backticks around line 359; fix by hand (mdformat garbles them).
3. Homebrew python3 3.15 lacks pytest and PyYAML; run tests with
   `uv run --with pytest`.


## Progress 2026-10-21

- change_permissions_recursive.py was already deleted (b1ade33a); the stop
  point above was stale. Scripts through `combine_text` and `commands` were
  done in later commits.
- compress_pdf kept: now `,compress_pdf` on ghostscript, with help (dc7437e2).
- Next item: `convert_md_to_individual_pdf`.
- Commit by path (`git commit -- <paths>`): other sessions stage changes in
  this repo, and a plain `git commit` sweeps them in.


- convert_md_to_individual_pdf kept: now `,convert_markdown_to_pdfs`, pandoc
  with typst (pdflatex is not installed), folders as arguments.
- Next item: `convert_md_to_pdf_book` - same pdflatex failure, same fix.
