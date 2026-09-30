#!/bin/bash
set -e

# ==========================================
# 1. РЕЖИМ ОБНОВЛЕНИЯ КОНФИГУРАЦИИ (--apply-updates)
# ==========================================
if [ "$1" = "--apply-updates" ]; then
    echo "=== Updating AnoLinux System Configurations ==="

    # Обновляем /etc/os-release
    sudo tee /etc/os-release > /dev/null << 'OSRELEASE'
NAME="AnoLinux"
ID=anolinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="36;1"
HOME_URL="https://github.com/anoplaymc/anolinux"
DOCUMENTATION_URL="https://github.com/anoplaymc/anolinux"
SUPPORT_URL="https://github.com/anoplaymc/anolinux"
BUG_REPORT_URL="https://github.com/anoplaymc/anolinux"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=anolinux
OSRELEASE

    # Обновляем конфиг Fastfetch
    sudo mkdir -p /etc/fastfetch
    sudo tee /etc/fastfetch/config.jsonc > /dev/null << 'FASTFETCH_CONF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "source": "linux"
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "de",
    "separator",
    "wm",
    "wmtheme",
    "theme",
    "icons",
    "font",
    "cursor",
    "separator",
    "terminal",
    "terminalfont",
    "cpu",
    "gpu",
    "memory",
    "swap",
    "disk",
    "battery",
    "poweradapter",
    "localip",
    "locale",
    "break",
    "colors"
  ]
}
FASTFETCH_CONF

    # Обновляем код пакетного менеджера 'ano' прямо в системе
    sudo tee /usr/local/bin/ano > /dev/null << 'ANO_SCRIPT'
#!/bin/bash
if [ "$1" = "update" ]; then
    sudo pacman -Syu
elif [ "$1" = "install" ]; then
    shift
    sudo pacman -S "$@"
elif [ "$1" = "remove" ]; then
    shift
    sudo pacman -R "$@"
elif [ "$1" = "search" ]; then
    shift
    sudo pacman -Ss "$@"
elif [ "$1" = "systemupdate" ]; then
    echo "Checking for updates..."
    TEMP_SCRIPT="/tmp/anolinux-latest.sh"
    
    if curl -sSL "https://raw.githubusercontent.com/anoplaymc/anolinux/main/anolinux-installer.sh" -o "$TEMP_SCRIPT"; then
        
        if grep -q "ID=anolinux" /etc/os-release; then
            echo "AnoLinux detected. Proceeding with update check..."
        else
            echo "Error: This system is not recognized as AnoLinux!"
            rm -f "$TEMP_SCRIPT"
            exit 1
        fi

        if [ ! -f "/etc/anolinux/installed-installer.sh" ]; then
            sudo mkdir -p /etc/anolinux
            sudo cp "$TEMP_SCRIPT" /etc/anolinux/installed-installer.sh
            sudo chmod +x /etc/anolinux/installed-installer.sh
            echo "Baseline created successfully!"
            rm -f "$TEMP_SCRIPT"
            exit 0
        fi

        if cmp -s "/etc/anolinux/installed-installer.sh" "$TEMP_SCRIPT"; then
            echo "Updates not found!"
            rm -f "$TEMP_SCRIPT"
        else
            echo "Updates found! Install updates? [y/n]"
            read -p "> " CONFIRM
            if [[ "$CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo "Applying configuration updates..."
                sudo cp "$TEMP_SCRIPT" /etc/anolinux/installed-installer.sh
                sudo chmod +x /etc/anolinux/installed-installer.sh
                
                sudo bash /etc/anolinux/installed-installer.sh --apply-updates
                
                rm -f "$TEMP_SCRIPT"
                echo "AnoLinux configuration updated successfully without losing your files!"
            else
                echo "Update cancelled."
                rm -f "$TEMP_SCRIPT"
            fi
        fi
    else
        echo "Error: Failed to download update from GitHub!"
        rm -f "$TEMP_SCRIPT"
    fi
else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo "Usage:"
    echo "  ano update       - Synchronize and upgrade system"
    echo "  ano install      - Install software packages"
    echo "  ano remove       - Remove software packages"
    echo "  ano search       - Search in AnoLinux repositories"
    echo "  ano systemupdate - Check and update AnoLinux configuration"
fi
ANO_SCRIPT
    sudo chmod +x /usr/local/bin/ano

    echo "AnoLinux configuration updated successfully!"
    exit 0
fi

# ==========================================
# 2. РЕЖИМ ЧИСТОЙ УСТАНОВКИ (С ISO)
# ==========================================
echo "=================================================="
echo "          ANOLINUX INSTALLATION SCRIPT            "
echo "=================================================="

# 1. Check if the disk is mounted to /mnt
if ! mountpoint -q /mnt; then
    echo "Error: Nothing is mounted at /mnt!"
    echo "Please partition your disk and mount the root partition to /mnt first."
    exit 1
fi

# 2. Interactive input before entering chroot
echo "--------------------------------------------------"
read -p "Install NVIDIA Drivers? [y/N]: " NVIDIA_CHOICE
read -p "Enter new username for AnoLinux: " USER_NAME
read -s -p "Enter password for user $USER_NAME: " USER_PASS
echo
read -s -p "Enter new password for root: " ROOT_PASS
echo
echo "--------------------------------------------------"

# Выбор типа загрузки (UEFI или BIOS)
echo "Select boot mode:"
echo "  1) UEFI (Recommended for modern systems & VMs)"
echo "  2) BIOS / Legacy (For older systems)"
read -p "Enter choice [1 or 2]: " BOOT_CHOICE

if [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ] || [ -z "$ROOT_PASS" ]; then
    echo "Error: Username and passwords cannot be empty!"
    exit 1
fi

# Формируем список пакетов
INSTALL_PKGS="base base-devel linux linux-firmware sudo networkmanager sddm plasma-meta konsole kitty fastfetch firefox git python-pyqt6 python-requests curl"

if [[ "$NVIDIA_CHOICE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    INSTALL_PKGS="$INSTALL_PKGS nvidia-dkms nvidia-utils nvidia-settings"
    echo "=== NVIDIA drivers will be included ==="
fi

# 3. Install stack via pacstrap
echo "=== Installing Arch base, KDE Plasma, Kitty, Fastfetch & Ano Stack ==="
pacstrap /mnt $INSTALL_PKGS

# 4. Generate fstab
echo "=== Generating fstab ==="
genfstab -U /mnt >> /mnt/etc/fstab

# Сохраняем текущий скрипт как эталон для будущих обновлений через systemupdate
CURRENT_SCRIPT_PATH="$(readlink -f "$0")"
sudo mkdir -p /mnt/etc/anolinux
if [ -f "$CURRENT_SCRIPT_PATH" ]; then
    cp "$CURRENT_SCRIPT_PATH" /mnt/etc/anolinux/installed-installer.sh
else
    # Fallback на случай запуска через curl pipe
    echo "# AnoLinux Baseline" > /mnt/etc/anolinux/installed-installer.sh
fi
chmod +x /mnt/etc/anolinux/installed-installer.sh

# 5. Deep Customization Inside chroot
echo "=== Applying AnoLinux Customization (Branding, Kernel, Tools) ==="
arch-chroot /mnt /bin/bash <<EOF
# Locale and Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname and hosts
echo "anolinux" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\tanolinux.localdomain\tanolinux" > /etc/hosts

# Passwords
echo "root:$ROOT_PASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$USER_NAME"
echo "$USER_NAME:$USER_PASS" | chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Branding: os-release update
cat << 'OSRELEASE' > /etc/os-release
NAME="AnoLinux"
ID=anolinux
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="36;1"
HOME_URL="https://github.com/anoplaymc/anolinux"
DOCUMENTATION_URL="https://github.com/anoplaymc/anolinux"
SUPPORT_URL="https://github.com/anoplaymc/anolinux"
BUG_REPORT_URL="https://github.com/anoplaymc/anolinux"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=anolinux
OSRELEASE

# Kernel branding in GRUB title
sed -i 's/TITLE=Arch Linux/TITLE=AnoLinux/g' /etc/grub.d/10_linux || true

# Creating our custom package manager wrapper 'ano'
cat << 'ANO_SCRIPT' > /usr/local/bin/ano
#!/bin/bash
if [ "\$1" = "update" ]; then
    sudo pacman -Syu
elif [ "\$1" = "install" ]; then
    shift
    sudo pacman -S "\$@"
elif [ "\$1" = "remove" ]; then
    shift
    sudo pacman -R "\$@"
elif [ "\$1" = "search" ]; then
    shift
    sudo pacman -Ss "\$@"
elif [ "\$1" = "systemupdate" ]; then
    echo "Checking for updates..."
    TEMP_SCRIPT="/tmp/anolinux-latest.sh"
    
    if curl -sSL "https://raw.githubusercontent.com/anoplaymc/anolinux/main/anolinux-installer.sh" -o "\$TEMP_SCRIPT"; then
        
        if grep -q "ID=anolinux" /etc/os-release; then
            echo "AnoLinux detected. Proceeding with update check..."
        else
            echo "Error: This system is not recognized as AnoLinux!"
            rm -f "\$TEMP_SCRIPT"
            exit 1
        fi

        if [ ! -f "/etc/anolinux/installed-installer.sh" ]; then
            sudo mkdir -p /etc/anolinux
            sudo cp "\$TEMP_SCRIPT" /etc/anolinux/installed-installer.sh
            sudo chmod +x /etc/anolinux/installed-installer.sh
            echo "Baseline created successfully!"
            rm -f "\$TEMP_SCRIPT"
            exit 0
        fi

        if cmp -s "/etc/anolinux/installed-installer.sh" "\$TEMP_SCRIPT"; then
            echo "Updates not found!"
            rm -f "\$TEMP_SCRIPT"
        else
            echo "Updates found! Install updates? [y/n]"
            read -p "> " CONFIRM
            if [[ "\$CONFIRM" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo "Applying configuration updates..."
                sudo cp "\$TEMP_SCRIPT" /etc/anolinux/installed-installer.sh
                sudo chmod +x /etc/anolinux/installed-installer.sh
                
                sudo bash /etc/anolinux/installed-installer.sh --apply-updates
                
                rm -f "\$TEMP_SCRIPT"
                echo "AnoLinux configuration updated successfully without losing your files!"
            else
                echo "Update cancelled."
                rm -f "\$TEMP_SCRIPT"
            fi
        fi
    else
        echo "Error: Failed to download update from GitHub!"
        rm -f "\$TEMP_SCRIPT"
    fi
else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo "Usage:"
    echo "  ano update       - Synchronize and upgrade system"
    echo "  ano install      - Install software packages"
    echo "  ano remove       - Remove software packages"
    echo "  ano search       - Search in AnoLinux repositories"
    echo "  ano systemupdate - Check and update AnoLinux configuration"
fi
ANO_SCRIPT
chmod +x /usr/local/bin/ano

# Custom Fastfetch configuration
mkdir -p /etc/fastfetch
cat << 'FASTFETCH_CONF' > /etc/fastfetch/config.jsonc
{
  "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "source": "linux"
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "display",
    "de",
    "separator",
    "wm",
    "wmtheme",
    "theme",
    "icons",
    "font",
    "cursor",
    "separator",
    "terminal",
    "terminalfont",
    "cpu",
    "gpu",
    "memory",
    "swap",
    "disk",
    "battery",
    "poweradapter",
    "localip",
    "locale",
    "break",
    "colors"
  ]
}
FASTFETCH_CONF

# Enable system services
systemctl enable NetworkManager
systemctl enable sddm

# Setup autostart configuration for the graphical installer
mkdir -p /usr/local/bin
mkdir -p /usr/share/applications
mkdir -p /etc/xdg/autostart

cat << 'DESKTOP' > /usr/share/applications/ano-installer.desktop
[Desktop Entry]
Name=AnoLinux Installer
Comment=Install AnoLinux on your hard drive
Exec=ano-installer
Icon=system-software-install
Terminal=false
Type=Application
Categories=System;
DESKTOP

cp /usr/share/applications/ano-installer.desktop /etc/xdg/autostart/

# Install GRUB bootloader based on user choice
echo ">>> Installing GRUB bootloader..."
pacman -S --noconfirm grub efibootmgr

if [ "$BOOT_CHOICE" = "1" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=AnoLinux --recheck
else
    read -p "Enter target disk for BIOS GRUB (e.g. /dev/sda): " TARGET_DISK
    grub-install --target=i386-pc "\$TARGET_DISK"
fi

grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "=================================================="
echo "    ANOLINUX SETUP & INSTALLATION COMPLETED!      "
echo "=================================================="
echo "You can now run the following commands to finish:"
echo "  umount -R /mnt"
echo "  reboot"
echo "=================================================="
