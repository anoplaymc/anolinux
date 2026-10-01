# 🚀 AnoLinux

## If you want to install this distro normally, please read all this text!

A custom Linux distribution based on **Arch Linux**, featuring **KDE Plasma**, a custom `ano` package manager wrapper, pre-configured `fastfetch`, and an automated bash installer.

## !! If you are beginner on linux, installing AnoLinux is not really recommended !!

## !! WARNING !! Bios(non-UEFI) installisation metod is on testing now, please use UEFI if you can!

## BUGS !!IMPORTANT TO READ!!:
## 1.
i found a bug on AnoLinux:
when AnoLinux booting on virtualbox, it works normally 
but when i was installed AnoLinux on my pc with NVIDIA RTX 4060
its been very laggy, you need to press CTRL+ALT+F3 and on terminal shell
type: ano install nvidia-dkms nvidia-utils nvidia-settings
and AnoLinux will work normally (Edited: I'm just added new script "configure.sh" and there included drivers installing, and if you will install the distro by this guide, you will install this script!)
## 2.
when changing/deleting your fastfetch config (~/.config/fastfetch/config.jsonc)
fastfetch can display Arch Linux logo, use my fastfetch config (uploaded on this repo) or copy "os logo" part from there
from my fastfetch config if u want to keep linux logo
on next version i will spoof AnoLinux from "arch" to "linux" or "lfs" on kernel settings

How to put my fastfetch config:

1. download file "fastfetch-config.jsonc" on this repo

2. rename file to "config.jsonc"

3. put this file on ~/.config/fastfetch/ (if this folder has file "config.jsonc" already - remove it)
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

## What you need to install yourself (in future, it will be included on "configure.sh" script):
### AUR Repositories (yay) (if you need)
ano install --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
### Pipewire or PulseAudio:
ano install pipewire / ano install pulseaudio
### Volume Control (if you need)
ano install pavucontrol
### zsh with "powerlevel10k" theme (if you need) (AUR needed)
ano install zsh ttf-meslo-nerd-font-powerlevel10k
chsh -s /usr/bin/zsh
yay -S zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
source ~/.zshrc
## 📦 Installation Guide

To install AnoLinux, boot from any official Arch Linux Live ISO, connect to the internet, and follow these steps:

### Step 1. Disk Partitioning (Automatic detection of your main drive)

## First, run `lsblk` to see your disk name (e.g., `sda`, `vda`, or `nvme0n1`), and set it to a variable (replace `sda` with your actual drive if needed):

DISK="/dev/sda"

# Create GPT label and partitions (EFI 512MiB + Root rest)
parted $DISK --script mklabel gpt

parted $DISK --script mkpart ESP fat32 1MiB 512MiB

parted $DISK --script set 1 boot on

parted $DISK --script mkpart primary ext4 512MiB 100%

# Format partitions (Adjust partition numbers if your disk uses p-suffixes like nvme0n1p1)
mkfs.fat -F32 ${DISK}1

mkfs.ext4 -F ${DISK}2

# Mount root and boot
mount ${DISK}2 /mnt

mkdir -p /mnt/boot

mount ${DISK}1 /mnt/boot

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
