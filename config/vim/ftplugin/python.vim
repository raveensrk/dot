autocmd BufWrite *.py silent !ctags -R .
autocmd ShellCmdPost * redraw!

function! Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!black -q -'
	call setpos('.', save_cursor)
endfunction

command! -range=% Format call Format(<line1>,<line2>)

let dirs=join(split(getenv("PYTHONPATH"), ":"), " ")
let pythontags=getenv('HOME') . "/python_venv/tags"
let ctagscmd="ctags -R " . dirs . " -f " . pythontags
execute 'set tags+=' . pythontags
echowindow "Running: " . ctagscmd
execute 'AsyncRun ' . ctagscmd
echowindow "Setting up tags file: " . pythontags
set tags
