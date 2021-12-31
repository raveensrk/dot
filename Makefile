.ONESHELL:
	# Applies to every targets in the file! By default every command
	# alls a subshell this prevents that

install_dotfiles:
	mkdir ~/.vim/backup
	stow -R stow -t "$(HOME)"

install_tpm: install_dotfiles
	git clone "https://github.com/tmux-plugins/tpm" "$(HOME)/.tmux/plugins/tpm"

install_packages_manual:

install_ctags:
	cd packages
	sudo apt install autoconf pkg-config automake
	git clone "https://github.com/universal-ctags/ctags.git"
	cd ctags
	rm .git -rf
	./autogen.sh
	./configure --prefix="$(HOME)/.local" # defaults to /usr/local
	make -j
	make install -j # may require extra privileges depending on where to install

install_jekyll:
	gem install jekyll bundler

install_curl_with_sftp:
# # {{{ Installing CURL with SFTP support
# 
# # https://github.com/moparisthebest/static-curl/releases/tag/v7.80.0 static binary
# 
# # https://andrewberls.com/blog/post/adding-sftp-support-to-curl
# repos_for_compile="$HOME/repos_for_compile"
# [ ! -d "$repos_for_compile" ] && mkdir "$repos_for_compile"
# 
# if [ "$distro" = "u" ]; then
#     pushd "$repos_for_compile"
# 
#     # wget https://www.libssh2.org/download/libssh2-1.10.0.tar.gz
#     # tar xvf libssh2-1.10.0.tar.gz
#     # pushd libssh2-1.10.0
#     # ./configure
#     # make
#     # sudo make install
#     # popd
#     #
#     # wget https://curl.se/download/curl-7.80.0.tar.gz
#     # tar xvf curl-7.80.0.tar.gz
#     # pushd curl-7.80.0
#     # ./configure --with-libssh2=/usr/local --with-openssl
#     # make # Error
#     # sudo make install
#     # popd
# 
#     popd
# 
# fi
# 
# # }}}

install_vim:
	cd packages
	git clone "https://github.com/vim/vim.git"
	cd vim
	rm .git -rf
	./configure --prefix="$(HOME)/.local" # defaults to /usr/local
	make -j
	make install -j


# TODO add urlview as a manual install
