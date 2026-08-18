" Cycle the lifecycle state of a todo line (~/dot/docs/todo-schema.md).
" :TodoState steps forward through the states configured in config/todo.toml
" and then through one stateless slot, wrapping:
"
"   - Buy milk -> - TODO: Buy milk -> - IN_PROGRESS: ... -> - OPTIONAL: ...
"   -> - DONE: ... -> - OBSOLETE: ... -> - Buy milk
"
" ,x runs it on the current line, or on every line of a visual selection.
" :TodoStateBack walks the other way, and :TodoState DONE jumps straight to a
" state. Only the state token is rewritten: indent, bullet char and every
" metadata field (due:, recurring:, tags, priority) are left alone. Both
" commands take a range, so :'<,'>TodoState marks a whole selection.

" [prefix, index, content] for a list line, or [] for anything else. The
" index is into todo#states(), or one past its end for a stateless bullet.
function! s:Parse(line) abort
	let l:m = matchlist(a:line, '^\(\s*[-*] \)\(.*\)$')
	if empty(l:m)
		return []
	endif
	" Checkbox items are the other markdown todo dialect; <CR> (ToggleCheckBox
	" in ftplugin/markdown.vim) owns those.
	if l:m[2] =~# '^\[.\]'
		return []
	endif
	let l:states = todo#states()
	for l:i in range(len(l:states))
		let l:hit = matchlist(l:m[2], '^' . l:states[l:i] . ':\s*\(.*\)$')
		if !empty(l:hit)
			return [l:m[1], l:i, l:hit[1]]
		endif
	endfor
	return [l:m[1], len(l:states), l:m[2]]
endfunction

function! s:Label(index) abort
	let l:states = todo#states()
	return a:index < len(l:states) ? l:states[a:index] : ''
endfunction

" Rewrite one line; returns the [from, to] labels, or [] when it is not a list
" item. `target` is an absolute index, `dir` a step when target is negative.
function! s:Apply(lnum, dir, target) abort
	let l:parsed = s:Parse(getline(a:lnum))
	if empty(l:parsed)
		return []
	endif
	let [l:prefix, l:index, l:content] = l:parsed
	" One slot past the states holds the stateless bullet.
	let l:slots = len(todo#states()) + 1
	let l:next = a:target >= 0 ? a:target : (l:index + a:dir + l:slots) % l:slots
	let l:label = s:Label(l:next)
	call setline(a:lnum, l:prefix . (empty(l:label) ? '' : l:label . ': ') . l:content)
	return [s:Label(l:index), l:label]
endfunction

function! s:Run(line1, line2, dir, arg) abort
	let l:target = -1
	if !empty(a:arg)
		let l:want = toupper(a:arg)
		let l:target = index(todo#states(), l:want)
		if l:target < 0
			if l:want ==# 'NONE'
				let l:target = len(todo#states())
			else
				echo 'todo-state: unknown state ' . a:arg
				return
			endif
		endif
	endif

	let l:changed = 0
	let l:last = []
	for l:lnum in range(a:line1, a:line2)
		let l:result = s:Apply(l:lnum, a:dir, l:target)
		if !empty(l:result)
			let l:changed += 1
			let l:last = l:result
		endif
	endfor

	if l:changed == 0
		echo 'todo-state: not a list item'
	elseif l:changed == 1
		echo printf('todo-state: %s -> %s',
			\ empty(l:last[0]) ? '(none)' : l:last[0],
			\ empty(l:last[1]) ? '(none)' : l:last[1])
	else
		echo printf('todo-state: %d lines', l:changed)
	endif
endfunction

" Global so -complete= can reach it (script-local completion needs a newer Vim).
function! TodoStateComplete(arglead, cmdline, cursorpos) abort
	let l:candidates = todo#states() + ['NONE']
	return filter(l:candidates, 'v:val =~? "^" . a:arglead')
endfunction

command! -buffer -range -nargs=? -complete=customlist,TodoStateComplete
	\ TodoState call s:Run(<line1>, <line2>, 1, <q-args>)
command! -buffer -range TodoStateBack call s:Run(<line1>, <line2>, -1, '')

nnoremap <buffer> <silent> ,x :<C-u>TodoState<CR>
xnoremap <buffer> <silent> ,x :TodoState<CR>
