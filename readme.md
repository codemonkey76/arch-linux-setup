# First install arch linux

## Refresh the Arch Linux keyring.

Refresh the Arch Linux keyring. This process involves refreshing the key database and ensuring that all necessary keys are trusted.

```bash
pacman-key --init
pacman-key --populate archlinux
```

## Create a new user
use the `useradd` command to create a new user. Replace `yourusername` with your desired username. This command will create the users home directory, add them to the wheel group and set bash as their default shell.

```bash
useradd -m -G wheel -s /bin/bash yourusername
```

## Set a password for the new user

Set a password for the newly created user, you will be prompted to enter and confirm the password

```bash
passwd yourusername
```

## Configure sudo access

To allow members of the wheel group to execute any command using `sudo`, you'll need to edit the `sudoers` file. It's recommended to use the `visudo` command for editing to prevent syntax errors.

```bash
EDITOR=nano visudo
```

Uncomment the line `%wheel ALL=(ALL) ALL` by removing the leading `#` character. If you want to not have to enter your password when using sudo, change it to `%wheel ALL=(ALL) NOPASSWD: ALL`

## Configure WSL to default to logging in with your user account

Open the `wsl.conf` file in the `/etc` folder and add a default username.

```bash
nano /etc/wsl.conf
```

Add the following text. Replace `yourusername` with your user name.

```bash
[user]
default=yourusername
```

## Exit and terminate your wsl instance

From powershell shutdown your WSL instance

```bash
wsl -t <distro-name>
```

Start up your wsl instance and it should auto login with your username.

```bash
wsl -d <distro-name>
```

## Run the setup script to setup your Arch Linux WSL Instance

Run the following command to setup your instance to my preferences.

```bash
curl -sSL https://raw.githubusercontent.com/codemonkey76/arch-linux-setup/main/setup.sh | sudo sh
```
