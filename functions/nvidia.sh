#!/bin/bash

nvidia_cuda() {
    sudo dnf install akmod-nvidia -y
}

install_nvidia_cuda() {
    if [ "$SILENT_MODE" != true ]; then  
        whiptail --title "Instalando NVIDIA Driver e CUDA" --msgbox "Instalando drivers NVIDIA e CUDA..." 8 45
    fi
    log_info "Instalando drivers NVIDIA e CUDA..."
    nvidia_cuda
    log_success "Drivers NVIDIA e CUDA instalados com sucesso!"
    [ "$SHOW_MENU" = true ] && show_menu || return
}
