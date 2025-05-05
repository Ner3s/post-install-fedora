#!/bin/bash

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
