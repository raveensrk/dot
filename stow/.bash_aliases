# BASH ALIASES sourced at ~/.bashrc
# set -o vi

if [ -d "$HOME/my_repos" ]; then
    export MY_REPOS="$HOME/my_repos"
elif [ -d "$HOME/repos" ]; then
    export MY_REPOS="$HOME/repos"
fi

# {{{ ENVIRONMENT VARIABLES

# export DISPLAY=:0
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.scripts:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
if [ -d /var/lib/flatpak/exports/bin ]; then
    export PATH="/var/lib/flatpak/exports/bin:$PATH"
fi
# shellcheck disable=SC2044
for dir in $(find ~/.scripts -type d); do export PATH="$dir:$PATH"; done

# }}}
# {{{ BASH SHOPTS
# This will exit bash shell as soon as it receives C-d as the last command
export IGNOREEOF=0
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
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar
# }}}
# {{{ INTERFACE
if [ -v xset ]; then
    xset r rate 300 50
    xset m 10 1
fi
# Colors
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if  test -r ~/.dircolors; then
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
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# LS aliases

if command -v exa > /dev/null; then
    alias ls='exa'
    alias l="exa -lah"
else
    alias ls='ls --color=auto'
    alias l="ls -Alh"
fi
alias y="yt-dlp"
alias ,edit_zzz="\$EDITOR ~/.dirs_stack"
alias ..="cd .."
alias ,.="open ."
alias ,top='top -d 0.125'
alias dam="sudo !!"
alias ,date_sshort="date +%Y%m%d%H%M%S"
alias ,date='date -I'
alias ,dates='date -Iseconds | sed "s/:/-/g"'
alias g='grep --color'
alias gr='grep --color -r'
alias h="history"
alias mkdir="mkdir -v"
alias cp="cp -vi"
alias mv="mv -vi"
alias rm="rm -vi"
alias r='ranger'
alias tmux="tmux -2"
alias tx="tmux attach || tmux"
alias tree="tree -C"
alias xo="xdg-open"
alias tree2="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # https://github.com/you-dont-need/You-Dont-Need-GUI
alias hg="hg --pager=off"
alias rsync="rsync -CazhPvu" # -C
alias rp="realpath"
alias ,exp="explorer.exe"
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

,convert-softlinks () {
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
    LESS_TERMCAP_md=$'\e[01;31m'          LESS_TERMCAP_me=$'\e[0m'          LESS_TERMCAP_se=$'\e[0m'          LESS_TERMCAP_so=$'\e[01;44;33m'          LESS_TERMCAP_ue=$'\e[0m'          LESS_TERMCAP_us=$'\e[01;32m'          command man "$@"
}
# }}}
# {{{ PROMPT AND COLORS
# shellcheck disable=SC1091
source "$HOME/.bash_prompt"
# }}}
# {{{ LOCATE FILES AND DIRS
updatedb_path="$HOME/.local/locate_db"
updatedb_home="$updatedb_path/home.db"
,updatedb () {
[[ ! -d "$updatedb_path" ]] && mkdir -p "$updatedb_path"
updatedb -l 0 -o "$updatedb_home" -U ~/
}

sd () {
    local dir
    dir=$(locate -d "$updatedb_home" .* | fzf)
    echo -e "${BLUE} The following command is executed... ${NC}"
    echo -e "${YELLOW} pushd $dir ${NC}"
    pushd "$dir" || return
}

sl () {
    locate -d "$updatedb_home" .* | fzf
}

sx () {
    local file
    file=$(locate -d "$updatedb_home" .* | fzf)
    echo -e "${BLUE} The following command is executed... ${NC}"
    echo -e "${YELLOW} source $file ${NC}"
    # shellcheck disable=SC1090
    source "$file"
}


# }}}
# {{{ UBUNTU SPECIFIC
if [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
fi
# }}}
# {{{ VIM STUFF
export EDITOR="emacs"
alias e="$EDITOR"
alias bashal="\$EDITOR ~/.bash_aliases && source ~/.bash_aliases"
alias vimrc="e ~/.vimrc"
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
        # cd -- "$chosen_dir"
        z "$chosen_dir"
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
# {{{ FZF
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history"
export FZF_CTRL_T_COMMAND="command find -L . $HOME/my_repos"
export FZF_DEFAULT_COMMAND="command find -L ."
export FZF_ALT_C_COMMAND="command find -L . -type d"
# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
# }}}
# {{{ Completion system
# shellcheck disable=SC1090
[ -f ~/.local/etc/profile.d/bash_completion.sh ] && source ~/.local/etc/profile.d/bash_completion.sh

# Use bash-completion, if available
# shellcheck disable=SC1090
[[ $PS1 && -f ~/.local/share/bash-completion/bash_completion  ]] && \
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
# {{{ zzz ALIASES
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
alias cd="z"
unset -f z
z () {
    local tmp="/tmp/.dirs_stack_tmp_$$"
    local dir=""
    if [ "$1" = "" ]; then
        dir="$HOME"
    elif [ "$1" = "-" ]; then
        dir="+1"
    else
        dir="$1"
    fi

    if [ -f "$dir" ]; then
        echo Choosen directory is a file. Changing directory to its enclosed path...
        dir="$(dirname "$dir")"
    fi 

    dir=$(realpath "$dir")
    pushd "$dir" || return
    dirs -v | awk '{print $2}' | sort | uniq >> ~/.dirs_stack
    cat ~/.dirs_stack_uniq ~/.dirs_stack | sort | uniq > "$tmp"
    cat "$tmp" > ~/.dirs_stack_uniq
    command rm "$tmp"
}
complete -o dirnames z

unset -f zz
zz () {
    local pushd_stack_index
    pushd_stack_index=$(dirs -v | fzf | awk '{print $1}')
    pushd +"$pushd_stack_index" || return
}

unset -f zzz
zzz () {
    z "$(cat ~/.dirs_stack | tail -n 50 | sort | uniq | sed "s|^~|${HOME}|" | fzf)" || return
}
# }}}
# {{{ Fedora BUG fix
# BUGFIX: bash: __vte_prompt_command: command not found
# https://ask.fedoraproject.org/t/how-to-fix-bash-vte-prompt-command-command-not-found-when-using-tmux/17704/3
# check if function exists and define empty one if doesn't
if [[ $(type -t "__vte_prompt_command") != function ]]; then
    function __vte_prompt_command(){
        return 0
    }
fi
# }}}
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
# {{{ WSL 2 specific - Ubuntu
if [ -e /etc/os-release ]; then
    which_linux=$(grep ^NAME= /etc/os-release | cut -d = -f 2 | tr -d "\"")
    if [ "$which_linux" = "Ubuntu" ]; then
        # shellcheck disable=SC1090
        . ~/my_repos/dotfiles-main/installer_scripts/install_colemak.bash > /dev/null 2>&1
    fi 
fi
# }}}
# {{{1 TODO IDEAS
# TODO Restart vim
# https://stackoverflow.com/questions/43113569/how-to-close-vim-editor-with-non-zero-return-value
alias chop="tr ' ' '\n'"
# {{{1 GIT
# I tried rebase before and it totally sucked. Its good if the changes are are different parts of a file, if its in the same path the changes are missed
git config --global pull.merge true
# {{{1 Other
alias srun_fast="srun --pty --cpus-per-task=4 --mem=8192 --cpu-freq=3400"

if command -v bat > /dev/null; then
    alias cat=bat
fi

# {{{1 Projectile?
ph () {
    echo "
    Help for projectile
    ---------------------

    pg: project git
    pe: project fzf file find and edit
    rr: project ranger
    rc: ranger continue
    pa: project add path to known projects
    p: all projects fzf find
    pp: all projects grep specific string ascii only
    pl: print line all projects
    pL: same with file name
    "

}
# Open git for my repos
alias pg='cd $(realpath ~/my_repos/* | fzf); lazygit'
# Edit files in my repos with vim
alias pe='cd $(realpath ~/my_repos/* | fzf); vim -c :FZF'
# Open ranger in my repos
alias rr='cd $(realpath ~/my_repos/* | fzf); ranger'
# Ranger continue session
alias rc='ranger'
# Add path as a project
pa () {
    realpath "$1" >> ~/.projects
}
# Find files in all project
# Note that p command will only work in all the paths in ~/.projects are realpaths
alias p='vim "$(find -L $(cat ~/.projects)  -type f -not -path "*/.git/*" | fzf)"'

bar_size=40
bar_char_done="#"
bar_char_todo="-"
bar_percentage_scale=2

function show_progress {
    current="$1"
    total="$2"

    # calculate the progress in percentage 
    percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total" )
    # The number of done and todo characters
done=$(bc <<< "scale=0; $bar_size * $percent / 100" )
todo=$(bc <<< "scale=0; $bar_size - $done" )

    # build the done and todo sub-bars
    done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")

    # output the bar
    echo -ne "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%"

    if [ $total -eq $current ]; then
        echo -e "\nDONE"
    fi
}

# /Users/raveenkumar/my_repos/dotfiles-main/stow/.scripts/pp
# Print any line in my projects
alias pprint='rg --no-filename . $(cat ~/.projects) | fzf'
# Same with file name included
alias pPrint='rg --with-filename -n  . $(cat ~/.projects) | fzf'
alias b='bash'
alias t='$HOME/.local/bin/todo.sh -d "$(find -L "$HOME/my_repos" -iname "todo.cfg" | fzf)"'
t_repeat () {
    local config
    config=$(find -L "$HOME/my_repos" -iname "todo.cfg" | fzf)
    while true; do 
        todo.sh -d "$config" ls
        sleep 2
        clear
    done
}

alias v=vim
alias routine="~/.scripts/,cat_repeat_file.bash routine"
alias todos_major="tall && routine"
todos_minor () {
    while :; do
        pp "todo\|\- \[ \]"
        sleep 1
    done
}
timer () {
    local count=0
    while ((count < 60*$1)); do
        sleep 1
        let count++
    done
    mpv ~/my_repos/dotfiles-main/sounds/ding.mp3 1> /dev/null 2>&1
    mpv ~/my_repos/dotfiles-main/sounds/ding.mp3 1> /dev/null 2>&1
    mpv ~/my_repos/dotfiles-main/sounds/ding.mp3 1> /dev/null 2>&1
    mpv ~/my_repos/dotfiles-main/sounds/ding.mp3 1> /dev/null 2>&1
    mpv ~/my_repos/dotfiles-main/sounds/ding.mp3 1> /dev/null 2>&1
}
alias n=newsboat
alias aa=",sync.bash"
# {{{1 Other Sources
[ ! -d ~/.local/scripts ] && mkdir ~/.local/scripts
#export PATH="${PATH}$(find -L "$HOME/.local/scripts" -type d -printf ":%h/%f")"
[ ! -d ~/.my_bash_aliases ] && mkdir ~/.my_bash_aliases
touch ~/.my_bash_aliases/tmp # So I dont get errors in for loop
for f in ~/.my_bash_aliases/*; do
    # shellcheck disable=SC1090
    source "$f"
done
# }}}
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep"

alias amake="make -C $HOME/my_repos/dotfiles-main -I $HOME/my_repos/dotfiles-main"
alias ai="sudo apt install -y"
alias jjc="$EDITOR $HOME/.config/jrnl/jrnl.yaml"
ahugo="hugo server --navigateTochanged"

alias magit="emacs --eval '(magit-status)'"
