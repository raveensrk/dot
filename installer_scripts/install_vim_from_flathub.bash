pushd ~/.tmp
wget -nc "https://dl.flathub.org/repo/appstream/org.vim.Vim.flatpakref"
flatpak install --user org.vim.Vim.flatpakref
popd

pushd ~/.tmp
wget -nc https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2
tar xf vim-8.2.tar.bz2
pushd vim82 || exit 2
./configure --prefix="$HOME/.local" # defaults to /usr/local
make
make install
popd || exit 2
popd