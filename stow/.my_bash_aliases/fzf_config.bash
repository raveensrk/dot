export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history"
export FZF_CTRL_T_COMMAND="command find -L . $HOME/my_repos 2> /dev/null"
export FZF_DEFAULT_COMMAND="command find -L . 2> /dev/null"
export FZF_ALT_C_COMMAND="command find -L . $HOME/my_repos -type d 2> /dev/null"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
