" set autochdir

if exists("g:loaded_finder") 
	finish
else
	" echom "Loading finder..."
endif

nmap <unique> <leader>cd :cd %:h<CR>
nmap <unique> <leader>/ :BLines<CR>
nmap <unique> <leader>? :Lines<CR>
nmap <unique> <leader>a <C-6><CR>
nmap <unique> <leader>e :e ./
" nmap <unique> <leader>fb :b 
noremap <unique> <leader>fb :BufExplorer<CR>
nmap <unique> <leader>fc :e ~/.vimrc<CR>
nmap <unique> <leader>ff :find 
nmap <unique> <leader>fH :Helptags<CR>
nmap <unique> <leader>fi :echo expand("%:p")<cr>
nmap <unique> <leader>fl :Lines<CR>
nmap <unique> <leader>fp :let @+ = expand("%:p")<cr>
" nmap <unique> <leader>fr :browse oldfiles<CR>
nmap <unique> <leader>gf :e <cfile><CR>
nmap <unique> <leader>h :help 
nmap <unique> <leader>fh :FuzzyHelps<cr>
nmap <unique> <leader>q :q<CR>
nmap <unique> <leader>r :RangerChooser<cr>
nmap <unique> <leader>w :w<CR>

set path+=$HOME/dot/**
set path+=$HOME/script/**
set path+=$HOME/work/**

let g:loaded_finder=1
" echom "Finder Loaded..."
