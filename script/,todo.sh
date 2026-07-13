#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

# built-in defaults; a config file overrides these
patterns=(TODO IN_PROGRESS FIXME BUG LATER '\[ \]')
extensions=(md)
default_dirs=(.)
ignore=()

config="${TODORC:-${XDG_CONFIG_HOME:-$HOME/.config}/todo/config}"
if [[ -f "$config" ]]; then
	# shellcheck source=/dev/null
	source "$config"
fi

if (($#)); then
	dirs=("$@")
else
	dirs=("${default_dirs[@]}")
fi

rg_args=()
for ext in "${extensions[@]}"; do
	rg_args+=(--glob "*.${ext}")
done
if ((${#ignore[@]})); then
	for glob in "${ignore[@]}"; do
		# rg matches slash-containing globs against the full displayed path;
		# anchor them with **/ so they apply at any depth under any search root
		if [[ $glob == */* && $glob != /* && $glob != '**'* ]]; then
			glob="**/${glob}"
		fi
		rg_args+=(--glob "!${glob}")
	done
fi

pattern=$(IFS='|'; printf '%s' "${patterns[*]}")

matches=$(rg --vimgrep --case-sensitive "${rg_args[@]}" -- "$pattern" "${dirs[@]}" || true)

if [[ -z "$matches" ]]; then
	echo "No matches for '$pattern' in *.{$(IFS=,; printf '%s' "${extensions[*]}")} under: $(IFS=' '; printf '%s' "${dirs[*]}")"
	exit 0
fi

vim -q <(printf '%s\n' "$matches") -c 'copen'
