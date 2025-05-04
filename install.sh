#!/bin/bash
if ! command -v whiptail &> /dev/null; then
    echo "O whiptail não está instalado. Instalando o pacote 'newt'..."
    sudo dnf install -y newt
fi

# Função para exibir o menu principal
show_menu() {
    whiptail --title "Script de Instalação" --menu "Escolha uma opção:" 15 60 7 \
        "1" "Instalar RPM Fusion" \
        "2" "Instalar Visual Studio Code" \
        "3" "Instalar Codecs" \
        "4" "Instalar Drivers NVIDIA e CUDA" \
        "5" "Instalar Aplicativos" \
        "6" "Instalar Ferramentas e Git" \
        "7" "Instalar Docker e Configuração" \
        "8" "Instalar NVM, Oh-my-zsh e Zinit" \
        "9" "Instalar Fonts" \
        "10" "Configurar Git" \
        "11" "Configurar chave ssh" \
        "12" "Instalar Tudo Automaticamente" \
        "13" "Sair" 2>/tmp/menuitem.txt

    menuitem=$(< /tmp/menuitem.txt)
    case $menuitem in
        1) install_rpmfusion ;;
        2) install_vscode ;;
        3) install_codecs ;;
        4) install_nvidia_cuda ;;
        5) install_apps ;;
        6) install_tools ;;
        7) install_docker ;;
        8) install_nvm_zsh_zinit ;;
        9) install_fonts ;;
        10) configure_git ;;
        11) create_ssh_key ;;
        12) install_all ;;
        13) exit 0 ;;
        *) whiptail --msgbox "Opção inválida" 8 45 ;;
    esac
}

move_ssh_keys() {
    SSH_FILENAME="$1"
    
    # Cria o diretório ~/.ssh se não existir
    [ ! -d $HOME/.ssh ] && mkdir -p $HOME/.ssh

    MOVED_FILES=""

    if [ -f "$SSH_FILENAME" ]; then
        mv "$SSH_FILENAME" $HOME/.ssh/
        MOVED_FILES="$MOVED_FILES\n$SSH_FILENAME -> ~/.ssh/"
    else
        whiptail --title "Arquivo Privado Não Encontrado" --msgbox "O arquivo $SSH_FILENAME não foi encontrado no diretório atual." 8 60
    fi

    if [ -f "$SSH_FILENAME.pub" ]; then
        mv "$SSH_FILENAME.pub" $HOME/.ssh/
        MOVED_FILES="$MOVED_FILES\n$SSH_FILENAME.pub -> ~/.ssh/"
    else
        whiptail --title "Arquivo Público Não Encontrado" --msgbox "O arquivo $SSH_FILENAME.pub não foi encontrado no diretório atual." 8 60
    fi

    if [ -n "$MOVED_FILES" ]; then
        whiptail --title "Arquivos SSH Movidos" --msgbox "Os seguintes arquivos foram movidos para ~/.ssh:$MOVED_FILES" 15 60
    else
        whiptail --title "Nenhuma Chave Encontrada" --msgbox "Nenhum arquivo relacionado a '$SSH_FILENAME' foi encontrado no diretório atual." 8 60
    fi
}

copy_ssh_to_clipboard() {
    SSH_KEY_PATH="$1"

    if command -v xclip &>/dev/null; then
        cat $SSH_KEY_PATH | xclip -selection clipboard
        whiptail --title "Chave SSH Copiada" --msgbox "A chave SSH foi copiada automaticamente para a área de transferência!\n\nCole diretamente no Github ." 10 60
    elif command -v wl-copy &>/dev/null; then
        cat $SSH_KEY_PATH | wl-copy
        whiptail --title "Chave SSH Copiada" --msgbox "A chave SSH foi copiada automaticamente para a área de transferência (Wayland)!\n\nCole diretamente no Github ." 10 60
    elif command -v xsel &>/dev/null; then
        cat $SSH_KEY_PATH | xsel --clipboard --input
        whiptail --title "Chave SSH Copiada" --msgbox "A chave SSH foi copiada automaticamente para a área de transferência!\n\nCole diretamente no Github ." 10 60
    else
        whiptail --title "Clipboard Não Encontrado" --msgbox "Não foi possível copiar automaticamente: nenhum utilitário de clipboard (xclip, wl-clipboard ou xsel) foi encontrado.\n\nPor favor, copie manualmente:\n\n$(cat "$SSH_KEY_PATH")" 15 70
    fi
}

#  SSH-key
create_ssh_key() {
    whiptail --title "Criando SSH Key" --msgbox "Criando chave SSH..." 8 45
    
    USER_EMAIL=$(whiptail --title "Criando SSH Key" --inputbox "Digite seu e-mail:" 8 45 --title "Git" 3>&1 1>&2 2>&3)
    ssh-keygen -t ed25519 -C "$USER_EMAIL"
    eval "$(ssh-agent -s)"
    
    SSH_FILENAME=$(whiptail --title "Criando SSH Key" --inputbox "Digite o nome do arquivo gerado: (sem .pub)" 8 45 --title "Git" 3>&1 1>&2 2>&3)
    move_ssh_keys "$SSH_FILENAME"

    ssh-add $HOME/.ssh/$SSH_FILENAME
    whiptail --title "Chave SSH Criada" --msgbox "Chave SSH criada e configurada com sucesso!" 8 45
    
    copy_ssh_to_clipboard "$HOME/.ssh/$SSH_FILENAME.pub"
    show_menu
}

# Função para instalar o RPM Fusion
install_rpmfusion() {
    whiptail --title "Instalando RPM Fusion" --msgbox "Instalando RPM Fusion..." 8 45
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf update --refresh
    show_menu
}

# Função para instalar o Visual Studio Code
install_vscode() {
    whiptail --title "Instalando Visual Studio Code" --msgbox "Instalando Visual Studio Code..." 8 45
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf install code -y
    show_menu
}

# Função para instalar Codecs
install_codecs() {
    whiptail --title "Instalando Codecs" --msgbox "Instalando codecs e pacotes multimídia..." 8 45
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
    sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
    sudo dnf groupupdate sound-and-video -y
    sudo dnf install amrnb amrwb faad2 flac gpac-libs lame libde265 libfc14audiodecoder mencoder x264 x265 ffmpegthumbnailer -y
    show_menu
}

# Função para instalar Drivers NVIDIA e CUDA
install_nvidia_cuda() {
    whiptail --title "Instalando NVIDIA Driver e CUDA" --msgbox "Instalando drivers NVIDIA e CUDA..." 8 45
    sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs -y
    sudo dnf install nvidia-vaapi-driver -y
    show_menu
}

# Função para instalar aplicativos
install_apps() {
    whiptail --title "Instalando Aplicativos" --msgbox "Instalando aplicativos..." 8 45
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf install google-chrome-stable -y
    sudo dnf remove fedora-chromium-config -y
    sudo dnf install flameshot peek gnome-tweaks steam gimp inkscape gnome-extensions-app htop -y
    sudo dnf install nvim -y
    flatpak install flathub com.discordapp.Discord -y
    flatpak install flathub com.github.tchx84.Flatseal -y
    flatpak install flathub com.obsproject.Studio -y
    flatpak install flathub io.github.jeffshee.Hidamari -y
    show_menu
}

# Função para instalar Ferramentas e Git
install_tools() {
    whiptail --title "Instalando Ferramentas e Git" --msgbox "Instalando Git e outras ferramentas..." 8 45
    sudo dnf install git zsh -y
    show_menu
}

# Função para instalar Docker e configuração
install_docker() {
    whiptail --title "Instalando Docker" --msgbox "Instalando Docker..." 8 45
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo systemctl start docker
    sudo chmod 666 /var/run/docker.sock
    show_menu
}

# Função para instalar NVM, Oh-my-zsh e Zinit
install_nvm_zsh_zinit() {
    whiptail --title "Instalando NVM, Oh-my-zsh e Zinit" --msgbox "Instalando NVM, Oh-my-zsh e Zinit..." 8 45
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    npm i -g yarn
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    echo "zinit ice depth=1; zinit light romkatv/powerlevel10k" >> ~/.zshrc
    echo "zinit light zdharma/fast-syntax-highlighting" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-completions" >> ~/.zshrc
    show_menu
}

# Função para instalar fontes
install_fonts() {
    whiptail --title "Instalando Fonts" --msgbox "Instalando fontes..." 8 45
    mkdir -p ~/.fonts
    cp fonts/*.ttf ~/.fonts/
    fc-cache -f -v
    show_menu
}

# Função para configurar o Git (pedir nome e email)
configure_git() {
    # Solicitar nome de usuário e e-mail para o Git
    USER_NAME=$(whiptail --title "Configuração Git" --inputbox "Digite seu nome de usuário do Git:" 8 45 --title "Git" 3>&1 1>&2 2>&3)
    USER_EMAIL=$(whiptail --title "Configuração Git" --inputbox "Digite seu e-mail do Git:" 8 45 --title "Git" 3>&1 1>&2 2>&3)

    # Definir o nome de usuário e e-mail do Git
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"

    # Configurações adicionais para Git
    git config --global init.defaultBranch "main"
    git config --global pull.ff "only"

    # Configurar aliases no Git
    git config --global alias.s "!git status -s"
    git config --global alias.c "!git add --all && git commit -m"
    git config --global alias.l "!git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
    git config --global alias.ls "!git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"

    whiptail --title "Git Configurado" --msgbox "Nome de usuário e e-mail do Git configurados!\nConfigurações adicionais aplicadas." 8 45
    show_menu
}

# Função para instalar tudo automaticamente, na ordem
install_all() {
    whiptail --title "Instalação Automática" --msgbox "Instalando tudo automaticamente..." 8 45

    # Instalar pacotes na ordem
    install_rpmfusion
    install_vscode
    install_codecs
    install_nvidia_cuda
    install_apps
    install_tools
    install_docker
    install_nvm_zsh_zinit
    install_fonts
    configure_git

    whiptail --title "Instalação Completa" --msgbox "Instalação concluída!" 8 45
    show_menu
}

# Executar o menu inicial
show_menu
