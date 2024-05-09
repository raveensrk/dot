function! BufferDelete() abort
    let buffers = split(execute("ls"), "\\n")
    let is_last_buffer = len(buffers)
    echom is_last_buffer
    if (is_last_buffer==1)
        execute "quit"
    else
        execute "bdelete"
    endif
endfunction

command! BufferDelete call BufferDelete()
nmap <leader>dd :BufferDelete<CR>

" # FIXME: This function is buggy. 
" function! DeleteTerminalBuffers() abort
"     let buffers = getbufinfo({'buflisted': 1})
" 	redir >> /tmp/thing
" 		echom buffers
" 	END
"     for buffer in buffers
" 		if buffer.type = "terminal"
" 			echowindow "Deleting buffer: Number: " . buffer.bufnr . ": Name: " . buffer.name 
" 			execute 'bdelete! ' . buffer.name 
" 		endif
"     endfor
" endfunction
" command! DeleteTerminalBuffers call DeleteTerminalBuffers()
" nmap <leader>dx :DeleteTerminalBuffers<CR>
