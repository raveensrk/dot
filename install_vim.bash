set -e

[ ! -d $HOME/.tmp        ] && mkdir "$HOME/.tmp"
[ ! -d $HOME/.vim        ] && mkdir "$HOME/.vim"
[ ! -d $HOME/.vim/undo   ] && mkdir "$HOME/.vim/undo"
[ ! -d $HOME/.vim/backup ] && mkdir "$HOME/.vim/backup"
[ ! -d $HOME/.vim/swap   ] && mkdir "$HOME/.vim/swap"

exit 0
