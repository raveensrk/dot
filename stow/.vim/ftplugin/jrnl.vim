syn match       at              /@/
syn match       tags            /@\w\+/ contains=at
syn match       todo            /@todo/
syn match       todo2           /@todo2/
syn match       doing           /@doing/
syn match       done            /@done/
syn match       entry           /\[\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d \w\w\]/
syn match       url             /https:\/\/[a-zA-Z.\/0-9-_~:+#=&?]\+/
syn match       heading         /^\#.*/
syn match       list1           /^-/
syn match       highlight       /highlight/

hi  entry ctermbg=234 ctermfg=197     cterm=underline
hi  at          ctermfg=197
hi  tags        ctermfg=White   cterm=underline ctermbg=232
hi  todo        ctermfg=White   ctermbg=18
hi  todo2       ctermfg=DarkBlue
hi  done        ctermfg=40      ctermbg=232
hi  url         cterm=underline ctermfg=27

hi  doing       ctermfg=black   ctermbg=40
hi  heading     ctermfg=197     cterm=bold,underline
" highlight heading ctermfg=197 cterm=bold,italic,underline

hi  highlight   cterm=italic
hi  Normal      ctermbg=232     ctermfg=white
hi  list1       ctermfg=197

