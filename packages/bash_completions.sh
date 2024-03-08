if [ ! -f ~/.local/etc/profile.d/bash_completion.sh ]; then
	pushd ~/.tmp
	wget -nc https://github.com/scop/bash-completion/releases/download/2.11/bash-completion-2.11.tar.xz
	tar xf bash-completion-2.11.tar.xz
	pushd "bash-completion-2.11"
	./configure --prefix="$HOME/.local"
	make >/dev/null
	make install >/dev/null
	popd
	popd
	bash add_sources.bash "[ -f ~/.local/etc/profile.d/bash_completion.sh ] && source ~/.local/etc/profile.d/bash_completion.sh" "$HOME/.bashrc"
fi
