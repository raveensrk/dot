#!/usr/bin/env bash

set -PCeuo pipefail
IFS=$'\n\t'

# shellcheck source=colors.sh
source "${DOT:-$HOME/dot}/script/colors.sh"

usage() {
	cat <<-HERE
		Usage: $(basename "$0") <url-or-file>

		Rehost an image on imgbb. Accepts either a remote URL (http/https)
		or a local file path. Prints the resulting imgbb URL to stdout,
		copies it to the clipboard (pbcopy), and opens it in the browser.

		Auth: requires an imgbb API key. Set via either:
		  export IMGBB_API_KEY=...        # in ~/.bashrc or ~/dot_local
		  ~/.config/imgbb/api_key         # single-line file (chmod 600)

		Get a free API key at https://api.imgbb.com/ (sign in, then
		"Add API key").
	HERE
	exit 0
}

if [[ $# -eq 0 ]]; then
	echor "missing argument: image URL or file path"
	echo "try: $(basename "$0") --help" >&2
	exit 2
fi

case "$1" in
	-h|--help) usage ;;
esac

if [[ $# -ne 1 ]]; then
	echor "expected exactly 1 argument, got $#"
	exit 2
fi

arg="$1"

for cmd in curl jq; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echor "missing required command: $cmd"
		exit 2
	fi
done

api_key="${IMGBB_API_KEY:-}"
if [[ -z "$api_key" ]]; then
	cred_file="$HOME/.config/imgbb/api_key"
	if [[ -f "$cred_file" ]]; then
		api_key=$(< "$cred_file")
		api_key="${api_key//[$'\r\n\t ']/}"
	fi
fi

if [[ -z "$api_key" ]]; then
	echor "no imgbb API key. set \$IMGBB_API_KEY or write to ~/.config/imgbb/api_key"
	exit 2
fi

if [[ "$arg" =~ ^https?:// ]]; then
	form_arg="image=$arg"
elif [[ -f "$arg" ]]; then
	form_arg="image=@$arg"
else
	echor "not a URL and not an existing file: $arg"
	exit 2
fi

response=$(curl -sS --max-time 120 \
	-F "key=$api_key" \
	-F "$form_arg" \
	"https://api.imgbb.com/1/upload" || true)

if [[ -z "$response" ]]; then
	echor "no response from imgbb API"
	exit 2
fi

success=$(jq -r '.success // false' <<<"$response")
if [[ "$success" != "true" ]]; then
	err=$(jq -r 'if (.error | type) == "object" then (.error.message // .status_txt // "unknown error") else (.error // .status_txt // "unknown error") end' <<<"$response")
	echor "imgbb upload failed: $err"
	exit 2
fi

link=$(jq -r '.data.url' <<<"$response")

echo "$link"

if command -v pbcopy >/dev/null 2>&1; then
	printf '%s' "$link" | pbcopy || true
fi

if command -v open >/dev/null 2>&1; then
	open "$link" || true
elif command -v xdg-open >/dev/null 2>&1; then
	xdg-open "$link" >/dev/null 2>&1 &
fi

echob "uploaded: $link" >&2
