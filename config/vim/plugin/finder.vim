set autochdir
" nmap <leader>fr :bro ol<cr>
nmap <leader>a <C-6><CR>
nmap <leader>d :bd<cr>
nmap <leader>fb :b 
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>ff :find 
nmap <leader>fg :vimgrep // **<Left><Left><Left><Left>
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @+ = expand("%:p")<cr>
nmap <leader>gf :e <cfile><CR>
nmap ,c :cwindow<cr>
nmap ,n :cnext<cr>
nmap ,p :cprevious<cr>
set list
" auto BufEnter * let &titlestring = hostname() .. "/" .. expand("%:p")
set title titlestring=%F titlelen=70
" set grepprg=grep\ -RnH\ $*\ --exclude=\"tags\"\ --exclude=\"TAGS\"\ /dev/null
set grepprg=RIPGREP_CONFIG_PATH=~/dot/config/ripgrep\ rg\ --no-heading\ --with-filename\ --column\ -g\ !tags\ -g\ !TAGS\ $*
