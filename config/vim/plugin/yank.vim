autocmd! TextYankPost * redir >> /tmp/vim_yank
            \ | silent echo ""
            \ | silent echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            \ | silent echo @"
            \ | redir END
command! YankRing tabnew /tmp/vim_yank
nmap ,y :YankRing<cr>G
