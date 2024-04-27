function! Done(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . 'move /## DONE'
	call setpos('.', save_cursor)
endfunction
command! -bar -range Done call Done(<line1>,<line2>)
map  <leader>> :Done<Cr>

" Test 
" Test 2

"## DONE

