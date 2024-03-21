set autochdir
nmap <leader>ff :find 
nmap <leader>fg :vimgrep // **<Left><Left><Left><Left>
nmap <leader>fb :b 
" nmap <leader>fr :bro ol<cr>
nmap <leader>gf :e <cfile><CR>
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>a <C-6><CR>
nmap <leader>d :bd<cr>
nmap <leader>fp :let @+ = expand("%:p")<cr>
nmap ,c :cwindow<cr>
nmap ,n :cnext<cr>
nmap ,p :cprevious<cr>
set list
