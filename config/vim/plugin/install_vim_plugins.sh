#!/usr/bin/env bash


"""
If any bug is observed. Install with --clean.
"""


set -euo pipefail
set -x
IFS=$'\n\t'

current_file=$(realpath "$0")

help() {
	cat <<-HERE
		Usage
		-----------------
	HERE
	exit 0
}

clean=0
while [ "$#" -ne 0 ]; do
	case "$1" in
	--help | -h)
		help
		;;
	--clean)
		clean=1
		;;
	*)
		echor "Unknown Argument: $1 while running $current_file!"
		exit 2
		;;
	esac
	shift
done

mkdir2 "$HOME/.vim/autoload"
# [ -d ~/.vim/bundle ] && rm -rf ~/.vim/bundle

if [[ "$clean" -eq 1 ]]; then
	rm_mkdir "$HOME/.vim/bundle"
	pushd2 "$HOME/.vim/bundle"
else
	mkdir2 ~/.vim/bundle
	pushd2 ~/.vim/bundle
	if [[ "$(command ls | wc -l)" -ne 0 ]]; then
		for dir in ./*; do
			pushd2 "$dir"
			git pull  &
			popd2
		done
	fi
fi


wget https://tpo.pe/pathogen.vim -O ~/.vim/autoload/pathogen.vim

# Digraph: https://www.vim.org/scripts/script.php?script_id=5724
# git clone "git@github.com:chrisbra/csv.vim.git" 
# git clone "git@github.com:davidhalter/jedi-vim.git" 
# git clone "git@github.com:rafi/awesome-vim-colorschemes.git" 
# git clone "git@github.com:tpope/vim-commentary" 
# git clone "git@github.com:tpope/vim-obsession.git" 
# git clone "git@github.com:yegappan/taglist.git" 
# git clone "https://github.com/MarcWeber/vim-addon-qf-layout.git" 
# git clone "https://github.com/SidOfc/mkdx" 
# git clone "https://github.com/dense-analysis/ale" 
# git clone "https://github.com/skywind3000/asyncrun.vim" 
# git clone git@github.com:vim-scripts/bufexplorer.zip.git 
# git clone https://github.com/AndrewRadev/splitjoin.vim 
# git clone https://github.com/ap/vim-buftabline 
# git clone https://github.com/kshenoy/vim-signature 
# git clone https://github.com/kyuhi/vim-emoji-complete 
# git clone https://github.com/mattesgroeger/vim-bookmarks 
# git clone https://github.com/moll/vim-bbye 
# git clone https://github.com/pixelneo/vim-python-docstring 
# git clone https://github.com/qpkorr/vim-bufkill ~/.vim/bundle/vim-bufkill 
# https://github.com/Shougo/unite.vim
# https://vimawesome.com/plugin/vim-interestingwords-safe-and-sound
# pip install jedi

git clone "git@github.com:Donaldttt/fuzzyy.git"                        || true # &
git clone "git@github.com:easymotion/vim-easymotion"                   || true # &
git clone "git@github.com:junegunn/fzf"                                || true # &
git clone "git@github.com:junegunn/fzf.vim"                            || true # &
git clone "git@github.com:junegunn/vim-easy-align"                     || true # &
git clone "git@github.com:mhinz/vim-signify"                           || true # &
git clone "git@github.com:nathanaelkane/vim-indent-guides"             || true # &
git clone "git@github.com:tomtom/tcomment_vim"                         || true # &
git clone "git@github.com:tpope/vim-characterize.git"                  || true # &
git clone "git@github.com:tpope/vim-dispatch"                          || true # &
git clone "git@github.com:tpope/vim-eunuch"                            || true # &
git clone "git@github.com:tpope/vim-fugitive"                          || true # &
git clone "git@github.com:tpope/vim-repeat"                            || true # &
git clone "git@github.com:tpope/vim-sensible"                          || true # &
git clone "git@github.com:tpope/vim-speeddating.git"                   || true # &
git clone "git@github.com:tpope/vim-surround"                          || true # &
git clone "git@github.com:tpope/vim-unimpaired"                        || true # &
git clone "git@github.com:tpope/vim-vinegar"                           || true # &
git clone "https://github.com/chrisbra/unicode.vim.git"                || true # &
git clone "https://github.com/mhinz/vim-startify"                      || true # &
git clone "https://github.com/preservim/vim-markdown.git"              || true # &
git clone "https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup" || true # &
git clone "https://github.com/wuelnerdotexe/vim-enfocado"			|| true # &
git clone "https://tpope.io/vim/scriptease.git"                        || true # &
git clone "https://github.com/morhetz/gruvbox"                         || true # &
git clone "https://github.com/907th/vim-auto-save"					   || true # &
# git clone --depth=1 https://github.com/github/copilot.vim.git ~/.vim/pack/github/start/copilot.vim || true
# git clone https://github.com/ledger/vim-ledger || true # & # This is giving me errors, not important
# LATER: Try this https://github.com/girishji/vimcomplete
# git clone https://github.com/nelstrom/vim-markdown-folding || true
# wait
