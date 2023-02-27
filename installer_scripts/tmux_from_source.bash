  pushd ~/.tmp
  wget -nc https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
  tar xf libevent-2.1.12-stable.tar.gz
  pushd libevent-2.1.12-stable
  ./configure --prefix=$HOME/.local --enable-shared
  make
  make install
  popd

  wget -nc https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz
  tar xf tmux-3.3a.tar.gz
  pushd tmux-3.3a
  PKG_CONFIG_PATH=$$HOME/.local/lib/pkgconfig ./configure --prefix=$HOME/.local && make
  make install
  popd
