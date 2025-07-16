#!/bin/csh

set code = "`tail -n 1 $HOME/.status`"
echo "code = $code"
if ($code != 0) then
    set prompt="%{\033[1;31m%}Fail:%{\033[0m%} % "
else
    set prompt="%{\033[1;32m%}Passs:%{\033[0m%} % "
endif
