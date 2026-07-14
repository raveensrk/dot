# Todo search script

`script/,todo.py` searches configured directories for outstanding Markdown tasks.
It is a pure Python CLI using ripgrep's JSON output as the scanning engine. By
default, it scans only Markdown extensions and opens matches in Vim's quickfix
list. Source comments are an explicit opt-in.

## Requirements

- Python 3.11 or newer
- ripgrep
- Vim for the default quickfix format
- fzf only when using `--format fzf`

## Accepted entries

Keyword entries require a colon and non-empty content:

```markdown
- TODO: Write the release notes
  - IN_PROGRESS: Test the migration
```

Checkbox entries use standard Markdown checkbox syntax:

```markdown
- [ ] Review the pull request
```

Entries may be indented, but only spaces or tabs may appear before the list
marker. Embedded keywords, missing colons, and empty content do not match.

## Source comments

With `--all-extensions`, files listed in `source_extensions` accept configured
keywords after a recognized comment prefix. Both full-line and inline comments
match:

```python
# TODO: Add input validation
run_migration()  # FIXME: Make this operation atomic
```

```systemverilog
// BUG: Reset sequencing is incorrect
/* LATER: Refactor the compatibility layer */
```

Bare keywords inside strings and identifiers such as `TODO_CONFIG` do not match.
Markdown files are excluded from source-comment scanning so headings and examples
are not mistaken for source comments.

Source matching is deliberately line-oriented rather than language-aware. A
comment-looking sequence inside a string can therefore match in some languages;
use `source_extensions` and `ignore` to keep the scan focused.

## Usage

Run without arguments to scan `default_dirs` and open Vim:

```bash
,todo.py
```

The default scan includes only files listed in `extensions`. Add
`--all-extensions` to also scan files listed in `source_extensions`:

```bash
,todo.py --all-extensions
,todo.py --all-extensions ~/repos/project
```

Pass one or more paths to override the configured roots:

```bash
,todo.py ~/repos/project ~/iCloud/notes
```

Missing roots produce a warning and are skipped. The scan fails only when none
of the requested roots exist.

Select a non-interactive or alternate output format with `--format`:

```bash
,todo.py --format plain
,todo.py --format fzf
,todo.py --format json
,todo.py --format markdown
```

The `plain` format is Vim-compatible `file:line:column:text`. The `fzf` format
opens the selected match in `${EDITOR:-vim}`. JSON and Markdown are suitable for
automation and reports. With no matches, plain output is empty, JSON returns
`[]`, and Markdown returns an empty report.

Each matching line produces one result. Ripgrep's structured output also allows
the scanner to handle colons in paths and decode non-UTF-8 matches safely.

## Configuration

`config/todo.toml` defines `patterns` for keyword entries and
`checkbox_patterns` for checkbox entries. Both arrays contain ripgrep regular
expressions. Markdown extensions, optional source extensions, recognized comment
prefixes, default search directories, and ignored paths live in the same file.

Set `TODO_CONFIG` to select another TOML file. When it is unset, the scanner uses
the repository's `config/todo.toml`, followed by
`$XDG_CONFIG_HOME/todo/config.toml` as the external installation fallback.

`source_extensions` is consulted only with `--all-extensions`. An empty array
disables source scanning entirely:

```bash
source_extensions = ["py", "sh", "bash", "sv", "svh", "v", "vim"]
```

Files listed in `extensions` always use Markdown parsing, even if an extension is
accidentally repeated in `source_extensions`.

Ripgrep's normal ignore behavior applies, including `.gitignore` files. The
additional `ignore` array can exclude paths across all configured roots.
