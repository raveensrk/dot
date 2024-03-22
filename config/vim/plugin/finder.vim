set autochdir
nmap ,cd :cd %:h<CR>
nmap <leader>/ :BLines<CR>
nmap <leader>? :Lines<CR>
nmap <leader>a <C-6><CR>
nmap <leader>d :bd<cr>
nmap <leader>fb :b 
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>ff :find *
nmap <leader>fg :cd %:h \| vimgrep // **<Left><Left><Left><Left>
nmap <leader>f. :e ./
nmap <leader>F :find ~/dot/**/*
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @+ = expand("%:p")<cr>
nmap <leader>gf :e <cfile><CR>
nmap <leader>h :help 
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>w :w<CR>
set grepprg=RIPGREP_CONFIG_PATH=~/dot/config/ripgrep\ rg\ --no-heading\ --with-filename\ --column\ -g\ !tags\ -g\ !TAGS\ $*
set title titlestring=%F titlelen=70
set path+=~/dot/**/**
