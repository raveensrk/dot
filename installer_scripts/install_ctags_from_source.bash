pushd ~/.tmp
wget -nc https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip -O ctags.zip
unzip -qo ctags.zip
pushd ctags-master
export ACLOCAL_PATH="/usr/share/aclocal"
./autogen.sh
./configure --prefix="$HOME/.local"
make
make install
popd
popd
