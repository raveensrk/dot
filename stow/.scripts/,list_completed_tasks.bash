#!/bin/bash

# set -x
set -e

file=$(ls ~/.agenda_files/*.org_archive | fzf)
echo "$file"
line=$(grep -n "^\*" "$file" | fzf | cut -d ":" -f 1)
emacs +"$line" "$file" 
