#!/opt/homebrew/bin/bash

pushd stow_vim_plugins/.packages
wget -nc https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz
tar xf bash-completion-2.11.tar.xz
pushd "bash-completion-2.11"
./configure --prefix="$HOME/.local"
make
make install
popd
popd

bash add_sources.bash "[ -f ~/.local/etc/profile.d/bash_completion.sh ] && source ~/.local/etc/profile.d/bash_completion.sh"
