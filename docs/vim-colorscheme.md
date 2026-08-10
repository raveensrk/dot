# Vim colorscheme

Set in `config/vim/after/plugin/colorscheme.vim`: `enfocado` (dark), with
`gruvbox` and `desert` kept commented as fallbacks.

## Tried and rejected

[`c9rgreen/vim-colors-modus`](https://github.com/c9rgreen/vim-colors-modus) —
WCAG AAA contrast, the scheme that best matches the eye-comfort research
(dark-on-light measurably beats light-on-dark for acuity and proofreading;
low-contrast schemes like Solarized feel restful but increase fatigue). Tried
it, did not like it, uninstalled. Sticking with enfocado and gruvbox.

Untried alternatives, noted so they are not re-researched:
[tempus-themes-vim](https://github.com/protesilaos/tempus-themes-vim) (WCAG AA,
16-colour so no `termguicolors` needed) and
[chasinglogic/modus-themes-vim](https://vimcolorschemes.com/chasinglogic/modus-themes-vim).

## Installing

Pathogen, no manifest — a plugin is just a git clone in `~/.vim/bundle/`:

```bash
git clone --depth 1 <repo-url> ~/.vim/bundle/<name>
```

`rm -rf` that directory to remove one. True-colour schemes also need
`set termguicolors`.
