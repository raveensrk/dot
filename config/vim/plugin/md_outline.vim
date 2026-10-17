" md_outline.vim - fold Markdown as an outline of every heading.
" Loads from the runtimepath. Hot reload: :source this file again.
"
" Settings (put in vimrc):
"   let g:mdoutline_enabled = 0   " start disabled (default 1)
"   let g:mdoutline_indent = 4    " spaces per heading level (default 8)
" Commands: :MdOutlineEnable  :MdOutlineDisable  :MdOutlineToggle

let g:mdoutline_enabled = get(g:, 'mdoutline_enabled', 1)
let g:mdoutline_indent = get(g:, 'mdoutline_indent', 8)

" {lnum: level} for every ATX heading outside fenced code blocks, so a
" "# comment" inside ```bash is not a heading. Cached per buffer change.
function! s:Headings() abort
  if get(b:, 'mdoutline_tick', -1) == b:changedtick
    return b:mdoutline_heads
  endif
  let heads = {}
  let fence = ''
  let lnum = 0
  for line in getline(1, '$')
    let lnum += 1
    let f = matchstr(line, '^ \{0,3}\zs\(`\{3,}\|\~\{3,}\)')
    if !empty(fence)
      if !empty(f) && f[0] ==# fence[0] && len(f) >= len(fence) && line =~# '^ \{0,3}[`~]\+\s*$'
        let fence = ''
      endif
    elseif !empty(f)
      let fence = f
    else
      let h = matchstr(line, '^#\{1,6}\ze\(\s\|$\)')
      if !empty(h)
        let heads[lnum] = len(h)
      endif
    endif
  endfor
  let b:mdoutline_tick = b:changedtick
  let b:mdoutline_heads = heads
  return heads
endfunction

function! MdOutlineFoldExpr() abort
  return has_key(s:Headings(), v:lnum) ? '>1' : '='
endfunction

function! MdOutlineFoldText() abort
  let level = get(s:Headings(), v:foldstart, 1)
  return repeat(' ', g:mdoutline_indent * (level - 1))
        \ . substitute(getline(v:foldstart), '^#\+\s*', '', '')
endfunction

" Closed-fold headings use the markdownH1..H6 colours, so they match the open
" heading lines (after/syntax/markdown.vim sets the rainbow palette).
function! s:PropTypes() abort
  for n in range(1, 6)
    let props = #{highlight: 'markdownH' . n, combine: v:true}
    if empty(prop_type_get('mdoutlineH' . n))
      call prop_type_add('mdoutlineH' . n, props)
    else
      call prop_type_change('mdoutlineH' . n, props)
    endif
  endfor
endfunction

" Vim draws every closed fold in one Folded colour and never shows CursorLine
" on it, so lay a popup over each visible closed fold: Folded (or CursorLine
" under the cursor) as background, the heading text in its level's colour.
let s:overlay = get(s:, 'overlay', #{key: '', ids: [], lnums: []})

function! s:HideOverlay() abort
  for id in s:overlay.ids
    call popup_close(id)
  endfor
  let s:overlay.ids = []
  let s:overlay.lnums = []
  let s:overlay.key = ''
endfunction

function! s:UpdateOverlay() abort
  if !get(b:, 'mdoutline_active', 0) || &foldmethod !=# 'expr' || mode() =~# "^[vV\<C-v>]"
    call s:HideOverlay()
    return
  endif
  let info = getwininfo(win_getid())[0]
  let cur = &cursorline && &cursorlineopt =~# 'line\|both' ? foldclosed('.') : -1
  let rows = []
  let lnum = info.topline
  while lnum <= info.botline
    let fc = foldclosed(lnum)
    if fc == -1
      let lnum += 1
      continue
    endif
    let row = screenpos(0, lnum, 1).row
    if row > 0
      call add(rows, [row, fc])
    endif
    let lnum = foldclosedend(lnum) + 1
  endwhile
  let key = string([info.winid, info.winrow, info.wincol, info.width, info.textoff,
        \ b:changedtick, rows, cur, g:mdoutline_indent])
  if key ==# s:overlay.key
    return
  endif
  let heads = s:Headings()
  let width = info.width - info.textoff
  let ids = []
  for [row, fc] in rows
    let text = foldtextresult(fc)
    let level = get(heads, fc, 0)
    let first = len(matchstr(text, '^ *')) + 1
    let props = level >= 1 && level <= 6 && first <= len(text)
          \ ? [#{col: first, length: len(text) - first + 1, type: 'mdoutlineH' . level}] : []
    let content = [#{text: text . repeat(' ', max([0, width - strdisplaywidth(text)])), props: props}]
    let opts = #{line: row, col: info.wincol + info.textoff, minwidth: width, maxwidth: width,
          \ highlight: fc == cur ? 'CursorLine' : 'Folded', wrap: 0, zindex: 1}
    " Reuse popups so moving the cursor does not recreate them all.
    if len(ids) < len(s:overlay.ids) && !empty(popup_getpos(s:overlay.ids[len(ids)]))
      let id = s:overlay.ids[len(ids)]
      call popup_settext(id, content)
      call popup_setoptions(id, opts)
    else
      let id = popup_create(content, opts)
    endif
    call add(ids, id)
  endfor
  for id in s:overlay.ids[len(ids):]
    call popup_close(id)
  endfor
  let s:overlay.ids = ids
  let s:overlay.lnums = map(copy(rows), 'v:val[1]')
  let s:overlay.key = key
endfunction

" The overlays swallow mouse clicks, so a click on one moves to its fold.
function! s:Click() abort
  let i = index(s:overlay.ids, getmousepos().winid)
  return i == -1 ? "\<LeftMouse>" : "\<Cmd>call cursor(" . s:overlay.lnums[i] . ", 1)\<CR>"
endfunction

" Vim's incremental expr-fold update can leave a heading inside the wrong fold
" after an edit, so rebuild the folds and reopen the sections that were open.
function! s:RefreshFolds() abort
  if !get(b:, 'mdoutline_active', 0) || &foldmethod !=# 'expr'
    return
  endif
  " Skip the rebuild when no heading moved, appeared or vanished, since it is
  " slow on big files.
  let heads = s:Headings()
  let sig = string(heads)
  if sig ==# get(b:, 'mdoutline_sig', '')
    return
  endif
  let b:mdoutline_sig = sig
  let open = filter(map(keys(heads), 'str2nr(v:val)'), 'foldclosed(v:val) == -1')
  let view = winsaveview()
  let &l:foldmethod = 'expr'
  normal! zM
  for lnum in open
    execute lnum . 'foldopen'
  endfor
  call winrestview(view)
endfunction

" True when the cursor is on the first character of the line (a heading's #).
function! s:AtColumnOne() abort
  return col('.') == 1
endfunction

" <Right>: at column 1 of a closed fold, open it; otherwise move right.
function! s:Right() abort
  return foldclosed('.') != -1 && s:AtColumnOne() ? 'zo' : "\<Right>"
endfunction

" <Left>: at column 1 of an open heading line, close it; on a closed fold jump to
" its parent heading; otherwise move left.
function! s:Left() abort
  if !s:AtColumnOne()
    return "\<Left>"
  endif
  if foldclosed('.') == -1
    return has_key(s:Headings(), line('.')) ? 'zc' : "\<Left>"
  endif
  let heads = s:Headings()
  let start = foldclosed('.')
  let level = get(heads, start, 1)
  let parent = 0
  for lnum in range(start - 1, 1, -1)
    if get(heads, lnum, 99) < level
      let parent = lnum
      break
    endif
  endfor
  " <Cmd> so a typed count is not glued onto the line number.
  return parent > 0 ? "\<Cmd>call cursor(" . parent . ", 1)\<CR>" : ''
endfunction

function! MdOutlineSetup() abort
  if !g:mdoutline_enabled
    return
  endif
  let b:mdoutline_active = 1
  nnoremap <buffer><expr><silent> <Right> <SID>Right()
  nnoremap <buffer><expr><silent> <Left> <SID>Left()
  nnoremap <buffer><expr><silent> <LeftMouse> <SID>Click()
  setlocal foldmethod=expr foldexpr=MdOutlineFoldExpr() foldtext=MdOutlineFoldText()
  " foldminlines=0 so a heading with no body still folds into the outline.
  setlocal foldminlines=0 fillchars+=fold:\ 
  setlocal cursorline
endfunction

" Undo MdOutlineSetup in the current window: back to the global fold and
" cursorline settings, and the default arrow keys.
function! MdOutlineTeardown() abort
  let b:mdoutline_active = 0
  for key in ['<Right>', '<Left>', '<LeftMouse>']
    if maparg(key, 'n', 0, 1)->get('buffer', 0)
      execute 'nunmap <buffer> ' . key
    endif
  endfor
  setlocal foldmethod< foldexpr< foldtext< foldminlines< fillchars< cursorline<
endfunction

function! s:MarkdownWindows() abort
  let wins = []
  for b in filter(range(1, bufnr('$')), 'getbufvar(v:val, "&filetype") ==# "markdown"')
    let wins += win_findbuf(b)
  endfor
  return wins
endfunction

function! s:SetEnabled(on) abort
  let g:mdoutline_enabled = a:on
  call s:HideOverlay()
  for w in s:MarkdownWindows()
    call win_execute(w, a:on ? 'call MdOutlineSetup() | normal! zx' : 'call MdOutlineTeardown()')
  endfor
  call s:UpdateOverlay()
endfunction

command! MdOutlineEnable call s:SetEnabled(1)
command! MdOutlineDisable call s:SetEnabled(0)
command! MdOutlineToggle call s:SetEnabled(!g:mdoutline_enabled)

call s:PropTypes()

augroup mdoutline
  autocmd!
  autocmd FileType markdown call MdOutlineSetup()
  " SafeState also catches fold opens/closes that leave the cursor in place.
  autocmd SafeState,SafeStateAgain,CursorMoved,CursorMovedI,TextChangedI,WinScrolled,VimResized,BufEnter,WinEnter,ModeChanged * call s:UpdateOverlay()
  autocmd WinLeave,BufLeave * call s:HideOverlay()
  autocmd TextChanged,InsertLeave * call s:RefreshFolds() | call s:UpdateOverlay()
augroup END

" Reapply to Markdown windows already open, so re-sourcing hot reloads.
call s:SetEnabled(g:mdoutline_enabled)
