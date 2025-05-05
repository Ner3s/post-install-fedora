#!/bin/bash

codecs() {
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
    sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
    sudo dnf groupupdate sound-and-video -y
    sudo dnf install amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265 ffmpegthumbnailer -y
}

install_codecs() {
    whiptail --title "Instalando Codecs" --msgbox "Instalando codecs e pacotes multimídia..." 8 45
    codecs
    show_menu
}

# Auto installation version without prompts or menu return
install_codecs_auto() {
    log_info "Instalando codecs e pacotes multimídia automaticamente..."
    codecs
    log_success "Codecs instalados com sucesso!"
}
