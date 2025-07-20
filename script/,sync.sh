#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'



cat ~/dot_personal/list_of_repos.txt | while read -r repo; do
	lazygit -p "$repo" || {
		echo "Failed to open lazygit for $repo"
		continue
	}
done
