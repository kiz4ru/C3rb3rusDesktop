#!/bin/bash

#############################################################
# C3rb3rusDesktop - VPN Status Checker
# Descripción: Muestra el estado de conexiones VPN
#############################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

#############################################################
# Verificar interfaz VPN
#############################################################

check_interface() {
    local interface="$1"
    
    if ip addr show "$interface" &>/dev/null; then
        local ip=$(ip -4 addr show "$interface" | grep inet | awk '{print $2}' | cut -d/ -f1)
        local gateway=$(ip route | grep "$interface" | grep via | awk '{print $3}' | head -1)
        local status="connected"
        
        echo "$status|$ip|$gateway"
        return 0
    else
        echo "disconnected||"
        return 1
    fi
}

#############################################################
# Mostrar estado completo
#############################################################

show_status() {
    clear
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "             VPN Connection Status"
    echo "═══════════════════════════════════════════════════"
    echo ""
    
    local any_connected=false
    
    # Check tun0 (HTB/THM)
    local tun0_info=$(check_interface "tun0")
    IFS='|' read -r status ip gateway <<< "$tun0_info"
    
    if [[ "$status" == "connected" ]]; then
        echo -e "  ${GREEN}● tun0${NC} - Connected"
        echo -e "    IP:      $ip"
        [[ -n "$gateway" ]] && echo -e "    Gateway: $gateway"
        echo ""
        any_connected=true
    else
        echo -e "  ${RED}○ tun0${NC} - Disconnected"
        echo ""
    fi
    
    # Check tun1
    local tun1_info=$(check_interface "tun1")
    IFS='|' read -r status ip gateway <<< "$tun1_info"
    
    if [[ "$status" == "connected" ]]; then
        echo -e "  ${GREEN}● tun1${NC} - Connected"
        echo -e "    IP:      $ip"
        [[ -n "$gateway" ]] && echo -e "    Gateway: $gateway"
        echo ""
        any_connected=true
    else
        echo -e "  ${RED}○ tun1${NC} - Disconnected"
        echo ""
    fi
    
    # Check wireguard interfaces
    if command -v wg &>/dev/null; then
        local wg_interfaces=$(wg show interfaces 2>/dev/null)
        if [[ -n "$wg_interfaces" ]]; then
            for iface in $wg_interfaces; do
                echo -e "  ${GREEN}● $iface${NC} - WireGuard Connected"
                local wg_ip=$(ip -4 addr show "$iface" | grep inet | awk '{print $2}' | cut -d/ -f1)
                [[ -n "$wg_ip" ]] && echo -e "    IP: $wg_ip"
                echo ""
                any_connected=true
            done
        fi
    fi
    
    echo "═══════════════════════════════════════════════════"
    
    # Información adicional
    if [[ "$any_connected" == true ]]; then
        echo ""
        echo -e "${CYAN}Active Connections:${NC}"
        echo ""
        
        # Mostrar procesos OpenVPN
        if pgrep openvpn &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} OpenVPN running"
            local ovpn_config=$(ps aux | grep openvpn | grep -v grep | grep -oP '(?<=--config )[^ ]+' | head -1)
            [[ -n "$ovpn_config" ]] && echo -e "    Config: $(basename "$ovpn_config")"
        fi
        
        # Mostrar procesos WireGuard
        if pgrep wg-quick &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} WireGuard running"
        fi
        
        echo ""
        echo -e "${YELLOW}Commands:${NC}"
        echo "  Disconnect OpenVPN: sudo killall openvpn"
        echo "  Disconnect WireGuard: sudo wg-quick down <interface>"
    else
        echo ""
        echo -e "${YELLOW}No VPN connections active${NC}"
        echo ""
        echo -e "${CYAN}Connect:${NC}"
        echo "  HTB: ~/.config/bspwm/scripts/htb_connect.sh"
        echo "  THM: ~/.config/bspwm/scripts/thm_connect.sh"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo ""
}

#############################################################
# Modo compacto para Polybar
#############################################################

compact_status() {
    local tun0_info=$(check_interface "tun0")
    local tun1_info=$(check_interface "tun1")
    
    IFS='|' read -r status0 ip0 gateway0 <<< "$tun0_info"
    IFS='|' read -r status1 ip1 gateway1 <<< "$tun1_info"
    
    if [[ "$status0" == "connected" ]]; then
        echo "VPN: $ip0"
    elif [[ "$status1" == "connected" ]]; then
        echo "VPN: $ip1"
    else
        echo "No VPN"
    fi
}

#############################################################
# Main
#############################################################

if [[ "$1" == "compact" ]]; then
    compact_status
else
    show_status
fi
