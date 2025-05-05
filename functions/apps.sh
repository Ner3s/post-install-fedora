#!/bin/bash

# Função para instalar aplicativos
install_apps() {
    whiptail --title "Instalando Aplicativos" --msgbox "Instalando aplicativos..." 8 45
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf install google-chrome-stable -y
    sudo dnf remove fedora-chromium-config -y
    sudo dnf install flameshot peek gnome-tweaks steam gimp inkscape gnome-extensions-app htop -y
    sudo dnf install nvim -y
    flatpak install flathub com.discordapp.Discord -y
    flatpak install flathub com.github.tchx84.Flatseal -y
    flatpak install flathub com.obsproject.Studio -y
    flatpak install flathub io.github.jeffshee.Hidamari -y
    show_menu
}
