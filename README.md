# 🚀 AnoLinux

A custom Linux distribution based on **Arch Linux**, featuring **KDE Plasma**, a custom `ano` package manager wrapper, pre-configured `fastfetch`, and an automated graphical installer.

## !! If you are beginner on linux, installing AnoLinux is not really recommended !!

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
bash <(curl -sSL [https://raw.githubusercontent.com/anoplaymc/anolinux/main/anolinux-installer.sh](https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/anolinux-installer.sh))

### After the script finishes successfully, unmount and reboot:
umount -R /mnt

reboot

### After rebooting enjoy your system!
