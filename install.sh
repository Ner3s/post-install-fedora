#!/bin/bash
# Check for necessary dependencies
if ! command -v whiptail &> /dev/null; then
    echo "O whiptail não está instalado. Instalando o pacote 'newt'..."
    sudo dnf install -y newt
fi

# Import utility libraries
source "$(dirname "$0")/lib/constants.sh"
source "$(dirname "$0")/lib/common.sh"
source "$(dirname "$0")/lib/utils.sh"
source "$(dirname "$0")/lib/clipboard.sh"
source "$(dirname "$0")/lib/gnome-extensions.sh"

# Setup function to ensure all required directories exist
setup_workspace() {
    local script_dir="$(pwd)"
    
    # Create fonts directory if it doesn't exist
    if [ ! -d "${script_dir}/fonts" ]; then
        mkdir -p "${script_dir}/fonts"
    fi
    
    # Ensure we have the right permissions
    chmod +x "${script_dir}/install.sh"
    find "${script_dir}/functions" -name "*.sh" -exec chmod +x {} \;
    find "${script_dir}/lib" -name "*.sh" -exec chmod +x {} \;
    
    log_success "Workspace setup complete"
}

# Import all function modules
import_modules() {
    # Import basic modules
    for module in functions/*.sh; do
        source "$module"
    done
    
    log_success "All modules imported successfully"
}

# Main execution
show_banner() {
    echo -e "\n${GREEN}=======================================${NC}"
    echo -e "${GREEN} ${SCRIPT_NAME} v${SCRIPT_VERSION} ${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${BLUE} Author: ${SCRIPT_AUTHOR} ${NC}"
    echo -e "${GREEN}=======================================${NC}\n"
}

main() {
    show_banner
    setup_workspace
    import_modules
    show_menu
}

# Start the script
main
