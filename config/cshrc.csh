#!/usr/bin/env csh

# ENVIRONMENT VARIABLES {{{1
setenv EDITOR vim
setenv VISUAL vim
setenv DOT $HOME/dot
setenv MYVIMRC \$DOT/config/vimrc
setenv PAGER   'less'
# setenv MANPAGER   'less'

# Man pager color
# setenv MANCOLOR   "Yes"
# setenv LESS_TERMCAP_so   '\e[38;5;3m'  #Yellow # FIXME: This color setup doesnot work.
# setenv LESS_TERMCAP_us   '\e[38;5;40m' #green
# setenv LESS_TERMCAP_md   '\e[38;5;4m'  #blue
# setenv LESS_TERMCAP_mb   '\e[38;5;1m'  #Red
# setenv LESS_TERMCAP_me   '\e[0m'
# setenv LESS_TERMCAP_se   '\e[0m'
# setenv LESS_TERMCAP_ue   '\e[0m'
# setenv LESS_TERMCAP_Se   '\e[0m'

# ALIASES {{{1
alias ,chop							"tr -d '\n'" # Remove newline
alias ,compress						"tar -cvza -f "
alias ,date2						'date -I'
alias ,date2_long   "date +%Y%m%d%H%M%S"
alias ,date2_long_long   'date -Iseconds | sed "s/:/-/g"'
alias ,date2_yesterday   '/bin/date -I -v-1d'
alias ,edit_bashrc   "vim \$DOT/config/bashrc"
alias ,edit_cshrc "vim $DOT/config/cshrc"
alias ,edit_vimrc   "vim \$DOT/config/vimrc"
alias ,fixme "vim -c 'RG fixme'"# TODO: Without RG
alias ,fr 'vim -c "bro ol"'
alias ,git_diff   'git diff --minimal -w -b -M --word-diff'
alias ,git_pickaxe   "git log -p -S"
alias ,goto "vim -c 'RG'" # TODO: Without RG
alias ,hcat   "paste -s" # To concatenate the contents of a vertical file horizontally
alias ,hexdump   "hexdump -Cv"
alias ,less   'less -s -R -wi -S --ignore-case'
alias ,path   'echo $PATH | tr ":" "\n" | tac'
alias ,rsync   "rsync -CazhPvu"                                         # -C
alias ,source_cshrc 'source $HOME/.cshrc && rehash'
alias ,tmux2   "tmux attach || tmux"
alias ,t   "tmux2"
alias ,todo "vim -c 'RG todo'"# TODO: Without RG
alias ,top2   'top -d 0.125'
alias ,tree2   "tree -C"
alias ,tree3   "find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # https://github.com/you-dont-need/You-Dont-Need-GUI
alias ,untar   "tar xvf"
alias ..   "cd .."
alias cp   "cp -vi"
alias grep   "grep --color"
alias h "history | less +G"
alias mkdir   "mkdir -v"
alias mv   "mv -vi"
alias q   "exit"
alias rm   "rm -vi"
alias v vim
# {{{1 Prompt
source $HOME/dot/config/csh_prompt.csh

# Shell options {{{1
set history = 100000
# set savehist = "100000 merge lock" # is lock needed?
set savehist = (100000 merge)
set histfile = ~/.csh_history
# set ignoreeof = 1 # This will exit only after 2 exit or 2 ^D

# TODO: Read the manual

# set autocorrect
set color
set colorcat
# set correct = all
set globdot
set globstar
set highlight
set implicitcd
set killdup = all
set listjobs = long
set nobeep
set noclobber
set owd
# set printexitvalue
set rmstar
# set rprompt = hello # Not needed
set savedirs
set visiblebell
set wordchars = "*?_-.[]~=()&"
set time = ( 2 "Time: Elapsed = %E, User = %U, Kernel = %S" )
# Keybinds {{{1
bindkey -e
bindkey "^[[1;5D"	backward-word					# Ctrl+Left (common)
bindkey "^[[1;5C"	forward-word    				# Ctrl+Right (common)
bindkey "^[[1;3D"	backward-word   				# Ctrl+Left (common)
bindkey "^[[1;3C"	forward-word    				# Ctrl+Right (common)
bindkey "^[[3~"		delete-char-or-list-or-eof		# Delete
bindkey "^r"		i-search-back					# Ctrl + r
bindkey "^s" 		i-search-fwd					# Ctrl + s

# GIT{{{1
git config --global user.name "Raveen Kumar"
# git config --global user.email "user@mail"
git config --global pull.rebase true
# git config --global pull.rebase false


