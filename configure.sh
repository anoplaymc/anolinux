#!/bin/bash
set -e

echo "=================================================="
echo "          ANOLINUX INSTALLATION SCRIPT PART 2     "
echo "=================================================="

# 1. Запрос на установку драйверов NVIDIA
read -p "Install NVIDIA Drivers? (Required for normally working) (Not fully configuring drivers) [y/n]: " NVIDIA_CHOICE

if [[ "$NVIDIA_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing NVIDIA drivers & linux-headers via ano ==="
    ano install nvidia-dkms nvidia-utils nvidia-settings linux-headers
else
    echo "=== Skipping NVIDIA drivers installation ==="
fi

echo "--------------------------------------------------"

# 2. Выбор альтернативной оболочки / окружения
echo "Install another shell from list?"
echo "  1) Gnome"
echo "  2) Xfce4"
echo "  3) Hyprland"
echo "  4) No, keep KDE Plasma"
read -p "Enter choice [1-4]: " SHELL_CHOICE

case "$SHELL_CHOICE" in
    1)
        echo "=== Installing GNOME desktop environment ==="
        ano install gnome gdm
        sudo systemctl disable sddm || true
        sudo systemctl enable gdm
        ;;
    2)
        echo "=== Installing Xfce4 desktop environment ==="
        ano install xfce4 xfce4-goodies
        ;;
    3)
        echo "=== Installing Hyprland window manager ==="
        ano install hyprland kitty waybar rofi mako
        ;;
    4|*)
        echo "=== Keeping default KDE Plasma configuration ==="
        ;;
esac

echo "================================================--"
echo "AnoLinux configures successfully! Enjoy your system! :)"
echo "(If you're installed another shell, choose it from login screen)"
echo "================================================--"
