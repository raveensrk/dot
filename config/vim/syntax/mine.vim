" so $VIMRUNTIME/syntax/hitest.vim
" syntax clear
set background=dark

syntax case    ignore

syntax match xTodo   /todo/
hi xTodo   ctermfg=130 ctermbg=black

syntax keyword xDone   done
hi link xDone   LightlineLeft_active_0_tabsel

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

sign define notes text=>> linehl=xNotes

" test sign

" call search("xNotes")
" let val = line('.')
" echo val
" sign define piet text=>> texthl=Search linehl=Notes
" exec ":sign place 3 line=" . val . " " . 'name=piet file=' . expand("%:p") 
"

let [searchposl, searchposc ] = searchpos("test sign", "n")
echomsg searchposl 
" function! PlaceSigns(text)
" call search(a:text)
" let val = line('.')
" exec ":sign place 2 line=" . val . " " . 'name=notes file=' . expand("%:p") 
" echomsg ":sign place 2 line=" . val . " " . 'name=notes file=' . expand("%:p") 
" endfunction
