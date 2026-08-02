" Highlighting for the TODO schema (~/dot/docs/todo-schema.md) in markdown.
"
" Matches only list lines shaped like the schema, e.g.
"   - TODO: Pay rent +Finance @home due:2026-08-05 recurring:monthly (A)
" so ordinary markdown bullets are unaffected. This file lives under
" ~/dot/config/vim/after/syntax/markdown/, so it runs after the main
" markdown syntax (and after markdown.vim in the parent directory).

" The whole todo line; contains the pieces below. containedin=ALL so it
" wins even inside markdown list-item groups.
syntax match todoItem /^\s*[-*] \(TODO\|IN_PROGRESS\|DONE\|OBSOLETE\): .*$/
	\ containedin=ALL contains=todoStateTodo,todoStateInProgress,
	\todoStateDone,todoStateObsolete,todoProjectTag,todoContextTag,
	\todoDate,todoRecurring,todoPriorityA,todoPriorityBC

syntax match todoStateTodo       /\%(^\s*[-*] \)\@<=TODO:/        contained
syntax match todoStateInProgress /\%(^\s*[-*] \)\@<=IN_PROGRESS:/ contained
syntax match todoStateDone       /\%(^\s*[-*] \)\@<=DONE:/        contained
syntax match todoStateObsolete   /\%(^\s*[-*] \)\@<=OBSOLETE:/    contained

syntax match todoProjectTag /\s\zs+\w\+/  contained
syntax match todoContextTag /\s\zs@\w\+/  contained
" Date with optional time, e.g. due:2026-08-01 or due:2026-08-01T10:00.
syntax match todoDate       /\<\(created\|completed\|due\):\d\{4}-\d\{2}-\d\{2}\(T\d\{2}:\d\{2}\)\?\>/ contained
syntax match todoRecurring  /\<recurring:\S\+/ contained
syntax match todoPriorityA  /(A)$/    contained
syntax match todoPriorityBC /([BC])$/ contained

function! s:TodoHighlights() abort
	" group : [gui hex, cterm 256, extra attrs]
	let l:colors = {
		\ 'todoStateTodo':       ['#ffd700', 220, 'bold'],
		\ 'todoStateInProgress': ['#4d88ff',  69, 'bold'],
		\ 'todoStateDone':       ['#33cc33',  70, 'bold'],
		\ 'todoStateObsolete':   ['#808080', 244, 'NONE'],
		\ 'todoProjectTag':      ['#3a3a3a', 237, 'NONE'],
		\ 'todoContextTag':      ['#3a3a3a', 237, 'NONE'],
		\ 'todoDate':            ['#3a3a3a', 237, 'NONE'],
		\ 'todoRecurring':       ['#3a3a3a', 237, 'NONE'],
		\ 'todoPriorityA':       ['#3a3a3a', 237, 'NONE'],
		\ 'todoPriorityBC':      ['#3a3a3a', 237, 'NONE'],
		\ }
	for [l:group, l:spec] in items(l:colors)
		let [l:gui, l:cterm, l:attr] = l:spec
		execute 'highlight ' . l:group
			\ . ' cterm=' . l:attr . ' gui=' . l:attr
			\ . ' ctermfg=' . l:cterm
			\ . ' guifg=' . l:gui
	endfor
endfunction

call s:TodoHighlights()

" Re-apply after any :colorscheme, which otherwise clears these overrides.
augroup MarkdownTodoHighlights
	autocmd!
	autocmd ColorScheme * call s:TodoHighlights()
augroup END
