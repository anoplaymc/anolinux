# 🚀 AnoLinux

A custom Linux distribution based on **Arch Linux**, featuring **KDE Plasma**, a custom `ano` package manager wrapper, pre-configured `fastfetch`, and an automated graphical installer.

## 📦 Installation Guide

To install AnoLinux, boot from any official Arch Linux Live ISO, connect to the internet, and follow these steps:

### Step 1. Disk Partitioning (Example for `/dev/sda`, if your disk is not /dev/sda type "lsblk")
parted /dev/sda --script mklabel gpt

parted /dev/sda --script mkpart primary ext4 0% 100%

mkfs.ext4 -F /dev/sda1

mount /dev/sda1 /mnt

### Step 2. Install and run the Installer
bash <(curl -sSL [https://raw.githubusercontent.com/anoplaymc/anolinux/main/anolinux-installer.sh](https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/anolinux-installer.sh))

### After the script finishes successfully, unmount and reboot:
umount -R /mnt
reboot

### After rebooting enjoy your system!
