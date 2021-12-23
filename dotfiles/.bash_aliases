# BASH ALIASES sourced at ~/.bashrc
set -o vi
# {{{ ENVIRONMENT VARIABLES

# export DISPLAY=:0
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
if [ -d /var/lib/flatpak/exports/bin ]; then
    export PATH="/var/lib/flatpak/exports/bin:$PATH"
fi
export VISUAL="vim"
export EDITOR="vim"

# }}}
# {{{ BASH SHOPTS
shopt -s direxpand
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
shopt -s histappend # append to the history file, don't overwrite it
HISTCONTROL= # Use ignoreboth to ingore both duplicated and commands that start with space
HISTSIZE=
HISTFILESIZE=
export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_history # Change the file location because certain bash sessions truncate .bash_history file upon close. # http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND" # Force prompt to write history after every command. http://superuser.com/questions/20900/bash-history-loss
shopt -s checkwinsize # check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
# bind 'TAB':menu-complete # If there are multiple matches for completion, Tab should cycle through them
# set completion-ignore-case on
# bind "set menu-complete-display-prefix on" # Perform partial completion on the first Tab press, only start cycling full results on the second Tab press
bind 'TAB':menu-complete # If there are multiple matches for completion, Tab should cycle through them
bind "set show-all-if-ambiguous on" # Display a list of the matching files
bind "set menu-complete-display-prefix on" # Perform partial completion on the first Tab press, only start cycling full results on the second Tab press
bind '"\e[A":history-search-backward' # Cycle through history based on characters already typed on the line
bind '"\e[B":history-search-forward'
set show-all-if-ambiguous on
set completion-ignore-case on
# }}}
# {{{ INTERFACE
if [ -v xset ]; then
    xset r rate 300 50
    xset m 10 1
fi
# }}}
# {{{ ALIASES
alias ..="cd .."
alias ,top='top -d 0.125'
alias ,sync="~/repos/my-scripts-main/src/sync_all_repos.bash ~/repos/"
alias ,sync_vcad="~/repos_vcad_sync/my-scripts-main/src/sync_all_repos.bash ~/repos_vcad_sync"
alias ,sync_my="~/my_repos/my-scripts-main/src/sync_all_repos.bash ~/my_repos/"
alias bashal="vim ~/.bash_aliases && source ~/.bash_aliases"
alias csh_aliases="vim ~/.aliases"
alias dam="sudo !!"
alias date1="date +%Y%m%d%H%M%S"
alias date2="date +%Y-%m-%d_%H:%M:%S"
alias date3="date +%d%b%y"
alias g='grep --color'
alias gr='grep --color -r'
alias h="history"
alias l="ls -A1"
alias mkdir="mkdir -v"
alias cp="cp -vi"
alias mv="mv -vi"
alias rm="rm -vi"
alias r='ranger'
alias tmux="tmux -2"
alias t="tmux attach || tmux"
alias tree="tree -C"
alias xo="xdg-open"
alias e="emacsclient -nw -a emacs -nw"
alias einit="e ~/.emacs"
alias em="emacs --daemon"
alias emk="emacsclient -e \"(server-force-delete)\""
v () {
     if [[ $# -ge 1 ]]; then
         vim $@
     else
         vim -c "History"
     fi
 }
alias vimrc="vim ~/.vimrc"
alias tree2="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # https://github.com/you-dont-need/You-Dont-Need-GUI
alias hg="hg --pager=off"
alias rsync="rsync -CazhPvu" # -C
alias rp="realpath"
alias d='pushd'
alias dv='dirs -v'

ff () {
    find -name "*$1*"
}

# This will cd and do ls but sometimes it gets broken

# cd () {
#     if [ -f $1 ]; then
#         dir=${1%/*}
#     else
#         dir=$1
#     fi
#     builtin cd $dir
#     ls
# }

convert-softlinks () {
    link_name="$1"
    # Get real path of original file
    orig=$(realpath "$link_name")
    # Remove link
    rm "$link_name"
    # Replace link with original
    cp "$orig" "$link_name"
    unset link_name orig 
}
# }}}
# {{{ WSL
alias ,e="explorer.exe ."
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

# Man colors
#------------------
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[01;32m' \
        command man "$@"
    }
# }}}
# {{{ PROMPT AND COLORS
source ~/.bash_prompt
# }}}
# {{{ LOCATE FILES AND DIRS
updatedb_path="$HOME/.local/locate_db"
updatedb_home="$updatedb_path/home.db"
,updatedb () {
    [[ ! -d "$updatedb_path" ]] && mkdir -p "$updatedb_path"
    updatedb -l 0 -o "$updatedb_home" -U ~/
}

unset -f se
se () {
    local file=$(fd . ~/repos | fzf)
    if [ "$file" = "" ]; then
        echo -e "${RED}❌ERROR! Empty string${NC}"
    else
        echo -e ${BLUE} The following command is executed... ${NC}
        echo -e ${YELLOW} 'vim' "$file" ${NC} 
        vim "$file"
    fi
}

sd () {
    local dir=$(locate -d "$updatedb_home" .* | fzf)
    echo -e ${BLUE} The following command is executed... ${NC}
    echo -e ${YELLOW} 'pushd' "$dir" ${NC} 
    pushd "$dir"
}

sl () {
    locate -d "$updatedb_home" .* | fzf
}

sx () {
    local file=$(locate -d "$updatedb_home" .* | fzf)
    echo -e ${BLUE} The following command is executed... ${NC}
    echo -e ${YELLOW} 'source' "$file" ${NC} 
    source "$file"
}

# }}}
# {{{ UBUNTU SPECIFIC
if [ -f /etc/bash_completion ]; then
     . /etc/bash_completion
fi
# }}}
# {{{ Other Sources
[ ! -d ~/.local/scripts ] && mkdir ~/.local/scripts
#export PATH="${PATH}$(find -L "$HOME/.local/scripts" -type d -printf ":%h/%f")"
[ ! -d ~/.my_bash_aliases ] && mkdir ~/.my_bash_aliases
touch ~/.my_bash_aliases/tmp # So I dont get errors in for loop
for f in ~/.my_bash_aliases/*; do
    source "$f"
done
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
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
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
# {{{ FD
source "$HOME/.local/packages/fd-v8.3.0-i686-unknown-linux-musl/autocomplete/fd.bash"
# }}}
# {{{ FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# }}}
# Colors
LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43" # TODO not working.
