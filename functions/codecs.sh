#!/bin/bash

codecs() {
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
    sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
    sudo dnf groupupdate sound-and-video -y
    sudo dnf install amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265 ffmpegthumbnailer -y
}

install_codecs() {
    [ "$SILENT_MODE" != true ] && whiptail --title "Instalando Codecs" --msgbox "Instalando codecs e pacotes multimídia..." 8 45
    log_info "Instalando codecs e pacotes multimídia..."
    codecs
    log_success "Codecs instalados com sucesso!"
    [ "$SHOW_MENU" = true ] && show_menu || return
}