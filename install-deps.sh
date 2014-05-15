#!/usr/bin/env bash
# Exit on error
set -e

echo ''

DOTFILES_ROOT="`pwd`"

user () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

install_z_script () {
	# https://github.com/rupa/z
	info "Installing z script (https://github.com/rupa/z)"
	echo ''
	cd
	git clone https://github.com/rupa/z.git
	chmod +x ~/z/z.sh
	# also consider moving over your current .z file if possible. it's painful to rebuild :)
	cd $DOTFILES_ROOT
}

if ! [ -d ~/z ]
then
	install_z_script
else
	user "z script already exists. Do you want to replace it [y]es, [n]o ?"
	read -n 1 replace_z_script
	echo ''

	case "$replace_z_script" in
		y | Y )
			info "Removing ~/z directory"
			echo ''
			rm -rf ~/z
			install_z_script;;
		n | N )
			info "Skipping z script"
			;;
		* )
			;;
	esac
fi

# Call install_packages with following parameters:
# $1 parameter: array of packages to be installed
# $2 parameter: true if you want to install all software without asking user each time if he wants to install this package
function install_packages () {
	packages=("${!1}")
	install_all=$2
	for package in "${packages[@]}"
	do
		if [ "$install_all" == "true" ]
		then
			install ${package}
		else
			user "Do you want to install $package [y]es or [n]o or install [a]ll"
			read -n 1 action

			echo ''
			case $action in
				a | A )
					install ${package}
					install_all=true
					;;
				y | Y )
					install ${package}
					;;
				n | N )
					info "Skipping package $package"
					echo ''
					;;
				* )
					;;
			esac
		fi
	done

}

# Add software HERE
apt_get_software=( vim chromium-browser firefox terminator curl gnome-do sublime-text)

for package in "${apt_get_software[@]}"
do
	if [ "$install_all" == "true" ]
	then
		install $package
	else
		user "Do you want to install $package [y]es or [n]o or install [a]ll"
		read -n 1 action

		echo ''
		case $action in
			a | A )
				install $package
				install_all=true
				;;
			y | Y )
				install $package
				;;
			n | N )
				info "Skipping package $package"
				echo ''
				;;
			* )
				;;
		esac
	fi
done

info "---- INSTALL: Finished successfully!"

user "Install additional dependencies ? [y]es, [n]o ?"
read -n 1 additional_deps

case "$additional_deps" in
  y | Y )
	echo ''
	info "---- INSTALL: Installing additional dependencies"
    . ./install-additional-deps.sh
    ;;
  * )
    ;;
esac

info "---- CLEANUP: Running autoremove"
sudo apt-get autoremove -y & wait