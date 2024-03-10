iab #!,          #!/usr/bin/env bash<CR><CR>
iab arg_parse,   <ESC>:read $DOT/snippet/sh/arg_parse.txt<CR>i
iab ask,         <ESC>:read $DOT/snippet/sh/ask.txt<CR>i
iab case,        <ESC>:read $DOT/snippet/sh/case.txt<CR>i
iab cv,          <ESC>:read $DOT/snippet/sh/cv.txt  <CR>i
iab if,          if [[ $var == 1 ]]; then<CR>fi
set iskeyword+=,
set number
set nowrap
let g:ale_sh_shellcheck_options = '-x -P ~/dot -P ~/script -P ~/dot/config -P ~/'

autocmd BufEnter PKGBUILD,.env
            \   let b:ale_sh_shellcheck_exclusions = 'SC2034,SC2154,SC2164'
let g:ale_sh_shfmt_options =''
