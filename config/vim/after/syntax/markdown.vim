" Rainbow-colored Markdown headings (H1..H6).
"
" Covers both the built-in markdown syntax (markdownH1..H6) and the
" preservim/vim-markdown plugin (which highlights headings via htmlH1..H6).
" This file lives under ~/dot/config/vim/after, so it runs after the main
" syntax has defined those groups.

function! s:RainbowHeadings() abort
	" VIBGYOR order, H1..H6 : [gui hex, cterm 256]
	let l:colors = {
		\ 1: ['#a05cff', 135],
		\ 2: ['#6a5acd', 62],
		\ 3: ['#4d88ff', 69],
		\ 4: ['#33cc33', 70],
		\ 5: ['#ffd700', 220],
		\ 6: ['#ff8c00', 208],
		\ }
	for [l:level, l:pair] in items(l:colors)
		let [l:gui, l:cterm] = l:pair
		for l:group in ['markdownH' . l:level, 'htmlH' . l:level]
			execute 'highlight ' . l:group
				\ . ' cterm=bold gui=bold'
				\ . ' ctermfg=' . l:cterm
				\ . ' guifg=' . l:gui
		endfor
	endfor
endfunction

" Per-character rainbow coloring of the word "rainbow" (case-insensitive,
" matched as a substring). Its 7 letters map to the 7 VIBGYOR colors.
function! s:RainbowWordColors() abort
	" letter position 1..7 (r,a,i,n,b,o,w) : [gui hex, cterm 256]
	let l:colors = {
		\ 1: ['#a05cff', 135],
		\ 2: ['#6a5acd', 62],
		\ 3: ['#4d88ff', 69],
		\ 4: ['#33cc33', 70],
		\ 5: ['#ffd700', 220],
		\ 6: ['#ff8c00', 208],
		\ 7: ['#ff5555', 203],
		\ }
	for [l:pos, l:pair] in items(l:colors)
		let [l:gui, l:cterm] = l:pair
		execute 'highlight RainbowWord' . l:pos
			\ . ' cterm=bold gui=bold'
			\ . ' ctermfg=' . l:cterm
			\ . ' guifg=' . l:gui
	endfor
endfunction

" Each match is one zero-width-anchored letter, so the 7 tile "rainbow"
" without overlap. \c = case-insensitive; containedin=ALL so it shows even
" inside headings, list items, emphasis and code spans.
syntax match RainbowWord1 /\cr\%(ainbow\)\@=/          containedin=ALL
syntax match RainbowWord2 /\c\%(r\)\@<=a\%(inbow\)\@=/ containedin=ALL
syntax match RainbowWord3 /\c\%(ra\)\@<=i\%(nbow\)\@=/ containedin=ALL
syntax match RainbowWord4 /\c\%(rai\)\@<=n\%(bow\)\@=/ containedin=ALL
syntax match RainbowWord5 /\c\%(rain\)\@<=b\%(ow\)\@=/ containedin=ALL
syntax match RainbowWord6 /\c\%(rainb\)\@<=o\%(w\)\@=/ containedin=ALL
syntax match RainbowWord7 /\c\%(rainbo\)\@<=w/         containedin=ALL

call s:RainbowHeadings()
call s:RainbowWordColors()

" Re-apply after any :colorscheme, which otherwise clears these overrides.
augroup MarkdownRainbowHeadings
	autocmd!
	autocmd ColorScheme * call s:RainbowHeadings()
	autocmd ColorScheme * call s:RainbowWordColors()
augroup END
