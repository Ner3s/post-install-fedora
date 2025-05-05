#!/bin/bash

install_tools() {
    whiptail --title "Instalando Ferramentas e Git" --msgbox "Instalando Git e outras ferramentas..." 8 45
    sudo dnf install git zsh -y
    show_menu
}
