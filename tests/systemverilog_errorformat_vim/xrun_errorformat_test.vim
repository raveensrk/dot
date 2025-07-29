cd %:h
set makeprg=cat\ logfile.log
set errorformat=%.%#error:\ %f:%l,
set errorformat+=%.%#xmvlog:\ (%f\\,%l\|%c),
" set errorformat+=%.%#xmvlog:\ %\\%#E\\,%l
" set errorformat+=%.%#xmvlog:\ %\\%#E\\,%.%#(%f\\,%l\|%c):\ %m
set errorformat+=%.%#xmvlog:\ %\\%#%t\\,%o%.%#(%f\\,%l\|%c):\ %m
" set errorformat+=%.%#xmsim:\ %\\%#E\\,%o:\ %m
set errorformat+=%E%.%#xmsim:\ %\\%#E\\,%o:\ %m,%C%.%#File:\ %f\\,\ line\ =\ %l\\,\ pos\ =\ %c,%Z
set errorformat+=%EUVM_FATAL\ @\ %.%#:\ %o
" set errorformat+=%E%o\ %f(%l)\ @\ %c:\ %m%.%#
set errorformat+=%IUVM_INFO\ %f(%l)\ @\ %c:\ %m%.%#
set errorformat+=%EError-%m 
set errorformat+=%WWarning-\[%m\] %m 


w
tabnew +lmake | lopen
