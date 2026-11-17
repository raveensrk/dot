#!/usr/bin/env bash
# Claude Code status line, run in place from this repo by the statusLine
# key in config/claude/settings.json (merged into ~/.claude/settings.json).
# Mirrors the PS1 in config/prompt:
# [user@host|path|branch*↑N|model|effort|C:NN%|$cost|S:+a/-r|U:+a/-r], blue user,
# green host, yellow path, home shown as ~.
# Input: Claude Code's status JSON on stdin. Needs jq.
input=$(cat)
cwd=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
model=$(jq -r '.model.display_name // empty' <<<"$input")
# Effort: shown only when the status JSON carries .effort.level.
effort=$(jq -r '.effort.level // empty' <<<"$input")
# Context used: shown only when the status JSON carries it.
used=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
# Session cost and lines changed: shown only when the status JSON carries them.
cost=$(jq -r '.cost.total_cost_usd // empty' <<<"$input")
added=$(jq -r '.cost.total_lines_added // empty' <<<"$input")
removed=$(jq -r '.cost.total_lines_removed // empty' <<<"$input")
dir=$cwd
tilde='~'
case "$cwd" in
  "$HOME") cwd=$tilde ;;
  "$HOME"/*) cwd=$tilde${cwd#"$HOME"} ;;
esac

# Git: branch, * when there are uncommitted changes, ↑N unpushed commits.
# Outside a repo nothing is shown.
branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null ||
  git -C "$dir" rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  [ -n "$(git -C "$dir" --no-optional-locks status --porcelain --untracked-files=no 2>/dev/null | head -1)" ] && branch="$branch*"
  ahead=$(git -C "$dir" rev-list --count @{upstream}..HEAD 2>/dev/null)
  [ -n "$ahead" ] && [ "$ahead" -gt 0 ] && branch="$branch↑$ahead"
  # Uncommitted lines, staged and not, in this repo: what /diff shows.
  stat=$(git -C "$dir" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
  u_add=$(sed -n 's/.* \([0-9]*\) insertion.*/\1/p' <<<"$stat")
  u_del=$(sed -n 's/.* \([0-9]*\) deletion.*/\1/p' <<<"$stat")
fi

printf '[\033[34m%s\033[0m@\033[32m%s\033[0m|\033[33m%s\033[0m' \
  "$(whoami)" "$(hostname -s)" "$cwd"
[ -n "$branch" ] && printf '|\033[35m%s\033[0m' "$branch"
[ -n "$model" ] && printf '|%s' "$model"
[ -n "$model" ] && [ -n "$effort" ] && printf '|%s' "$effort"
[ -n "$used" ] && printf '|C:%.0f%%' "$used"
[ -n "$cost" ] && printf '|$%.2f' "$cost"
# S: lines Claude changed this session, all repos, committed or not.
[ -n "$added" ] && printf '|S:\033[32m+%s\033[0m/\033[31m-%s\033[0m' "$added" "${removed:-0}"
# U: uncommitted lines in this repo; left out when there are none.
[ -n "$u_add$u_del" ] && printf '|U:\033[32m+%s\033[0m/\033[31m-%s\033[0m' "${u_add:-0}" "${u_del:-0}"
printf ']'
