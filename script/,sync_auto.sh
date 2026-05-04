#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source "$DOT/script/header.sh"

REPO_LIST="$HOME/dot_local/list_of_repos.txt"

require_file "$REPO_LIST"

sync_repo() {
	local repo="$1"

	box "$repo"

	if [[ ! -d "$repo/.git" ]]; then
		echor "Not a git repo: $repo"
		return 0
	fi

	local branch
	branch=$(git -C "$repo" branch --show-current)

	if [[ -z "$branch" ]]; then
		echor "Detached HEAD or no branch in $repo — opening lazygit"
		lazygit -p "$repo"
		return 0
	fi

	# Fetch
	echob "Fetching origin in $repo"
	if ! git -C "$repo" fetch origin 2>&1; then
		echor "Fetch failed for $repo — skipping"
		return 0
	fi

	# Dirty working tree check
	local status_output
	status_output=$(git -C "$repo" status --porcelain)
	if [[ -n "$status_output" ]]; then
		echoy "Dirty working tree in $repo — opening lazygit"
		lazygit -p "$repo"
		return 0
	fi

	# Compute ahead/behind counts relative to tracking branch
	local ahead behind
	ahead=$(git -C "$repo" rev-list "origin/${branch}..HEAD" --count 2>/dev/null || echo 0)
	behind=$(git -C "$repo" rev-list "HEAD..origin/${branch}" --count 2>/dev/null || echo 0)

	# Diverged: both ahead and behind
	if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
		echoy "Diverged history in $repo (ahead=$ahead, behind=$behind) — opening lazygit"
		lazygit -p "$repo"
		return 0
	fi

	# Ahead only: nothing to pull, just push
	if [[ "$ahead" -gt 0 && "$behind" -eq 0 ]]; then
		echob "Local is ahead by $ahead commit(s) in $repo — pushing"
		git -C "$repo" push origin "$branch"
		echog "Pushed $repo"
		return 0
	fi

	# Up to date
	if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
		echog "Already up to date: $repo"
		return 0
	fi

	# Behind only: merge then push
	echob "Remote has $behind new commit(s) in $repo — merging"
	if git -C "$repo" merge --no-ff "origin/${branch}" --no-edit; then
		git -C "$repo" push origin "$branch"
		echog "Synced $repo"
	else
		echor "Merge conflict in $repo — aborting merge and opening lazygit"
		git -C "$repo" merge --abort 2>/dev/null || true
		lazygit -p "$repo"
	fi
}

while IFS= read -r repo || [[ -n "$repo" ]]; do
	# Skip blank lines and comments
	[[ -z "$repo" || "$repo" == \#* ]] && continue
	sync_repo "$repo" || true
done < "$REPO_LIST"

echog "All repos processed."
