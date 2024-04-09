#!/bin/bash

xcode-select --install

if ! command -v brew; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# brew update

packages=(
	# basictex
	# vim
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
	# gitui
	lesspipe
	lolcat
	mactex
	mediainfo
	neofetch
	neomutt
	newsboat
	pandoc
	pkg-config
	poppler
	python
	ranger
	ripgrep
	rsync
	ruby
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
	hstr
	mpv
)

export HOMEBREW_NO_AUTO_UPDATE=1

brew install ${packages[@]}

macport_packages=(
	"gtkwave"
	"gtk2"
	"sqlite3-tcl"
)

sudo port install ${macport_packages[@]}

sudo port select --set pygments py312-pygments
