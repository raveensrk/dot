" command! FIX set winfixbuf
" nmap <leader>F :set winfixbuf!<cr>
nmap     <leader>.              :e .<CR>
nmap     <leader><down>         :tabnext<cr>
nmap     <leader><leader><down> :lnext<cr>
nmap     <leader><leader><up>   :lprevious<cr>
nmap     <leader><left>         :bp<cr>
nmap     <leader><right>        :bn<cr>
nmap     <leader><up>           :tabprev<cr>
nmap     <leader>D              :bd!<cr>
nmap     <leader>K              :%bd\|e#<cr>
nnoremap <C-N>                  :bnext<CR>
nnoremap <C-P>                  :bprev<CR>

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

