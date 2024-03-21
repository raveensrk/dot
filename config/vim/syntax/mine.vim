" so $VIMRUNTIME/syntax/hitest.vim
" syntax clear
set background=dark

syntax case    ignore

syntax match xTodo   /^todo/
hi xTodo   ctermfg=130 ctermbg=black

syntax match xDone   /^done/
hi xDone ctermfg=232 ctermbg=28

syntax keyword xOthers others
hi link xOthers Question

syntax keyword xNotes  notes
hi link xNotes  Notes

syntax region xSeperator  start=/^---/ end="---$"
hi link xSeperator Constant

hi Normal ctermfg=white
hi Notes  ctermfg=white ctermbg=blue

hi Dash ctermfg=blue ctermbg=black
syntax match Dash /^-/

call PlaceSign("todo", "sign_todo", "ToolbarButton", "xTodo", "0")
call PlaceSign("done", "sign_done", "ToolbarButton", "xDone", "0")
