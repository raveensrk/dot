
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
