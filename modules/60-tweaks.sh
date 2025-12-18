#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Tweaks
# Descripción: Optimizaciones y ajustes del sistema
#############################################################

set -euo pipefail

# SCRIPT_DIR viene de install.sh cuando se ejecuta con source

#############################################################
# Optimizar parámetros de kernel
#############################################################

optimize_kernel() {
    log_info "Optimizando parámetros de kernel..."
    
    local sysctl_conf="/etc/sysctl.d/99-c3rb3rus.conf"
    
    sudo tee "$sysctl_conf" > /dev/null << 'EOF'
# C3rb3rusDesktop - Kernel optimizations

# Network performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr

# File descriptors
fs.file-max = 2097152

# Swap usage (reduce swappiness)
vm.swappiness = 10

# Cache pressure
vm.vfs_cache_pressure = 50
EOF
    
    sudo sysctl -p "$sysctl_conf" >/dev/null 2>&1
    
    log_success "Parámetros de kernel optimizados"
}

#############################################################
# Configurar límites del sistema
#############################################################

configure_limits() {
    log_info "Configurando límites del sistema..."
    
    local limits_conf="/etc/security/limits.d/99-c3rb3rus.conf"
    
    sudo tee "$limits_conf" > /dev/null << 'EOF'
# C3rb3rusDesktop - System limits

* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF
    
    log_success "Límites del sistema configurados"
}

#############################################################
# Habilitar BBR (congestion control)
#############################################################

enable_bbr() {
    log_info "Habilitando BBR congestion control..."
    
    # Verificar si el kernel soporta BBR
    if ! modprobe tcp_bbr 2>/dev/null; then
        log_warning "Kernel no soporta BBR, omitiendo..."
        return 0
    fi
    
    echo "tcp_bbr" | sudo tee /etc/modules-load.d/bbr.conf > /dev/null
    
    log_success "BBR habilitado"
}

#############################################################
# Optimizar systemd-journald
#############################################################

optimize_journald() {
    log_info "Optimizando systemd-journald..."
    
    local journald_conf="/etc/systemd/journald.conf.d/99-c3rb3rus.conf"
    
    sudo mkdir -p /etc/systemd/journald.conf.d/
    
    sudo tee "$journald_conf" > /dev/null << 'EOF'
[Journal]
SystemMaxUse=500M
SystemMaxFileSize=50M
MaxRetentionSec=1week
EOF
    
    sudo systemctl restart systemd-journald
    
    log_success "journald optimizado"
}

#############################################################
# Deshabilitar servicios innecesarios
#############################################################

disable_unnecessary_services() {
    log_info "Deshabilitando servicios innecesarios..."
    
    local services_to_disable=(
        "bluetooth.service"
        "cups.service"
        "avahi-daemon.service"
    )
    
    for service in "${services_to_disable[@]}"; do
        if systemctl is-enabled "$service" &>/dev/null; then
            sudo systemctl disable --now "$service" 2>/dev/null || true
            log_info "Deshabilitado: $service"
        fi
    done
    
    log_success "Servicios optimizados"
}

#############################################################
# Configurar DNS más rápidos
#############################################################

configure_dns() {
    log_info "Configurando DNS optimizados..."
    
    # Verificar si NetworkManager está activo
    if ! systemctl is-active NetworkManager &>/dev/null; then
        log_warning "NetworkManager no activo, omitiendo configuración DNS"
        return 0
    fi
    
    # Configurar DNS (Cloudflare y Google)
    local dns_conf="/etc/NetworkManager/conf.d/dns.conf"
    
    sudo tee "$dns_conf" > /dev/null << 'EOF'
[main]
dns=default

[global-dns]
servers=1.1.1.1,8.8.8.8,1.0.0.1,8.8.4.4
EOF
    
    sudo systemctl restart NetworkManager
    
    log_success "DNS configurados (Cloudflare + Google)"
}

#############################################################
# Optimizar I/O scheduler
#############################################################

optimize_io_scheduler() {
    log_info "Optimizando I/O scheduler..."
    
    # Detectar si es SSD o HDD
    local root_disk=$(lsblk -no pkname $(findmnt -n -o SOURCE /))
    
    if [[ -z "$root_disk" ]]; then
        log_warning "No se pudo detectar disco, omitiendo..."
        return 0
    fi
    
    # Verificar si es SSD
    local rotational=$(cat /sys/block/$root_disk/queue/rotational 2>/dev/null || echo "1")
    
    if [[ "$rotational" == "0" ]]; then
        # SSD - usar none/noop
        echo "none" | sudo tee /sys/block/$root_disk/queue/scheduler > /dev/null 2>&1 || true
        log_success "I/O scheduler optimizado para SSD (none)"
    else
        # HDD - usar mq-deadline
        echo "mq-deadline" | sudo tee /sys/block/$root_disk/queue/scheduler > /dev/null 2>&1 || true
        log_success "I/O scheduler optimizado para HDD (mq-deadline)"
    fi
}

#############################################################
# Configurar preload (si se desea)
#############################################################

install_preload() {
    log_info "Instalando preload para carga rápida de aplicaciones..."
    
    if dpkg -l | grep -q preload; then
        log_success "preload ya está instalado"
        return 0
    fi
    
    sudo apt install -y preload 2>&1 | grep -E "Setting up|already" || true
    sudo systemctl enable preload
    
    log_success "preload instalado y habilitado"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 60 - System Tweaks & Optimizations"
    echo "=============================================="
    echo ""
    
    log_warning "Este módulo modifica configuraciones del sistema"
    log_warning "Se recomienda solo en instalaciones dedicadas a pentesting"
    echo ""
    
    read -p "¿Deseas continuar? (s/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        log_warning "Módulo de tweaks omitido"
        return 0
    fi
    
    optimize_kernel
    configure_limits
    enable_bbr
    optimize_journald
    disable_unnecessary_services
    configure_dns
    optimize_io_scheduler
    install_preload
    
    echo ""
    log_success "Módulo de tweaks completado"
    log_warning "Se recomienda reiniciar para aplicar todos los cambios"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
