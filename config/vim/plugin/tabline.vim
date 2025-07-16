set showtabline=2
" set tabline=%!MyTabLine()
function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    let tab = i + 1
    let winnr = tabpagewinnr(tab)
    let buflist = tabpagebuflist(tab)
    let bufnr = buflist[winnr - 1]
    let bufname = bufname(bufnr)
    " let name = fnamemodify(bufname, ':t') !=# '' ? fnamemodify(bufname, ':t') : '[No Name]'
	let name = fnamemodify(bufname(bufnr), ':p')
    let s .= '%' . tab . 'T'
    let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let s .= ' ' . tab . ': ' . name . ' '
  endfor
  let s .= '%#TabLineFill#%T'
  return s
endfunction
