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
nmap <leader>fr :FR<cr>:copen<cr>

function! TimeoutBuffer()
    call timer_start(10000, "bunfr()")
    echomsg "Timer completed..."
endfunction
call TimeoutBuffer()

			func MyHandler(timer)
			  echo 'Handler called'
			endfunc
			let timer = timer_start(500, 'MyHandler',
				\ {'repeat': 3})

