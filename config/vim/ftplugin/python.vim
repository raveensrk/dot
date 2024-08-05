function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!black -q  -l 80 -'
	call setpos('.', save_cursor)
endfunction

command! -buffer -range=% Format call s:Format(<line1>,<line2>)
command! -buffer Lint Dispatch pylint --max-line-length 300 --logging-format-style=new %   
command! CommentInspect call CommentAllMatchingLines('^\s\+inspect')
let b:ale_linters = ['pylint']
let b:ale_python_pylint_options= '--max-line-length 300'
setlocal foldmethod=marker
