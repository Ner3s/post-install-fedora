#!/bin/bash

# Função para instalar fontes
install_fonts() {
    whiptail --title "Instalando Fonts" --msgbox "Instalando fontes..." 8 45
    mkdir -p ~/.fonts
    cp fonts/*.ttf ~/.fonts/
    fc-cache -f -v
    show_menu
}
