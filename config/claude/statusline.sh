#!/usr/bin/env bash
# Claude Code status line, run in place from this repo by the statusLine
# key in config/claude/settings.json (merged into ~/.claude/settings.json).
# Mirrors the PS1 in config/prompt: [user@host|path|model], blue user,
# green host, yellow path, home shown as ~.
# Input: Claude Code's status JSON on stdin. Needs jq.
input=$(cat)
cwd=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
model=$(jq -r '.model.display_name // empty' <<<"$input")
tilde='~'
case "$cwd" in
  "$HOME") cwd=$tilde ;;
  "$HOME"/*) cwd=$tilde${cwd#"$HOME"} ;;
esac

printf '[\033[34m%s\033[0m@\033[32m%s\033[0m|\033[33m%s\033[0m' \
  "$(whoami)" "$(hostname -s)" "$cwd"
[ -n "$model" ] && printf '|%s' "$model"
printf ']'
