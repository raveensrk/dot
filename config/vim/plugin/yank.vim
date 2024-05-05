autocmd! TextYankPost * redir >> /tmp/vim_yank
            \ | silent echo @"
            \ | redir END
command! YankRing call execute('tabnew /tmp/vim_yank | norm G')
nmap ,y :YankRing<cr>
