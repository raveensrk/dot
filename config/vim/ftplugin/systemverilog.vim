setlocal autoindent
setlocal expandtab
setlocal isfname-==
setlocal shiftwidth=4
setlocal smartindent
setlocal tabstop=4 softtabstop=4
setlocal formatprg=verible-verilog-format\ --indentation_spaces\ 4\ --over_column_limit_penalty\ 80\ -
function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . "!verible-verilog-format --indentation_spaces 4 --over_column_limit_penalty 80 -"
	call setpos('.', save_cursor)
endfunction

command! -buffer -range=% Format call s:Format(<line1>,<line2>)


function! s:Lint() abort
	let save_cursor = getcurpos()
	let file=expand("%:p")
	" execute 'silent! term verible-verilog-lint '..file
	execute '!verilator.sh --file '..file..' --lint'
	execute '!verible-verilog-lint '..file
	call setpos('.', save_cursor)
endfunction


command! -buffer Lint call s:Lint()
execute 'ALEDisableBuffer'

command! -bar -buffer Compile AsyncRun verilator.sh --file % 
