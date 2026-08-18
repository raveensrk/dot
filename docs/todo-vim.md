# Todo in Vim

Buffer-local plugins for editing todo items ([todo-schema.md](todo-schema.md)) in
Markdown. They live in `config/vim/ftplugin/markdown/` and load automatically for
`.md` buffers via the `runtimepath` entry in `config/vimrc` — no install step.

`config/vim/autoload/todo.vim` holds what they share: `todo#states()` reads the
`states` array out of `config/todo.toml` (honouring `$TODO_CONFIG`, falling back
to the schema's five), and `todo#line_pattern()` builds the todo-line regex from
it. So the state vocabulary is defined once and `,todo.py --states` agrees with
Vim.

## Commands

| Command | Mapping | What it does |
|---|---|---|
| `:TodoState [STATE]` | `,x` | Cycle the line's state forward, or set `STATE` directly |
| `:TodoStateBack` | — | Cycle backward |
| `:TodoShiftDue` / `:TodoShiftDueBack` | `<S-Right>` / `<S-Left>` | Shift `due:` by one `recurring:` interval |
| `:TodoFilterDue` | `,D` | Fold everything except due/overdue items and their sub-items |
| `:Todo` / `:Todo!` | `,t` / `,d` | Cross-file quickfix from `,todo.py` (defined in `config/vimrc`) |

## State cycling

`:TodoState` steps through the configured states and then one stateless slot,
wrapping both ways:

```
- Buy milk        ->  - TODO: Buy milk
- TODO: ...       ->  - IN_PROGRESS: ...
- IN_PROGRESS:    ->  - OPTIONAL: ...
- OPTIONAL: ...   ->  - DONE: ...
- DONE: ...       ->  - OBSOLETE: ...
- OBSOLETE: ...   ->  - Buy milk
```

Only the state token is rewritten. Indent, bullet character, and every metadata
field (`+Project`, `@Context`, `due:`, `recurring:`, priority) survive untouched —
no `created:`/`completed:` bookkeeping happens, by design.

`,x` cycles the line under the cursor; in visual mode it cycles every selected
line. Both commands also take a range directly, so `:'<,'>TodoState` marks a
selection and `:%TodoState` a whole file; non-list lines in the range are
skipped. `:TodoState` takes an argument to jump straight to a state
(`:TodoState DONE`, or `:TodoState NONE` to strip it); it is case-insensitive and
tab-completes. `:TodoStateBack` is unbound — run it as a command.

Checkbox items (`- [ ] ...`) are left alone — `<CR>` cycles those through
`[ ]`/`[x]`/`[o]` via `ToggleCheckBox()` in `config/vim/ftplugin/markdown.vim`.

To bind another key (`<CR>` is taken by `ToggleCheckBox`), add it to the local
overlay:

```vim
" ~/dot_local/config/vim/ftplugin/markdown/local.vim
nnoremap <buffer> <silent> ,X :<C-u>TodoStateBack<CR>
```

## Highlighting

`config/vim/after/syntax/markdown/todo.vim` colours the state token, tags, dates
and priority. `todo_due.vim` adds a background tint to `TODO`/`IN_PROGRESS` lines
by due date (overdue, today, tomorrow) using text properties, since syntax rules
cannot compare dates.

## Tests

`tests/test_todo_state_vim.py` drives headless Vim over a temp file, the same way
`tests/test_spaced_text.py` does. Run with `python3 -m pytest tests/`.
