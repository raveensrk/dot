#!/bin/bash

set -e

item=$(grep --exclude-dir=.git --exclude-dir=.hg -H -n -r . | fzf -e )
file=$(echo "$item" | awk -F ':' '{print $1}')
line=$(echo "$item" | awk -F ':' '{print $2}')
file_absolute_path="$file"

vim -c ":$line" "$file_absolute_path"
