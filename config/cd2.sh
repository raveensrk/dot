#!/usr/bin/env bash

cd2() {
	if test -z "$1"; then
		builtin cd "$HOME" || return 2
	elif [[ "$1" == "-" ]]; then
		builtin cd - || return 2
	else
		builtin cd "$1" || return 2
	fi
	echo "$PWD" >> "$HOME"/cds.txt
	ls -X --color --group-directories-first
}

cd2s() {
	cd2s="$HOME/cds.txt"
	cd "$(sort "$cd2s" | uniq | fzf +s)" || return 2
}
