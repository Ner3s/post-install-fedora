#!/bin/bash

make_backup() {
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Backup de Extensões GNOME" --msgbox "Iniciando backup das extensões GNOME..." 8 60
    fi
    
    OUTPUT_DIR="$PROJECT_DIR/backups/gnome-extensions"
    mkdir -p "$OUTPUT_DIR"

    ACTIVE_EXTENSIONS_FILE="$OUTPUT_DIR/active-extensions.list"

    log_info "Exportando lista de extensões ativas..."

    gsettings get org.gnome.shell enabled-extensions > "$ACTIVE_EXTENSIONS_FILE"

    log_info "Lista de extensões ativas salva em $ACTIVE_EXTENSIONS_FILE"
    log_info "Exportando configurações individuais das extensões..."

    EXTENSIONS_DIR="/org/gnome/shell/extensions"

    dconf list "$EXTENSIONS_DIR/" | while read -r extension; do
        EXTENSION_NAME="${extension%/}"
        CONFIG_FILE="$OUTPUT_DIR/${EXTENSION_NAME}.conf"
        log_info "Exportando $EXTENSION_NAME para $CONFIG_FILE"
        dconf dump "$EXTENSIONS_DIR/$EXTENSION_NAME/" > "$CONFIG_FILE"
    done

    log_success "Backup completo das extensões GNOME salvo em $OUTPUT_DIR"
    
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Backup Concluído" --msgbox "Backup das extensões GNOME foi salvo em:\n$OUTPUT_DIR" 10 60
    fi
    
    # Return to submenu if not in automatic mode
    [ "$SHOW_MENU" = true ] && return
}

restore_backup() {
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Restaurar Extensões GNOME" --msgbox "Iniciando restauração das extensões GNOME..." 8 60
    fi
    
    BACKUP_DIR="$PROJECT_DIR/backups/gnome-extensions"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        if [ "$SILENT_MODE" != true ]; then
            whiptail --title "Erro" --msgbox "Diretório de backup não encontrado:\n$BACKUP_DIR\n\nFaça um backup primeiro." 10 60
        fi
        log_error "Diretório de backup não encontrado: $BACKUP_DIR"
        [ "$SHOW_MENU" = true ] && return
        return 1
    fi
    
    log_info "Verificando se o gnome-extensions-app está instalado..."
    if ! rpm -q gnome-extensions-app &> /dev/null; then
        log_info "Instalando gnome-extensions-app..."
        sudo dnf install -y gnome-extensions-app
        log_success "gnome-extensions-app instalado com sucesso!"
    else
        log_info "gnome-extensions-app já está instalado."
    fi

    if ! command -v gnome-shell-extension-installer &> /dev/null; then
        log_info "Instalando gnome-shell-extension-installer..."
        # Use the existing extension installer in the externals directory
        chmod +x "$PROJECT_DIR/lib/externals/gnome-shell-extension-installer"
        sudo cp "$PROJECT_DIR/lib/externals/gnome-shell-extension-installer" /usr/bin/
        log_success "gnome-shell-extension-installer instalado com sucesso!"
    else
        log_info "gnome-shell-extension-installer já está instalado."
    fi
    
    ACTIVE_EXTENSIONS_FILE="$BACKUP_DIR/active-extensions.list"
    if [ ! -f "$ACTIVE_EXTENSIONS_FILE" ]; then
        if [ "$SILENT_MODE" != true ]; then
            whiptail --title "Erro" --msgbox "Arquivo de extensões ativas não encontrado:\n$ACTIVE_EXTENSIONS_FILE" 10 60
        fi
        log_error "Arquivo de extensões ativas não encontrado: $ACTIVE_EXTENSIONS_FILE"
        [ "$SHOW_MENU" = true ] && return
        return 1
    fi
    
    GNOME_SHELL_VERSION=$(gnome-shell --version | awk '{print $3}')
    log_info "Versão do GNOME Shell: $GNOME_SHELL_VERSION"
    
    log_info "Instalando extensões do GNOME..."

    cat "$ACTIVE_EXTENSIONS_FILE" | tr -d "[]' " | tr ',' '\n' | while read -r extension_id; do
        if [ -n "$extension_id" ]; then
            log_info "Instalando extensão: $extension_id"

            extension_numeric_id=$(echo "$extension_id" | grep -oP '^\d+' || echo "")
            
            if [ -n "$extension_numeric_id" ]; then
                gnome-shell-extension-installer "$extension_numeric_id" --yes --version="$GNOME_SHELL_VERSION"
            else
                log_warning "Não foi possível obter ID numérico para $extension_id. Tentando instalar pelo nome..."
                gnome-shell-extension-installer "$extension_id" --yes --version="$GNOME_SHELL_VERSION"
            fi
        fi
    done

    log_info "Restaurando lista de extensões ativas..."
    EXTENSIONS=$(cat "$ACTIVE_EXTENSIONS_FILE")
    gsettings set org.gnome.shell enabled-extensions "$EXTENSIONS"
    
    log_info "Restaurando configurações individuais das extensões..."
    EXTENSIONS_DIR="/org/gnome/shell/extensions"
    
    # Find all configuration files
    for config_file in "$BACKUP_DIR"/*.conf; do
        if [ -f "$config_file" ]; then
            # Extract extension name from filename
            EXTENSION_NAME=$(basename "$config_file" .conf)
            log_info "Restaurando configurações para $EXTENSION_NAME"
            
            # Import configuration from file to dconf
            dconf load "$EXTENSIONS_DIR/$EXTENSION_NAME/" < "$config_file"
        fi
    done
    
    log_success "Restauração das extensões GNOME concluída"
    
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Restauração Concluída" --msgbox "As extensões GNOME foram instaladas e configurações restauradas.\n\nPode ser necessário reiniciar o GNOME Shell (Alt+F2, r, Enter)." 10 70
    fi
    
    [ "$SHOW_MENU" = true ] && return
}

install_gnome_extensions_installer() {
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Instalando GNOME Extensions Installer" --msgbox "Instalando gnome-shell-extensions-installer..." 8 60
    fi
    
    log_info "Instalando gnome-shell-extensions-installer..."
    
    if ! command -v gnome-shell-extension-installer &> /dev/null; then
        chmod +x "$PROJECT_DIR/lib/externals/gnome-shell-extension-installer"
        sudo cp "$PROJECT_DIR/lib/externals/gnome-shell-extension-installer" /usr/bin/
        log_success "gnome-shell-extensions-installer instalado com sucesso!"
    else
        log_info "gnome-shell-extension-installer já está instalado."
        whiptail --title "Instalação Concluída" --msgbox "gnome-shell-extension-installer já está instalado." 8 60
        return
    fi
    
    if [ "$SILENT_MODE" != true ]; then
        whiptail --title "Instalação Concluída" --msgbox "gnome-shell-extensions-installer instalado com sucesso!" 8 60
    fi
    
    [ "$SHOW_MENU" = true ] && return
}

manage_gnome_extensions() {
    while true; do
        whiptail --title "Gerenciar extensões GNOME" --menu "Escolha uma opção:" 15 60 2 \
            "0" "Instalar gnome-shell-extensions-installer" \
            "1" "Fazer backup das extensões GNOME" \
            "2" "Restaurar backup das extensões GNOME" \
            "3" "Voltar ao menu principal" 2>/tmp/menuchoice.txt
        
        # Check if the user pressed Cancel or Esc
        if [ $? -ne 0 ]; then
            echo "Menu cancelled."
            return
        fi
        
        menuchoice=$(< /tmp/menuchoice.txt)
        case $menuchoice in
            0) install_gnome_extensions_installer ;;
            1) make_backup ;;
            2) restore_backup ;;
            3) return ;;
            *) whiptail --msgbox "Opção inválida" 8 45 ;;
        esac
    done
}