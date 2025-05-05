#!/bin/bash

# Função para exibir o menu principal
show_menu() {
    while true; do
        whiptail --title "$SCRIPT_NAME" --menu "Escolha uma opção:" 20 70 14 \
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
            "11" "Configurar chave SSH" \
            "12" "Instalar Tudo Automaticamente" \
            "13" "Verificar Atualizações" \
            "14" "Sair" 2>/tmp/menuitem.txt
        
        # Check if the user pressed Cancel or Esc
        if [ $? -ne 0 ]; then
            echo "Menu cancelled."
            exit 0
        fi
        
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
            13) check_for_updates ;;
            14) 
                whiptail --title "Saindo" --msgbox "Obrigado por usar o $SCRIPT_NAME!" 8 45
                exit 0 
                ;;
            *) whiptail --msgbox "Opção inválida" 8 45 ;;
        esac
    done
}

# Função para instalar tudo automaticamente, na ordem
install_all() {
    whiptail --title "Instalação Automática" --msgbox "Instalando tudo automaticamente..." 8 45

    log_info "Iniciando instalação automática de todos os componentes"
    
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

    log_success "Instalação automática concluída com sucesso!"
    whiptail --title "Instalação Completa" --msgbox "Instalação concluída!" 8 45
}

# Function to check for updates
check_for_updates() {
    whiptail --title "Verificando Atualizações" --msgbox "Verificando atualizações..." 8 45
    
    # Create a temporary directory
    local temp_dir=$(mktemp -d)
    log_info "Verificando atualizações do script..."
    
    # Download the repository's main branch to check for updates
    if git clone --depth=1 https://github.com/${GITHUB_REPO}.git "$temp_dir" &>/dev/null; then
        # Compare versions
        if [ -f "$temp_dir/lib/constants.sh" ]; then
            local remote_version=$(grep "SCRIPT_VERSION=" "$temp_dir/lib/constants.sh" | cut -d'"' -f2)
            
            if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
                if whiptail --title "Atualização Disponível" --yesno "Uma nova versão está disponível: $remote_version\nVersão atual: $SCRIPT_VERSION\n\nDeseja atualizar?" 12 60; then
                    log_info "Atualizando para a versão $remote_version..."
                    
                    # Copy all files from temp dir to current dir
                    cp -rf "$temp_dir"/* "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
                    
                    log_success "Atualização concluída. Reiniciando o script..."
                    whiptail --title "Atualização Concluída" --msgbox "Atualização para a versão $remote_version concluída. O script será reiniciado." 8 60
                    
                    # Clean up and restart script
                    rm -rf "$temp_dir"
                    exec "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/install.sh"
                fi
            else
                whiptail --title "Nenhuma Atualização" --msgbox "Você já está executando a versão mais recente ($SCRIPT_VERSION)!" 8 60
            fi
        else
            whiptail --title "Erro na Verificação" --msgbox "Não foi possível determinar a versão mais recente." 8 60
        fi
    else
        whiptail --title "Erro na Verificação" --msgbox "Não foi possível verificar atualizações. Verifique sua conexão com a internet." 8 60
    fi
    
    # Clean up
    rm -rf "$temp_dir"
}
