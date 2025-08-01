" Replace

nmap <leader>R$ :.,$s///gc<Left><Left><Left>
nmap <leader>R% :%s///gc<Left><Left><Left>
nmap <leader>R. :s///gc<Left><Left><Left>
nmap <leader>Rw :%s+\<\>++gc<Left><Left><Left>

vmap <leader>R% y:%s+"++gc<Left><Left><Left>
vmap <leader>R. y:s+"++gc<Left><Left><Left>
vmap <leader>Rw y:%s+\<"\>++gc<Left><Left><Left>

nmap <leader>S  :tab   split<CR>:term<cr>
nmap <leader>T  :tab   split<CR>
nmap <leader>X  :.!bash<CR>:redraw!<CR>
nmap <leader>Z  :windo set scrollbind!<CR>
nmap <leader>fx :set   winfixbuf!<CR>
nmap <leader>z  <C-w>

" Sourcing

" Source full file
nmap <leader>s  :so<cr>
xmap <leader>x  :so<CR>
 
" Source Current line
nmap <leader>x  :.so<CR>

" Source Current line in bash and replace it with bash results
xmap <leader>X  :!bash<CR>:redraw!<CR>

" Simple Auto Completions
" imap <TAB>        <C-n>
" imap <S-TAB>      <C-p>
" imap <TAB><TAB>    <C-x><C-l>

" Move up and down based on display lines by default
nnoremap gj j
nnoremap gk k
nnoremap j gj
nnoremap k gk

nnoremap <up> g<up>
nnoremap <down> g<down>
nnoremap g<up> <up>
nnoremap g<down> <down>

vnoremap gj j
vnoremap gk k
vnoremap j gj
vnoremap k gk

vnoremap <up> g<up>
vnoremap <down> g<down>
vnoremap g<up> <up>
vnoremap g<down> <down>

" Finding word under cursor
nmap <leader>fw :vim /\C\<\>/ $PWD/**/*<left><left><left><left>

" Start searching all my projects directors for notes in *.md
nmap <leader>fn :NGrep<CR>
