# 🚀 AnoLinux/Ano Package Manager

## If you want to install this distro normally, please read all this text!

A custom Linux distribution based on **Arch Linux**, featuring **KDE Plasma**, a custom `ano` package manager(available on Arch), pre-configured `fastfetch`, and an automated bash installer.

Also a package manager for make Arch (and maybe NixOS in future) a bit easier (ano package manager installation on Arch Linux in the end)

## !! If you are beginner on linux, installing AnoLinux is not really recommended !!

## On next versions of AnoLinux Install script this bugs will be fixed!
## If you will find any bugs - tell me pls

## Usage:
AnoLinux has a package manager "ano", its pacman-based and you can run "ano install" without sudo, 
it will ask password automatically if need, full usage of "ano" you can find by typing "ano" in terminal
Also you can use basic pacman package manager there!

After installisation you will have a preinstalled kde plasma, kitty, sddm, fastfetch 
and basical system and DE utilities
(You can install another shell, for example:
Hyprland: "ano install hyprland"
xfce: "ano install xfce4"
source ~/.zshrc
## 📦 Installation Guide
### Manual installation
To install AnoLinux manually, you need to read the [AnoLinux Handbook](https://github.com/anoplaymc/anolinux-handbook)
To install AnoLinux, boot from any official Arch Linux Live ISO, connect to the internet, and follow these steps:

### Step 1. Disk Partitioning by installing script
#### Warning: this script will delete all your data, if you want custom partitioning, do it manually!#### Warning: this script will delete all your data, if you want custom partitioning - do it manually!
bash <(curl -sSL https://raw.githubusercontent.com/anoplaymc/parted_setup/refs/heads/main/setup.sh)

### Step 2. Install and run the Installer
bash <(curl -sSL https://raw.githubusercontent.com/anoplaymc/anolinux/refs/heads/main/anolinux-installer.sh)

### After the script finishes successfully, unmount and reboot:
umount -R /mnt

reboot

### After rebooting choose "Arch Linux"(first line on "GRUB") and follow this steps:
After rebooting press CTRL+ALT+F3 to enter bash shell mode
Type this command:
bash <(curl -sSL https://raw.githubusercontent.com/anoplaymc/anolinux/refs/heads/main/configure.sh)
Follow steps on script
After the script finishes successfully, reboot your system ("sudo reboot")
## Login on your account and enjoy your new system! :)


# How to install Ano Package Manager
## On Arch or Arch-based Linux Distros:
### Step 1. Download the installer
curl -sSL https://raw.githubusercontent.com/anoplaymc/anolinux/refs/heads/main/install-manager.sh -o install-manager.sh
### Step 2. Make script executable
chmod +x install-manager.sh
### Step 3. Run installation script
sudo ./install-manager.sh
## After this steps you can enjoy Fully working Ano Package Manager! :) (How to delete: sudo ano delmgr or sudo rm -rf /usr/local/bin/ano)
