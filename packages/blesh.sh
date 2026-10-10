#!/usr/bin/env bash
# Install ble.sh into ~/.local/share/blesh.
#
# Needs git, GNU make and gawk. Clones akinomyoga/ble.sh to ~/.local/src/ble.sh
# and runs make install. config/bashrc sources it in interactive shells.
# config/blesh.sh attaches it, after fzf, from ~/.bashrc.

set -euo pipefail

if [[ ${1:-} == -h || ${1:-} == --help || ${1:-} == help ]]; then
	sed -n '2,6p' "$0"
	echo
	echo "usage: packages/blesh.sh"
	echo "writes: ~/.local/src/ble.sh  ~/.local/share/blesh/ble.sh"
	echo "exit: 0 installed, 1 a required command is missing"
	exit 0
fi

for cmd in git make gawk; do
	command -v "$cmd" >/dev/null || {
		echo "blesh.sh: $cmd is not installed" >&2
		exit 1
	}
done

src="$HOME/.local/src/ble.sh"
if [[ ! -d $src/.git ]]; then
	mkdir -p "$HOME/.local/src"
	git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$src"
fi
make -C "$src" install PREFIX="$HOME/.local"
