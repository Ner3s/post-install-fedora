#!/bin/bash
git_common() {
    # Configurações adicionais para Git
    git config --global init.defaultBranch "main"
    git config --global pull.ff "only"

    # Configurar aliases no Git
    git config --global alias.s "!git status -s"
    git config --global alias.c "!git add --all && git commit -m"
    git config --global alias.l "!git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
    git config --global alias.ls "!git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"

}

configure_git() {
    # Solicitar nome de usuário e e-mail para o Git
    USER_NAME=$(whiptail --title "Configuração Git" --inputbox "Digite seu nome de usuário do Git:" 8 45 --title "Git" 3>&1 1>&2 2>&3)
    USER_EMAIL=$(whiptail --title "Configuração Git" --inputbox "Digite seu e-mail do Git:" 8 45 --title "Git" 3>&1 1>&2 2>&3)

    # Definir o nome de usuário e e-mail do Git
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"

    git_common

    whiptail --title "Git Configurado" --msgbox "Nome de usuário e e-mail do Git configurados!\nConfigurações adicionais aplicadas." 8 45
    show_menu
}

# Auto installation version without prompts or menu return
configure_git_auto() {
    log_info "Configurando Git automaticamente..."
    git_common
    log_success "Git configurado com valores padrão. Você pode alterar isso mais tarde com 'git config --global user.name' e 'git config --global user.email'."
}
