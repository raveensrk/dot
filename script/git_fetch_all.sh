#!/usr/bin/env bash
# Fetch all repos listed in a file (default: ~/dot_local/list_of_repos.txt)

REPO_LIST="$HOME/dot_local/list_of_repos.txt"
LOG="$HOME/dot_local/git_fetch_all.log"

usage() {
    cat << HELP
Usage: $(basename "$0") [-f|--file <repo_list>] [-h|--help]

Options:
  -f, --file <path>   Path to file containing repo paths (one per line)
                      Default: ~/dot_local/list_of_repos.txt
  -h, --help          Show this help message
HELP
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--file)
            REPO_LIST="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ ! -f "$REPO_LIST" ]]; then
    echo "Error: repo list file not found: $REPO_LIST" >&2
    exit 1
fi

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG"

while IFS= read -r repo || [[ -n "$repo" ]]; do
    [[ -z "$repo" || "$repo" == \#* ]] && continue
    if git -C "$repo" fetch --all --prune 2>&1 | tee -a "$LOG"; then
        echo "[OK] $repo" >> "$LOG"
    else
        echo "[FAIL] $repo" >> "$LOG"
    fi
done < "$REPO_LIST"
