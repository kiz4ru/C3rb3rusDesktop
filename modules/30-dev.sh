#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo de Desarrollo
# Descripción: Instala entorno completo de desarrollo
#############################################################

set -euo pipefail

# Cargar funciones de logging
# SCRIPT_DIR viene de install.sh cuando se ejecuta con source

#############################################################
# Instalar Python y herramientas relacionadas
#############################################################

install_python_dev() {
    log_info "Instalando entorno de desarrollo Python..."
    
    local python_packages=(
        "python3"
        "python3-pip"
        "python3-dev"
        "python3-venv"
        "python3-setuptools"
        "python3-wheel"
        "python-is-python3"     # Alias 'python' -> 'python3'
        "ipython3"
        "python3-pytest"
    )
    
    sudo apt install -y "${python_packages[@]}" 2>&1 | grep -E "Setting up|already" || true
    
    # Actualizar pip
    python3 -m pip install --upgrade pip setuptools wheel
    
    # Instalar herramientas de desarrollo Python
    local pip_dev_tools=(
        "virtualenv"
        "pipenv"
        "poetry"
        "black"                 # Code formatter
        "flake8"                # Linter
        "pylint"                # Linter
        "autopep8"              # Auto-formatter
        "ipython"               # Enhanced REPL
        "jupyter"               # Notebooks
        "ptpython"              # Better REPL
    )
    
    log_info "Instalando herramientas de desarrollo Python..."
    python3 -m pip install --user "${pip_dev_tools[@]}" 2>&1 | \
        grep -E "Successfully installed|already satisfied" || true
    
    log_success "Entorno Python instalado"
}

#############################################################
# Instalar Node.js y npm
#############################################################

install_nodejs() {
    log_info "Instalando Node.js y npm..."
    
    # Instalar desde repos de Kali
    sudo apt install -y nodejs npm 2>&1 | grep -E "Setting up|already" || true
    
    # Verificar versión
    local node_version=$(node --version 2>/dev/null || echo "no instalado")
    log_info "Node.js versión: $node_version"
    
    # Configurar npm para instalaciones globales sin sudo
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    
    # Agregar a PATH si no está
    if ! grep -q ".npm-global/bin" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    log_success "Node.js y npm instalados"
}

#############################################################
# Instalar Neovim con configuración moderna
#############################################################

install_neovim() {
    log_info "Instalando Neovim..."
    
    # Instalar Neovim desde repos
    sudo apt install -y neovim 2>&1 | grep -E "Setting up|already" || true
    
    # Instalar dependencias para plugins
    sudo apt install -y ripgrep fd-find 2>&1 | grep -E "Setting up|already" || true
    
    # Crear symlinks
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd" 2>/dev/null || true
    
    # Crear estructura de directorios para Neovim
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.local/share/nvim/site/autoload"
    
    # Instalar vim-plug (plugin manager)
    if [[ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]]; then
        log_info "Instalando vim-plug..."
        curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    
    # Crear configuración básica si no existe
    if [[ ! -f "$HOME/.config/nvim/init.vim" ]]; then
        cat > "$HOME/.config/nvim/init.vim" << 'EOF'
" C3rb3rusDesktop - Neovim Configuration
" Configuración básica de Neovim

set number relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set mouse=a
set clipboard=unnamedplus
set ignorecase
set smartcase
set incsearch
set hlsearch
set termguicolors
set cursorline
set splitbelow splitright

" Vim-plug plugins
call plug#begin('~/.local/share/nvim/plugged')

" File explorer
Plug 'preservim/nerdtree'

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Color schemes
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }

" Git integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

" Comments
Plug 'tpope/vim-commentary'

" LSP support
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Theme
colorscheme gruvbox
set background=dark

" Key mappings
let mapleader = " "
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Install plugins automatically on first run
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
EOF
        log_info "Configuración básica de Neovim creada"
    fi
    
    log_success "Neovim instalado y configurado"
}

#############################################################
# Instalar Visual Studio Code
#############################################################

install_vscode() {
    log_info "Instalando Visual Studio Code..."
    
    # Verificar si ya está instalado
    if command -v code &>/dev/null; then
        log_success "VS Code ya está instalado"
        return 0
    fi
    
    # Agregar repositorio de Microsoft
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        log_info "Agregando repositorio de VS Code..."
        
        # Importar clave GPG de Microsoft
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
            gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
        
        # Agregar repositorio
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
            sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        
        # Actualizar e instalar
        sudo apt update
        sudo apt install -y code
        
        log_success "VS Code instalado"
    else
        sudo apt install -y code 2>&1 | grep -E "Setting up|already" || true
    fi
    
    # Instalar extensiones útiles (si code está disponible)
    if command -v code &>/dev/null; then
        log_info "Instalando extensiones de VS Code..."
        
        local extensions=(
            "ms-python.python"
            "ms-vscode.cpptools"
            "eamodio.gitlens"
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
            "PKief.material-icon-theme"
            "dracula-theme.theme-dracula"
        )
        
        for ext in "${extensions[@]}"; do
            code --install-extension "$ext" --force 2>/dev/null || true
        done
        
        log_info "Extensiones de VS Code instaladas"
    fi
}

#############################################################
# Instalar Kitty Terminal
#############################################################

install_kitty() {
    log_info "Instalando Kitty Terminal..."
    
    sudo apt install -y kitty 2>&1 | grep -E "Setting up|already" || true
    
    # Crear configuración de Kitty
    mkdir -p "$HOME/.config/kitty"
    
    if [[ ! -f "$HOME/.config/kitty/kitty.conf" ]]; then
        cat > "$HOME/.config/kitty/kitty.conf" << 'EOF'
# C3rb3rusDesktop - Kitty Terminal Configuration

# Font
font_family      JetBrains Mono
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 11.0

# Cursor
cursor_shape beam
cursor_blink_interval 0.5
cursor_stop_blinking_after 15.0

# Scrollback
scrollback_lines 10000

# Mouse
mouse_hide_wait 3.0
url_color #0087bd
url_style curly

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Window
remember_window_size  yes
initial_window_width  1200
initial_window_height 700
window_padding_width 4

# Opacity
background_opacity 0.95

# Color scheme - Dracula
foreground            #f8f8f2
background            #282a36
selection_foreground  #ffffff
selection_background  #44475a

# Black
color0  #21222c
color8  #6272a4

# Red
color1  #ff5555
color9  #ff6e6e

# Green
color2  #50fa7b
color10 #69ff94

# Yellow
color3  #f1fa8c
color11 #ffffa5

# Blue
color4  #bd93f9
color12 #d6acff

# Magenta
color5  #ff79c6
color13 #ff92df

# Cyan
color6  #8be9fd
color14 #a4ffff

# White
color7  #f8f8f2
color15 #ffffff

# Tab bar
tab_bar_edge bottom
tab_bar_style powerline
tab_powerline_style slanted

# Keybindings
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+t new_tab
map ctrl+shift+q close_tab
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab
EOF
        log_info "Configuración de Kitty creada"
    fi
    
    log_success "Kitty Terminal instalado"
}

#############################################################
# Instalar herramientas de desarrollo adicionales
#############################################################

install_dev_tools() {
    log_info "Instalando herramientas de desarrollo adicionales..."
    
    local dev_tools=(
        # Version control
        "git-lfs"
        "tig"                   # Git TUI
        
        # Terminal tools
        "fzf"                   # Fuzzy finder
        "bat"                   # Cat con syntax highlight
        "exa"                   # ls mejorado
        "tldr"                  # Simplified man pages
        
        # Editors
        "vim-gtk3"
        "emacs-nox"
        
        # Build tools
        "ninja-build"
        "meson"
        
        # Documentation
        "man-db"
        "manpages-dev"
        
        # Database clients
        "sqlite3"
        "postgresql-client"
        "redis-tools"
    )
    
    sudo apt install -y "${dev_tools[@]}" 2>&1 | grep -E "Setting up|already" || true
    
    # Instalar oh-my-posh (prompt personalizable)
    if [[ ! -f /usr/local/bin/oh-my-posh ]]; then
        log_info "Instalando oh-my-posh..."
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 \
            -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
    fi
    
    log_success "Herramientas de desarrollo instaladas"
}

#############################################################
# Configurar Git
#############################################################

configure_git() {
    log_info "Configurando Git..."
    
    # Solo configurar si no está ya configurado
    if ! git config --global user.name &>/dev/null; then
        log_warning "Git no tiene nombre de usuario configurado"
        log_info "Puedes configurarlo después con: git config --global user.name 'Tu Nombre'"
    fi
    
    # Configuraciones útiles
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nvim
    git config --global color.ui auto
    
    log_success "Git configurado"
}

#############################################################
# Crear workspace de desarrollo
#############################################################

create_dev_workspace() {
    log_info "Creando workspace de desarrollo..."
    
    local dev_dir="$HOME/development"
    local subdirs=(
        "projects"      # Proyectos personales
        "github"        # Repos clonados de GitHub
        "learning"      # Proyectos de aprendizaje
        "scripts"       # Scripts útiles
        "docker"        # Dockerfiles
        "venvs"         # Virtual environments Python
    )
    
    mkdir -p "$dev_dir"
    
    for dir in "${subdirs[@]}"; do
        mkdir -p "$dev_dir/$dir"
    done
    
    log_success "Workspace de desarrollo creado en: $dev_dir"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo Dev - Entorno de Desarrollo"
    echo "=============================================="
    echo ""
    
    install_python_dev
    install_nodejs
    install_neovim
    install_vscode
    install_kitty
    install_dev_tools
    configure_git
    create_dev_workspace
    
    echo ""
    log_success "Módulo de desarrollo completado exitosamente"
    log_info "Reinicia la terminal para aplicar cambios en PATH"
    echo ""
}

# Ejecutar si se invoca directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
