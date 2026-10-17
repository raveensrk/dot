#!/usr/bin/env bash
set -euo pipefail

# Commit staged changes with an AI-written conventional commit message.
# lazygit's commit and push helper: asks the model for the message, then runs
# the commit (or push) the human asked for.
# Claude Code (Opus 5.5, low effort) writes the message; pi is the fallback
# when claude is missing, fails or prints nothing.
# Usage: lazygit_pi_commit.sh [push] [-y]
#   push  run git push after the commit
#   -y    commit without opening the editor

case "${1:-}" in
  -h|--help) sed -n '4s/^# \{0,1\}//p' "$0"; exit 0 ;;
  help) sed -n '4,/^[^#]/{/^#/s/^# \{0,1\}//p;}' "$0"; exit 0 ;;
esac

d=$(git diff --cached)
if [[ -z "$d" ]]; then
  echo "Nothing staged"
  exit 1
fi

prompt='Write a Conventional Commits message (type(scope): subject, e.g. feat: ..., fix: ...) for this staged diff. Output only the message. No markdown fences. Only Plain Text.'

msg=
if command -v claude >/dev/null; then
  msg=$(printf '%s' "$d" | claude -p --no-session-persistence --tools "" \
    --model claude-opus-5-5 --effort low "$prompt") || msg=
fi
if [[ -z $msg ]]; then
  echo "claude failed, falling back to pi" >&2
  msg=$(printf '%s' "$d" | pi -p -nt -nc --no-session --thinking off -- "$prompt")
fi

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
