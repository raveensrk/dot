# https://colemak.com/Unix
[ ! -d ~/.tmp ] && mkdir ~/.tmp
pushd ~/.tmp
wget -nc "https://colemak.com/pub/unix/colemak-1.0.tar.gz"
tar xvf colemak-1.0.tar.gz
pushd colemak-1.0
setxkbmap us; xmodmap xmodmap/xmodmap.colemak && xset r 66
setxkbmap us -variant colemak
popd
popd
