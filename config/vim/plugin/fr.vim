set laststatus=2
func! QfOldFiles(info)
    " get information about a range of quickfix entries
    let items = getqflist({'id' : a:info.id, 'items' : 1}).items
    let l = []
    for idx in range(a:info.start_idx - 1, a:info.end_idx - 1)
        " use the simplified file name
        call add(l, fnamemodify(bufname(items[idx].bufnr), ':p:t'))
    endfor
    return l
endfunc
command! FR call setqflist([], ' ', {'title': 'Recent files', 'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
command! TQ call timer_start(5000, 'TimeoutQuickFixWindow', {'repeat': 1})
" let timer = timer_start(5000, 'TimeoutBuffer',
"             \ {'repeat': 1})
let g:enable_fuzzyy_MRU_files = 1
" nmap <leader>fr :FR<cr>:copen<cr>:TQ<cr>
nmap <leader>fr :FuzzyMRUFiles<cr>

function! TimeoutQuickFixWindow(timer)
    " let bufnr = bufnr("Recent Files")
    " echowindow bufnr
    " execute '!date'
    " echowindow "Timer completed..." .. a:timer
    execute 'cclose'
endfunction


