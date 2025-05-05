#!/bin/bash

# Verificar se o whiptail está instalado
if ! command -v whiptail &> /dev/null; then
    echo "O whiptail não está instalado. Instalando o pacote 'newt'..."
    sudo dnf install -y newt
fi

# Importa as bibliotecas utilitárias
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/clipboard.sh"

# Importa funções específicas de instalação
source "$(dirname "$0")/functions/rpmfusion.sh"
source "$(dirname "$0")/functions/vscode.sh"
source "$(dirname "$0")/functions/codecs.sh"
source "$(dirname "$0")/functions/nvidia.sh"
source "$(dirname "$0")/functions/apps.sh"
source "$(dirname "$0")/functions/tools.sh"
source "$(dirname "$0")/functions/docker.sh"
source "$(dirname "$0")/functions/development.sh"
source "$(dirname "$0")/functions/fonts.sh"
source "$(dirname "$0")/functions/git.sh"
source "$(dirname "$0")/functions/ssh.sh"

# Executar o menu inicial
show_menu
