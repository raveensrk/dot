# Racket docs step of ~/dot/install.sh and ~/dot/uninstall.sh. Sourced, never run.
#
# racket_docs_install builds Markdown copies of every installed Racket manual with
# `raco setup --doc-markdown`. Markdown already in the folder is kept unless the
# caller set force=1. A full `raco setup` also compiles collections and rebuilds the
# HTML docs first, so the first run takes minutes. Skipped when raco is missing.
# racket_docs_uninstall removes the folder.
# Both print what they do, and write only when the caller set apply=1.
# Env: HOME, XDG_DATA_HOME (default ~/.local/share).
# Folder: $XDG_DATA_HOME/doc/racket.

racket_docs_dir="${XDG_DATA_HOME:-$HOME/.local/share}/doc/racket"

# True when the folder holds at least one Markdown file.
racket_docs_present() {
	[ -d "$racket_docs_dir" ] && [ -n "$(find "$racket_docs_dir" -name '*.md' -print -quit)" ]
}

racket_docs_install() {
	if ! command -v raco > /dev/null; then
		printf 'skip    Racket docs (no raco on PATH)\n'
		return 0
	fi
	if racket_docs_present && [ "${force:-0}" != 1 ]; then
		printf 'ok      %s (pass --force to rebuild)\n' "$racket_docs_dir"
		return 0
	fi
	printf 'build   %s (raco setup --doc-markdown)\n' "$racket_docs_dir"
	[ "$apply" = 1 ] || return 0
	mkdir -p "$racket_docs_dir"
	raco setup --doc-markdown "$racket_docs_dir" < /dev/null
}

racket_docs_uninstall() {
	[ -d "$racket_docs_dir" ] || return 0
	printf 'remove  %s\n' "$racket_docs_dir"
	[ "$apply" = 1 ] || return 0
	rm -rf "$racket_docs_dir"
}
