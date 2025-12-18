#!/bin/bash

#############################################################
# C3rb3rusDesktop - HTB VPN Connection Manager
# Descripción: Conecta a Hack The Box VPN
#############################################################

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directorio de configuraciones VPN
VPN_DIR="$HOME/pentesting/htb"
mkdir -p "$VPN_DIR"

#############################################################
# Funciones
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

#############################################################
# Verificar si ya hay VPN conectada
#############################################################

check_vpn_status() {
    if ip addr show tun0 &>/dev/null; then
        local ip=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
        log_warning "Ya hay una VPN conectada en tun0"
        log_info "IP actual: $ip"
        
        read -p "¿Deseas desconectar y reconectar? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            disconnect_vpn
        else
            exit 0
        fi
    fi
}

#############################################################
# Desconectar VPN
#############################################################

disconnect_vpn() {
    log_info "Desconectando VPN..."
    sudo killall openvpn 2>/dev/null || true
    sleep 2
    log_success "VPN desconectada"
}

#############################################################
# Listar archivos .ovpn disponibles
#############################################################

list_ovpn_files() {
    local ovpn_files=("$VPN_DIR"/*.ovpn)
    
    if [[ ! -e "${ovpn_files[0]}" ]]; then
        log_error "No se encontraron archivos .ovpn en $VPN_DIR"
        log_info "Descarga tu archivo .ovpn desde:"
        log_info "  https://app.hackthebox.com/home/htb"
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

#############################################################
# Conectar VPN
#############################################################

connect_vpn() {
    local ovpn_file="$1"
    
    log_info "Conectando a HTB VPN..."
    log_info "Archivo: $(basename "$ovpn_file")"
    echo ""
    
    # Conectar en background
    sudo openvpn --config "$ovpn_file" --daemon --log /tmp/htb_vpn.log
    
    # Esperar a que se establezca la conexión
    log_info "Esperando conexión..."
    local timeout=30
    local elapsed=0
    
    while [[ $elapsed -lt $timeout ]]; do
        if ip addr show tun0 &>/dev/null; then
            local ip=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
            echo ""
            log_success "Conexión establecida"
            log_success "IP de VPN: $ip"
            
            # Notificación
            notify-send "HTB VPN Connected" "IP: $ip" -u normal -t 5000 2>/dev/null || true
            
            # Guardar IP para referencia
            echo "$ip" > "$VPN_DIR/.current_vpn_ip"
            
            return 0
        fi
        sleep 1
        ((elapsed++))
        echo -n "."
    done
    
    echo ""
    log_error "Timeout esperando conexión VPN"
    log_info "Verifica el log: /tmp/htb_vpn.log"
    return 1
}

#############################################################
# Mostrar información de conexión
#############################################################

show_connection_info() {
    echo ""
    echo "═══════════════════════════════════════════"
    echo "          HTB VPN - Connection Info        "
    echo "═══════════════════════════════════════════"
    echo ""
    
    # IP de VPN
    if ip addr show tun0 &>/dev/null; then
        local vpn_ip=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
        echo -e "  ${GREEN}VPN IP:${NC} $vpn_ip"
    fi
    
    # Gateway
    local gateway=$(ip route | grep tun0 | grep via | awk '{print $3}' | head -1)
    if [[ -n "$gateway" ]]; then
        echo -e "  ${BLUE}Gateway:${NC} $gateway"
    fi
    
    # DNS
    if [[ -f /etc/resolv.conf ]]; then
        local dns=$(grep nameserver /etc/resolv.conf | head -1 | awk '{print $2}')
        echo -e "  ${BLUE}DNS:${NC} $dns"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════"
    echo ""
}

#############################################################
# Main
#############################################################

main() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "     Hack The Box - VPN Connection Tool    "
    echo "═══════════════════════════════════════════"
    echo ""
    
    # Verificar permisos sudo
    if ! sudo -n true 2>/dev/null; then
        log_info "Se requieren permisos sudo..."
        sudo -v
    fi
    
    # Verificar estado actual
    check_vpn_status
    
    # Seleccionar archivo
    ovpn_file=$(list_ovpn_files)
    
    # Conectar
    if connect_vpn "$ovpn_file"; then
        show_connection_info
        log_success "Usa 'sudo killall openvpn' para desconectar"
    else
        exit 1
    fi
}

main "$@"
