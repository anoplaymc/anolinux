#!/bin/bash
set -e

# Проверка на запуск скрипта установки от root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: Please run this script with root privileges (sudo)."
    exit 1
fi

echo "=================================================="
echo "      ANO MANAGER INSTALLATION SCRIPT (NIXOS)     "
echo "=================================================="

cat << 'ANO_SCRIPT' > /usr/local/bin/ano
#!/bin/bash

CONFIG_FILE="/etc/nixos/configuration.nix"

# Функция для добавления пакета в configuration.nix
add_to_config() {
    local pkg="$1"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[-] Error: Configuration file $CONFIG_FILE not found."
        exit 1
    }

    # Проверяем, есть ли уже такой пакет в конфигурации, чтобы не дублировать
    if grep -q "\b$pkg\b" "$CONFIG_FILE"; then
        echo "[*] Package '$pkg' is already present in $CONFIG_FILE"
        return
    }

    # Создаем бэкап конфигурации
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    # Используем awk для вставки пакета внутрь блока environment.systemPackages
    awk -v pkg="$pkg" '
    BEGIN { in_block = 0 }
    /environment\.systemPackages\s*=\s*with\s+pkgs;\s*\[/ {
        in_block = 1
        print
        next
    }
    in_block && /\]/ {
        print "    " pkg
        in_block = 0
    }
    { print }
    ' "${CONFIG_FILE}.bak" > "$CONFIG_FILE"

    echo "[+] Added '$pkg' to environment.systemPackages in $CONFIG_FILE"
}

# Проверяем команду удаления пакетного менеджера
if [ "$1" = "delmgr" ]; then
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

# Команды менеджера для NixOS
if [ "$1" = "update" ]; then
    shift
    sudo nixos-rebuild switch --upgrade "$@"
elif [ "$1" = "install" ]; then
    shift
    if [ -z "$1" ]; then
        echo "[-] Error: No package specified."
        exit 1
    fi
    
    # 1. Сначала запускаем nix-shell с пакетом
    echo "[*] Launching temporary nix-shell for '$1'..."
    nix-shell -p "$1" &
    SHELL_PID=$!

    # 2. Добавляем пакет в configuration.nix
    add_to_config "$1"

    # Ждем завершения сессии nix-shell (или можно оставить выполняться)
    wait $SHELL_PID || true

    # 3. Выводим сообщение с требованием запустить ano update
    echo "=================================================="
    echo "      Packages installed, type \"ano update\" to finish installation"
    echo "=================================================="
elif [ "$1" = "search" ]; then
    shift
    nix search nixpkgs "$@"
else
    echo "=== AnoLinux Package Manager (NixOS Edition) ==="
    echo "Usage:"
    echo "  ano update     - Upgrade NixOS system (nixos-rebuild switch)"
    echo "  ano install    - Run package in nix-shell and add to configuration.nix"
    echo "  ano search     - Search packages in nixpkgs"
    echo "  ano delmgr     - Completely remove 'ano' package manager from system"
fi
ANO_SCRIPT

# Делаем файл исполняемым
chmod +x /usr/local/bin/ano

echo "=================================================="
echo "      'ano' PACKAGE MANAGER SUCCESSFULLY INSTALLED!"
echo "=================================================="
