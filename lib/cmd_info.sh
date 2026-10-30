# cmd_info.sh - shell library, loaded with source; not a command.
# shellcheck shell=bash
# Look up commands (executables, aliases, functions) and print them as a
# colored table with a one-line description. Used by ,ls_comma_cmds and ,ls_fav.

# Compiled commands have no header to read. These are checked to answer --help
# without side effects (clap prints help and exits before running anything), so
# their description is the first line of `--help`, capped at 2 seconds. Add a
# binary here only after checking that.
HELP_SAFE_BINARIES=""

# describe NAME FILE: the first meaningful header line, without "NAME - ".
describe() {
	local name=$1 file=$2 line
	if ! grep -Iq . "$file" 2>/dev/null; then
		if [[ " $HELP_SAFE_BINARIES " == *" $name "* ]]; then
			line=$(timeout --foreground 2 "$file" --help </dev/null 2>/dev/null | awk 'NF { print; exit }') || true
			line=${line%.}
		fi
		echo "${line:-(compiled binary)}"
		return
	fi
	# The header's first paragraph, joined into one line: comment lines, or a
	# docstring's lines, up to a blank line or the first line of code.
	line=$(sed -n '2,30p' "$file" | awk '
		function add(s) { out = out (out == "" ? "" : " ") s }
		function done() { if (out != "") { print out; exit } }
		/^# \/\/\/|^# dependencies|^# requires-python/ { next }
		/^#[[:space:]]*(set |shellcheck|-\*-|coding[:=])/ { next }
		doc { sub(/"""[[:space:]]*$/, ""); if (!NF) done(); add($0); if (end) done(); next }
		/^"""/ { sub(/^"""[[:space:]]*/, ""); end = sub(/"""[[:space:]]*$/, ""); doc = 1; if (NF) add($0); if (end) done(); next }
		/^#/ { sub(/^#[[:space:]]*/, ""); if (!NF) done(); add($0); next }
		{ done(); exit }
		END { if (out != "") print out }
	' | head -1)
	line=${line#"$name - "}
	# Keep the first sentence: up to the first ". " (a period followed by a space).
	line=${line%%. *}
	line=${line%.}
	echo "${line:-(no description)}"
}

# cmd_lookup: read names on stdin, one per line; print "name<TAB>where<TAB>detail"
# for each one that exists. Runs an interactive Bash so aliases and functions
# from the profile are visible. Unknown names are dropped.
#
# The inner Bash gets the names as arguments and /dev/null as stdin, never the
# terminal or a pipe: an interactive Bash started from a script in a terminal
# otherwise grabs the terminal and the caller is stopped ("Stopped" in jobs).
cmd_lookup() {
	local names=() c
	while IFS= read -r c; do
		[ -n "$c" ] && names+=("$c")
	done
	[ ${#names[@]} -gt 0 ] || return 0
	bash +m -ic '
		for c in "$@"; do
			if [ "$(type -t -- "$c")" = alias ]; then
				printf "%s\talias\t%s\n" "$c" "$(alias -- "$c" | sed "s/^[^=]*=//; s/^'"'"'//; s/'"'"'$//")"
			elif p=$(type -P -- "$c"); then
				printf "%s\t%s\t\n" "$c" "$p"
			elif t=$(type -t -- "$c"); then
				printf "%s\t%s\t\n" "$c" "$t"
			fi
		done
	' cmd_lookup "${names[@]}" </dev/null 2>/dev/null
}

# cmd_describe_rows: read lookup rows on stdin, print "name<TAB>where<TAB>desc".
# A fourth field, if present, is a note that replaces the description.
cmd_describe_rows() {
	local name where detail note desc
	while IFS=$'\t' read -r name where detail note; do
		if [ -n "$note" ]; then
			desc=$note
		elif [ -f "$where" ]; then
			desc=$(describe "$name" "$where")
		elif [ "$where" = alias ]; then
			desc="runs: $detail"
		else
			desc="($where)"
		fi
		[ -f "$where" ] && where=${where/#$HOME/\~}
		printf '%s\t%s\t%s\n' "$name" "$where" "$desc"
	done
}

# cmd_table: read "name<TAB>where<TAB>desc" rows on stdin and print aligned
# columns. A row with only a name starting with "## " is a section heading.
# Colored only on a terminal and never when NO_COLOR is set (https://no-color.org).
cmd_table() {
	local color=
	if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
		color=1
	fi
	awk -F'\t' -v color="$color" '
		BEGIN { if (color) { cn = "\033[1;32m"; cw = "\033[34m"; cx = "\033[2m"; ch = "\033[1;33m"; r = "\033[0m" } }
		{ n[NR] = $1; w[NR] = $2; d[NR] = $3
		  if ($1 ~ /^## /) next
		  if (length($1) > a) a = length($1); if (length($2) > b) b = length($2) }
		END { for (i = 1; i <= NR; i++) {
			if (n[i] ~ /^## /) { printf "%s%s%s%s\n", (i > 1 ? "\n" : ""), ch, substr(n[i], 4), r; continue }
			# Dim the placeholders: no description, compiled binary, function.
			c = (d[i] ~ /^\(/) ? cx : ""
			printf "%s%-" a "s%s  %s%-" b "s%s  %s%s%s\n", cn, n[i], r, cw, w[i], r, c, d[i], (c == "" ? "" : r)
		} }
	'
}
