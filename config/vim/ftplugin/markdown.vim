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

function! s:Format(line1,line2) abort
	let save_cursor = getcurpos()
	execute a:line1 . ',' . a:line2 . '!prettier --parser markdown --prose-wrap always'
	call setpos('.', save_cursor)
endfunction
silent command! -buffer -bar -range=% Format call s:Format(<line1>,<line2>)
" autocmd BufWritePre *.md silent Format
" silent autocmd BufRead resume*.md let b:vim_markdown_folding_disabled=0
let b:surround_49 = "```\r```" " Number 1 Key
autocmd BufEnter *.md ALEDisableBuffer
autocmd BufEnter *.md syntax match SpecialKey   /^-\ \[x\].*/
autocmd BufEnter *.md syntax match Removed   /^-\ \[o\].*/

function! s:Msg(msg)
	call popup_create(a:msg, #{
				\ pos: "topright",
				\ minwidth: 20,
				\ time: 3000,
				\ highlight: 'SpecialKey',
				\ border: [],
				\ padding: [0,1,0,1],
				\ moved: "any",
				\ })
endfunction
function! s:MsgFail(msg_fail)
	call popup_create(a:msg_fail, #{
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
		call s:Msg("Toggled Checkbox...")
	catch /^Vim\%((\a\+)\)\=:E486:/
		try
			execute a:line1 . "," . a:line2 . 's/\[x\]/\[o\]/'
			call s:Msg("Toggled Checkbox...")
		catch
			try
				execute a:line1 . "," . a:line2 . 's/\[o\]/\[ \]/'
			catch
				call s:MsgFail("Unable to Toggle Checkbox...")
			endtry
		endtry
	endtry
endfunction

command! -range ToggleCheckBox call ToggleCheckBox(<line1>,<line2>)
nnoremap <buffer> <CR> :ToggleCheckBox<CR>
xnoremap <buffer> <CR> :ToggleCheckBox<CR>

function! IncrementHeading()
	try
		s/^#/##/
		call s:Msg("Incremented Heading")
	catch
		try
			s/^/# /
			call s:Msg("Incremented Heading")
		catch
			call s:MsgFail("Unable to increment heading...")
		endtry
	endtry
endfunction

command! IncrementHeading call IncrementHeading()
nnoremap <buffer> g<right> :IncrementHeading<CR>


function! DecrementHeading()
	try
		s/^##/#/
		call s:Msg("Decremented Heading")
	catch
		try
			s/^# //
		catch
			call s:MsgFail("Unable to decrement heading...")
		endtry
	endtry
endfunction

command! DecrementHeading call DecrementHeading()
nnoremap <buffer> g<left> :DecrementHeading<CR>


let _ =<< trim eval END
	- [ ] Test 1
	- [ ] Test 2
	-  ] Test 3
	# Heading
	### Heading 2
END

function! SortThisParagraph() abort
	execute "normal! vip:!sort\<cr>"
endfunction
command! SortThisParagraph call SortThisParagraph()
nnoremap <buffer> g<CR> :SortThisParagraph<CR>
nmap <buffer> gX yi`:"<CR>
