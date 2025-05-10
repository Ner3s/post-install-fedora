#!/bin/bash
rpmfusion() {
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo dnf update --refresh -y
}

install_rpmfusion() {
    [ "$SILENT_MODE" != true ] && whiptail --title "Instalando RPM Fusion" --msgbox "Instalando RPM Fusion..." 8 45
    log_info "Instalando RPM Fusion..."
    rpmfusion
    log_success "RPM Fusion instalado com sucesso!"
    [ "$SHOW_MENU" = true ] && show_menu || return
}