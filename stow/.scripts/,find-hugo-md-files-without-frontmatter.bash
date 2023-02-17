#!/usr/bin/env bash

mapfile -t files < <(find . -type f -name "*.md" -exec sh -c 'grep -q -m 1 -e "^---" "$1" || echo "$1"' _ {} \;)

echo $files
