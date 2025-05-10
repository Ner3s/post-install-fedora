#!/bin/bash
# Check for necessary dependencies
if ! command -v whiptail &> /dev/null; then
    echo "O whiptail não está instalado. Instalando o pacote 'newt'..."
    sudo dnf install -y newt
fi

# Define global project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Import utility libraries
source "${PROJECT_DIR}/lib/constants.sh"
source "${PROJECT_DIR}/lib/common.sh"
source "${PROJECT_DIR}/lib/utils.sh"
source "${PROJECT_DIR}/lib/clipboard.sh"
# source "${PROJECT_DIR}/lib/gnome-extensions.sh"

# Setup function to ensure all required directories exist
setup_workspace() {
    # Create fonts directory if it doesn't exist
    if [ ! -d "${PROJECT_DIR}/fonts" ]; then
        mkdir -p "${PROJECT_DIR}/fonts"
    fi
    
    # Ensure we have the right permissions
    chmod +x "${PROJECT_DIR}/install.sh"
    find "${PROJECT_DIR}/functions" -name "*.sh" -exec chmod +x {} \;
    find "${PROJECT_DIR}/lib" -name "*.sh" -exec chmod +x {} \;
    
    log_success "Workspace setup complete"
}

# Import all function modules
import_modules() {
    # Import basic modules
    for module in ${PROJECT_DIR}/functions/*.sh; do
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
