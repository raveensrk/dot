#!/usr/bin/env bash

echo "Setting up fzf and ripgrep..."
export FZF_DEFAULT_OPTS="--keep-right --layout=reverse +s -e --history=$HOME/.fzf_history"
export FZF_COMPLETION_OPTS="--keep-right --layout=reverse +s -e --history=$HOME/.fzf_history"
export RIPGREP_CONFIG_PATH="$DOT/config/ripgrep"
echo "Done setting up fzf and ripgrep"
