nmap <leader>R$ :.,$s///gc<Left><Left><Left>
nmap <leader>R% :%s///gc<Left><Left><Left>
nmap <leader>R. :s///gc<Left><Left><Left>
nmap <leader>Rw :%s+\<\>++gc<Left><Left><Left>
nmap <leader>S  :tab   split<CR>:term<cr>
nmap <leader>T  :tab   split<CR>
nmap <leader>X  :.!bash<CR>:redraw!<CR>
nmap <leader>Z  :windo set scrollbind!<CR>
nmap <leader>fx :set   winfixbuf!<CR>
nmap <leader>s  :so<cr>
nmap <leader>x  :.so<CR>
nmap <leader>z  <C-w>
vmap <leader>R% y:%s+"++gc<Left><Left><Left>
vmap <leader>R. y:s+"++gc<Left><Left><Left>
vmap <leader>Rw y:%s+\<"\>++gc<Left><Left><Left>
xmap <leader>X  :!bash<CR>:redraw!<CR>
xmap <leader>x  :so<CR>

" Simple Auto Completions
" imap <TAB>        <C-n>
" imap <S-TAB>      <C-p>
" imap <TAB><TAB>    <C-x><C-l>
