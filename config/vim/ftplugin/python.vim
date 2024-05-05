function! Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!black -q -'
	call setpos('.', save_cursor)
endfunction

command! -range=% Format call Format(<line1>,<line2>)
