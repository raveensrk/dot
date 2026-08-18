" Shared helpers for the markdown todo plugins (~/dot/docs/todo-schema.md).
" The state vocabulary lives in config/todo.toml so vim and ,todo.py agree on
" it; this reads that one line directly rather than shelling out to python.

let s:fallback = ['TODO', 'IN_PROGRESS', 'OPTIONAL', 'DONE', 'OBSOLETE']

" Lifecycle states in cycle order, cached for the session.
function! todo#states() abort
	if exists('s:states')
		return s:states
	endif
	let s:states = s:fallback
	let l:path = expand(empty($TODO_CONFIG) ? '~/dot/config/todo.toml' : $TODO_CONFIG)
	if !filereadable(l:path)
		return s:states
	endif
	for l:line in readfile(l:path)
		if l:line !~# '^\s*states\s*='
			continue
		endif
		let l:found = []
		" substitute() only for its side effect: collect every quoted token.
		call substitute(l:line, '"\([A-Z_]\+\)"', '\=add(l:found, submatch(1))', 'g')
		if !empty(l:found)
			let s:states = l:found
		endif
		break
	endfor
	return s:states
endfunction

" Matches a todo line up to and including the state's ': ' separator.
function! todo#line_pattern() abort
	return '^\s*[-*] \(' . join(todo#states(), '\|') . '\): '
endfunction
