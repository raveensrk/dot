# Newsboat

RSS reader. Config lives in [config/newsboat/config](../config/newsboat/config),
feeds in [config/newsboat/urls](../config/newsboat/urls).

Run it with the `newsboat2` alias from [config/bashrc](../config/bashrc), which
passes both files explicitly:

```sh
newsboat2
```

Install notes: [packages/newsboat.md](../packages/newsboat.md).
Tests: [tests/test_newsboat.py](../tests/test_newsboat.py).

## Theme: Chrome Teal

Dark, cyberpunk, tuned for low eye strain. Teal dominant, magenta accents.

### Design rules

The theme is not just a color list. These five rules are what keep "cyberpunk"
from becoming eye strain, and they explain most of the choices in the config.

1. **Neon is an accent, never a surface.** Article body text is soft off-white
   (`color252`). Saturated color appears only on the selection bar, info bar,
   unread rows, and inline accents.
2. **The selection bar is a dark saturated block** (`color23`), not a bright
   one. Bright inverted bars are the single largest strain source in a TUI.
3. **No pure black, no pure white.** Backgrounds inherit the terminal,
   foregrounds stop at `color252`.
4. **Hierarchy from dimming, not more hue.** Only two hue families are in play.
5. **Mid-luminance neons** (`80`, `117`, `176`, `213`), never `color51` or
   `color201`.

### Palette

Newsboat speaks only the 256-color palette. There is no hex or truecolor
support, so every value is an index.

| Index | Role |
|---|---|
| `color252` | Article body text |
| `color245` | Header labels, dim metadata |
| `color240` | Read rows |
| `color117` | Unread rows (cyan) |
| `color80` | Primary teal, header values |
| `color195` | Selection foreground |
| `color23` | Selection background |
| `color176` | Links |
| `color213` | Titles, hint keys |
| `color150` | Quotes, code spans |
| `color215` | ALL-CAPS runs |

### Read vs unread

Carried **entirely by color**. There is no `N` marker and no `(unread/total)`
counts in the list formats.

| State | Appearance |
|---|---|
| Unread | `color117` cyan, bold |
| Read | `color240` dark gray |
| Selected | `color195` on `color23`, whole row |

Consequence worth knowing: a partly-read feed now looks identical to a fully
unread one. That information used to come from the `(11/15)` counts.

## Traps

Each of these cost real debugging time. They are not in the man page.

### `unread` is article-only; feeds use `unread_count`

`highlight-feed "unread > 50"` is accepted at parse time and then fails at
render time with `attribute 'unread' is not available`, leaving the feed list
**completely empty**. The correct feed attribute is `unread_count`.

Confirmed valid feed attributes: `unread_count`, `total_count`, `title`,
`tags`, `feedurl`, `latest_article_age`.

### A highlight rule on a list view breaks the selection bar

Any `highlight feedlist`, `highlight articlelist`, `highlight-article`, or
`highlight-feed` rule paints its own foreground *and background* over the
characters it matches, which **overrides `listfocus`**. The result is a
selection bar that colors only the blank padding after the row text.

Use the built-in `listnormal`, `listnormal_unread`, `listfocus`, and
`listfocus_unread` elements instead. They distinguish read from unread *and*
respect focus. `highlight article` (the article **body**) is unaffected, since
the body has no focus bar to clobber.

### `hint-*` elements do not inherit the info bar background

They are drawn on top of the `info` bar. Any hint element left on a `default`
background punches a black hole in the strip and the bar looks like patchwork.
Give every `hint-*` element the same background as `info`.

### A parse check is not a render check

`newsboat -x print-unread` validates directives and filter *syntax*, but a
filter referencing a non-existent attribute still passes. Verify by rendering.

### The locale must be set

With `LANG` unset, newsboat aborts with
`iconv_open('', 'WCHAR_T') failed` **before printing the real error**, which
masks config problems entirely. Set `LANG`/`LC_ALL` when testing.

### No feed-delete keybinding exists

Newsboat has `delete-article` and `delete-all-articles`, both of which act on
articles. Nothing removes a feed or writes to the urls file. Use `E`
(`edit-urls`) to open the urls file in `$EDITOR`; the list reloads on save.
`Ctrl+R` (`reload-urls`) re-reads it if edited elsewhere.

## Browser

Newsboat falls back to `lynx` when `$BROWSER` is unset, which exits `127` when
lynx is not installed. The config format has no OS conditionals, so the
branching lives in [script/open_url](../script/open_url):

```
browser "open_url %u"
```

Resolution order: `$BROWSER`, then `open` (macOS), then `xdg-open` (Linux).

## Feed order

`feed-sort-order none` keeps feeds in the same order as the urls file. It is
the default, but is set explicitly so a sort option is not reintroduced by
accident.

## UI elements and their config names

Use these names when asking for a change, so the right directive gets touched.

| On screen | Config element |
|---|---|
| Top bar | `color title`, `*-title-format` |
| Feed and article rows | `color listnormal`, `color listnormal_unread` |
| Highlighted row | `color listfocus`, `color listfocus_unread` |
| Bottom key bar | `color info`, `color hint-key`, `color hint-description` |
| Article text | `color article`, `highlight article` |
| `~` filler below text | `color end-of-text-marker` |
| Reload progress line | Not themable. No config element exists. |

In-app help is `?`, which lists every keybinding for the **current context**.

## Verifying a change

Parse check, then render check. Both matter, for the reason above.

```sh
python3 -m pytest tests/test_newsboat.py -q
```

To eyeball the real output without touching your live cache, render it in tmux
against a copy:

```sh
cp ~/.newsboat/cache.db /tmp/vis.db
tmux new-session -d -s nb -x 100 -y 20 'LANG=en_US.UTF-8 newsboat -C config/newsboat/config -u config/newsboat/urls -c /tmp/vis.db'
tmux capture-pane -t nb -p -e | cat -v
```

`capture-pane -e` keeps the escape codes, so the actual colors can be asserted
rather than guessed. This is how the selection-bar bug was proven: the focused
row must be one unbroken run with `48;5;23` set once, with no `[0m` resets
punching holes in it.

## References

- Newsboat manual: `man newsboat`
- <https://newsboat.org/releases/2.43/docs/newsboat.html>
- 256-color chart: <https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html>
