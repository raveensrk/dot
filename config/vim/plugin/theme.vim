hi CurSearch ctermbg=black ctermfg=1
hi Search ctermbg=black ctermfg=154
" set cursorline
" set cursorlineopt=screenline,number
" set columns=80
" set colorcolumn=+1
" set cursorcolumn
autocmd BufEnter,WinEnter * highlight ALEInfoLine ctermfg=3 ctermbg=black
autocmd BufEnter,WinEnter * highlight ALEInfo ctermfg=white ctermbg=black
autocmd BufEnter,WinEnter * highlight ALEWarning ctermbg=black ctermfg=1
autocmd BufEnter,WinEnter * highlight ALEWarningLine ctermbg=black ctermfg=white
autocmd BufEnter,WinEnter * highlight ALEError ctermbg=black ctermfg=red
autocmd BufEnter,WinEnter * highlight ALEErrorLine ctermbg=black ctermfg=white
autocmd BufEnter,WinEnter * highlight clear CursorLine
autocmd BufEnter,WinEnter * highlight clear CursorLineNr
autocmd BufEnter,WinEnter * highlight clear CursorColumn
autocmd BufEnter,WinEnter * highlight CursorLine ctermbg=black
autocmd BufEnter,WinEnter * highlight ColorColumn ctermbg=black
autocmd BufEnter,WinEnter * highlight CursorColumn ctermbg=black
autocmd BufEnter,WinEnter * highlight CursorLineNr ctermbg=black
set laststatus=2
" highlight NonText ctermfg=green ctermbg=black
highlight SpecialKey ctermfg=2 ctermbg=NONE
highlight Normal ctermbg=NONE
