#!/bin/bash

set -e

item=$(grep -H -n -r . | fzf)
file=$(echo "$item" | awk -F ':' '{print $1}')
line=$(echo "$item" | awk -F ':' '{print $2}')
file_absolute_path="$file"

vim -c ":$line" "$file_absolute_path"
