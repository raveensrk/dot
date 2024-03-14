" Contains all my abbreviations
" --------------------------------
ab vaild valid
ab teh the
ab fro for
ab dispaly display

function! Eatchar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunction
" iabbr <silent> if if ()<Left><C-R>=Eatchar('\s')<CR>
iab lr <C-R>=printf("<leader")<CR><C-R>=Eatchar('\s')<CR>><C-R>=Eatchar('\s')<CR>
iab --- ------------------------------------------------------------------------------  
iab #! #!/usr/bin/env bash<CR>
