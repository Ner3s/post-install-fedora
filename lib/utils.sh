#!/bin/bash

show_menu() {
    while true; do
        whiptail --title "$SCRIPT_NAME" --menu "Escolha uma opção:" 20 70 14 \
            "1" "Instalar RPM Fusion" \
            "2" "Instalar Codecs" \
            "3" "Instalar Drivers NVIDIA e CUDA" \
            "4" "Instalar Aplicativos" \
            "5" "Instalar Ferramentas e Git" \
            "6" "Instalar Docker e Configuração" \
            "7" "Instalar NVM, Oh-my-zsh e Zinit" \
            "8" "Instalar Fonts" \
            "9" "Configurar Git" \
            "10" "Configurar chave SSH" \
            "11" "Instalar Tudo Automaticamente" \
            "12" "Verificar Atualizações" \
            "13" "Sair" 2>/tmp/menuitem.txt
        
        # Check if the user pressed Cancel or Esc
        if [ $? -ne 0 ]; then
            echo "Menu cancelled."
            exit 0
        fi
        
        menuitem=$(< /tmp/menuitem.txt)
        case $menuitem in
            1) install_rpmfusion ;;
            2) install_codecs ;;
            3) install_nvidia_cuda ;;
            4) install_apps ;;
            5) install_tools ;;
            6) install_docker ;;
            7) install_nvm_zsh_zinit ;;
            8) install_fonts ;;
            9) configure_git ;;
            10) create_ssh_key ;;
            11) install_all ;;
            12) check_for_updates ;;
            13) 
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
    
    log_info "Verificando atualizações do script..."
    
    # Get current directory
    local current_dir="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
    
    # Save current branch and stash any changes
    cd "$current_dir" || return
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    git stash &>/dev/null
    
    # Fetch latest changes
    if git fetch origin $current_branch &>/dev/null; then
        # Check if there are updates available
        local updates_available=$(git rev-list HEAD..origin/$current_branch --count 2>/dev/null)
        
        if [ "$updates_available" -gt 0 ]; then
            if whiptail --title "Atualização Disponível" --yesno "Existem atualizações disponíveis.\n\nDeseja atualizar o $SCRIPT_NAME?" 10 60; then
                log_info "Atualizando o script..."
                
                # Pull changes
                if git pull origin $current_branch &>/dev/null; then
                    # Get new version after update
                    source "$current_dir/lib/constants.sh"
                    
                    log_success "Atualização concluída para a versão $SCRIPT_VERSION. Reiniciando o script..."
                    whiptail --title "Atualização Concluída" --msgbox "Atualização para a versão $SCRIPT_VERSION concluída. O script será reiniciado." 8 60
                    
                    # Apply any stashed changes
                    git stash pop &>/dev/null
                    
                    # Restart script
                    exec "$current_dir/install.sh"
                else
                    log_error "Falha ao atualizar o script."
                    whiptail --title "Erro na Atualização" --msgbox "Não foi possível atualizar o script. Tente novamente mais tarde." 8 60
                    # Apply any stashed changes
                    git stash pop &>/dev/null
                fi
            else
                # Apply any stashed changes if user declines update
                git stash pop &>/dev/null
            fi
        else
            whiptail --title "Nenhuma Atualização" --msgbox "Você já está executando a versão mais recente ($SCRIPT_VERSION)!" 8 60
            # Apply any stashed changes
            git stash pop &>/dev/null
        fi
    else
        whiptail --title "Erro na Verificação" --msgbox "Não foi possível verificar atualizações. Verifique sua conexão com a internet." 8 60
    fi
}
