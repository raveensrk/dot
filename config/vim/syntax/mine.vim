" so $VIMRUNTIME/syntax/hitest.vim
" syntax clear
set background=dark

syntax case    ignore
syntax keyword xTodo   todo
syntax keyword xDone   done
syntax keyword xOthers others
syntax keyword xNotes  notes

hi Normal ctermfg=white
hi Notes  ctermfg=white ctermbg=blue

hi link xTodo   CocErrorSign
hi link xDone   LightlineLeft_active_0_tabsel
hi link xOthers Question
hi link xNotes  Notes
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
