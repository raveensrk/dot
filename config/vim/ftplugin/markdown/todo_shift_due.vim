" Shift the due: date of a todo line (~/dot/docs/todo-schema.md) by one
" recurrence interval: <S-Right> forward, <S-Left> backward. The interval
" comes from the line's recurring: field (daily/weekly/monthly/yearly or
" compact 2d/3w/6m); without one it defaults to 1 day. A THH:MM time
" suffix on the due date is preserved. Shifting an overdue date forward
" advances it by whole intervals until it lands after today (daily ->
" tomorrow, weekly -> next occurrence of that weekday, ...), so recurring
" tasks keep their anchor instead of stepping through the past.

let s:todo_line = '^\s*[-*] \(TODO\|IN_PROGRESS\|OPTIONAL\|DONE\|OBSOLETE\): '

" [count, unit] parsed from the recurring: value; unit is d/w/m/y.
function! s:ParseInterval(line) abort
	let l:rec = matchstr(a:line, '\<recurring:\zs\S\+')
	let l:named = {'daily': [1, 'd'], 'weekly': [1, 'w'],
		\ 'monthly': [1, 'm'], 'yearly': [1, 'y']}
	if has_key(l:named, l:rec)
		return l:named[l:rec]
	endif
	let l:m = matchlist(l:rec, '^\(\d\+\)\([dwmy]\)$')
	if !empty(l:m)
		return [str2nr(l:m[1]), l:m[2]]
	endif
	return [1, 'd']
endfunction

function! s:DaysInMonth(year, month) abort
	let l:days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if a:month == 2 && (a:year % 4 == 0 && (a:year % 100 != 0 || a:year % 400 == 0))
		return 29
	endif
	return l:days[a:month - 1]
endfunction

function! s:AddInterval(date, n, unit) abort
	let [l:y, l:m, l:d] = map(split(a:date, '-'), 'str2nr(v:val)')
	if a:unit ==# 'd' || a:unit ==# 'w'
		let l:days = a:n * (a:unit ==# 'w' ? 7 : 1)
		" Noon avoids DST off-by-one-day surprises.
		let l:t = strptime('%Y-%m-%d %H', a:date . ' 12') + l:days * 86400
		return strftime('%Y-%m-%d', l:t)
	elseif a:unit ==# 'm'
		let l:total = (l:m - 1) + a:n
		let l:y += l:total / 12
		let l:m = l:total % 12 + 1
		if l:m < 1
			" Vimscript % keeps the sign of the dividend.
			let l:m += 12
			let l:y -= 1
		endif
	elseif a:unit ==# 'y'
		let l:y += a:n
	endif
	let l:d = min([l:d, s:DaysInMonth(l:y, l:m)])
	return printf('%04d-%02d-%02d', l:y, l:m, l:d)
endfunction

function! s:ShiftDue(dir) abort
	let l:line = getline('.')
	if l:line !~# s:todo_line
		echo 'todo-shift: not a todo line'
		return
	endif
	let l:date = matchstr(l:line, '\<due:\zs\d\{4}-\d\{2}-\d\{2}')
	if empty(l:date)
		echo 'todo-shift: no due: date on this line'
		return
	endif
	let l:today = strftime('%Y-%m-%d')
	let [l:n, l:unit] = s:ParseInterval(l:line)
	" ISO dates compare correctly as strings.
	if a:dir > 0 && l:date <# l:today
		" Overdue: advance by whole intervals until strictly after today,
		" keeping the recurrence anchor (weekday, day-of-month, ...).
		let l:new = l:date
		while l:new <=# l:today
			let l:new = s:AddInterval(l:new, l:n, l:unit)
		endwhile
		let l:why = printf('overdue -> next %d%s', l:n, l:unit)
	else
		let l:new = s:AddInterval(l:date, a:dir * l:n, l:unit)
		let l:why = printf('%d%s', l:n, l:unit)
	endif
	call setline('.', substitute(l:line,
		\ '\<due:\zs\d\{4}-\d\{2}-\d\{2}', l:new, ''))
	echo printf('due: %s -> %s (%s)', l:date, l:new, l:why)
endfunction

command! -buffer TodoShiftDue     call s:ShiftDue(1)
command! -buffer TodoShiftDueBack call s:ShiftDue(-1)
nnoremap <buffer> <silent> <S-Right> :<C-u>TodoShiftDue<CR>
nnoremap <buffer> <silent> <S-Left>  :<C-u>TodoShiftDueBack<CR>
