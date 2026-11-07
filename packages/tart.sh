#!/usr/bin/env bash
# Install tart (cirruslabs macOS VM tool) into ~/Applications/My_Apps/tart.app.
#
# The cirruslabs/cli brew tap formula fails on Homebrew 7 (depends_on :macos
# outside on_macos), so this pulls the latest GitHub release instead. tart
# must run from inside its signed app bundle, so ~/.local/bin/tart is a small
# exec wrapper, not a copy or a symlink. Rerun to upgrade.

set -euo pipefail

if [[ ${1:-} == -h || ${1:-} == --help || ${1:-} == help ]]; then
	sed -n '2,7p' "$0"
	echo
	echo "usage: packages/tart.sh"
	echo "writes: ~/Applications/My_Apps/tart.app  ~/.local/bin/tart"
	echo "exit: 0 installed, 1 not macOS or a required command is missing"
	exit 0
fi

[[ $(uname) == Darwin ]] || {
	echo "tart.sh: tart runs on macOS only" >&2
	exit 1
}
for cmd in curl tar; do
	command -v "$cmd" >/dev/null || {
		echo "tart.sh: $cmd is not installed" >&2
		exit 1
	}
done

url=https://github.com/cirruslabs/tart/releases/latest/download/tart.tar.gz
work="$HOME/tmp/tart-install"
rm -rf "$work"
mkdir -p "$work" "$HOME/Applications/My_Apps" "$HOME/.local/bin"
curl -fsSL --max-time 300 -o "$work/tart.tar.gz" "$url"
tar xzf "$work/tart.tar.gz" -C "$work"

rm -rf "$HOME/Applications/My_Apps/tart.app"
mv "$work/tart.app" "$HOME/Applications/My_Apps/tart.app"
rm -rf "$work"

# shellcheck disable=SC2016 # $HOME and $@ expand when the wrapper runs
printf '#!/bin/sh\nexec "$HOME/Applications/My_Apps/tart.app/Contents/MacOS/tart" "$@"\n' >"$HOME/.local/bin/tart"
chmod +x "$HOME/.local/bin/tart"
"$HOME/.local/bin/tart" --version
