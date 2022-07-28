ctags.zip:
	wget -nc https://github.com/universal-ctags/ctags/archive/refs/heads/master.zip -O ctags.zip

install-ctags: ctags.zip
	unzip -qo ctags.zip
	cd ctags-master ;\
	export ACLOCAL_PATH="/usr/share/aclocal" ;\
	./autogen.sh ;\
	./configure --prefix="$$HOME/.local" ;\
	make  ;\
	make install

pkg-config-0.29.2.tar.gz:
	wget -nc http://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz

install-pkg-config: pkg-config-0.29.2.tar.gz
	tar xf pkg-config-0.29.2.tar.gz
	cd ./pkg-config-0.29.2 ;\
	./configure --prefix="$$HOME/.local" --with-internal-glib ;\
	make  ;\
	make install

clean:
