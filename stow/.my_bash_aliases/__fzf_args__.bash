#!/usr/bin/env bash

# This keybinding will take last 10 commands from the current shell and list
# all the arguments vertically with fzf selection for insertion at the current
# pointer location. Keybinding is assigned as C-x a.

__fzf_args__() {
    local cmd opts
    cmd="builtin fc -l -10 | cut -f2- | tr ' ' '\n' | tr -d ' ' | sed '/^$/d' | sort | uniq"
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
    eval "$cmd" |
        FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) "$@" |
        while read -r item; do
            printf '%q ' "$item"  # escape special chars
        done
}

fzf-arg-widget() {
    local selected="$(__fzf_args__ "$@")"
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
}

# CTRL-. - Paste the selected file path into the command line
bind -m emacs-standard -x '"\C-xa":"fzf-arg-widget"'
bind -m vi-insert -x '"\C-xa":"fzf-arg-widget"'
bind -m vi-command -x '"\C-xa":"fzf-arg-widget"'
