setlocal autoindent
setlocal expandtab
setlocal isfname-==
setlocal shiftwidth=4
setlocal smartindent
setlocal tabstop=4 softtabstop=4
setlocal formatprg=verible-verilog-format\ --indentation_spaces\ 4\ --over_column_limit_penalty\ 100\ -
function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . "!verible-verilog-format --indentation_spaces 4 --over_column_limit_penalty 100 -"
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
" execute 'ALEDisableBuffer'

command! -bar -buffer Compile AsyncRun verilator.sh --file % 
let g:ale_verilog_verilator_options="-sv 
			\ --timing 
			\ --trace 
			\ --trace-params
			\ --trace-structs 
			\ --trace-depth 1 \
			\ --timing"
autocmd QuickFixCmdPost *.sv clast
autocmd QuickFixCmdPost make clast

set errorformat=%.%#xmvlog:\ %\\%#E\\,%o\ (%f\\,%l\|%c):\ %m
set errorformat+=%.%#xmelab:\ %\\%#E\\,%o\ (%f\\,%l\|%c):\ %m
set errorformat+=%EUVM_FATAL\ %f(%l)\ %m
set errorformat+=%E%.%#xmsim:\ %\\%#E\\,%o:\ %m,%C%.%#File:\ %f\\,\ line\ =\ %l\\,\ pos\ =\ %c,%Z
set errorformat+=%EUVM_FATAL\ @\ %.%#:\ %o
set errorformat+=%EUVM_ERROR\ %f(%l)\ @\ %.%#:\ %m
set errorformat+=%EUVM_ERROR\ %f(%l)\ @\ %c:\ %m%.%#
set errorformat+=xmsim:\ %\\%#W\\,%o\ (%f\\,%l\|%c):\ %m%.%#
set errorformat+=xmsim:\ %\\%#F\\,%o\ (%f\\,%l):\ %m%.%#
set errorformat+=xmvlog:\ %\\%#W\\,%o\ (%f\\,%l\|%c):\ %m%.%#
" set errorformat+=%IUVM_INFO\ %f(%l)\ @\%m%.%#

command! -buffer ConvertDeclarationToDisplay s/.*\w\+ \(\w\+\);/$display("%20s = %0d", "\1", \1);/
