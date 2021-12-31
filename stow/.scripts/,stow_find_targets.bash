#!/bin/bash

set -e

for d in $(find -name "stow"); do
	echo "$d"
	stowd=$(realpath "$d")
	echo "$stowd"
	pushd "$stowd"
	cd ..
	stow -R stow -t "$HOME" 2>&1 | tee ".stow.log"
	while read -r line; do
		regex='^.*existing target is not owned by stow:\s(.*)\s=>\s(.*)$'
		if [[ "$line" =~ $regex ]]; then
			# echo "${BASH_REMATCH[0]}"
			# echo "${BASH_REMATCH[1]}"
			# echo "${BASH_REMATCH[2]}"
			rm -v "$HOME/${BASH_REMATCH[1]}"
		fi

		regex2='^.*existing target is neither a link nor a directory:\s(.*)$'
		if [[ "$line" =~ $regex2 ]]; then
			# echo "${BASH_REMATCH[0]}"
			# echo "${BASH_REMATCH[1]}"
			# echo "${BASH_REMATCH[2]}"
			rm -v "$HOME/${BASH_REMATCH[1]}"
		fi
	done < ".stow.log"
    rm ".stow.log"
	popd
done
