#!/bin/bash

# Função para instalar Drivers NVIDIA e CUDA
install_nvidia_cuda() {
    whiptail --title "Instalando NVIDIA Driver e CUDA" --msgbox "Instalando drivers NVIDIA e CUDA..." 8 45
    sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs -y
    sudo dnf install nvidia-vaapi-driver -y
    show_menu
}
