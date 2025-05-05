#!/bin/bash

nvidia_cuda() {
    sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs -y
    sudo dnf install nvidia-vaapi-driver -y
}

install_nvidia_cuda() {
    whiptail --title "Instalando NVIDIA Driver e CUDA" --msgbox "Instalando drivers NVIDIA e CUDA..." 8 45
    nvidia_cuda
    show_menu
}

# Auto installation version without prompts or menu return
install_nvidia_cuda_auto() {
    log_info "Instalando drivers NVIDIA e CUDA automaticamente..."
    nvidia_cuda
    log_success "Drivers NVIDIA e CUDA instalados com sucesso!"
}
