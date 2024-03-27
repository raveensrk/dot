function! Bookmark() abort
    let bookmark=expand("%:p:~").":".line(".").":".col(".")." # ".getline(".")
    echowindow bookmark
    redir! >> ~/.bookmarks | echo bookmark | redir END
endfunction
command! BookmarkAdd call Bookmark()
command! BookmarkList tabnew ~/.bookmarks
command! BA call Bookmark()
command! BL tabnew ~/.bookmarks
