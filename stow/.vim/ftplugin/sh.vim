" Vim skeleton for bash scripts
autocmd BufNewFile  *.bash	0r ~/.vim/skeleton/bash
iab arg_parse <ESC>:read ~/.vim/my_snippets/sh/arg_parse.txt<CR>i
iab if if [ ];then<CR>fi
iab #! #!/usr/bin/env bash<CR><CR>
iab ask <ESC>:read ~/.vim/my_snippets/sh/ask.txt<CR>i
