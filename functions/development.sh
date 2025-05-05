#!/bin/bash

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
