
function! Bookmark() abort
    let bookmark=expand("%:p:~").":".line(".").":".col(".")." # ".getline(".")
    echowindow bookmark
    redir! >> ~/.bookmarks | echo bookmark | redir END
endfunction

command! BookmarkAdd call Bookmark()
command! BookmarkList tabnew ~/.bookmarks
command! BA call Bookmark()
command! BL tabnew ~/.bookmarks
let g:EasyMotion_keys = 'arstzxcvqwfp'
let g:EasyMotion_smartcase = 1
nnoremap ,f <Plug>(easymotion-s)


" This will highlight the current word but dont change cursor
nnoremap <leader>* *<C-o>
vnoremap <leader>* *<C-o>
" Same as before but partial match
nnoremap <leader>g* g*<C-o>
vnoremap <leader>g* g*<C-o>

" Search for word under cursor in all windows
nnoremap <leader>w* :windo /<C-r><C-w>/<CR>

