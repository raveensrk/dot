syntax match tags /@\w\+/
syntax match todo   /@todo/
syntax match todo2   /@todo2/
syntax match doing   /@doing/
syntax match done   /@done/
syntax match entry /\[\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d \w\w\]/
syn match url /https:\/\/[a-zA-Z.\/0-9-_]\+/
syn match heading /^\#.*/

highlight entry ctermbg=232  cterm=standout 
hi tags ctermfg=White cterm=underline ctermbg=232
highlight todo ctermfg=White ctermbg=18
highlight todo2 ctermfg=DarkBlue
highlight done ctermfg=40 ctermbg=232
hi url cterm=underline ctermfg=27

highlight doing ctermfg=White ctermbg=52
highlight heading ctermfg=White ctermbg=5

syn match highlight /highlight/
hi highlight cterm=italic
