#!/bin/bash

# Função para instalar o RPM Fusion
install_rpmfusion() {
    whiptail --title "Instalando RPM Fusion" --msgbox "Instalando RPM Fusion..." 8 45
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$\(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$\(rpm -E %fedora).noarch.rpm
    sudo dnf update --refresh
    show_menu
}
