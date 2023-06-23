#!/usr/bin/env bash

set -e

mapfile -t files < <(find . -type f -name "*.md" -exec sh -c 'grep -q -m 1 -e "^---" "$1" || echo "$1"' _ {} \;)

for file in "${files[@]}"; do
    $EDITOR "$file"
    sleep 1
done



