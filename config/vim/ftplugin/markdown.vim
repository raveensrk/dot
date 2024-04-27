let b:vim_markdown_folding_disabled = 1
let b:vim_markdown_borderless_table = 0
setlocal conceallevel=0
setlocal formatprg=prettier\ --parser\ markdown
setlocal wrap

function! Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!prettier --parser markdown --prose-wrap always'
	call setpos('.', save_cursor)
endfunction
silent command! -bar -range=% Format call Format(<line1>,<line2>)
silent autocmd BufWritePre *.md Format
silent autocmd BufRead resume*.md let b:vim_markdown_folding_disabled=0
let b:surround_49 = "```\r```"
