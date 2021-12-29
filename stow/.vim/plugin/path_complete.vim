fun! EnvComplete(findstart, base)

	" Call this completion with i_CTRL-X_CTRL-U
	" Test this with $HOME/
	" Should complete wihtout removing $HOME variable

	let envvar = getline('.')
	let envvar = substitute(envvar, ".*\\$", "\\$", "")

	if a:findstart
		" locate the start of the word
		let line = getline('.')
		let start = col('.') - 1
		while start > 0 && line[start - 1] =~ '\a'
			let start -= 1
		endwhile
		return start
	else
		" find files under envvar and append to "a:base"
		let res = []
		let tmp = split(globpath(envvar, '*'), '\n')
		for m in tmp
			let m = substitute(m, ".*/", "", "")
			if m =~ '^' . a:base
				call add(res, m)
			endif
		endfor
		return res
	endif
endfun

set completefunc=EnvComplete
" i_CTRL-x_CTRL-u
