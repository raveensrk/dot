#!/bin/bash

set -e

while [ "$1" ]; do
	case "$1" in
		-r)
			shift
			repo="$1"
			;;
		*)
			echo -e "${RED}❌ ERROR! WRONG Argument!${NC}"
			exit 2
			;;
	esac
	shift
done

item=$(hg --repository "$repo" files | xargs grep . -n | fzf)
file=$(echo "$item" | awk -F ':' '{print $1}')
line=$(echo "$item" | awk -F ':' '{print $2}')
file_absolute_path="$repo/$file"

vim -c ":$line" "$file_absolute_path"
