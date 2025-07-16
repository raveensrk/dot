" This is a workaround for the issue where Copilot does not work in macOS when
" another node is installed.
" BUG fix https://github.com/orgs/community/discussions/16800
let g:copilot_node_command = "/opt/homebrew/bin/node"


let g:copilot_filetypes = {
			\ 'journal': v:true,
			\ }

" Accept the Copilot suggestion next word with <TAB>

imap <C-L> <Plug>(copilot-accept-word)
