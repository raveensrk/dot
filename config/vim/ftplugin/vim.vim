set nowrap
set number
" TODO :IS
iab ff function! name () abort<CR>endfunction
set isk+=:
syntax match Entity "function" conceal cchar=ﬀ
syntax match Entity "endfunction" conceal cchar=ë
set conceallevel=2
hi Conceal ctermfg=green
