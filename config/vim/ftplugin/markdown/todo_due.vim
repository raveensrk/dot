" Subtle background tint for todo lines (~/dot/docs/todo-schema.md) whose
" due: date is overdue, today, or tomorrow. Syntax patterns cannot compare
" dates, so an autocmd rescans the buffer and applies text properties.
" DONE/OBSOLETE items are ignored. The properties use 'combine' so the
" normal foreground highlighting (state colors, dim metadata) shows through.

if !has('textprop') || !has('patch-9.0.0067')
	finish
endif

function! s:DueHighlights() abort
	" group : [gui bg, cterm bg] - subtle tints for a dark background
	highlight TodoDueOverdue  ctermbg=52 guibg=#402020
	highlight TodoDueToday    ctermbg=58 guibg=#403a20
	highlight TodoDueTomorrow ctermbg=23 guibg=#203440
endfunction

call s:DueHighlights()

augroup MarkdownTodoDueColors
	autocmd!
	autocmd ColorScheme * call s:DueHighlights()
augroup END

for s:type in ['todoDueOverdue', 'todoDueToday', 'todoDueTomorrow']
	if empty(prop_type_get(s:type))
		call prop_type_add(s:type, {'highlight': substitute(s:type, '^t', 'T', ''), 'combine': v:true})
	endif
endfor

let s:active_line = '^\s*[-*] \(TODO\|IN_PROGRESS\): '

function! s:Sync() abort
	for l:type in ['todoDueOverdue', 'todoDueToday', 'todoDueTomorrow']
		call prop_remove({'type': l:type, 'bufnr': bufnr(''), 'all': 1})
	endfor
	let l:today = strftime('%Y-%m-%d')
	let l:tomorrow = strftime('%Y-%m-%d', localtime() + 86400)
	for l:lnum in range(1, line('$'))
		let l:line = getline(l:lnum)
		if l:line !~# s:active_line
			continue
		endif
		let l:due = matchstr(l:line, '\<due:\zs\d\{4}-\d\{2}-\d\{2}')
		if empty(l:due)
			continue
		endif
		" ISO dates compare correctly as strings.
		if l:due <# l:today
			let l:type = 'todoDueOverdue'
		elseif l:due ==# l:today
			let l:type = 'todoDueToday'
		elseif l:due ==# l:tomorrow
			let l:type = 'todoDueTomorrow'
		else
			continue
		endif
		call prop_add(l:lnum, 1, {'type': l:type, 'length': len(l:line)})
	endfor
endfunction

augroup MarkdownTodoDue
	autocmd! * <buffer>
	autocmd TextChanged,TextChangedI,BufEnter <buffer> call s:Sync()
augroup END

call s:Sync()
