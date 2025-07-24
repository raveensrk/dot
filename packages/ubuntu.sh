#!/usr/bin/env bash

set -PCeuo pipefail
# set -x
IFS=$'\n\t'

sudo apt update
sudo apt upgrade
# sudo apt-get install build-essential

# if ! command -v brew; then
# 	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

packages=(
	fzf
	direnv
	fortune
	# lesspipe # LATER: Needed?
	pandoc
	ranger
	ripgrep
	shellcheck
	shfmt
	universal-ctags
	# up # LATER: Ultimate plumber needed?
	direnv
	entr
	eza
	jq
	zoxide
	pipx
	yq
)

for package in ${packages[@]}; do
	sudo apt install $package
done

# sudo apt install pipx
# sudo apt install ${package[@]}

pipx install mdformat

bash ./lazygit_ubuntu.sh

# brew install ${packages[*]}

curl https://fx.wtf/install.sh | sh
