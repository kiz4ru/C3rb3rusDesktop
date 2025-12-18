#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Cleanup
# Descripción: Limpieza del sistema post-instalación
#############################################################

set -euo pipefail

# Cargar funciones de logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/validation.sh"

#############################################################
# Limpiar caché de paquetes
#############################################################

clean_package_cache() {
    log_info "Limpiando caché de paquetes..."
    
    sudo apt autoremove -y 2>&1 | grep -E "Removing|removed" || true
    sudo apt autoclean -y
    sudo apt clean
    
    log_success "Caché de paquetes limpiado"
}

#############################################################
# Limpiar archivos temporales
#############################################################

clean_temp_files() {
    log_info "Limpiando archivos temporales..."
    
    # Temp del sistema
    sudo rm -rf /tmp/* 2>/dev/null || true
    sudo rm -rf /var/tmp/* 2>/dev/null || true
    
    # Logs antiguos
    sudo journalctl --vacuum-time=7d 2>/dev/null || true
    
    log_success "Archivos temporales eliminados"
}

#############################################################
# Limpiar thumbnails
#############################################################

clean_thumbnails() {
    log_info "Limpiando thumbnails..."
    
    if [[ -d "$HOME/.cache/thumbnails" ]]; then
        rm -rf "$HOME/.cache/thumbnails"/*
    fi
    
    log_success "Thumbnails eliminados"
}

#############################################################
# Optimizar base de datos de paquetes
#############################################################

optimize_dpkg() {
    log_info "Optimizando base de datos de paquetes..."
    
    sudo dpkg --configure -a
    
    log_success "Base de datos optimizada"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo Cleanup - Limpieza del Sistema"
    echo "=============================================="
    echo ""
    
    clean_package_cache
    clean_temp_files
    clean_thumbnails
    optimize_dpkg
    
    echo ""
    log_success "Limpieza completada"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
