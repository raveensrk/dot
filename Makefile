.ONESHELL:

install:
	bash ./install_everything.bash
	echo use install_scripts recepie to install other scripts, install fzf before.
install_scripts:
	$(eval file=$(shell ls ./installer_scripts | fzf -m))
	bash ./installer_scripts/$(file)
