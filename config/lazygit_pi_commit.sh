#!/usr/bin/env bash
set -euo pipefail

# Commit staged changes with an AI-written conventional commit message.
# lazygit's commit and push helper: asks the model for the message, then runs
# the commit (or push) the human asked for.
# Claude Code (Opus 5.5, low effort) writes the message; pi is the fallback
# when claude is missing, fails or prints nothing.
# Usage: lazygit_pi_commit.sh [push] [-y] | --message
#   push       run git push after the commit
#   -y         commit without opening the editor
#   --message  print the message for the full diff (tracked edits vs HEAD and
#              untracked files) and stage or commit nothing

case "${1:-}" in
  -h|--help) sed -n '4s/^# \{0,1\}//p' "$0"; exit 0 ;;
  help) sed -n '4,/^[^#]/{/^#/s/^# \{0,1\}//p;}' "$0"; exit 0 ;;
esac

message_only=
for a in "$@"; do
  [[ $a == --message ]] && message_only=1
done

if [[ -n $message_only ]]; then
  # Diff everything through a throwaway index, so the real one is untouched.
  idx=$(mktemp)
  trap 'rm -f "$idx"' EXIT
  real=$(git rev-parse --git-path index)
  if [[ -f $real ]]; then cp "$real" "$idx"; else rm -f "$idx"; fi
  GIT_INDEX_FILE=$idx git add -A
  d=$(GIT_INDEX_FILE=$idx git diff --cached)
else
  d=$(git diff --cached)
fi
if [[ -z "$d" ]]; then
  if [[ -n $message_only ]]; then echo "Nothing to commit" >&2; else echo "Nothing staged"; fi
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

if [[ -n $message_only ]]; then
  if [[ -z $msg ]]; then echo "No message written" >&2; exit 1; fi
  printf '%s\n' "$msg"
  exit 0
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
