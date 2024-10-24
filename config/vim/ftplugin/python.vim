function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!black -q  -l 200 -'
	call setpos('.', save_cursor)
endfunction

command! -buffer -range=% Format call s:Format(<line1>,<line2>)
command! -buffer Lint Dispatch pylint --max-line-length 300 --logging-format-style=new %   
command! CommentInspect call CommentAllMatchingLines('^\s\+inspect')
setlocal foldmethod=marker
let g:ale_linters = {'python': ['pylint']}
let g:ale_linters_explicit = 1
let g:ale_python_pylint_options = '--max-line-length 200 --logging-format-style=new %'
