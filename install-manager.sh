#!/bin/bash
set -e

# Проверка на запуск скрипта установки от root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: Please run this script with root privileges (sudo)."
    exit 1
fi

echo "=================================================="
echo "         ANO MANAGER INSTALLATION SCRIPT          "
echo "=================================================="

# 1. Проверяем, есть ли уже старый скрипт ano, и удаляем его перед установкой нового
if [ -f /usr/local/bin/ano ]; then
    echo "[*] Found existing 'ano' script. Removing old version..."
    rm -f /usr/local/bin/ano
fi

# 2. Генерируем тело скрипта ano с динамической проверкой os-release
cat << 'ANO_SCRIPT' > /usr/local/bin/ano
#!/bin/bash

# Определяем текущий дистрибутив по /etc/os-release
IS_ANOLINUX=false
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "anolinux" ]; then
        IS_ANOLINUX=true
    fi
fi

# Проверяем команду удаления пакетного менеджера (доступна ТОЛЬКО если это НЕ AnoLinux)
if [ "$1" = "delmgr" ]; then
    if [ "$IS_ANOLINUX" = true ]; then
        echo "[-] Error: 'ano' is the native package manager of AnoLinux and cannot be removed via delmgr."
        exit 1
    fi

    # Жесткая проверка: если запуск не от root, сразу выдаем ошибку
    if [ "$EUID" -ne 0 ]; then
        echo "[-] Error: Removing 'ano' requires root privileges."
        echo "    Please run: sudo ano delmgr"
        exit 1
    fi

    echo "=== AnoLinux Package Manager Uninstallation ==="
    read -p "Are you sure you want to completely remove 'ano' manager from the system? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        if rm -f /usr/local/bin/ano; then
            echo "[+] 'ano' package manager has been successfully removed from your system."
            exit 0
        else
            echo "[-] Error: Failed to remove /usr/local/bin/ano"
            exit 1
        fi
    else
        echo "[*] Uninstallation cancelled."
        exit 0
    fi
fi

# Остальные команды менеджера
if [ "$1" = "update" ]; then
    sudo pacman -Syu
elif [ "$1" = "install" ]; then
    shift
    sudo pacman -S "$@"
elif [ "$1" = "remove" ]; then
    shift
    sudo pacman -R "$@"
elif [ "$1" = "removeall" ]; then
    shift
    sudo pacman -Rns "$@"
elif [ "$1" = "search" ]; then
    shift
    sudo pacman -Ss "$@"
else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo "Usage:"
    echo "  ano update   - Synchronize and upgrade system"
    echo "  ano install  - Install software packages"
    echo "  ano remove   - Remove software package"
    echo "  ano removeall- Remove software package and needed for it"
    echo "  ano search   - Search in AnoLinux repositories"
    
    # Показываем delmgr в справке только если это НЕ AnoLinux
    if [ "$IS_ANOLINUX" = false ]; then
        echo "  ano delmgr   - Completely remove 'ano' package manager from system"
    fi
fi
ANO_SCRIPT

# Делаем файл исполняемым
chmod +x /usr/local/bin/ano

echo "=================================================="
echo "      'ano' PACKAGE MANAGER SUCCESSFULLY INSTALLED!"
echo "=================================================="
