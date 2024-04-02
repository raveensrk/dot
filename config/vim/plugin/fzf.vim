nmap <leader>h :FuzzyHelps<cr>
let g:fzf_vim = {}
let g:fzf_layout = { 'down': '40%' }
" let g:fzf_preview_window = ['hidden', 'right,50%', 'ctrl-/']
let g:fzf_preview_window = []
let g:fzf_buffers_jump = 1
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'
let g:fzf_tags_command = 'ctags -R'
let g:fzf_commands_expect = 'alt-enter,ctrl-x'
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
imap <expr> <c-x>f fzf#vim#complete#path('rg --hidden --files')
imap <c-x>k <plug>(fzf-complete-word)
imap <c-x>l <plug>(fzf-complete-line)
inoremap <expr> <c-x><c-k> fzf#vim#complete#word()
nmap <leader>f. :DOT<CR>
command! -bang DOT call fzf#vim#files('$HOME/dot', <bang>0)
command! -bang -nargs=? -complete=dir Files 
            \ call fzf#vim#files(<q-args>, {'options': ['--exact', '--layout=reverse', '--info=inline']}, <bang>0)

inoremap <expr> <c-x>L fzf#vim#complete(fzf#wrap({
      \ 'prefix': '^.*$',
      \ 'source': g:rgsource,
      \ 'options': '--ansi --delimiter : --nth 3..',
      \ 'reducer': { lines -> join(split(lines[0], ':\zs')[2:], '') }}))

function! s:make_sentence(lines)
    return substitute(join(a:lines), '^.', '\=toupper(submatch(0))', '').'.'
endfunction

inoremap <expr> <c-x><c-s> fzf#vim#complete({
      \ 'source':  'cat /usr/share/dict/words',
      \ 'reducer': function('<sid>make_sentence'),
      \ 'options': '--multi --reverse --margin 15%,0',
      \ 'left':    20})

let g:fzf_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
    copen
    cc
endfunction

let g:fzf_action = {
            \ 'ctrl-q': function('s:build_quickfix_list'),
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

let g:fzf_colors =
            \ { 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'Ignore'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'] }

let g:fzf_history_dir = '~/.local/share/fzf-history'

let g:fzf_vim.listproc = { list -> fzf#vim#listproc#location(list) }

set autochdir
command! FDot Files ~/dot 
" nmap <leader>fb :Buffers<cr>
function! FindFiles () abort
    set wildoptions=pum,fuzzy,tagfile
    let dir=expand("%:p:h:~:.")
    let dir=input("Enter dir path to search: ", dir, "dir")
    redraw!
    let cmd =  "Files "..dir
    call histadd("cmd", cmd)
    execute cmd
    echowindow cmd
    set wildoptions=fuzzy,tagfile
endfunction
command! FindFiles call FindFiles()
" nmap <leader>ff :FindFiles<cr>
nmap <leader>fr :History<CR>
nmap <leader>fl :Lines<CR>
nmap <leader>fh :Helptags<CR>
