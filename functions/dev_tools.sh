#!/bin/bash

install_dev_tools() {
    # Define all available development tools with descriptions
    tools=(
        "zsh" "Z shell (improved bash)" "on"
        "docker" "Container platform" "on"
        "go" "Go programming language" "on"
        "node" "Node.js via NVM" "on"
        "rust" "Rust programming language" "on"
    )
    
    # First ask if the user wants to select all tools
    if whiptail --title "Seleção de Ferramentas de Desenvolvimento" --yesno "Deseja selecionar todas as ferramentas de desenvolvimento?\n\n(Você pode personalizar a seleção na próxima tela)" 10 75; then
        select_all="yes"
    else
        select_all="no"
    fi
    
    # Create temporary file for whiptail output
    temp_file=$(mktemp)
    
    # Extract tool names for later use
    tool_names=()
    for ((i=0; i<${#tools[@]}; i+=3)); do
        tool_names+=("${tools[i]}")
    done
    
    # Set all items to on or off based on select_all
    if [ "$select_all" = "yes" ]; then
        for ((i=2; i<${#tools[@]}; i+=3)); do
            tools[i]="on"
        done
    fi
    
    # Show selection dialog with checklist
    whiptail --title "Selecionar Ferramentas de Desenvolvimento" \
             --checklist "Use ESPAÇO para selecionar/desmarcar ferramentas, ENTER para confirmar:" \
             20 78 15 \
             "${tools[@]}" 2>"$temp_file"
    
    # Check if the user pressed Cancel or Esc
    if [ $? -ne 0 ]; then
        echo "Seleção cancelada."
        rm -f "$temp_file"
        show_menu
        return
    fi
    
    # Read selected options
    selected_tools=$(cat "$temp_file")
    rm -f "$temp_file"
    
    # If nothing was selected, return to menu
    if [ -z "$selected_tools" ]; then
        whiptail --title "Nenhuma seleção" --msgbox "Nenhuma ferramenta foi selecionada." 8 45
        show_menu
        return
    fi
    
    # Process selected tools
    for tool in $selected_tools; do
        # Remove quotes from tool name
        tool=$(echo $tool | tr -d '"')
        
        case "$tool" in
            "zsh")
                install_zsh
                ;;
            "docker")
                install_docker_tools
                ;;
            "go")
                install_go
                ;;
            "node")
                install_node
                ;;
            "rust")
                install_rust
                ;;
        esac
    done
    
    whiptail --title "Instalação Concluída" --msgbox "Ferramentas de desenvolvimento selecionadas foram instaladas com sucesso!" 8 60
    show_menu
}

# Auto installation version without prompts or menu return
install_dev_tools_auto() {
    log_info "Instalando todas as ferramentas de desenvolvimento automaticamente..."
    
    # Install Zsh and Oh-My-Zsh
    log_info "Instalando Zsh e Oh-My-Zsh..."
    sudo dnf install zsh -y
    
    # Install Oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    
    # Install Zinit
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    
    # Add plugins to zshrc
    echo "zinit ice depth=1; zinit light romkatv/powerlevel10k" >> ~/.zshrc
    echo "zinit light zdharma/fast-syntax-highlighting" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-completions" >> ~/.zshrc
    
    # Install Docker
    log_info "Instalando Docker e Docker Compose..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    
    # Start Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    sudo chmod 666 /var/run/docker.sock
    
    # Install Go
    log_info "Instalando linguagem Go..."
    sudo dnf install golang -y
    
    # Create Go workspace if it doesn't exist
    if [ ! -d "$HOME/go" ]; then
        mkdir -p "$HOME/go/src"
        mkdir -p "$HOME/go/bin"
        mkdir -p "$HOME/go/pkg"
        
        # Add Go environment variables to .profile
        if ! grep -q "export GOPATH=" "$HOME/.profile"; then
            echo 'export GOPATH="$HOME/go"' >> "$HOME/.profile"
            echo 'export PATH="$PATH:$GOPATH/bin"' >> "$HOME/.profile"
        fi
    fi
    
    # Install NVM and Node.js
    log_info "Instalando NVM e Node.js..."
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS version of Node.js
    if command -v nvm &>/dev/null; then
        nvm install --lts
        
        # Install Yarn if Node.js was installed successfully
        if command -v node &>/dev/null; then
            npm i -g yarn
        fi
    fi
    
    # Install Rust
    log_info "Instalando linguagem Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    log_success "Todas as ferramentas de desenvolvimento foram instaladas com sucesso!"
}

# Basic Zsh installation
install_zsh() {
    whiptail --title "Instalando Zsh" --infobox "Instalando Zsh..." 8 45
    sudo dnf install zsh -y
    
    if whiptail --title "Configurar Oh-my-zsh?" --yesno "Deseja instalar e configurar Oh-my-zsh e Zinit?" 8 60; then
        install_oh_my_zsh
    fi
}

# Docker installation
install_docker_tools() {
    whiptail --title "Instalando Docker" --msgbox "Instalando Docker e Docker Compose..." 8 45
    
    # Install Docker repository and tools
    sudo dnf -y install dnf-plugins-core
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    
    # Start Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group to avoid using sudo
    if whiptail --title "Configuração Docker" --yesno "Deseja adicionar seu usuário ao grupo docker para evitar usar sudo?" 8 60; then
        sudo usermod -aG docker $USER
        whiptail --title "Grupo Docker" --msgbox "Usuário adicionado ao grupo docker.\nPor favor faça logout e login novamente para aplicar as alterações." 8 60
    fi
    
    # Set proper permissions for Docker socket
    sudo chmod 666 /var/run/docker.sock
}

# Go language installation
install_go() {
    whiptail --title "Instalando Go" --infobox "Instalando linguagem Go..." 8 45
    
    # Install Go from repositories
    sudo dnf install golang -y
    
    # Check if installation was successful
    if command -v go &>/dev/null; then
        GO_VERSION=$(go version | cut -d' ' -f3 | sed 's/go//')
        whiptail --title "Go Instalado" --msgbox "Go $GO_VERSION foi instalado com sucesso!\n\nVersão instalada: $(go version)" 10 60
        
        # Create Go workspace if it doesn't exist
        if [ ! -d "$HOME/go" ]; then
            mkdir -p "$HOME/go/src"
            mkdir -p "$HOME/go/bin"
            mkdir -p "$HOME/go/pkg"
            
            # Add Go environment variables to .profile
            if ! grep -q "export GOPATH=" "$HOME/.profile"; then
                echo 'export GOPATH="$HOME/go"' >> "$HOME/.profile"
                echo 'export PATH="$PATH:$GOPATH/bin"' >> "$HOME/.profile"
            fi
        fi
    else
        whiptail --title "Erro" --msgbox "Falha ao instalar Go. Por favor tente novamente." 8 45
    fi
}

# Node.js installation via NVM
install_node() {
    whiptail --title "Instalando NVM e Node.js" --msgbox "Instalando NVM (Node Version Manager)..." 8 45
    
    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS version of Node.js
    if command -v nvm &>/dev/null; then
        nvm install --lts
        
        # Install Yarn if Node.js was installed successfully
        if command -v node &>/dev/null; then
            npm i -g yarn
            whiptail --title "Node.js e Yarn Instalados" --msgbox "Node.js $(node -v) e Yarn $(yarn -v) foram instalados com sucesso!" 8 60
        else
            whiptail --title "Aviso" --msgbox "NVM foi instalado, mas houve um problema ao instalar Node.js." 8 45
        fi
    else
        whiptail --title "Erro" --msgbox "Falha ao configurar NVM. Por favor tente novamente." 8 45
    fi
}

# Rust installation
install_rust() {
    whiptail --title "Instalando Rust" --infobox "Instalando linguagem Rust..." 8 45
    
    # Install Rust via rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    
    # Make cargo available in the current session
    source "$HOME/.cargo/env"
    
    # Verify installation
    if command -v rustc &>/dev/null; then
        RUST_VERSION=$(rustc --version | cut -d' ' -f2)
        whiptail --title "Rust Instalado" --msgbox "Rust $RUST_VERSION foi instalado com sucesso!" 8 60
    else
        whiptail --title "Erro" --msgbox "Falha ao instalar Rust. Por favor tente novamente." 8 45
    fi
}

# Oh-my-zsh and Zinit installation
install_oh_my_zsh() {
    whiptail --title "Instalando Oh-my-zsh e Zinit" --msgbox "Instalando Oh-my-zsh e plugins..." 8 45
    
    # Install Oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
    
    # Install Zinit
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    
    # Add plugins to zshrc
    echo "zinit ice depth=1; zinit light romkatv/powerlevel10k" >> ~/.zshrc
    echo "zinit light zdharma/fast-syntax-highlighting" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-autosuggestions" >> ~/.zshrc
    echo "zinit light zsh-users/zsh-completions" >> ~/.zshrc
    
    whiptail --title "Oh-my-zsh Instalado" --msgbox "Oh-my-zsh e Zinit foram instalados com sucesso!\n\nPara ativar o Zsh como seu shell padrão, execute:\nchsh -s $(which zsh)" 10 70
}