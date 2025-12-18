#!/bin/bash

#############################################################
# Polybar Module: VPN Status
# Muestra el estado de conexión VPN con estilo
#############################################################

# Obtener IP del gateway para saber qué VPN
get_vpn_gateway() {
    local interface=$1
    ip route | grep "dev $interface" | grep -oP 'via \K[\d.]+' | head -1
}

if ip addr show tun0 &>/dev/null; then
    IP=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
    GATEWAY=$(get_vpn_gateway tun0)
    echo "🔐 HTB: $IP"
elif ip addr show tun1 &>/dev/null; then
    IP=$(ip -4 addr show tun1 | grep inet | awk '{print $2}' | cut -d/ -f1)
    GATEWAY=$(get_vpn_gateway tun1)
    echo "🔐 THM: $IP"
else
    echo "⚠️  Disconnected"
fi
