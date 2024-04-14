let g:ale_sh_shellcheck_options = '-x -P ~/dot -P ~/script -P ~/dot/config -P \~/ '
autocmd BufEnter PKGBUILD,.env
            \   let b:ale_sh_shellcheck_exclusions = 'SC2034,SC2154,SC2164'
let g:ale_sh_shfmt_options =''
set formatprg=shfmt
set nospell
set isk+=,
