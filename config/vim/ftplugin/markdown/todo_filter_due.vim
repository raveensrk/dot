" Toggle a filtered view showing only active todo lines
" (~/dot/docs/todo-schema.md) whose due: date is today or earlier;
" everything else collapses into folds. ,D toggles the view. The global
" ,d (:Todo!) is the cross-file quickfix equivalent.

let s:active_line = '^\s*[-*] \(TODO\|IN_PROGRESS\): '

function! TodoDueFoldExpr(lnum) abort
	let l:line = getline(a:lnum)
	if l:line !~# s:active_line
		return 1
	endif
	let l:due = matchstr(l:line, '\<due:\zs\d\{4}-\d\{2}-\d\{2}')
	" ISO dates compare correctly as strings.
	return !empty(l:due) && l:due <=# strftime('%Y-%m-%d') ? 0 : 1
endfunction

function! s:Toggle() abort
	if get(b:, 'todo_due_filter', 0)
		let b:todo_due_filter = 0
		let [&l:foldmethod, &l:foldexpr, &l:foldlevel, &l:foldenable,
			\ &l:foldminlines, &l:foldtext, &l:fillchars] = b:todo_due_filter_save
		" Folds made by the expr method survive the switch back to manual;
		" wipe them (this also drops any hand-made manual folds).
		if &l:foldmethod ==# 'manual'
			normal! zE
		endif
		if exists('b:todo_due_filter_folded_hl')
			call hlset(b:todo_due_filter_folded_hl)
			unlet b:todo_due_filter_folded_hl
		endif
		echo 'todo-filter: off'
	else
		let b:todo_due_filter_save = [&l:foldmethod, &l:foldexpr, &l:foldlevel,
			\ &l:foldenable, &l:foldminlines, &l:foldtext, &l:fillchars]
		let b:todo_due_filter = 1
		setlocal foldmethod=expr foldexpr=TodoDueFoldExpr(v:lnum)
		setlocal foldlevel=0 foldenable foldminlines=0
		" Render closed folds as blank lines: no fold text, and a space
		" instead of the '-' filler.
		setlocal foldtext=''
		execute 'setlocal fillchars+=fold:\ '
		" Render fold rows as pure background: clear the Folded colors
		" while filtered, restoring the saved definition on toggle-off.
		" (Highlights are global, so other windows' folds blank out too.)
		if exists('*hlget')
			let b:todo_due_filter_folded_hl = hlget('Folded')
			call hlset([{'name': 'Folded', 'cleared': v:true}])
		endif
		echo 'todo-filter: only due/overdue shown'
	endif
endfunction

command! -buffer TodoFilterDue call s:Toggle()
nnoremap <buffer> <silent> ,D :<C-u>TodoFilterDue<CR>
