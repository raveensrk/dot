#!/bin/bash

xcode-select --install

if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export HOMEBREW_NO_AUTO_UPDATE=1

brew update
brew upgrade

brew install <<-HERE
	autoconf
	automake
	bat
	cscope
	curl
	cyrus-sasl
	dialog
	ffmpeg
	ffmpegthumbnailer
	findutils
	fortune
	gnuplot
	graphicsmagick
	grep
	htop
	iina
	imagemagick
	ispell
	jq
	lazygit
	lesspipe
	lolcat
	mactex
	mediainfo
	neofetch
	newsboat
	pandoc
	pkg-config
	python
	ranger
	ripgrep
	rsync
	shellcheck
	shfmt
	sqlite
	tldr
	universal-ctags
	up
	urlview
	w3m
	wget
	dict
	direnv
	entr
	mpv
HERE

macport_packages=(
)

sudo port install <<-HERE
	gtkwave
	gtk2
	sqlite3-tcl
HERE

sudo port select --set pygments py312-pygments

# basictex
# vim
# gitui
brew uninstall <<-HERE
	neomutt
	ruby
	poppler
	hstr
HERE
