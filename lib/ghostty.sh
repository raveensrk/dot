# Ghostty step of ~/dot/install.sh and ~/dot/uninstall.sh. Sourced, never run.
#
# ghostty_install points Ghostty at ~/dot/config/config.ghostty: it writes
# `config-file = $HOME/dot/config/config.ghostty` as the last config-file line,
# creating the file when missing, and replaces an include of dot/config/ghostty.conf.
# On macOS the Library file wins, so the include is written only there. A second
# include under the XDG dir is removed: Ghostty skips a repeated config-file, and
# the theme picker then wins. Other systems write the XDG config.ghostty.
# ghostty_uninstall removes the dot include from every one of those files, and a
# file left empty.
# Both print what they do, and write only when the caller set apply=1.
# Env: HOME, XDG_CONFIG_HOME (default ~/.config).
# Files, on macOS: ~/Library/Application Support/com.mitchellh.ghostty/config.ghostty.
# Also $XDG_CONFIG_HOME/ghostty/config and config.ghostty.

ghostty_line="config-file = $HOME/dot/config/config.ghostty"
ghostty_drop='^[[:space:]]*config-file[[:space:]]*=[[:space:]]*"?\??[[:space:]]*.*dot/config/(ghostty\.conf|config\.ghostty)"?[[:space:]]*$'
ghostty_xdg="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
ghostty_mac="$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"

# The file Ghostty reads on this system.
ghostty_main() {
	if [ "$(uname -s)" = Darwin ]; then
		printf '%s\n' "$ghostty_mac"
	else
		printf '%s\n' "$ghostty_xdg/config.ghostty"
	fi
}

ghostty_ensure() {
	file=$1
	if [ ! -f "$file" ]; then
		printf 'create  %s\n' "$file"
		[ "$apply" = 1 ] || return 0
		mkdir -p "$(dirname "$file")"
		printf '%s\n' "$ghostty_line" > "$file"
		return
	fi
	count=$(grep -cE "$ghostty_drop" "$file" || true)
	last=$(grep -E '^[[:space:]]*config-file[[:space:]]*=' "$file" | tail -n 1 || true)
	if [ "$count" -eq 1 ] && [ "$last" = "$ghostty_line" ]; then
		printf 'ok      %s\n' "$file"
		return
	fi
	printf 'update  %s (dot include goes last)\n' "$file"
	[ "$apply" = 1 ] || return 0
	mkdir -p "$HOME/tmp"
	scratch=$(mktemp "$HOME/tmp/ghostty-install.XXXXXX")
	grep -vE "$ghostty_drop" "$file" >| "$scratch" || true
	printf '%s\n' "$ghostty_line" >> "$scratch"
	cat "$scratch" >| "$file"
	rm -f "$scratch"
}

ghostty_strip() {
	file=$1
	[ -f "$file" ] || return 0
	grep -qE "$ghostty_drop" "$file" || return 0
	printf 'strip   %s (dot include)\n' "$file"
	[ "$apply" = 1 ] || return 0
	mkdir -p "$HOME/tmp"
	scratch=$(mktemp "$HOME/tmp/ghostty-install.XXXXXX")
	grep -vE "$ghostty_drop" "$file" >| "$scratch" || true
	if [ ! -s "$scratch" ]; then
		rm -f "$file" "$scratch"
		return
	fi
	cat "$scratch" >| "$file"
	rm -f "$scratch"
}

ghostty_install() {
	ghostty_ensure "$(ghostty_main)"
	[ "$(uname -s)" = Darwin ] && ghostty_strip "$ghostty_xdg/config.ghostty"
	ghostty_strip "$ghostty_xdg/config"
}

ghostty_uninstall() {
	[ "$(uname -s)" = Darwin ] && ghostty_strip "$ghostty_mac"
	ghostty_strip "$ghostty_xdg/config.ghostty"
	ghostty_strip "$ghostty_xdg/config"
}
