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

echo "--------------------------------------------------"

# 3. Установка AUR helper (yay)
read -p "Install AUR (yay) (git included)? [y/n]: " YAY_CHOICE

if [[ "$YAY_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing base-devel, git and building yay ==="
    ano install --needed base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
else
    echo "=== Skipping AUR (yay) installation ==="
fi

echo "--------------------------------------------------"

# 4. Выбор звукового сервера
echo "Install PipeWire or PulseAudio?"
echo "  1) Pipewire"
echo "  2) PulseAudio"
echo "  3) No, i will use system without sound"
read -p "Enter choice [1-3]: " SOUND_CHOICE

case "$SOUND_CHOICE" in
    1)
        echo "=== Installing PipeWire ==="
        ano install pipewire
        ;;
    2)
        echo "=== Installing PulseAudio ==="
        ano install pulseaudio
        ;;
    3|*)
        echo "=== Skipping sound server installation ==="
        ;;
esac

echo "--------------------------------------------------"

# 5. Установка регулятора громкости
read -p "Install Volume Control? (pavucontrol) [y/n]: " PAVU_CHOICE

if [[ "$PAVU_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing pavucontrol ==="
    ano install pavucontrol
else
    echo "=== Skipping pavucontrol installation ==="
fi

echo "--------------------------------------------------"

# 6. Установка zsh и темы powerlevel10k
read -p "Install zsh with powerlevel10k theme? (if you don't installed AUR before on this script, do not accept it! It will break script work!) [y/n]: " ZSH_CHOICE

if [[ "$ZSH_CHOICE" =~ ^[Yy]$ ]]; then
    echo "=== Installing ZSH and Meslo Nerd Font ==="
    ano install zsh ttf-meslo-nerd-font-powerlevel10k
    
    echo "=== Changing default shell to ZSH ==="
    chsh -s /usr/bin/zsh
    
    echo "=== Installing powerlevel10k theme from AUR ==="
    yay -S --noconfirm zsh-theme-powerlevel10k-git
    
    echo "=== Configuring .zshrc ==="
    echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
else
    echo "=== Skipping ZSH installation ==="
fi

echo "=================================================="
echo "AnoLinux configures successfully! Enjoy your system! :)"
echo "(If you're installed another shell, choose it from login screen)"
echo "(If your shell is xfce4, do not choose wayland session)"
if [[ "$ZSH_CHOICE" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Applying zsh configuration..."
    source ~/.zshrc || true
fi
echo "=================================================="
