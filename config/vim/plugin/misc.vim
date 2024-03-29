set ttimeoutlen=9000 ttimeout timeout timeoutlen=9000
nmap ,gg :!google  
command! DiffWithSaved :w !diff % -
command! TrimWhiteSpace %s/ \+$//g
command! KeyCodes :help keycodes
command! YankHistory redir! > /tmp/vim_history | history cmd -20, | redir END | tabnew /tmp/vim_history 
let g:enable_fuzzyy_keymaps = 0

command! -nargs=1 -complete=dir TagsGen !ctags -R <args>
let g:fuzzyy_window_layout = { 'FuzzyFiles': { 'preview': 0 } }
let g:fuzzyy_window_layout = { 'FuzzyMRUFiles': { 'preview': 0 } }

command! FIX set winfixbuf

command! LazyGit !lazygit
