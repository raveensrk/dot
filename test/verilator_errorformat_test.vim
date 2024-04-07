cd %:h
set makeprg=cat\ verilator.log
set errorformat=%E%.%#:\ %f:%l:%c:\ %m
w
silent make! | copen
