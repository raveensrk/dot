pushd ~/.tmp
tar xf pkg-config-0.29.2.tar.gz
pushd ./pkg-config-0.29.2
./configure --prefix="$HOME/.local" --with-internal-glib
make
make install
popd
popd
