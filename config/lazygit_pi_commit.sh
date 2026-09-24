#!/usr/bin/env bash
set -euo pipefail

d=$(git diff --cached)
if [[ -z "$d" ]]; then
  echo "Nothing staged"
  exit 1
fi

msg=$(printf '%s' "$d" | pi -p -nt -nc --no-session --thinking off -- \
  'Write a conventional commit message for this staged diff. Output only the message. No markdown fences.')

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$msg" > "$tmp"

push= noedit=
for a in "$@"; do
  case $a in
    push) push=1 ;;
    -y) noedit=1 ;;
  esac
done

if [[ -n $noedit ]]; then
  git commit -F "$tmp"
else
  git commit -e -F "$tmp"
fi
[[ -n $push ]] && git push
