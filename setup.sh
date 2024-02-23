#!/bin/bash

# Exit on error and ensure errors in pipelines are caught
set -eo pipefail

# Update Packages
update_system() {
	echo "Updating system..."
	sudo pacman -Syu --noconfirm
}

install_pacman_packages() {
	echo "Installing packages from official repositories..."
	sudo pacman -S --noconfirm neovim rustup fish starship bat duf zellij exa git gitui zoxide php mariadb unzip base-devel stow fzf openssh github-cli go php-sqlite
}

install_yay() {
	echo "Installing yay for AUR support..."
	cd ~
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si --noconfirm
	cd .. && rm -rf yay
}

configure_mariadb() {
	echo "Configuring MariaDB..."
	sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	
	# Can only enable if systemd is running
	sudo systemctl enable --now mariadb.service
 	echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '';" | sudo mariadb
}

install_dotfiles() {
	echo "Installing dotfiles..."
	git clone https://github.com/codemonkey76/dotfiles ~/dotfiles
	cd ~/dotfiles
	stow .
}

install_bun() {
	echo "Installing Bun..."
	yay -S --noconfirm bun-bin
}

install_composer() {
	echo "Installing Composer..."
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
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
	sudo chsh -s /usr/bin/fish $(whoami)
}

install_rust_toolchain() {
	echo "Install rust stable toolchain..."
	rustup default stable
}

setup_ssh() {
	echo "Setting up SSH Key..."
	ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
}

setup_php_extensions() {
	echo "extension=mysqli" | sudo tee /etc/php/conf.d/mysql.ini > /dev/null
 	echo "extension=pdo_mysql" | sudo tee -a /etc/php/conf.d/mysql.ini > /dev/null
 	echo "extension=pdo_sqlite" | sudo tee /etc/php/conf.d/sqlite.ini > /dev/null
 }
 
get_options() {
	read -t 10 -p "Setup Github Credentials? [y/n]: " response < /dev/tty

	if [ -z "$response" ]; then
		echo "No response. Assuming 'no'..."
	else
		case "$response" in
			[yY]|[yY][eE][sS])
				SETUP_GITHUB=true
				;;
			*)
				SETUP_GITHUB=false
				;;
		esac
	fi
}


setup_github() {
	echo "Setting up Github credentials..."
	# Collect user's email and name
	read -p "Enter your name: " name < /dev/tty
	read -p "Enter your email: " email < /dev/tty

	# Configure git with user's name and email
	git config --global user.name "$name"
	git config --global user.email "$email"

	# Add SSH Key to github
	if [ -f ~/.ssh/id_ed25519 ]; then
		echo "Adding SSH key to Github..."
		gh auth login -s admin:public_key
		gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication
	fi
	
	echo "Completed setup of Github credentials."
}

main() {
	get_options
	update_system
	install_pacman_packages
	install_yay
	configure_mariadb
	install_bun
	install_composer
	install_composer_global_packages
 	setup_php_extensions
	install_rust_toolchain
	install_dotfiles
	switch_to_fish_shell
	setup_ssh
	if [ "$SETUP_GITHUB" = true ]; then
		setup_github
	fi
}

# Call the main function
main
