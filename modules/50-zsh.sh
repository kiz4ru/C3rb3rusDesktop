#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Zsh
# Descripción: Instala y configura Zsh + Powerlevel10k
#############################################################

set -euo pipefail

# SCRIPT_DIR viene de install.sh cuando se ejecuta con source

#############################################################
# Instalar Zsh
#############################################################

install_zsh() {
    log_info "Instalando Zsh..."
    
    sudo apt install -y zsh zsh-autosuggestions zsh-syntax-highlighting 2>&1 | \
        grep -E "Setting up|already" || true
    
    log_success "Zsh instalado"
}

#############################################################
# Instalar Oh My Zsh
#############################################################

install_oh_my_zsh() {
    log_info "Instalando Oh My Zsh..."
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warning "Oh My Zsh ya está instalado"
        return 0
    fi
    
    # Instalar sin cambiar shell automáticamente
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    log_success "Oh My Zsh instalado"
}

#############################################################
# Instalar Powerlevel10k
#############################################################

install_powerlevel10k() {
    log_info "Instalando Powerlevel10k..."
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [[ -d "$p10k_dir" ]]; then
        log_warning "Powerlevel10k ya está instalado"
        cd "$p10k_dir" && git pull
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
    
    log_success "Powerlevel10k instalado"
}

#############################################################
# Instalar plugins útiles
#############################################################

install_zsh_plugins() {
    log_info "Instalando plugins de Zsh..."
    
    local custom_plugins="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # zsh-autosuggestions
    if [[ ! -d "$custom_plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_plugins/zsh-autosuggestions"
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$custom_plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom_plugins/zsh-syntax-highlighting"
    fi
    
    # zsh-completions
    if [[ ! -d "$custom_plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$custom_plugins/zsh-completions"
    fi
    
    log_success "Plugins de Zsh instalados"
}

#############################################################
# Configurar .zshrc
#############################################################

configure_zshrc() {
    log_info "Configurando .zshrc..."
    
    # Backup del .zshrc actual si existe
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup_$(date +%Y%m%d_%H%M%S)"
    fi
    
    cat > "$HOME/.zshrc" << 'EOF'
# C3rb3rusDesktop - Zsh Configuration

# Path to oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    sudo
    docker
    kubectl
    python
    pip
    golang
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'
alias htb='cd ~/pentesting/htb'
alias thm='cd ~/pentesting/thm'

# Pentesting aliases
alias nmap-quick='nmap -sC -sV -oA nmap/quick'
alias nmap-full='nmap -p- -oA nmap/full'
alias gobuster-dir='gobuster dir -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u'
alias ffuf-dir='ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u'

# VPN management
alias vpn-status='~/C3rb3rusDesktop/scripts/vpn/vpn_status.sh'
alias vpn-htb='~/C3rb3rusDesktop/scripts/vpn/htb_connect.sh'
alias vpn-thm='~/C3rb3rusDesktop/scripts/vpn/thm_connect.sh'
alias vpn-kill='sudo killall openvpn'

# Target management
alias target='~/C3rb3rusDesktop/scripts/vpn/target_manager.sh'
alias set-target='echo "$1" > ~/.config/bspwm/target_ip.txt && echo "Target set: $1"'

# Python virtual environment
alias venv='python3 -m venv venv'
alias activate='source venv/bin/activate'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph'

# System
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'
alias vpnip='ip addr show tun0 2>/dev/null | grep inet | awk "{print \$2}" | cut -d/ -f1'

# Pentesting functions
function scan() {
    if [[ -z "$1" ]]; then
        echo "Usage: scan <IP>"
        return 1
    fi
    mkdir -p nmap
    nmap -sC -sV -oA nmap/$(echo $1 | tr '.' '_') $1
}

function web-enum() {
    if [[ -z "$1" ]]; then
        echo "Usage: web-enum <URL>"
        return 1
    fi
    gobuster dir -w /usr/share/seclists/Discovery/Web-Content/common.txt -u $1
}

# Environment
export EDITOR=nvim
export VISUAL=nvim
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Powerlevel10k configuration (run 'p10k configure' to customize)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
    
    log_success ".zshrc configurado"
}

#############################################################
# Cambiar shell por defecto
#############################################################

change_default_shell() {
    log_info "Cambiando shell por defecto a Zsh..."
    
    local current_shell=$(getent passwd "$USER" | cut -d: -f7)
    
    if [[ "$current_shell" == */zsh ]]; then
        log_success "Zsh ya es el shell por defecto"
        return 0
    fi
    
    # Cambiar shell
    chsh -s "$(which zsh)"
    
    log_success "Shell cambiado a Zsh (requiere logout/login)"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 50 - Zsh + Powerlevel10k"
    echo "=============================================="
    echo ""
    
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_plugins
    configure_zshrc
    change_default_shell
    
    echo ""
    log_success "Módulo Zsh completado"
    log_warning "Cierra sesión y vuelve a entrar para aplicar cambios"
    log_info "Ejecuta 'p10k configure' para personalizar el prompt"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
