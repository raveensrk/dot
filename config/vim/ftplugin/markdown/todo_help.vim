" :TodoHelp / ,? echoes a cheat sheet for the todo plugins
" (~/dot/docs/todo-schema.md). The state line is built from todo#states() so
" it tracks config/todo.toml; the command table is maintained by hand here and
" mirrors docs/todo-vim.md.

function! s:Lines() abort
	return [
		\ 'Todo cheat sheet  (~/dot/docs/todo-vim.md)',
		\ '  States   ' . join(todo#states(), ' > ') . ' > (none)',
		\ '  Format   - STATE: content +Project @Context created: due: recurring: (A)',
		\ '',
		\ '  ,x         :TodoState [STATE|NONE]   cycle state / set it  (visual: selection)',
		\ '             :TodoStateBack            cycle backward',
		\ '  <S-Right>  :TodoShiftDue             shift due: by one recurring: interval',
		\ '  <S-Left>   :TodoShiftDueBack         ...backward',
		\ '  ,D         :TodoFilterDue            toggle fold: only due/overdue items',
		\ '  ,t  ,d     :Todo  :Todo!             quickfix of all / due tasks (,todo.py)',
		\ '  ,?         :TodoHelp                 this cheat sheet',
		\ ]
endfunction

function! s:Show() abort
	let l:lines = s:Lines()
	echohl Title
	echo l:lines[0]
	echohl None
	for l:line in l:lines[1:]
		echo l:line
	endfor
endfunction

command! -buffer TodoHelp call s:Show()
nnoremap <buffer> <silent> ,? :<C-u>TodoHelp<CR>
