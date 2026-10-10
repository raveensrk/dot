" Colorscheme: enfocado (dark); gruvbox and desert kept below as fallbacks.
"
" Tried and rejected: c9rgreen/vim-colors-modus (WCAG AAA; matches the
" eye-comfort research - dark-on-light beats light-on-dark for acuity and
" proofreading, and low-contrast schemes like Solarized raise fatigue). Did
" not like it, uninstalled.
" Untried, noted so they are not re-researched:
"   https://github.com/protesilaos/tempus-themes-vim (WCAG AA, 16-colour,
"   no termguicolors needed)
"   https://vimcolorschemes.com/chasinglogic/modus-themes-vim
"
" Install a scheme with pathogen (no manifest, a plugin is a git clone):
"   git clone --depth 1 <repo-url> ~/.vim/bundle/<name>
" Remove it by deleting that directory. True-colour schemes also need
" `set termguicolors`.

colo enfocado
set background=dark

" Fallback

" colo gruvbox
" let g:gruvbox_contrast_dark="hard"
" set background=dark

" colo desert
" set background=dark
