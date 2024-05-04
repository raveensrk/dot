let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_borderless_table = 0
" let g:vim_markdown_folding_level = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0
setlocal conceallevel=2
setlocal formatprg=prettier\ --parser\ markdown
setlocal wrap
setlocal spell

function! Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!prettier --parser markdown --prose-wrap always'
	call setpos('.', save_cursor)
endfunction
silent command! -bar -range=% Format call Format(<line1>,<line2>)
" autocmd BufWritePre *.md silent Format
" silent autocmd BufRead resume*.md let b:vim_markdown_folding_disabled=0
let b:surround_49 = "```\r```"
autocmd BufEnter *.md ALEDisableBuffer
autocmd BufEnter *.md syntax match SpecialKey   /^-\ \[x\].*/
autocmd BufEnter *.md syntax match Removed   /^-\ \[o\].*/

function! s:Msg()
	call popup_create("Toggled Check Box", #{
				\ pos: "topright",
				\ minwidth: 20,
				\ time: 3000,
				\ highlight: 'SpecialKey',
				\ border: [],
				\ padding: [0,1,0,1],
				\ moved: "any",
				\ })
endfunction
function! s:MsgFail()
	call popup_create("Unable to Toggle Check Box", #{
				\ pos: "topright",
				\ minwidth: 20,
				\ time: 3000,
				\ highlight: 'SpellBad',
				\ border: [],
				\ padding: [0,1,0,1],
				\ moved: "any",
				\ })
endfunction

function! ToggleCheckBox(line1,line2)
	try
		execute a:line1 . "," . a:line2 . 's/\[ \]/\[x\]/'
		call s:Msg()
	catch /^Vim\%((\a\+)\)\=:E486:/
		try
			execute a:line1 . "," . a:line2 . 's/\[x\]/\[o\]/'
			call s:Msg()
		catch
			try
				execute a:line1 . "," . a:line2 . 's/\[o\]/\[ \]/'
			catch
				call s:MsgFail()
			endtry
		endtry
	endtry
endfunction

command! -range ToggleCheckBox call ToggleCheckBox(<line1>,<line2>)
nnoremap <buffer> <CR> :ToggleCheckBox<CR>
xnoremap <buffer> <CR> :ToggleCheckBox<CR>


let _ =<< trim eval END
	- [ ] Test 1
	- [ ] Test 2
	-  ] Test 3
END


function! SortThisParagraph() abort
	execute "normal! vip:!sort\<cr>"
endfunction
command! SortThisParagraph call SortThisParagraph()
