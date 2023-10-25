vim.cmd([[
let mapleader=" "
set winbar=%f
set laststatus=3
set cmdheight=0
set mousescroll=ver:1,hor:1
set rnu nu 
" let &stc='%#NonText#%{&nu?v:lnum:""}%=%{&rnu&&(v:lnum%2)?"\ ".v:relnum:""}%#LineNr#%{&rnu&&!(v:lnum%2)?"\ ".v:relnum:""}'
set jumpoptions=view
nmap <leader>w :w<cr>
nmap <leader>% :%so<cr>

]])

