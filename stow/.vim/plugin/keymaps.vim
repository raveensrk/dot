" imap nnn <Esc>
" This will create a file under cursor
nmap <leader>gf :e <cfile><CR>
" Find all reference of the string under cursor
nnoremap <leader>ref :grep  * -r<CR>
nmap     <leader>= gg=G2<C-o>
nnoremap Y yg_
nmap     <leader>b :Buffers<CR>
nnoremap <leader>t :set nowrap!<cr>
nnoremap <leader>n :set nu!<cr>
nnoremap <leader>s :so %<cr>
nnoremap <leader>fp :let @* = expand("%:p")<cr>
