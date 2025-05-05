#!/bin/bash

# Função para instalar Docker e configuração
install_docker() {
    whiptail --title "Instalando Docker" --msgbox "Instalando Docker..." 8 45
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo systemctl start docker
    sudo chmod 666 /var/run/docker.sock
    show_menu
}
