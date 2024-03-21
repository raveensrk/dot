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
command! FR call setqflist([], ' ', {'lines' : v:oldfiles, 'efm' : '%f', 'quickfixtextfunc' : 'QfOldFiles'})
nmap <leader>fr :FR<cr>:copen<cr>
