#!/bin/bash

echo --------------
echo Location
echo --------------
realpath $1

echo --------------
echo Help
echo --------------
cat $1 | grep "# HELP:" | sed "s/\s\+# HELP://g"

exit 0
