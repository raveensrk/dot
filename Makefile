.ONESHELL:

install:
	bash ./install_everything.bash
	bash ./installer_scripts/straight.bash
	echo use install_scripts recepie to install other scripts, install fzf before.
install_scripts:
	$(eval file=$(shell ls ./installer_scripts | fzf -m))
	bash ./installer_scripts/$(file)
