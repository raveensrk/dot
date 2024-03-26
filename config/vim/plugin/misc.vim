let g:sneak#label = 1
let g:colorizer_auto_color = 1
let g:colorizer_conceal_cursor_mode='nvc'
let g:ale_virtualtext_cursor=0
set ttimeoutlen=9000 ttimeout timeout timeoutlen=9000
nmap ,gg :!google  

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


command! DiffWithSaved :w !diff % -
command! TrimWhiteSpace %s/ \+$//g
command! KeyCodes :help keycodes
command! YankHistory redir! > /tmp/vim_history | history cmd -20, | redir END | tabnew /tmp/vim_history 
function! Bookmark() abort
    let bookmark=expand("%:p:~").":".line(".").":".col(".")." # ".getline(".")
    echowindow bookmark
    redir! >> ~/.bookmarks | echo bookmark | redir END
endfunction
command! BookmarkAdd call Bookmark()
nmap ,bm :BookmarkAdd<CR>
nmap ,bl :tabnew ~/.bookmarks<CR>
command! BookmarkList tabnew ~/.bookmarks
let g:EasyMotion_keys = 'arstzxcvqwfp'
let g:EasyMotion_smartcase = 1
nnoremap ,f <Plug>(easymotion-s)
set laststatus=2

command! TitleCase s/\v<(.)(\w*)/\u\1\L\2/g
" highlight NonText ctermfg=green ctermbg=black
highlight SpecialKey ctermfg=2 ctermbg=NONE
highlight Normal ctermbg=NONE
let g:enable_fuzzyy_keymaps = 0
nmap <leader>gs :echowindow "Git status..."<CR>:Git<CR>
nmap <leader>gp :echowindow "Git push..."<CR>:Git push<CR>

command! SnippetRead fzf#run({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'sink': 'read'})
inoremap <expr> <c-x>s fzf#vim#complete({'dir': '~/dot/config/vim/snippet', 'source': 'find . -type f', 'reducer': { lines -> join(readfile(lines[0]))}})


