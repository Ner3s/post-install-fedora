# Script de Pós-Instalação para Fedora

Este script automatiza o processo de pós-instalação de um sistema Fedora Linux, instalando softwares essenciais, ferramentas e configurações para deixar seu sistema pronto para desenvolvimento e uso diário.

[English](README.md) | [Português (Brasil)](README-pt-BR.md)

## ⚡ Instalação Automática

Execute este comando para baixar e executar o script de instalação automaticamente:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ner3s/post-install-fedora/main/auto-install.sh)"
```

Se preferir clonar o repositório primeiro:

```bash
git clone https://github.com/ner3s/post-install-fedora.git
cd post-install-fedora
chmod +x install.sh
./install.sh
```

## 🛠️ Recursos

O script fornece uma interface de menu para instalar e configurar os seguintes componentes:

### 1. RPM Fusion
- Instala os repositórios RPM Fusion free e non-free
- Atualiza o banco de dados de pacotes do sistema

### 2. Visual Studio Code
- Adiciona o repositório da Microsoft
- Instala a versão estável mais recente do Visual Studio Code

### 3. Codecs Multimídia
- Instala o FFmpeg e pacotes de suporte multimídia
- Adiciona codecs de áudio e vídeo para reprodução abrangente de mídia

### 4. Drivers NVIDIA e CUDA
- Instala drivers proprietários NVIDIA
- Configura o CUDA para computação acelerada por GPU
- Configura drivers VAAPI para aceleração de hardware

### 5. Aplicativos
- Google Chrome
- Flameshot (ferramenta de captura de tela)
- Peek (gravador de tela)
- GNOME Tweaks
- Steam
- GIMP e Inkscape
- Neovim
- Discord (via Flatpak)
- Flatseal (gerenciador de permissões Flatpak)
- OBS Studio (via Flatpak)
- Hidamari (via Flatpak)

### 6. Ferramentas de Desenvolvimento
- Git
- ZSH

### 7. Docker
- Instala o Docker Engine
- Configura o Docker Compose
- Define as permissões apropriadas

### 8. Ambiente de Desenvolvimento
- NVM (Node Version Manager)
- Última versão LTS do Node.js
- Gerenciador de pacotes Yarn
- Oh-my-zsh
- Gerenciador de plugins Zinit com plugins:
  - Tema Powerlevel10k
  - Destaque de sintaxe
  - Sugestões automáticas
  - Completions

### 9. Fontes
- JetBrains Mono
- MesloLGS (perfeita para terminais e IDEs)

### 10. Configuração do Git
- Configuração interativa de nome de usuário e email
- Configura aliases úteis do Git
- Define as melhores práticas como nome do branch padrão

### 11. Gerenciamento de Chaves SSH
- Cria e configura chaves SSH
- Adiciona automaticamente as chaves ao agente SSH
- Copia a chave pública para a área de transferência para fácil configuração no GitHub/GitLab

## 🧰 Estrutura do Projeto

```
post-install-fedora/
├── install.sh              # Script principal
├── README.md               # Documentação em inglês
├── README-pt-BR.md         # Esta documentação em português
├── LICENSE                 # Arquivo de licença MIT
├── fonts/                  # Arquivos de fontes
│   ├── JetBrainsMono.ttf
│   └── MesloLGS.ttf
├── functions/              # Módulos de instalação individuais
│   ├── apps.sh             # Instalação de aplicativos
│   ├── codecs.sh           # Codecs multimídia
│   ├── development.sh      # NVM, Oh-my-zsh e Zinit
│   ├── docker.sh           # Instalação do Docker
│   ├── fonts.sh            # Instalação de fontes
│   ├── git.sh              # Configuração do Git
│   ├── nvidia.sh           # Drivers NVIDIA
│   ├── rpmfusion.sh        # Repositórios RPM Fusion
│   ├── ssh.sh              # Gerenciamento de chaves SSH
│   ├── tools.sh            # Ferramentas de desenvolvimento
│   └── vscode.sh           # Instalação do VS Code
└── lib/                    # Funções utilitárias
    ├── clipboard.sh        # Utilitários de cópia para área de transferência
    └── utils.sh            # Menu e utilidades gerais
```

## 🚀 Uso

Após a instalação, basta executar `./install.sh` e selecionar os componentes que deseja instalar no menu.

Para uma configuração completamente automatizada, selecione a opção 12 "Instalar Tudo Automaticamente" para instalar todos os componentes na ordem recomendada.

## 🛡️ Requisitos

- Fedora Linux (testado no Fedora 37+)
- Conexão com a Internet
- Privilégios de sudo

## 🔄 Personalização

Cada componente está separado em seu próprio arquivo, facilitando a personalização:
- Edite qualquer arquivo no diretório `functions/` para modificar um componente específico
- Adicione novas funções criando novos arquivos no diretório `functions/` e incluindo-os no `install.sh`

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - consulte o arquivo [LICENSE](LICENSE) para obter detalhes.
