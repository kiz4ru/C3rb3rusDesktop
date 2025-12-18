#!/bin/bash

#############################################################
# C3rb3rusDesktop - Menú Interactivo
# Descripción: Menú principal del sistema
#############################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

#############################################################
# Banner
#############################################################

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
    echo -e "${GREEN}  Instalador Modular para Kali Linux + bspwm${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

#############################################################
# Menú principal
#############################################################

show_main_menu() {
    local choice
    
    choice=$(whiptail --title "C3rb3rusDesktop - Menú Principal" \
        --menu "\nSelecciona una opción:" 20 78 11 \
        "1" "Instalación Completa (Recomendado)" \
        "2" "Instalación Personalizada (Elige módulos)" \
        "3" "Ejecutar módulo específico" \
        "4" "Ver estado del sistema" \
        "5" "Actualizar C3rb3rusDesktop" \
        "6" "Desinstalar" \
        "0" "Salir" \
        3>&1 1>&2 2>&3)
    
    echo "$choice"
}

#############################################################
# Instalación completa
#############################################################

full_installation() {
    if whiptail --title "Instalación Completa" \
        --yesno "\n¿Deseas instalar todos los módulos?\n\nEsto incluye:\n- Sistema base\n- Herramientas pentesting\n- Entorno desarrollo\n- bspwm completo\n- Zsh + Powerlevel10k\n- Optimizaciones\n\nTiempo estimado: 30-60 minutos" \
        18 78; then
        
        bash "$SCRIPT_DIR/install.sh" --full
    fi
}

#############################################################
# Instalación personalizada
#############################################################

custom_installation() {
    local components
    
    components=$(whiptail --title "Instalación Personalizada" \
        --checklist "\nSelecciona los módulos a instalar:" 22 78 14 \
        "system" "Sistema base (Requerido)" ON \
        "pentesting" "Herramientas Pentesting + VPN" ON \
        "dev" "Entorno de Desarrollo" ON \
        "bspwm" "bspwm Window Manager" ON \
        "keybinds" "Configurar atajos de teclado" ON \
        "polybar" "Polybar (barra de estado)" ON \
        "picom" "Picom (compositor)" ON \
        "zsh" "Zsh + Powerlevel10k" ON \
        "tweaks" "Optimizaciones del sistema" OFF \
        3>&1 1>&2 2>&3)
    
    if [[ -z "$components" ]]; then
        return 0
    fi
    
    bash "$SCRIPT_DIR/install.sh" --custom "$components"
}

#############################################################
# Ejecutar módulo específico
#############################################################

run_specific_module() {
    local modules=()
    
    for module in "$SCRIPT_DIR"/modules/*.sh; do
        local name=$(basename "$module")
        local desc=$(grep "^# Descripción:" "$module" | cut -d: -f2 | xargs)
        modules+=("$name" "$desc")
    done
    
    local choice=$(whiptail --title "Ejecutar Módulo Específico" \
        --menu "\nSelecciona un módulo:" 22 78 14 \
        "${modules[@]}" \
        3>&1 1>&2 2>&3)
    
    if [[ -n "$choice" ]]; then
        bash "$SCRIPT_DIR/modules/$choice"
        read -p "Presiona ENTER para continuar..."
    fi
}

#############################################################
# Ver estado del sistema
#############################################################

show_system_status() {
    local status_text=""
    
    # Verificar bspwm
    if command -v bspwm &>/dev/null; then
        status_text+="✓ bspwm instalado\n"
    else
        status_text+="✗ bspwm no instalado\n"
    fi
    
    # Verificar VPN
    if ip addr show tun0 &>/dev/null; then
        local vpn_ip=$(ip -4 addr show tun0 | grep inet | awk '{print $2}' | cut -d/ -f1)
        status_text+="✓ VPN conectada: $vpn_ip\n"
    else
        status_text+="✗ VPN desconectada\n"
    fi
    
    # Verificar Zsh
    if [[ "$SHELL" == */zsh ]]; then
        status_text+="✓ Zsh configurado\n"
    else
        status_text+="○ Zsh disponible pero no activo\n"
    fi
    
    # Verificar Polybar
    if pgrep -x polybar >/dev/null; then
        status_text+="✓ Polybar ejecutándose\n"
    else
        status_text+="✗ Polybar no ejecutándose\n"
    fi
    
    whiptail --title "Estado del Sistema" --msgbox "$status_text" 15 60
}

#############################################################
# Actualizar C3rb3rusDesktop
#############################################################

update_c3rb3rus() {
    if whiptail --title "Actualizar" \
        --yesno "\n¿Deseas actualizar C3rb3rusDesktop desde Git?" 10 60; then
        
        cd "$SCRIPT_DIR"
        git pull
        
        whiptail --title "Actualización" --msgbox "Actualización completada" 8 50
    fi
}

#############################################################
# Desinstalar
#############################################################

uninstall_c3rb3rus() {
    if whiptail --title "Desinstalar" \
        --yesno "\n⚠️  ADVERTENCIA ⚠️\n\n¿Estás seguro de que deseas desinstalar C3rb3rusDesktop?\n\nEsto eliminará:\n- Configuraciones de bspwm\n- Scripts instalados\n- (Los paquetes NO se eliminarán)" \
        16 70; then
        
        bash "$SCRIPT_DIR/uninstall.sh"
    fi
}

#############################################################
# Main loop
#############################################################

main() {
    while true; do
        show_banner
        
        local choice=$(show_main_menu)
        
        case "$choice" in
            1) full_installation ;;
            2) custom_installation ;;
            3) run_specific_module ;;
            4) show_system_status ;;
            5) update_c3rb3rus ;;
            6) uninstall_c3rb3rus ;;
            0|"") exit 0 ;;
        esac
    done
}

main "$@"
