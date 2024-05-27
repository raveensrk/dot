function! BufferDelete() abort
    let buffers = split(execute("ls"), "\\n")
    let is_last_buffer = len(buffers)
    echom is_last_buffer
    if (is_last_buffer==1)
        execute "quit"
    else
        execute "bdelete"
    endif
endfunction

command! BufferDelete call BufferDelete()
nmap <leader>d :BufferDelete<CR>

