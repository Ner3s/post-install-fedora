#!/bin/bash

fonts() {
    # Create user fonts directory
    mkdir -p ~/.fonts
    
    # Check if local fonts directory exists
    local script_dir="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
    local fonts_dir="${script_dir}/fonts"
    local font_installed=false
    
    # First try to copy from local fonts directory
    if [ -d "$fonts_dir" ] && [ "$(ls -A "$fonts_dir" 2>/dev/null)" ]; then
        cp "$fonts_dir"/*.ttf ~/.fonts/ 2>/dev/null
        font_installed=true
    else
        # If local fonts directory is missing or empty, download fonts from the internet
        whiptail --title "Baixando Fontes" --msgbox "A pasta de fontes local não foi encontrada. Baixando fontes da internet..." 8 60
        
        # Ensure we have the constants loaded
        source "${script_dir}/lib/constants.sh"
        source "${script_dir}/lib/common.sh"
        
        # Create a temporary fonts directory
        local temp_fonts_dir="${script_dir}/temp_fonts"
        mkdir -p "$temp_fonts_dir"
        
        # Download each font
        for font_info in "${FONT_RESOURCES[@]}"; do
            IFS=":" read -r font_name font_url <<< "$font_info"
            download_resource "$font_url" "${temp_fonts_dir}/${font_name}" "font $font_name"
            cp "${temp_fonts_dir}/${font_name}" ~/.fonts/ 2>/dev/null
            font_installed=true
        done
        
        # Clean up temporary directory
        rm -rf "$temp_fonts_dir"
    fi
    
    # Update font cache if any font was installed
    if [ "$font_installed" = true ]; then
        fc-cache -f -v
    fi
}

install_fonts() {
    [ "$SILENT_MODE" != true ] && whiptail --title "Instalando Fonts" --msgbox "Instalando fontes..." 8 45
    log_info "Instalando fontes..."
    fonts
    log_success "As fontes foram instaladas com sucesso!"
    [ "$SILENT_MODE" != true ] && whiptail --title "Fontes Instaladas" --msgbox "As fontes foram instaladas com sucesso!" 8 45
    [ "$SHOW_MENU" = true ] && show_menu ||return
}