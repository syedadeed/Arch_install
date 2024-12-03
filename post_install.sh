#!/bin/bash

configure_wifi ()
{
    sudo systemctl start NetworkManager && sleep 2
    sudo systemctl enable NetworkManager && sleep 3
    sudo nmcli device wifi list && sleep 5
    echo "Enter wifi password: "
    read ps
    ps="$ps"
    sudo nmcli device wifi connect Airtel password $ps ifname wlp0s20u2 name Home
    sudo nmcli connection modify Home connection.autoconnect yes
    sudo nmcli connection up Home
}

update_hostname ()
{
    sudo hostnamectl set-hostname arch
    echo -e "127.0.0.1 localhost\n127.0.1.1 arch" | sudo tee -a /etc/hosts
}

audio_setup ()
{
    sudo pacman -Syy --noconfirm pipewire
    systemctl --user enable pipewire.service
    sudo pacman -Syy --noconfirm pipewire-alsa
    sudo pacman -Syy --noconfirm pipewire-jack
    sudo pacman -Syy --noconfirm pipewire-pulse
    systemctl --user enable pipewire-pulse.service
}

bluetooth_setup ()
{
    sudo pacman -Syy --noconfirm bluez
    sudo pacman -Syy --noconfirm bluez-utils
    sudo systemctl enable bluetooth.service
}

font_installation ()
{
    sudo pacman -Syy --noconfirm noto-fonts
    sudo pacman -Syy --noconfirm noto-fonts-cjk
    sudo pacman -Syy --noconfirm noto-fonts-extra
    sudo pacman -Syy --noconfirm noto-fonts-emoji
}

gui_setup ()
{
    sudo pacman -Syy --noconfirm hyprland
    sudo pacman -Syy --noconfirm kitty
    sudo pacman -Syy --noconfirm firefox
    sudo pacman -Syy --noconfirm hyprpicker
    sudo pacman -Syy --noconfirm grim
    sudo pacman -Syy --noconfirm slurp
    sudo pacman -Syy --noconfirm swww
    sudo pacman -Syy --noconfirm xdg-desktop-portal-hyprland
}

cli_tools_installation ()
{
    sudo pacman -Syy --noconfirm android-tools
    sudo pacman -Syy --noconfirm bash-completion
    sudo pacman -Syy --noconfirm fzf
    sudo pacman -Syy --noconfirm git
    sudo pacman -Syy --noconfirm github-cli
    sudo pacman -Syy --noconfirm man-db
    sudo pacman -Syy --noconfirm man-pages
    sudo pacman -Syy --noconfirm neovim
    sudo pacman -Syy --noconfirm unzip
    sudo pacman -Syy --noconfirm wl-clipboard
}

configure_wifi
update_hostname
audio_setup
bluetooth_setup
font_installation
gui_setup
cli_tools_installation

#xremap, Bibata cursor theme
