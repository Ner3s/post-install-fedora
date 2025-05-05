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
            "9" "Instalar Tudo Automaticamente" \
            "10" "Verificar Atualizações" \
            "11" "Sair" 2>/tmp/menuitem.txt
        
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
            9) install_all ;;
            10) check_for_updates ;;
            11) 
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
        export AUTO_INSTALL=true
        
        # Display message about automated installation
        whiptail --title "Instalação Silenciosa" --msgbox "Instalando tudo automaticamente sem prompts..." 8 60
        
        # Install everything in order using the auto functions
        install_rpmfusion_auto
        install_codecs_auto
        install_nvidia_cuda_auto
        install_apps_auto
        install_dev_tools_auto
        install_fonts_auto
        configure_git_auto
        
        # Unset auto install flag
        unset AUTO_INSTALL
        
        log_success "Instalação silenciosa concluída com sucesso!"
        whiptail --title "Instalação Completa" --msgbox "Instalação silenciosa concluída!" 8 45
    else
        # User chose normal mode - install everything with user intervention
        log_info "Iniciando instalação em modo normal com configuração individual"
        
        whiptail --title "Instalação Normal" --msgbox "Você selecionou o modo normal. Cada componente solicitará configurações." 8 60
        
        # Install components one by one with normal interactive functions
        whiptail --title "RPM Fusion" --msgbox "Primeira etapa: Instalação do RPM Fusion.\nPressione Enter para continuar." 8 60
        install_rpmfusion
        
        whiptail --title "Codecs" --msgbox "Próxima etapa: Instalação de Codecs.\nPressione Enter para continuar." 8 60
        install_codecs
        
        whiptail --title "NVIDIA e CUDA" --msgbox "Próxima etapa: Instalação de drivers NVIDIA e CUDA (se aplicável).\nPressione Enter para continuar." 8 60
        install_nvidia_cuda
        
        whiptail --title "Aplicativos" --msgbox "Próxima etapa: Instalação de Aplicativos.\nPressione Enter para continuar." 8 60
        install_apps
        
        whiptail --title "Ferramentas de Desenvolvimento" --msgbox "Próxima etapa: Instalação de Ferramentas de Desenvolvimento.\nPressione Enter para continuar." 8 60
        install_dev_tools
        
        whiptail --title "Fontes" --msgbox "Próxima etapa: Instalação de Fontes.\nPressione Enter para continuar." 8 60
        install_fonts
        
        whiptail --title "Git" --msgbox "Próxima etapa: Configuração do Git.\nPressione Enter para continuar." 8 60
        configure_git
        
        whiptail --title "SSH" --msgbox "Etapa final: Criação de chave SSH (opcional).\nPressione Enter para continuar." 8 60
        create_ssh_key
        
        log_success "Instalação normal concluída com sucesso!"
        whiptail --title "Instalação Completa" --msgbox "Instalação normal concluída!" 8 45
    fi
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
