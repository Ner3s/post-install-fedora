#!/bin/bash

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
