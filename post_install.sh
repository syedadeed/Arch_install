#!/bin/bash

configure_wifi ()
{
    sudo systemctl start NetworkManager && sleep 2
    sudo systemctl enable NetworkManager && sleep 3
    sudo nmcli device wifi list && sleep 5
    sudo nmcli device wifi connect Airtel password airtel1029 ifname wlp0s20u2 name Home
    sudo nmcli connection modify Home connection.autoconnect yes
    sudo nmcli connection up Home
}

update_hostname ()
{
    sudo hostnamectl set-hostname arch
    echo -e "127.0.0.1 localhost\n127.0.1.1 arch" | sudo tee -a /etc/hosts
}

install_packages ()
{
    sudo pacman -Syy
    sudo pacman -S --noconfirm intel-ucode
    sudo pacman -S --noconfirm neovim
    sudo pacman -S --noconfirm unzip
    sudo pacman -S --noconfirm man-db
    sudo pacman -S --noconfirm man-pages
    sudo pacman -S --noconfirm android-tools
    sudo pacman -S --noconfirm git
    sudo pacman -S --noconfirm bash-completion
    sudo pacman -S --noconfirm hyprland
    sudo pacman -S --noconfirm hyprpicker
    sudo pacman -S --noconfirm pipewire
    systemctl --user enable pipewire.service
    sudo pacman -S --noconfirm pipewire-alsa
    sudo pacman -S --noconfirm pipewire-jack
    sudo pacman -S --noconfirm pipewire-pulse
    systemctl --user enable pipewire-pulse.service
    sudo pacman -S --noconfirm bluez
    sudo pacman -S --noconfirm bluez-utils
    sudo systemctl enable bluetooth.service
    sudo pacman -S --noconfirm bat
    sudo pacman -S --noconfirm swww
    sudo pacman -S --noconfirm zoxide
    sudo pacman -S --noconfirm fzf
    sudo pacman -S --noconfirm grim
    sudo pacman -S --noconfirm slurp
    sudo pacman -S --noconfirm wl-clipboard
    sudo pacman -S --noconfirm kitty
    sudo pacman -S --noconfirm xdg-desktop-portal-hyprland
    sudo pacman -S --noconfirm python-pip
    sudo pacman -S --noconfirm python-virtualenv
    sudo pacman -S --noconfirm tk
    sudo pacman -S --noconfirm noto-fonts
    sudo pacman -S --noconfirm noto-fonts-emoji
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    echo -e "[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    sudo pacman -Syy
    sudo pacman -S --noconfirm zen-browser-bin
}

configure_wifi
update_hostname
install_packages

#xremap, Bibata cursor theme

#Silent boot stuff
touch ~/.hushlogin
#edit /etc/systemd/system/getty.target.wants/getty@tty1.service file
#comment/remove the line "ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM"
#replace it with the line "ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin adeed --noclear %I $TERM"
