#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Please run this script as a normal user with sudo privileges". 1>&2
	exit 1
fi


sudo pacman -Syu --noconfirm

sudo pacman -S --noconfirm neovim
