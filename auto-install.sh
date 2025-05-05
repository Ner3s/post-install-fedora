#!/bin/bash

REPO_NAME="post-install-fedora"
REPO_URL="https://github.com/Ner3s/$REPO_NAME.git"
DIRECTORY="$HOME/$REPO_NAME"

# Git installation check
if ! command -v git &> /dev/null;
then
    echo "O git não está instalado. Instalando o pacote 'git'..."
    sudo dnf install -y git
    echo "Git instalado com sucesso. \n"
fi

if [ -d "$DIRECTORY" ]; then
    echo "O repositório já existe. Atualizando o repositório..."
    cd "$DIRECTORY" || exit
    git stash && git pull
    chmod +x install.sh
    ./install.sh
else
    echo "O repositório não existe. Clonando o repositório..."
    git clone "$REPO_URL" "$DIRECTORY"
    cd "$DIRECTORY" || exit
    chmod +x install.sh
    ./install.sh
fi