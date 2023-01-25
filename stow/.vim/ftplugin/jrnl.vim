syntax match tags /@\w\+/
syntax match todo   /@todo/
syntax match todo2   /@todo2/
syntax match doing   /@doing/
syntax match done   /@done/
syntax match entry /\[\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d \w\w\]/

hi tags ctermfg=White ctermbg=Gray
highlight todo ctermfg=White ctermbg=DarkBlue
highlight todo2 ctermfg=DarkBlue
highlight doing ctermfg=White ctermbg=darkred
highlight done ctermfg=darkgreen
highlight entry ctermbg=DarkMagenta

