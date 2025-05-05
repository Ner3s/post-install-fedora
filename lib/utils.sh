#!/bin/bash

# Função para exibir o menu principal
show_menu() {
    whiptail --title "Script de Instalação" --menu "Escolha uma opção:" 15 60 7 \
        "1" "Instalar RPM Fusion" \
        "2" "Instalar Visual Studio Code" \
        "3" "Instalar Codecs" \
        "4" "Instalar Drivers NVIDIA e CUDA" \
        "5" "Instalar Aplicativos" \
        "6" "Instalar Ferramentas e Git" \
        "7" "Instalar Docker e Configuração" \
        "8" "Instalar NVM, Oh-my-zsh e Zinit" \
        "9" "Instalar Fonts" \
        "10" "Configurar Git" \
        "11" "Configurar chave ssh" \
        "12" "Instalar Tudo Automaticamente" \
        "13" "Sair" 2>/tmp/menuitem.txt

    menuitem=$(< /tmp/menuitem.txt)
    case $menuitem in
        1) install_rpmfusion ;;
        2) install_vscode ;;
        3) install_codecs ;;
        4) install_nvidia_cuda ;;
        5) install_apps ;;
        6) install_tools ;;
        7) install_docker ;;
        8) install_nvm_zsh_zinit ;;
        9) install_fonts ;;
        10) configure_git ;;
        11) create_ssh_key ;;
        12) install_all ;;
        13) exit 0 ;;
        *) whiptail --msgbox "Opção inválida" 8 45 ;;
    esac
}

# Função para instalar tudo automaticamente, na ordem
install_all() {
    whiptail --title "Instalação Automática" --msgbox "Instalando tudo automaticamente..." 8 45

    # Instalar pacotes na ordem
    install_rpmfusion
    install_vscode
    install_codecs
    install_nvidia_cuda
    install_apps
    install_tools
    install_docker
    install_nvm_zsh_zinit
    install_fonts
    configure_git

    whiptail --title "Instalação Completa" --msgbox "Instalação concluída!" 8 45
    show_menu
}
