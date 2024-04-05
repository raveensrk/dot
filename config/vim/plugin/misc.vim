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
set nu
command! LazyGit !lazygit
command! LG !lazygit

nmap <C-w>> <C-w>><C-w>
nmap <C-w>< <C-w><<C-w>

command! GB Git add . | Git commit -m "Bug fix" | Git push
command! -range Align <line1>,<line2>EasyAlign */ \|(\|)\|=\|[\|\]\|;/ 
