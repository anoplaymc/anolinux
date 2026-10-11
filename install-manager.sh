#!/bin/bash
set -e

# Проверка на запуск от root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: Please run this script with root privileges (sudo)."
    exit 1
fi

echo "=================================================="
echo "          ANO MANAGER INSTALLATION SCRIPT         "
echo "=================================================="

# 1. Создание скрипта пакетного менеджера 'ano'
echo "[*] Installing 'ano' wrapper to /usr/local/bin/ano..."

cat << 'ANO_SCRIPT' > /usr/local/bin/ano
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
elif [ "$1" = "delmgr" ]; then
    echo "=== AnoLinux Package Manager Uninstallation ==="
    read -p "Are you sure you want to completely remove 'ano' manager from the system? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "[*] Removing /usr/local/bin/ano..."
        rm -f /usr/local/bin/ano
        echo "[+] 'ano' package manager has been successfully removed from your system."
        exit 0
    else
        echo "[*] Uninstallation cancelled."
        exit 0
    fi
else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo "Usage:"
    echo "  ano update   - Synchronize and upgrade system"
    echo "  ano install  - Install software packages"
    echo "  ano remove   - Remove software packages"
    echo "  ano search   - Search in AnoLinux repositories"
    echo "  ano delmgr   - Completely remove 'ano' package manager from system"
fi
ANO_SCRIPT

# 2. Выставление правильных прав на выполнение
chmod +x /usr/local/bin/ano

echo "=================================================="
echo "      'ano' PACKAGE MANAGER SUCCESSFULLY INSTALLED!"
echo "=================================================="
echo "You can now use it in your terminal:"
echo "  ano update"
echo "  ano install <package>"
echo "  ano remove <package>"
echo "  ano search <query>"
echo "  ano delmgr (to uninstall)"
echo "=================================================="
