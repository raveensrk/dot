#!/usr/bin/env bash

# BASH ALIASES sourced at ~/.bashrc
set -o vi
# set -o emacs
export EDITOR="vim"
# {{{ PROMPT AND COLORS
source "$HOME/.bash_prompt"
# }}}
# {{{ ENVIRONMENT VARIABLES
export MY_REPOS="$HOME/my_repos"
# export DISPLAY=:0
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
if [ -d /var/lib/flatpak/exports/bin ]; then
	export PATH="/var/lib/flatpak/exports/bin:$PATH"
fi
for dir in $(find ~/.scripts -type d); do export PATH="$dir:$PATH"; done
# }}}
# {{{ BASH SHOPTS
# This will exit bash shell as soon as it receives C-d as the last command
export IGNOREEOF=0
# shopt -s direxpand
shopt -s histappend
shopt -s checkwinsize
shopt -s checkjobs
shopt -s execfail
shopt -s cmdhist
shopt -s lithist
shopt -s no_empty_cmd_completion
export HISTCONTROL="ignoredups,erasedups"
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTIGNORE="^v,^vim,^cd,^ls,^l"
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_history
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# export PROMPT_COMMAND="$PROMPT_COMMAND"

# }}}
# {{{ INTERFACE
if [ -v xset ]; then
	# Insead of this use macos settings -> keyboard -> repeat fast -> delay short
	xset r rate 300 50
	xset m 10 1
fi
# Colors
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	if test -r ~/.dircolors; then
		eval "$(dircolors -b ~/.dircolors)"
	else
		eval "$(dircolors -b)"
	fi
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi
# }}}
# {{{ ALIASES
if command -v bat >/dev/null; then
	alias cat=bat
fi
alias ,chop="tr -d '\n'"         # Remove newline
alias ,transposevh="tr '\n' ' '" # Transpose vertical to horizontal
alias ,transposehv="tr ' ' '\n'" # Transpose horizontal to vertical
alias ,untar="tar xf"
alias ,hcat="paste -s" # To concatenate the contents of a vertical file horizontally
# LS aliases

if command -v exa >/dev/null; then
	alias ls='exa'
	alias l="exa -lah"
else
	alias ls='ls --color=auto'
	alias l="ls -Alh"
fi
alias ltr="ls -tr"
alias ..="cd .."
alias ,top_faster_refresh='top -d 0.125'
alias ,date='date -I'
alias ,date_yesterday='/bin/date -I -v-1d'
alias ,date1="date +%Y%m%d%H%M%S"
alias ,date2='date -Iseconds | sed "s/:/-/g"'
alias mkdir="mkdir -v"
alias cp="cp -vi"
alias mv="mv -vi"
alias rm="rm -vi"
alias tmux="tmux -2"
alias t="tmux attach || tmux"
alias ,tree="tree -C"
alias ,tree2="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # https://github.com/you-dont-need/You-Dont-Need-GUI
alias ,rsync="rsync -CazhPvu"                                         # -C
alias ,rp="realpath"

# }}}
# {{{ PAGERS
export PAGER='less'
# Less colors
#-------------------
alias less='less --ignore-case'
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Man colors
#------------------
man() {
	LESS_TERMCAP_md=$'\e[01;31m' LESS_TERMCAP_me=$'\e[0m' LESS_TERMCAP_se=$'\e[0m' LESS_TERMCAP_so=$'\e[01;44;33m' LESS_TERMCAP_ue=$'\e[0m' LESS_TERMCAP_us=$'\e[01;32m' command man "$@"
}
# }}}
# {{{ VIM
# export EDITOR="vim"
alias ,bashrc="vim ~/.bashrc"
alias ,vimrc="vim ~/.vimrc"
alias v="vim"
alias vl='vim -c "normal '\''0"'
# }}}
# RANGER {{{
# shellcheck shell=sh

# Compatible with ranger 1.4.2 through 1.9.*
#
# Automatically change the current working directory after closing ranger
#
# This is a shell function to automatically change the current working
# directory to the last visited one after ranger quits. Either put it into your
# .zshrc/.bashrc/etc or source this file from your shell configuration.
# To undo the effect of this function, you can type "cd -" to return to the
# original directory.

ranger_cd() {
	temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
	local dir_or_file

	[[ -f "$@" ]] && dir_or_file=$(dirname "$@") || dir_or_file="$@"

	ranger --choosedir="$temp_file" -- "${dir_or_file:-$PWD}"
	if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
		cd "$chosen_dir"
	fi
	rm -f -- "$temp_file"
}

alias r="ranger_cd"

# This binds Ctrl-O to ranger-cd:
bind '"\C-o":"ranger-cd\C-m"'

# shellcheck shell=sh

# Compatible with ranger 1.5.3 through 1.9.*
#
# Change the prompt when you open a shell from inside ranger
#
# Source this file from your shell startup file (.bashrc, .zshrc etc) for it to
# work.

[ -n "$RANGER_LEVEL" ] && PS1="$PS1"'(in ranger) '
# }}}
# {{{ Completion system
if [ -f /etc/bash_completion ]; then
	# shellcheck disable=SC1091
	. /etc/bash_completion
fi
# shellcheck disable=SC1090
[ -f ~/.local/etc/profile.d/bash_completion.sh ] && source ~/.local/etc/profile.d/bash_completion.sh

# Use bash-completion, if available
# shellcheck disable=SC1090
[[ $PS1 && -f ~/.local/share/bash-completion/bash_completion ]] &&
	. ~/.local/share/bash-completion/bash_completion

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		# shellcheck disable=SC1091
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		# shellcheck disable=SC1091
		. /etc/bash_completion
	fi
fi

# }}}
# {{{ BUG FIXES
# MACOS Specific {{{
if [ "$(uname -a | awk '{print $1}')" = "Darwin" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
	# https://github.com/platformio/platformio-atom-ide-terminal/issues/196
	update_terminal_cwd() {
		# Identify the directory using a "file:" scheme URL,
		# including the host name to disambiguate local vs.
		# remote connections. Percent-escape spaces.
		local SEARCH=' '
		local REPLACE='%20'
		local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
		printf '\e]7;%s\a' "$PWD_URL"
	}
fi

# }}}
# }}}
# {{{ GREP
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep"

,find-grep() {
	echo '''
    find -L . -type f -exec grep --color=auto -nHi --null -e string {} \;
    '''
}
# }}}
# {{{ Other Sources
[ ! -d ~/.local/scripts ] && mkdir ~/.local/scripts
# export PATH="${PATH}$(find -L "$HOME/.local/scripts" -type d -printf ":%h/%f")"
[ ! -d ~/.my_bash_aliases ] && mkdir ~/.my_bash_aliases
# touch ~/.my_bash_aliases/tmp # So I dont get errors in for loop
for f in ~/.my_bash_aliases/*; do
	source "$f"
done
# }}}

# TESTING

export is_linux=$(uname -a | cut -d ' ' -f 1)
alias ,ff="source $HOME/.scripts/bg_fg_fzf"
alias ,hexdump="hexdump -Cv"

# if [ "$TERM" = "screen-256color" ]; then
# 	tmux rename-window "HOME"
# fi

,google() {
	open $(echo "https://www.google.com/search?q=$@" | tr ' ' '+')
}

alias ,compress="tar -cva -f "

export TERM=xterm-256color
alias ,tmux_conf="vim ~/.tmux.conf"
alias ,chatgpt="chatgpt -i"
alias ,muttrc="vim ~/.muttrc"
alias ,bashal="vim ~/.bash_aliases && source ~/.bashrc"
alias ,note="vim ~/iCloud/$(,date).txt -c \"norm gg\" -c \"norm 2O\" -c \"norm p\""
alias ,clipboard="vim ~/clipboard.txt -c \"norm gg\" -c \"norm 5O\" -c \"norm p\""
alias ,.="cd ~/my_repos"
export CDPATH+="$HOME/my_repos"

,github() { 
    open $(echo "https://github.com/search?q=$@&type=repositories&s=stars&o=desc" | tr ' ' '+')
}

,git_pickaxe () {
    # This function will search for all the change logs and contents containing the "string"
    git log -p -S $@
}

export MANPAGER="vim +MANPAGER --not-a-term -"
clear
