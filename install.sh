#!/bin/bash

#############################################################
# C3rb3rusDesktop - Script Principal
# Descripción: Instalador modular para Kali Linux con bspwm
# Autor: C3rb3rus Team
# Versión: 2.0.0
#############################################################

set -euo pipefail

# Directorio del script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="$SCRIPT_DIR/modules"
readonly SCRIPTS_DIR="$SCRIPT_DIR/scripts"
readonly CONFIG_DIR="$SCRIPT_DIR/config"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Banner ASCII
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
   ______               __                     
  / ____/___ __________/ /_  ___  _______  ___
 / /   / _ / ___/ __  / __ \/ _ \/ ___/ / / /
/ /___/  __/ /  / /_/ / /_/ /  __/ /  / /_/ / 
\____/\___/_/   \__,_/_.___/\___/_/   \__,_/  
                                               
     ____  _____ _____ __ ______________  ____ 
    / __ \/ ___// ___// //_/_  __/ __ \/ __ \
   / / / /\__ \\__ \/ ,<   / / / / / / /_/ /
  / /_/ /___/ /__/ / /| | / / / /_/ / ____/ 
 /_____//____/____/_/ |_|/_/  \____/_/      
                                             
EOF
    echo -e "${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Instalador Modular v2.0 - Kali Linux + bspwm${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# Cargar módulo de validación
source "$MODULES_DIR/00-checks.sh"

#############################################################
# Menú interactivo principal
#############################################################

show_main_menu() {
    local choice
    
    choice=$(whiptail --title "C3rb3rusDesktop - Menú Principal" \
        --menu "\nSelecciona los componentes a instalar:\n(Usa ESPACIO para marcar, ENTER para continuar)" \
        20 78 11 \
        "1" "Actualización del Sistema (RECOMENDADO)" \
        "2" "Herramientas de Pentesting + VPN Tools" \
        "3" "Entorno de Desarrollo (Python, Neovim, VSCode)" \
        "4" "bspwm + sxhkd + Polybar (Window Manager)" \
        "5" "Zsh + Powerlevel10k + plugins" \
        "6" "Scripts de utilidad para HTB/THM" \
        "7" "Tweaks de Rendimiento" \
        "8" "Limpieza del Sistema" \
        "9" "INSTALACIÓN COMPLETA (Todo lo anterior)" \
        "0" "Salir" \
        3>&1 1>&2 2>&3)
    
    echo "$choice"
}

show_component_selection() {
    local components
    
    components=$(whiptail --title "Selección de Componentes" \
        --checklist "\nMarca los componentes que deseas instalar:" \
        22 78 12 \
        "system" "Sistema base (Requerido)" ON \
        "pentesting" "Herramientas Pentesting + VPN" ON \
        "dev" "Entorno de Desarrollo" ON \
        "bspwm" "bspwm Window Manager base" ON \
        "keybinds" "Atajos de teclado (sxhkd)" ON \
        "polybar" "Polybar (barra de estado)" ON \
        "picom" "Picom (compositor)" ON \
        "zsh" "Zsh + Powerlevel10k" ON \
        "tweaks" "Optimizaciones del sistema" OFF \
        "cleanup" "Limpieza del Sistema" ON \
        3>&1 1>&2 2>&3)
    
    echo "$components"
}

#############################################################
# Confirmación de instalación
#############################################################

confirm_installation() {
    local components="$1"
    
    whiptail --title "Confirmar Instalación" \
        --yesno "\n¿Deseas proceder con la instalación de los siguientes componentes?\n\n$components\n\nEsto puede tardar varios minutos." \
        15 78
    
    return $?
}

#############################################################
# Ejecutar módulos de instalación
#############################################################

run_installation() {
    local components="$1"
    local start_time=$(date +%s)
    
    log_info "Iniciando instalación de componentes..."
    ecSistema base (10-system.sh)
    if [[ "$components" == *"system"* ]]; then
        [[ -f "$MODULES_DIR/10-system.sh" ]] && bash "$MODULES_DIR/10-system.sh"
    fi
    
    # Pentesting (20-pentesting.sh)
    if [[ "$components" == *"pentesting"* ]]; then
        [[ -f "$MODULES_DIR/20-pentesting.sh" ]] && bash "$MODULES_DIR/20-pentesting.sh"
    fi
    
    # Desarrollo (30-dev.sh)
    if [[ "$components" == *"dev"* ]]; then
        [[ -f "$MODULES_DIR/30-dev.sh" ]] && bash "$MODULES_DIR/30-dev.sh"
    fi
    
    # bspwm base (40-bspwm.sh)
    if [[ "$components" == *"bspwm"* ]]; then
        [[ -f "$MODULES_DIR/40-bspwm.sh" ]] && bash "$MODULES_DIR/40-bspwm.sh"
    fi
    
    # Keybindings (41-keybinds.sh)
    if [[ "$components" == *"keybinds"* ]]; then
        [[ -f "$MODULES_DIR/41-keybinds.sh" ]] && bash "$MODULES_DIR/41-keybinds.sh"
    fi
    
    # Polybar (42-polybar.sh)
    if [[ "$components" == *"polybar"* ]]; then
        [[ -f "$MODULES_DIR/42-polybar.sh" ]] && bash "$MODULES_DIR/42-polybar.sh"
    fi
    
    # Picom (43-picom.sh)
    if [[ "$components" == *"picom"* ]]; then
        [[ -f "$MODULES_DIR/43-picom.sh" ]] && bash "$MODULES_DIR/43-picom.sh"
    fi
    
    # Zsh (50-zsh.sh)
    if [[ "$components" == *"zsh"* ]]; then
        [[ -f "$MODULES_DIR/50-zsh.sh" ]] && bash "$MODULES_DIR/50-zsh.sh"
    fi
    
    # Tweaks (60-tweaks.sh)
    if [[ "$components" == *"tweaks"* ]]; then
        [[ -f "$MODULES_DIR/60-tweaks.sh" ]] && bash "$MODULES_DIR/60-tweaks.sh"
    fi
    
    # Cleanup (99-cleanup.sh)
    if [[ "$components" == *"cleanup"* ]]; then
        [[ -f "$MODULES_DIR/99-cleanup.sh" ]] && bash "$MODULES_DIR/99-cleanup.shg_warning "Módulo cleanup.sh no encontrado (será creado próximamente)"
        fi
        echo ""
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    log_success "Instalación completada en $duration segundos"
}

#############################################################
# Resumen post-instalación
#############################################################

show_post_install_summary() {
    whiptail --title "Instalación Completada" --msgbox "\n✓ La instalación se completó exitosamente\n\nAcciones recomendadas:\n\n1. Si instalaste bspwm: Cierra sesión y selecciona 'bspwm' en el login\n2. Si instalaste Zsh: Ejecuta 'zsh' o reinicia la terminal\n3. Revisa el backup en: $SCRIPT_DIR/backup/\n4. Para VPN de HTB/THM: Usa los scripts en $SCRIPTS_DIR/\n\n¿Deseas reiniciar el sistema ahora?" 18 78
    
    if [[ $? -eq 0 ]]; then
        log_info "Reiniciando el sistema en 5 segundos..."
        sleep 5
        systemctl reboot
    fi
}

#############################################################
# Función principal
#############################################################

main() {
    # Mostrar banner
    show_banner
    
    # Validar el sistema
    if ! validate_system; then
        log_error "La validación del sistema falló. Abortando instalación."
        exit 1
    fi
    
    # Pausa antes del menú
    read -p "Presiona ENTER para continuar al menú principal..."
    
    # Mostrar menú y obtener selección
    local components
    components=$(show_component_selection)
    
    # Si el usuario canceló, salir
    if [[ -z "$components" ]]; then
        log_warning "Instalación cancelada por el usuario"
        exit 0
    fi
    
    # Limpiar formato de whiptail (remover comillas)
    components=$(echo "$components" | tr -d '"')
    
    # Confirmar instalación
    if ! confirm_installation "$components"; then
        log_warning "Instalación cancelada por el usuario"
        exit 0
    fi
    
    # Ejecutar instalación
    run_installation "$components"
    
    # Mostrar resumen
    show_post_install_summary
}Parsear argumentos
    local install_mode="interactive"
    local custom_components=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --full)
                install_mode="full"
                shift
                ;;
            --custom)
                install_mode="custom"
                custom_components="$2"
                shift 2
                ;;
            --help|-h)
                echo "Uso: $0 [OPCIÓN]"
                echo ""
                echo "Opciones:"
                echo "  --full          Instalación completa (todos los módulos)"
                echo "  --custom MODS   Instalación personalizada"
                echo "  --help, -h      Mostrar esta ayuda"
                echo ""
                echo "Ejemplo:"
                echo "  $0 --custom 'system pentesting bspwm'"
                exit 0
                ;;
            *)
                echo "Opción desconocida: $1"
                echo "Usa --help para ver opciones disponibles"
                exit 1
                ;;
        esac
    done
    
    # Mostrar banner
    show_banner
    
    # Validar el sistema
    if ! validate_system; then
        log_error "La validación del sistema falló. Abortando instalación."
        exit 1
    fi
    
    # Determinar componentes según modo
    local components
    
    case "$install_mode" in
        full)
            components="system pentesting dev bspwm keybinds polybar picom zsh tweaks cleanup"
            log_info "Instalación completa seleccionada"
            ;;
        custom)
            components="$custom_components"
            log_info "Instalación personalizada: $components"
            ;;
        interactive)
            read -p "Presiona ENTER para continuar al menú de selección..."
            components=$(show_component_selection)
            
            if [[ -z "$components" ]]; then
                log_warning "Instalación cancelada por el usuario"
                exit 0
            fi
            
            components=$(echo "$components" | tr -d '"')
            ;;
    esac