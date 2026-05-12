#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

source "$DOT/script/header.sh"

REPO_LIST="$HOME/dot_local/list_of_repos.txt"

sync_repo() {
	local repo="$1"

	if [[ ! -d "$repo/.git" ]]; then
		return 0
	fi

	box "$repo"

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

use_default=true
target_dirs=()
list_files=()

while [[ $# -gt 0 ]]; do
	case "$1" in
		-d|--dir)
			target_dirs+=("$2")
			use_default=false
			shift 2
			;;
		-f|--file)
			list_files+=("$2")
			use_default=false
			shift 2
			;;
		-h|--help)
			echo "Usage: $(basename "$0") [-d|--dir <dir>] [-f|--file <file>]"
			exit 0
			;;
		*)
			echor "Unknown option: $1"
			exit 1
			;;
	esac
done

if [[ "$use_default" == true ]]; then
	list_files+=("$REPO_LIST")
fi

repos_to_sync=()

for lf in "${list_files[@]}"; do
	if [[ ! -f "$lf" ]]; then
		echor "List file not found: $lf"
		continue
	fi
	while IFS= read -r repo || [[ -n "$repo" ]]; do
		[[ -z "$repo" || "$repo" == \#* ]] && continue
		repos_to_sync+=("$repo")
	done < "$lf"
done

for td in "${target_dirs[@]}"; do
	if [[ ! -d "$td" ]]; then
		echor "Directory not found: $td"
		continue
	fi
	echob "Scanning directory: $td"
	while IFS= read -r git_dir; do
		repos_to_sync+=("$(dirname "$git_dir")")
	done < <(find "$td" -name ".git" -type d -prune)
done

processed_repos=$'\n'
for repo in "${repos_to_sync[@]}"; do
	# Resolve absolute path to ensure accurate deduplication
	repo_path=$(cd "$repo" 2>/dev/null && pwd) || repo_path="$repo"
	
	if [[ "$processed_repos" == *$'\n'"$repo_path"$'\n'* ]]; then
		continue
	fi
	processed_repos="${processed_repos}${repo_path}"$'\n'
	
	sync_repo "$repo" || true
done

echog "All repos processed."
