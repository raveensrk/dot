function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '%!jq'
	call setpos('.', save_cursor)
endfunction
silent command! -buffer -bar -range=% Format call s:Format(<line1>,<line2>)
