#!/usr/bin/env bash
# Usage: install.sh [-a|--apply] [-p|--packages] [-h|--help|help]
# Install this machine's setup from ~/dot. Dry-run by default.
# Options: -a, --apply make the changes; -p, --packages also install system packages; -h, --help short help; help long help.
# Example: install.sh --apply
#
# The primary installer; uninstall.sh undoes it. Steps, in order:
#   1. Ghostty   point Ghostty at config/config.ghostty (lib/ghostty.sh)
#   2. agents    lib/agents.py install: pi, Claude Code and Codex config, Go and Rust
#                builds, then ~/repos/agent1/install.py
#   3. repos     every other install.py under ~/repos, sorted; hidden, build and
#                dependency folders, agent1 (step 2 runs it) and odysseus skipped
#   4. pi patch  lib/pi_timeout_label.py; skipped when pi is not Homebrew's
#   5. packages  only with --packages: packages/macos.sh or packages/ubuntu.sh, then
#                config/vim/plugin/install_vim_plugins.sh. These have no dry run,
#                so a dry run only names them. They need a network, and sudo.
# A dry run runs every step without --apply and prints its plan; an installer
# that never mentions --apply has no dry run, so it is only named. Each installer
# runs from its own folder with no keyboard input, so one that asks a question
# fails instead of waiting. The first failure stops the run.
# Env: HOME, XDG_CONFIG_HOME (Ghostty, default ~/.config), AGENT1 (agent1 repo).
# Exit: 0 done. 2 unknown argument. Otherwise the failing step's status.

set -PCeuo pipefail
IFS=$'\n\t'

dot=$(cd "$(dirname "$0")" && pwd -P)
apply=0
packages=0
while [ "$#" -ne 0 ]; do
	case "$1" in
		-h|--help) sed -n '2,/^#$/s/^# \{0,1\}//p' "$0"; exit 0 ;;
		help) sed -n '2,/^[^#]/s/^# \{0,1\}//p' "$0"; exit 0 ;;
		-a|--apply) apply=1 ;;
		-p|--packages) packages=1 ;;
		*) printf 'Unknown argument: %s\ninstall.sh -h\n' "$1" >&2; exit 2 ;;
	esac
	shift
done

flags=()
[ "$apply" = 1 ] && flags=(--apply)
[ "$apply" = 1 ] || printf 'dry run: nothing will change; pass --apply to write\n'

step() { printf '\n== %s\n' "$1"; }

# Runs installer $1 from its own folder: its shebang when executable, else python3.
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

# Every install.py under ~/repos except agent1's, one per line, sorted.
repo_installers() {
	[ -d "$HOME/repos" ] || return 0
	find "$HOME/repos" \
		\( -name '.*' -o -name node_modules -o -name target -o -name dist -o -name build \
		-o -name vendor -o -name __pycache__ -o -name venv -o -name site-packages \
		-o -name odysseus \) -prune \
		-o -type f -name install.py -print \
		| grep -vxF "${AGENT1:-$HOME/repos/agent1}/install.py" | LC_ALL=C sort || true
}

step "Ghostty"
# shellcheck source=lib/ghostty.sh
. "$dot/lib/ghostty.sh"
ghostty_install

step "agents: lib/agents.py install"
python3 "$dot/lib/agents.py" install ${flags[@]+"${flags[@]}"} < /dev/null

for installer in $(repo_installers); do
	step "~${installer#"$HOME"}"
	run "$installer"
done

step "pi timeout label patch"
python3 "$dot/lib/pi_timeout_label.py" ${flags[@]+"${flags[@]}"} < /dev/null

if [ "$packages" = 1 ]; then
	case "$(uname -s)" in
		Darwin) pkg="$dot/packages/macos.sh" ;;
		*) pkg="$dot/packages/ubuntu.sh" ;;
	esac
	vim="$dot/config/vim/plugin/install_vim_plugins.sh"
	step "packages: ${pkg#"$dot/"}"
	if [ "$apply" = 1 ]; then bash "$pkg"; else printf 'would run %s\n' "$pkg"; fi
	step "vim plugins: ${vim#"$dot/"}"
	if [ "$apply" = 1 ]; then bash "$vim"; else printf 'would run %s\n' "$vim"; fi
fi

if [ "$apply" = 1 ]; then
	printf '\ninstall done\n'
else
	printf '\ndry run done; run install.sh --apply to write\n'
fi
