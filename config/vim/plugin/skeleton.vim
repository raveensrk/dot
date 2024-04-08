autocmd BufNewFile *.bash	0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sh		0read $DOT/config/vim/skeleton/bash
autocmd BufNewFile *.sv		0read $DOT/config/vim/skeleton/sv/main.sv
command! Skeleton :read ~/dot/config/vim/skeleton/bash
