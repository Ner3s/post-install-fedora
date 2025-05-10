#!/bin/bash

install_apps() {
    # Define all available applications with descriptions
    apps=(
        "flameshot" "Screenshot tool" "on"
        "peek" "GIF screen recorder" "on"
        "gnome-tweaks" "GNOME desktop customization tool" "on"
        "gnome-extensions-app" "GNOME Extensions manager" "on"
        "gimp" "Image editor" "on"
        "inkscape" "Vector graphics editor" "on"
        "steam" "Gaming platform" "on"
        "discord" "Discord chat app (Flatpak)" "on"
        "htop" "System monitor tool" "on"
        "fastfetch" "Fast system information fetcher" "on"
        "nvim" "Neovim text editor" "on"
        "obs-studio" "Streaming and recording tool" "on"
        "google-chrome" "Google Chrome web browser" "on"
        "brave" "Web browser" "on"
        "vscode" "Visual Studio Code editor" "on"
        "flatseal" "Flatpak permissions manager" "on"
        "hidamari" "Live wallpaper app" "on"
        "dbeaver" "Multi-plataform database tool" "on"
    )
    
    # First ask if the user wants to select all applications
    if whiptail --title "Seleção de Aplicativos" --yesno "Deseja selecionar todos os aplicativos?\n\n(Você pode personalizar a seleção na próxima tela)" 10 65; then
        select_all="yes"
    else
        select_all="no"
    fi
    
    # Create temporary file for whiptail output
    temp_file=$(mktemp)
    
    # Extract app names for later use
    app_names=()
    for ((i=0; i<${#apps[@]}; i+=3)); do
        app_names+=("${apps[i]}")
    done
    
    # Set all items to on
    if [ "$select_all" = "yes" ]; then
        for ((i=2; i<${#apps[@]}; i+=3)); do
            apps[i]="on"
        done
    else
        # Set all items to off
        for ((i=2; i<${#apps[@]}; i+=3)); do
            apps[i]="off"
        done
    fi
    
    # Show selection dialog with checklist
    whiptail --title "Selecionar Aplicativos" \
             --checklist "Use ESPAÇO para selecionar/desmarcar aplicativos, ENTER para confirmar:" \
             20 78 15 \
             "${apps[@]}" 2>"$temp_file"
    
    # Check if the user pressed Cancel or Esc
    if [ $? -ne 0 ]; then
        echo "Seleção cancelada."
        rm -f "$temp_file"
        [ "$SHOW_MENU" = true ] && show_menu || return
        return
    fi
    
    # Read selected options
    selected_apps=$(cat "$temp_file")
    rm -f "$temp_file"
    
    # If nothing was selected, return to menu
    if [ -z "$selected_apps" ]; then
        whiptail --title "Nenhuma seleção" --msgbox "Nenhum aplicativo foi selecionado." 8 45
        [ "$SHOW_MENU" = true ] && show_menu || return
        return
    fi
    
    # Install RPM repositories
    whiptail --title "Instalando Repositórios" --msgbox "Configurando repositórios necessários..." 8 45
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
    
    # Process selected applications
    for app in $selected_apps; do
        # Remove quotes from app name
        app=$(echo $app | tr -d '"')
        
        case "$app" in
            "google-chrome")
                whiptail --title "Instalando Google Chrome" --infobox "Instalando Google Chrome..." 8 45
                sudo dnf config-manager setopt google-chrome.enabled=1 -y
                sudo dnf install google-chrome-stable -y
                ;;
            "brave")
                whiptail --title "Instalando Brave" --infobox "Instalando Brave..." 8 45
                sudo dnf install dnf-plugins-core -y
                sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
                sudo dnf install brave-browser -y
                ;;
            "vscode")
                whiptail --title "Instalando Visual Studio Code" --infobox "Instalando Visual Studio Code..." 8 45
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
                sudo dnf install code -y
                ;;
            "flatseal")
                whiptail --title "Instalando Flatseal" --infobox "Instalando Flatseal via Flatpak..." 8 45
                flatpak install flathub com.github.tchx84.Flatseal -y
                ;;
            "hidamari")
                whiptail --title "Instalando Hidamari" --infobox "Instalando Hidamari via Flatpak..." 8 45
                flatpak install flathub io.github.jeffshee.Hidamari -y
                ;;
            "dbeaver")
                whiptail --title "Instalando Hidamari" --infobox "Instalando DBeaver Community via Flatpak..." 8 45
                flatpak install flathub io.dbeaver.DBeaverCommunity -y
                ;;
            *)
                # Install regular DNF packages
                whiptail --title "Instalando $app" --infobox "Instalando $app..." 8 45
                sudo dnf install "$app" -y
                ;;
        esac
    done
    
    whiptail --title "Instalação Concluída" --msgbox "Aplicativos selecionados foram instalados com sucesso!" 8 60
    [ "$SHOW_MENU" = true ] && show_menu || return
}

# Auto installation version without prompts or menu return
install_apps_auto() {
    log_info "Instalando todos os aplicativos automaticamente..."
    
    # Install RPM repositories
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
    
    # Install Google Chrome
    log_info "Instalando Google Chrome..."
    sudo dnf config-manager setopt google-chrome.enabled=1 -y

    # Install Brave browser
    log_info "Instalando Brave browser..."
    sudo dnf install dnf-plugins-core -y
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    
     # Install VS Code
    log_info "Instalando Visual Studio Code..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    # Install regular DNF packages
    log_info "Instalando pacotes DNF padrão..."
    sudo dnf install flameshot peek gnome-tweaks steam gimp inkscape gnome-extensions-app htop nvim fastfetch discord obs-studio google-chrome-stable brave-browser code -y
    
    # Install Flatpak applications
    log_info "Instalando aplicativos Flatpak..."
    flatpak install flathub com.github.tchx84.Flatseal -y
    flatpak install flathub io.github.jeffshee.Hidamari -y
    
    log_success "Todos os aplicativos instalados com sucesso!"
}
