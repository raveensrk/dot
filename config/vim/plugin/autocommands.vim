" Refuse to open files larger than 10 MB
" Set the threshold (e.g., 10MB = 10 * 1024 * 1024 bytes)
let g:large_file_limit = 10485760

augroup PreventLargeFiles
    autocmd!
    autocmd BufReadPre * let fsize = getfsize(expand("<afile>"))
		\ | echo "File size = " . fsize
        \ | if fsize > g:large_file_limit
        \ |   echoerr "Error: File is too large (" . (fsize / 1024 / 1024) . "MB). Refusing to open."
        \ |   execute "bdelete"
        \ | endif
augroup END



