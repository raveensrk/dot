#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

echo "==> Updating brew metadata..."
brew update

echo "==> Checking brew health..."
brew doctor || true

echo "==> Removing old versions..."
brew cleanup -s

echo "==> Removing unused dependencies..."
brew autoremove

echo "==> Clearing download cache..."
rm -rf "$(brew --cache)"

echo "==> Pruning dead symlinks..."
brew cleanup --prune=all

echo "==> Done."
echo "Disk usage after cleanup:"
brew cleanup -n
