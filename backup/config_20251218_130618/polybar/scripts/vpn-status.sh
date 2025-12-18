#!/bin/bash
if ip addr show tun0 &>/dev/null; then
    IP=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
    echo "VPN: $IP"
elif ip addr show tun1 &>/dev/null; then
    IP=$(ip -4 addr show tun1 | grep inet | awk '{print $2}' | cut -d/ -f1)
    echo "VPN: $IP"
else
    echo "No VPN"
fi
