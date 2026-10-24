#!/usr/bin/env bash
# Usage: uninstall.sh [-a|--apply] [-h|--help|help]
# Undo install.sh. Dry-run by default.
# Options: -a, --apply make the changes; -h, --help short help; help long help.
# Example: uninstall.sh --apply
#
# Steps, the reverse of install.sh:
#   1. Racket    remove the Markdown docs in ~/.local/share/doc/racket
#   2. repos     every uninstall.py under ~/repos, reverse sorted; the same folders
#                install.sh skips, and agent1 (step 3 runs it), are skipped
#   3. agents    lib/agents.py uninstall: trash the copied config files, unregister the
#                ~/.agents plugin, then ~/repos/agent1/uninstall.py. Keys merged
#                into harness settings stay; see `python3 lib/agents.py help`
#   4. Ghostty   remove the dot include from the Ghostty config files
# Not undone: the pi timeout label patch (`brew reinstall pi` drops it) and
# system packages from install.sh --packages.
# A dry run runs every step without --apply; an uninstaller that never mentions
# --apply has no dry run, so it is only named. Each uninstaller runs from its own
# folder with no keyboard input. The first failure stops the run.
# Env: HOME, XDG_CONFIG_HOME (Ghostty, default ~/.config), XDG_DATA_HOME (Racket
# docs, default ~/.local/share), AGENT1 (agent1 repo).
# Exit: 0 done. 2 unknown argument. Otherwise the failing step's status.

set -PCeuo pipefail
IFS=$'\n\t'

dot=$(cd "$(dirname "$0")" && pwd -P)
apply=0
while [ "$#" -ne 0 ]; do
	case "$1" in
		-h|--help) sed -n '2,/^#$/s/^# \{0,1\}//p' "$0"; exit 0 ;;
		help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0 ;;
		-a|--apply) apply=1 ;;
		*) printf 'Unknown argument: %s\nuninstall.sh -h\n' "$1" >&2; exit 2 ;;
	esac
	shift
done

flags=()
[ "$apply" = 1 ] && flags=(--apply)
[ "$apply" = 1 ] || printf 'dry run: nothing will change; pass --apply to write\n'

step() { printf '\n== %s\n' "$1"; }

# Runs uninstaller $1 from its own folder: its shebang when executable, else python3.
# A dry run only names one that never mentions --apply: it would make its changes.
run() {
	if [ "$apply" = 0 ] && ! grep -qF -- --apply "$1"; then
		printf 'would run %s (it has no dry run)\n' "$1"
	elif [ -x "$1" ]; then
		(cd "$(dirname "$1")" && "$1" ${flags[@]+"${flags[@]}"} < /dev/null)
	else
		(cd "$(dirname "$1")" && python3 "$1" ${flags[@]+"${flags[@]}"} < /dev/null)
	fi
}

# Every uninstall.py under ~/repos except agent1's, one per line, reverse sorted.
repo_uninstallers() {
	[ -d "$HOME/repos" ] || return 0
	find "$HOME/repos" \
		\( -name '.*' -o -name node_modules -o -name target -o -name dist -o -name build \
		-o -name vendor -o -name __pycache__ -o -name venv -o -name site-packages \
		-o -name odysseus \) -prune \
		-o -type f -name uninstall.py -print \
		| grep -vxF "${AGENT1:-$HOME/repos/agent1}/uninstall.py" | LC_ALL=C sort -r || true
}

step "Racket Markdown docs"
# shellcheck source=lib/racket_docs.sh
. "$dot/lib/racket_docs.sh"
racket_docs_uninstall

for uninstaller in $(repo_uninstallers); do
	step "~${uninstaller#"$HOME"}"
	run "$uninstaller"
done

step "agents: lib/agents.py uninstall"
python3 "$dot/lib/agents.py" uninstall ${flags[@]+"${flags[@]}"} < /dev/null

step "Ghostty"
# shellcheck source=lib/ghostty.sh
. "$dot/lib/ghostty.sh"
ghostty_uninstall

if [ "$apply" = 1 ]; then
	printf '\nuninstall done\n'
else
	printf '\ndry run done; run uninstall.sh --apply to write\n'
fi
