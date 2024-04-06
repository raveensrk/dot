set autochdir
nmap ,cd :cd %:h<CR>
nmap <leader>/ :BLines<CR>
nmap <leader>? :Lines<CR>
nmap <leader>a <C-6><CR>
nmap <leader>fb :b 
nmap <leader>fc :e ~/.vimrc<CR>
nmap <leader>ff :find *
nmap <leader>e :e ./
nmap <leader>fi :echo expand("%:p")<cr>
nmap <leader>fp :let @+ = expand("%:p")<cr>
nmap <leader>gf :e <cfile><CR>
nmap <leader>h :help 
nmap <leader>q :q<CR>
nmap <leader>r :RangerChooser<cr>
nmap <leader>w :w<CR>
set title titlestring=%F titlelen=70
set path+=$HOME/dot/**
set path+=$HOME/script/**
set path+=~/work/**/**
