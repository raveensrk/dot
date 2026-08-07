" Spaced writing style: 1 space between characters, 4 between words.
" T h i s    i s    t h e    s t y l e
"
" :ToggleSpacedType  toggle live spaced typing in the current buffer
" :SpaceText         convert range (default current line) to spaced style
" :UnspaceText       convert spaced range back to normal text

function! s:SpacedInsertChar() abort
	if v:char ==# ' '
		" previous char already left one trailing space; 3 more = 4-space gap
		let v:char = '   '
	else
		let v:char = v:char .. ' '
	endif
endfunction

function! ToggleSpacedType() abort
	if get(b:, 'spaced_type', 0)
		let b:spaced_type = 0
		autocmd! SpacedType * <buffer>
		silent! iunmap <buffer> <BS>
		echo "SpacedType OFF"
	else
		let b:spaced_type = 1
		augroup SpacedType
			autocmd InsertCharPre <buffer> call s:SpacedInsertChar()
		augroup END
		inoremap <buffer> <BS> <BS><BS>
		echo "SpacedType ON"
	endif
endfunction

function! s:SpaceOutLine(line) abort
	let words = split(a:line)
	call map(words, {_, w -> join(split(w, '\zs'), ' ')})
	return join(words, '    ')
endfunction

function! s:UnspaceLine(line) abort
	let words = split(a:line, '  \+')
	call map(words, {_, w -> substitute(w, ' ', '', 'g')})
	return join(words, ' ')
endfunction

function! SpaceText(line1, line2) abort
	for lnum in range(a:line1, a:line2)
		call setline(lnum, s:SpaceOutLine(getline(lnum)))
	endfor
endfunction

function! UnspaceText(line1, line2) abort
	for lnum in range(a:line1, a:line2)
		call setline(lnum, s:UnspaceLine(getline(lnum)))
	endfor
endfunction

command! ToggleSpacedType call ToggleSpacedType()
command! -range SpaceText call SpaceText(<line1>, <line2>)
command! -range UnspaceText call UnspaceText(<line1>, <line2>)
