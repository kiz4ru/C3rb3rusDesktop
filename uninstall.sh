#!/bin/bash

#############################################################
# C3rb3rusDesktop - Uninstaller
# Descripción: Desinstala configuraciones de C3rb3rusDesktop
#############################################################

set -euo pipefail

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

#############################################################
# Confirmar desinstalación
#############################################################

confirm_uninstall() {
    clear
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  C3rb3rusDesktop - Desinstalador"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_warning "Esta acción eliminará:"
    echo ""
    echo "  - Configuraciones de bspwm (~/.config/bspwm)"
    echo "  - Configuraciones de sxhkd (~/.config/sxhkd)"
    echo "  - Configuraciones de polybar (~/.config/polybar)"
    echo "  - Configuraciones de picom (~/.config/picom)"
    echo "  - Configuraciones de rofi (~/.config/rofi)"
    echo "  - Configuraciones de Zsh (.zshrc)"
    echo "  - Scripts de VPN y utilidades"
    echo ""
    log_info "Los paquetes instalados NO serán eliminados"
    log_info "Los backups en backup/ se conservarán"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
    
    read -p "¿Deseas continuar? (escribe 'SI' para confirmar): " confirm
    
    if [[ "$confirm" != "SI" ]]; then
        log_warning "Desinstalación cancelada"
        exit 0
    fi
}

#############################################################
# Crear backup final
#############################################################

create_final_backup() {
    log_info "Creando backup final antes de desinstalar..."
    
    local backup_dir="$HOME/.c3rb3rus_uninstall_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup de configuraciones
    [[ -d "$HOME/.config/bspwm" ]] && cp -r "$HOME/.config/bspwm" "$backup_dir/"
    [[ -d "$HOME/.config/sxhkd" ]] && cp -r "$HOME/.config/sxhkd" "$backup_dir/"
    [[ -d "$HOME/.config/polybar" ]] && cp -r "$HOME/.config/polybar" "$backup_dir/"
    [[ -d "$HOME/.config/picom" ]] && cp -r "$HOME/.config/picom" "$backup_dir/"
    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$backup_dir/"
    
    log_success "Backup creado en: $backup_dir"
}

#############################################################
# Eliminar configuraciones
#############################################################

remove_configurations() {
    log_info "Eliminando configuraciones de C3rb3rusDesktop..."
    
    # bspwm y componentes
    rm -rf "$HOME/.config/bspwm"
    rm -rf "$HOME/.config/sxhkd"
    rm -rf "$HOME/.config/polybar"
    rm -rf "$HOME/.config/picom"
    rm -rf "$HOME/.config/rofi"
    
    log_success "Configuraciones de bspwm eliminadas"
}

#############################################################
# Restaurar .zshrc
#############################################################

restore_zshrc() {
    log_info "Restaurando .zshrc..."
    
    # Buscar backup más reciente
    local backup=$(ls -t "$HOME/.zshrc.backup_"* 2>/dev/null | head -1)
    
    if [[ -n "$backup" ]]; then
        cp "$backup" "$HOME/.zshrc"
        log_success ".zshrc restaurado desde backup"
    else
        log_warning "No se encontró backup de .zshrc"
    fi
}

#############################################################
# Eliminar sesión de bspwm
#############################################################

remove_bspwm_session() {
    log_info "Eliminando sesión de bspwm del login..."
    
    if [[ -f /usr/share/xsessions/bspwm.desktop ]]; then
        sudo rm /usr/share/xsessions/bspwm.desktop
        log_success "Sesión de bspwm eliminada"
    fi
}

#############################################################
# Limpiar archivos temporales
#############################################################

cleanup_temp_files() {
    log_info "Limpiando archivos temporales..."
    
    rm -f /tmp/c3rb3rus_*.log
    rm -f /tmp/htb_vpn.log
    rm -f /tmp/thm_vpn.log
    rm -f /tmp/polybar.log
    
    log_success "Archivos temporales eliminados"
}

#############################################################
# Resumen final
#############################################################

show_final_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_success "Desinstalación completada"
    echo ""
    log_info "Cambios realizados:"
    echo "  ✓ Configuraciones eliminadas"
    echo "  ✓ Backup final creado"
    echo "  ✓ Sesión de bspwm eliminada"
    echo ""
    log_warning "Paquetes instalados conservados (usa apt si deseas eliminarlos)"
    echo ""
    log_info "Para eliminar paquetes manualmente:"
    echo "  sudo apt remove bspwm sxhkd polybar picom rofi"
    echo ""
    log_info "Para restaurar desde backup:"
    echo "  ls -la ~/.c3rb3rus_uninstall_backup_*"
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

#############################################################
# Función principal
#############################################################

main() {
    # Verificar que no se ejecute como root
    if [[ $EUID -eq 0 ]]; then
        log_error "No ejecutes este script como root"
        exit 1
    fi
    
    confirm_uninstall
    create_final_backup
    remove_configurations
    restore_zshrc
    remove_bspwm_session
    cleanup_temp_files
    show_final_summary
    
    read -p "Presiona ENTER para salir..."
}

main "$@"
