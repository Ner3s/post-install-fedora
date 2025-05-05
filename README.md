# Fedora Post-Installation Script

This script automates the post-installation setup of a Fedora Linux system, installing essential software, tools, and configurations to get your system ready for development and daily use.

[English](README.md) | [Português (Brasil)](README_pt-BR.md)

## ⚡ Automatic Installation

Run this one-liner to automatically download and execute the installation script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ner3s/post-install-fedora/main/install.sh)"
```

If you prefer to clone the repository first:

```bash
git clone https://github.com/ner3s/post-install-fedora.git
cd post-install-fedora
chmod +x install.sh
./install.sh
```

## 🛠️ Features

The script provides a menu-driven interface to install and configure the following components:

### 1. RPM Fusion
- Installs both free and non-free RPM Fusion repositories
- Updates the system package database

### 2. Visual Studio Code
- Adds the Microsoft repository
- Installs the latest stable version of Visual Studio Code

### 3. Multimedia Codecs
- Installs FFmpeg and multimedia support packages
- Adds audio and video codecs for comprehensive media playback

### 4. NVIDIA Drivers & CUDA
- Installs proprietary NVIDIA drivers
- Sets up CUDA for GPU-accelerated computing
- Configures VAAPI drivers for hardware acceleration

### 5. Applications
- Google Chrome
- Flameshot (screenshot tool)
- Peek (screen recorder)
- GNOME Tweaks
- Steam
- GIMP and Inkscape
- Neovim
- Discord (via Flatpak)
- Flatseal (Flatpak permission manager)
- OBS Studio (via Flatpak)
- Hidamari (via Flatpak)

### 6. Development Tools
- Git
- ZSH

### 7. Docker
- Installs Docker Engine
- Configures Docker Compose
- Sets appropriate permissions

### 8. Development Environment
- NVM (Node Version Manager)
- Latest LTS version of Node.js
- Yarn package manager
- Oh-my-zsh
- Zinit plugin manager with plugins:
  - Powerlevel10k theme
  - Syntax highlighting
  - Auto-suggestions
  - Completions

### 9. Fonts
- JetBrains Mono
- MesloLGS (perfect for terminals and IDEs)

### 10. Git Configuration
- Interactive setup of user name and email
- Configures useful Git aliases
- Sets best practices like default branch name

### 11. SSH Key Management
- Creates and configures SSH keys
- Automatically adds keys to the SSH agent
- Copies public key to clipboard for easy GitHub/GitLab setup

## 🧰 Project Structure

```
post-install-fedora/
├── install.sh              # Main script
├── README.md               # This documentation (English)
├── README-pt-BR.md         # Portuguese documentation
├── LICENSE                 # MIT License file
├── fonts/                  # Font files
│   ├── JetBrainsMono.ttf
│   └── MesloLGS.ttf
├── functions/              # Individual installation modules
│   ├── apps.sh             # Application installation
│   ├── codecs.sh           # Multimedia codecs
│   ├── development.sh      # NVM, Oh-my-zsh and Zinit
│   ├── docker.sh           # Docker installation
│   ├── fonts.sh            # Font installation
│   ├── git.sh              # Git configuration
│   ├── nvidia.sh           # NVIDIA drivers
│   ├── rpmfusion.sh        # RPM Fusion repositories
│   ├── ssh.sh              # SSH key management
│   ├── tools.sh            # Development tools
│   └── vscode.sh           # VS Code installation
└── lib/                    # Utility functions
    ├── clipboard.sh        # SSH copy to clipboard utils
    └── utils.sh            # Menu and general utilities
```

## 🚀 Usage

After installation, just run `./install.sh` and select the components you want to install from the menu.

For a completely automated setup, select option 12 "Instalar Tudo Automaticamente" to install all components in the recommended order.

## 🛡️ Requirements

- Fedora Linux (tested on Fedora 37+)
- Internet connection
- Sudo privileges

## 🔄 Customization

Each component is separated into its own file, making it easy to customize:
- Edit any file in the `functions/` directory to modify a specific component
- Add new functions by creating new files in the `functions/` directory and including them in `install.sh`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.