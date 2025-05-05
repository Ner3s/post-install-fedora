#!/bin/bash
rpmfusion() {
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo dnf update --refresh -y
}

install_rpmfusion() {
    whiptail --title "Instalando RPM Fusion" --msgbox "Instalando RPM Fusion..." 8 45
    rpmfusion
    show_menu
}

# Auto installation version without prompts or menu return
install_rpmfusion_auto() {
    log_info "Instalando RPM Fusion automaticamente..."
    rpmfusion
    log_success "RPM Fusion instalado com sucesso!"
}
