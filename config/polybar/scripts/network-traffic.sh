#!/bin/bash

#############################################################
# Polybar Module: Network Traffic
# Muestra el tráfico de red en tiempo real
#############################################################

# Detectar interfaz activa
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [[ -z "$INTERFACE" ]]; then
    echo "No network"
    exit 0
fi

# Leer estadísticas
RX1=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX1=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

sleep 1

RX2=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX2=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)

# Calcular diferencias
RX=$((RX2 - RX1))
TX=$((TX2 - TX1))

# Convertir a KB/s
RX_KB=$((RX / 1024))
TX_KB=$((TX / 1024))

echo "↓ ${RX_KB}KB/s ↑ ${TX_KB}KB/s"
