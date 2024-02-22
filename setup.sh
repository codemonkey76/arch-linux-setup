#!/bin/bash

# Exist on error and ensure errors in pipelines are caught
cd ~
set -eo pipefail

# Update Packages
update_system() {
	echo "Updating system..."
	sudo pacman -Syu --noconfirm
}

install_pacman_packages() {
	echo "Installing packages from official repositories..."
	sudo pacman -S --noconfirm neovim rustup fish starship bat duf zellij exa git gitui zoxide php mariadb unzip base-devel stow
}

install_yay() {
	echo "Installing yay for AUR support..."
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd .. && rm -rf yay
}

configure_mariadb() {
	echo "Configuring MariaDB..."
	sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	
 	# Can only enable if systemd is running
  	#sudo systemctl enable --now mariadb.service
}

install_dotfiles() {
	echo "Installing dotfiles..."
 	git clone https://github.com/codemonkey76/dotfiles ~/dotfiles
	cd ~/dotfiles
 	stow .
	# Add your dotfiles installation commands here
}

install_bun() {
	echo "Installing Bun..."
	yay -S --noconfirm bun-bin
}

install_composer() {
	echo "Installing Composer..."
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'edb40769019ccf227279e3bdd1f5b2e9950eb000c3233ee85148944e555d97be3ea4f40c3c2fe73b22f875385f6a5155') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
}

install_composer_global_packages() {
	echo "Installing global Composer packages..."
	composer global require laravel/installer
}

switch_to_fish_shell() {
	echo "Setting fish shell as default..."
	sudo ch -s /usr/bin/fish $(whoami)
}

install_rust_toolchain() {
	echo "Install rust stable toolchain..."
	rustup default stable
}

main() {
	update_system
	install_pacman_packages
	install_yay
	configure_mariadb
	install_bun
	install_composer
	install_composer_global_packages
	install_rust_toolchain
	install_dotfiles
	switch_to_fish_shell
}

# Call the main function
main
