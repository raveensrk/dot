" Visually right-align todo metadata (~/dot/docs/todo-schema.md) in markdown.
"
" The real metadata tail (+Project @Context created: due: recurring: (A)) is
" hidden in place by a text property highlighted as Ignore (invisible), and
" re-drawn at the right window edge as right-aligned virtual text. Conceal
" is deliberately NOT used: Vim budgets virtual-text space against the raw
" (pre-conceal) line width, which leaves a ragged right edge or truncated
" text. One property carries the whole tail (Vim renders each right-aligned
" property on its own screen line, so per-token coloring is not possible).
" Purely visual - the buffer text is untouched. The cursor line is skipped,
" so it shows the raw line with normal highlighting for natural editing.
" :TodoAlignToggle switches the whole thing off/on per buffer.

if !has('textprop') || !has('patch-9.0.0067')
	finish
endif

" Make the in-place metadata invisible by painting it in the Normal
" background color; fall back to Ignore when no background is set.
function! s:HideHighlight() abort
	highlight TodoVirtMeta ctermfg=141 guifg=#af87ff
	let l:gui = synIDattr(hlID('Normal'), 'bg#')
	let l:cterm = synIDattr(hlID('Normal'), 'bg', 'cterm')
	let l:cmd = 'highlight TodoHideMeta'
	if !empty(l:gui)
		let l:cmd .= ' guifg=' . l:gui . ' guibg=' . l:gui
	endif
	if !empty(l:cterm)
		let l:cmd .= ' ctermfg=' . l:cterm . ' ctermbg=' . l:cterm
	endif
	if empty(l:gui) && empty(l:cterm)
		highlight! link TodoHideMeta Ignore
	else
		execute l:cmd
	endif
endfunction

call s:HideHighlight()

augroup MarkdownTodoAlignColors
	autocmd!
	autocmd ColorScheme * call s:HideHighlight()
augroup END

if empty(prop_type_get('todoVirtMeta'))
	call prop_type_add('todoVirtMeta', {'highlight': 'TodoVirtMeta'})
endif
if empty(prop_type_get('todoHideMeta'))
	call prop_type_add('todoHideMeta', {'highlight': 'TodoHideMeta'})
endif

let s:todo_line = '^\s*[-*] \(TODO\|IN_PROGRESS\|DONE\|OBSOLETE\): '
let s:meta_start = ' \%(+\w\|@\w\|\%(created\|completed\|due\):\d\|recurring:\S\|([ABC])\)'

function! s:RemoveProps() abort
	for l:type in ['todoVirtMeta', 'todoHideMeta']
		call prop_remove({'type': l:type, 'bufnr': bufnr(''), 'all': 1})
	endfor
endfunction

function! s:Sync() abort
	if get(b:, 'todo_align_off', 0)
		return
	endif
	call s:RemoveProps()
	let l:curline = line('.')
	for l:lnum in range(1, line('$'))
		if l:lnum == l:curline
			continue
		endif
		let l:line = getline(l:lnum)
		if l:line !~# s:todo_line
			continue
		endif
		let [l:tail, l:start, l:end] = matchstrpos(l:line, s:meta_start . '.*$')
		if l:start < 0
			continue
		endif
		call prop_add(l:lnum, l:start + 1, {
			\ 'type': 'todoHideMeta',
			\ 'length': len(l:line) - l:start,
			\ })
		call prop_add(l:lnum, 0, {
			\ 'type': 'todoVirtMeta',
			\ 'text': trim(l:tail),
			\ 'text_align': 'right',
			\ })
	endfor
	let b:todo_align_lastline = l:curline
endfunction

function! s:CursorSync() abort
	if line('.') != get(b:, 'todo_align_lastline', -1)
		call s:Sync()
	endif
endfunction

function! s:Toggle() abort
	if get(b:, 'todo_align_off', 0)
		let b:todo_align_off = 0
		call s:Sync()
	else
		let b:todo_align_off = 1
		call s:RemoveProps()
	endif
endfunction

command! -buffer TodoAlignToggle call s:Toggle()

augroup MarkdownTodoAlign
	autocmd! * <buffer>
	autocmd TextChanged,TextChangedI,BufEnter <buffer> call s:Sync()
	autocmd CursorMoved,CursorMovedI <buffer> call s:CursorSync()
augroup END

call s:Sync()
