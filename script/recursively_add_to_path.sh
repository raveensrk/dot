#!/usr/bin/env bash

recursively_add_to_path () {
	local path="$1"
	readarray -t array < <(find "$path" -type d -print0 | xargs -0 realpath)
	# echo "${array[@]}"
	PATH="$(echo "${array[@]}" | tr " " ":"):$PATH"
	# export PATH
	# echo "PATH = $PATH"
	return 0
}
