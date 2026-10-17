#!/bin/bash
set -e

# Проверка на запуск от root
if [ "$EUID" -ne 0 ]; then
    echo "[-] Error: Please run this script with root privileges (sudo)."
    exit 1
fi

echo "=================================================="
echo "      ANO DECLARATIVE MANAGER SETUP SCRIPT      "
echo "=================================================="

# Создаем директорию для конфига, если её нет
mkdir -p /etc/ano

# Создаем дефолтный ano.conf, если он отсутствует
if [ ! -f /etc/ano/ano.conf ]; then
    cat << 'EOF' > /etc/ano/ano.conf
# ==================================================
#          ANO PACKAGE MANAGER CONFIG FILE
#          JUST WRITE NAME OF PACKAGES HERE AND THEY'LL BE
#          INSTALLED!
# ==================================================
EOF
fi

cat << 'ANO_SCRIPT' > /usr/local/bin/ano
#!/bin/bash

CONFIG_FILE="/etc/ano/ano.conf"

# Функция очистки конфига от комментариев и пустых строк для получения чистого списка пакетов
get_declared_packages() {
    if [ -f "$CONFIG_FILE" ]; then
        grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$' | tr '\n' ' '
    fi
}

# Функция добавления пакета в конфиг (если его там еще нет)
add_to_config() {
    local pkg="$1"
    if [ -f "$CONFIG_FILE" ]; then
        # Проверяем, нет ли уже такого пакета в файле
        if ! grep -q -E "^\s*${pkg}\s*$" "$CONFIG_FILE"; then
            echo "$pkg" >> "$CONFIG_FILE"
        fi
    fi
}

# Функция удаления пакета из конфига
remove_from_config() {
    local pkg="$1"
    if [ -f "$CONFIG_FILE" ]; then
        # Удаляем строку с именем пакета (игнорируя пробелы)
        sed -i -E "/^\s*${pkg}\s*$/d" "$CONFIG_FILE"
    fi
}

# Обработка команд
if [ "$1" = "update" ]; then
    sudo pacman -Syu

elif [ "$1" = "rebuild" ]; then
    # Проверяем флаги для rebuild
    if [ "$2" = "--autowrite" ]; then
        if [ -z "$3" ]; then
            echo "[-] Error: Specify a package to install."
            exit 1
        shift 2
        fi
        pkg="$2"
        echo "=== Installing package and auto-writing to config: $pkg ==="
        sudo pacman -S --needed "$pkg"
        add_to_config "$pkg"
        echo "[+] Package '$pkg' successfully installed and added to $CONFIG_FILE"
        exit 0

    elif [ "$2" = "--autoremove" ]; then
        if [ -z "$3" ]; then
            echo "[-] Error: Specify a package to remove."
            exit 1
        fi
        pkg="$3"
        echo "=== Removing package without touching config: $pkg ==="
        sudo pacman -R "$pkg"
        remove_from_config "$pkg"
        echo "[+] Package '$pkg' removed and cleaned from config."
        exit 0

    elif [ "$2" = "--autoremoveall" ]; then
        if [ -z "$3" ]; then
            echo "[-] Error: Specify a package to remove."
            exit 1
        fi
        pkg="$3"
        echo "=== Removing package and its dependencies without touching config: $pkg ==="
        sudo pacman -Rns "$pkg"
        remove_from_config "$pkg"
        echo "[+] Package '$pkg' and its dependencies removed and cleaned from config."
        exit 0
    fi

    # Основной режим декларативной синхронизации (просто ano rebuild)
    echo "=== Synchronizing system state with $CONFIG_FILE ==="
    
    # 1. Получаем список пакетов из файла конфигурации
    desired_pkgs=$(get_declared_packages)
    
    if [ -z "$desired_pkgs" ]; then
        echo "[*] Warning: Config file is empty. No declarative packages to install."
        exit 0
    fi

    echo "[*] Target packages: $desired_pkgs"

    # 2. Устанавливаем то, что прописано в конфиге, но еще не установлено
    sudo pacman -S --needed $desired_pkgs

    # 3. Автоматическое удаление: ищем то, что установлено явно, но удалено из конфига
    # Получаем список всех явно установленных пакетов в системе
    explicit_installed=$(pacman -Qqe)

    for installed_pkg in $explicit_installed; do
        # Проверяем, есть ли этот пакет в файле конфигурации
        if ! grep -q -E "^\s*${installed_pkg}\s*$" "$CONFIG_FILE"; then
            # Исключаем базовые метапакеты системы, чтобы случайно не снести систему
            if [[ "$installed_pkg" =~ ^(base|base-devel|linux|linux-firmware|sudo|networkmanager|sddm|plasma-meta|grub)$ ]]; then
                continue
            fi
            echo "[-] Package '$installed_pkg' was removed from config. Uninstalling..."
            sudo pacman -R --noconfirm "$installed_pkg" || true
        fi
    done

    echo "[+] System successfully rebuilt from $CONFIG_FILE!"

elif [ "$1" = "search" ]; then
    if [ -z "$2" ]; then
        echo "[-] Error: Specify a search query."
        exit 1
    fi
    shift
    sudo pacman -Ss "$@"

else
    echo "=== AnoLinux Package Manager (ano) ==="
    echo " For install any package you need to write it name at /etc/ano/ano.conf"
    echo "Usage:"
    echo "  ano update   - Synchronize and upgrade system"
    echo "  ano rebuild - Rebuilding updated packages from ano.conf"
    echo "  ano rebuild --autowrite <package>  - Installing packages without writing it in ano.conf"
    echo "  ano rebuild --autoremove <package>   - Removing packages without writing it in ano.conf"
    echo "  ano rebuild --autoremoveall <package> - Remove package and needed for it without writing it in ano.conf"
    echo "  ano search <package>   - Search in AnoLinux repositories"
fi
ANO_SCRIPT

# Делаем скрипт исполняемым
chmod +x /usr/local/bin/ano

echo "=================================================="
echo "     DECLARATIVE 'ano' SUCCESSFULLY INSTALLED!    "
echo "=================================================="
