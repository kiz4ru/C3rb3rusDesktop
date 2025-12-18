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
