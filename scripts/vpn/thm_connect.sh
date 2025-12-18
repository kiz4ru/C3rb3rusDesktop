#!/bin/bash

#############################################################
# C3rb3rusDesktop - TryHackMe VPN Connection Manager
# Descripción: Conecta a TryHackMe VPN
#############################################################

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directorio de configuraciones VPN
VPN_DIR="$HOME/pentesting/thm"
mkdir -p "$VPN_DIR"

#############################################################
# Funciones (reutilizando lógica de HTB)
#############################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

check_vpn_status() {
    if ip addr show tun0 &>/dev/null || ip addr show tun1 &>/dev/null; then
        log_warning "Ya hay una VPN conectada"
        read -p "¿Deseas desconectar y reconectar? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            sudo killall openvpn 2>/dev/null || true
            sleep 2
        else
            exit 0
        fi
    fi
}

list_ovpn_files() {
    local ovpn_files=("$VPN_DIR"/*.ovpn)
    
    if [[ ! -e "${ovpn_files[0]}" ]]; then
        log_error "No se encontraron archivos .ovpn en $VPN_DIR"
        log_info "Descarga tu archivo .ovpn desde:"
        log_info "  https://tryhackme.com/access"
        log_info "Y colócalo en: $VPN_DIR"
        exit 1
    fi
    
    echo ""
    log_info "Archivos VPN disponibles:"
    echo ""
    
    local i=1
    for file in "${ovpn_files[@]}"; do
        echo "  $i) $(basename "$file")"
        ((i++))
    done
    
    echo ""
    read -p "Selecciona el archivo (1-$((i-1))): " selection
    
    if [[ $selection -ge 1 && $selection -lt $i ]]; then
        selected_file="${ovpn_files[$((selection-1))]}"
        echo "$selected_file"
    else
        log_error "Selección inválida"
        exit 1
    fi
}

connect_vpn() {
    local ovpn_file="$1"
    
    log_info "Conectando a TryHackMe VPN..."
    log_info "Archivo: $(basename "$ovpn_file")"
    echo ""
    
    sudo openvpn --config "$ovpn_file" --daemon --log /tmp/thm_vpn.log
    
    log_info "Esperando conexión..."
    local timeout=30
    local elapsed=0
    
    while [[ $elapsed -lt $timeout ]]; do
        for iface in tun0 tun1; do
            if ip addr show "$iface" &>/dev/null; then
                local ip=$(ip -4 addr show "$iface" | grep inet | awk '{print $2}' | cut -d/ -f1)
                echo ""
                log_success "Conexión establecida en $iface"
                log_success "IP de VPN: $ip"
                notify-send "THM VPN Connected" "IP: $ip" -u normal -t 5000 2>/dev/null || true
                return 0
            fi
        done
        sleep 1
        ((elapsed++))
        echo -n "."
    done
    
    echo ""
    log_error "Timeout esperando conexión VPN"
    return 1
}

#############################################################
# Main
#############################################################

main() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "     TryHackMe - VPN Connection Tool       "
    echo "═══════════════════════════════════════════"
    echo ""
    
    if ! sudo -n true 2>/dev/null; then
        log_info "Se requieren permisos sudo..."
        sudo -v
    fi
    
    check_vpn_status
    ovpn_file=$(list_ovpn_files)
    connect_vpn "$ovpn_file"
}

main "$@"
