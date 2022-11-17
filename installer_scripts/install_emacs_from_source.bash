cd ~/.tmp
wget -nc https://mirror.hostiran.ir/gnu/gnu/emacs/emacs-28.1.tar.gz
tar -xf emacs-28.1.tar.gz
cd emacs-28.1
./configure --with-x-toolkit=no --prefix=$HOME/.local
make
make install
