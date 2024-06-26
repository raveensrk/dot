#!/usr/bin/env bash

export FZF_DEFAULT_OPTS="--layout=reverse +s -e --history=$HOME/.fzf_history"
export FZF_COMPLETION_OPTS="--layout=reverse +s -e --history=$HOME/.fzf_history"
export RIPGREP_CONFIG_PATH="$DOT/config/ripgrep"
eval "$(fzf --bash)"
