#!/usr/bin/env bash
# Usage: install.sh [-h|--help|help]
# Point Ghostty at ~/dot/config/config.ghostty.
# Options: -h, --help short help; help long help.
# Example: install.sh
#
# Writes `config-file = $HOME/dot/config/config.ghostty` as the last config-file
# line. Creates that file when missing. Replaces an include of dot/config/ghostty.conf.
# On macOS the Library file wins, so the include is written only there. A second
# include under the XDG dir is removed: Ghostty skips a repeated config-file, and
# the theme picker then wins. Other systems write the XDG config.ghostty.
# A bare call does that install. Help exits before any write.
# Env: HOME, XDG_CONFIG_HOME (default ~/.config).
# Reads and writes, on macOS: ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty.
# Also reads $XDG_CONFIG_HOME/ghostty/config and config.ghostty, and removes a dot include there.
# Exit: 0 help or install done. 2 unknown argument. Other failures exit via set -e.

set -PCeuo pipefail
IFS=$'\n\t'

case "${1:-}" in
	-h|--help) sed -n '2,/^#$/s/^# \{0,1\}//p' "$0"; exit 0 ;;
	help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0 ;;
	"") ;;
	*) printf 'Unknown argument: %s\ninstall.sh -h\n' "$1" >&2; exit 2 ;;
esac

line="config-file = $HOME/dot/config/config.ghostty"
drop='^[[:space:]]*config-file[[:space:]]*=[[:space:]]*"?\??[[:space:]]*.*dot/config/(ghostty\.conf|config\.ghostty)"?[[:space:]]*$'

ensure() {
	file=$1
	mkdir -p "$(dirname "$file")"
	if [ ! -f "$file" ]; then
		printf '%s\n' "$line" > "$file"
		return
	fi
	count=$(grep -cE "$drop" "$file" || true)
	last=$(grep -E '^[[:space:]]*config-file[[:space:]]*=' "$file" | tail -n 1 || true)
	if [ "$count" -eq 1 ] && [ "$last" = "$line" ]; then
		return
	fi
	scratch=$(mktemp "$HOME/tmp/ghostty-install.XXXXXX")
	grep -vE "$drop" "$file" >| "$scratch" || true
	printf '%s\n' "$line" >> "$scratch"
	cat "$scratch" >| "$file"
	rm -f "$scratch"
}

strip_dot() {
	file=$1
	[ -f "$file" ] || return 0
	grep -qE "$drop" "$file" || return 0
	scratch=$(mktemp "$HOME/tmp/ghostty-install.XXXXXX")
	grep -vE "$drop" "$file" >| "$scratch" || true
	if [ ! -s "$scratch" ]; then
		rm -f "$file" "$scratch"
		return
	fi
	cat "$scratch" >| "$file"
	rm -f "$scratch"
}

xdg="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
if [ "$(uname -s)" = Darwin ]; then
	ensure "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
	strip_dot "$xdg/config.ghostty"
	strip_dot "$xdg/config"
else
	ensure "$xdg/config.ghostty"
	strip_dot "$xdg/config"
fi
