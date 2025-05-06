#!/bin/bash

show_menu() {
    while true; do
        whiptail --title "$SCRIPT_NAME" --menu "Escolha uma opção:" 20 70 14 \
            "1" "Instalar RPM Fusion" \
            "2" "Instalar Codecs" \
            "3" "Instalar Drivers NVIDIA e CUDA" \
            "4" "Instalar Aplicativos" \
            "5" "Instalar Ferramentas de Desenvolvimento" \
            "6" "Instalar Fonts" \
            "7" "Configurar Git" \
            "8" "Configurar chave SSH" \
            "9" "Gerenciar Extensões GNOME" \
            "10" "Instalar Tudo Automaticamente" \
            "11" "Verificar Atualizações" \
            "12" "Sair" 2>/tmp/menuitem.txt
        
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
            5) install_dev_tools ;;
            6) install_fonts ;;
            7) configure_git ;;
            8) create_ssh_key ;;
            9) manage_gnome_extensions ;;
            10) install_all ;;
            11) check_for_updates ;;
            12) 
                whiptail --title "Saindo" --msgbox "Obrigado por usar o $SCRIPT_NAME!" 8 45
                exit 0 
                ;;
            *) whiptail --msgbox "Opção inválida" 8 45 ;;
        esac
    done
}

# Função para instalar tudo automaticamente, na ordem
install_all() {
    # Ask user if they want silent mode or normal mode
    if whiptail --title "Modo de Instalação" --yesno "Escolha o modo de instalação:\n\nSelecione 'Sim' para modo silencioso (instalação automática sem prompts)\nSelecione 'Não' para modo normal (configurar cada componente)" 12 78; then
        # User chose silent mode
        log_info "Iniciando instalação automática em modo silencioso"
        
        # Set flag to indicate we're in automatic installation mode
        export SILENT_MODE=true
        export SHOW_MENU=false
        
        # Display message about automated installation
        whiptail --title "Instalação Silenciosa" --msgbox "Instalando tudo automaticamente sem prompts..." 8 60
        
        # Install everything in order using the auto functions
        install_rpmfusion
        install_codecs
        install_nvidia_cuda
        install_apps_auto
        install_dev_tools_auto
        install_fonts
        configure_git
        
        # reset flags
        unset SILENT_MODE
        unset SHOW_MENU
        
        log_success "Instalação silenciosa concluída com sucesso!"
        whiptail --title "Instalação Completa" --msgbox "Instalação silenciosa concluída!" 8 45
    else
        # User chose normal mode - install everything with user intervention
        log_info "Iniciando instalação em modo normal com configuração individual"
        export SHOW_MENU=false
        
        whiptail --title "Instalação Normal" --msgbox "Você selecionou o modo normal. Cada componente solicitará configurações." 8 60
        
        install_rpmfusion
        install_codecs
        install_nvidia_cuda
        install_apps
        install_dev_tools
        install_fonts
        configure_git
        create_ssh_key
        
        log_success "Instalação normal concluída com sucesso!"
        whiptail --title "Instalação Completa" --msgbox "Instalação normal concluída!" 8 45

        unset SHOW_MENU
    fi
    show_menu
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
