#!/bin/bash

##############################################################
# C3rb3rusDesktop - Keybindings Helper
# Muestra los atajos de teclado en terminal
##############################################################

set -euo pipefail

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║          C3rb3rusDesktop - Keyboard Shortcuts                ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Función para mostrar categoría
show_category() {
    local title="$1"
    echo -e "\n${GREEN}━━━ $title ━━━${NC}\n"
}

# Función para mostrar atajo
show_key() {
    local key="$1"
    local desc="$2"
    printf "  ${YELLOW}%-35s${NC} ${desc}\n" "$key"
}

# Menú de opciones
echo -e "${BLUE}Selecciona una categoría:${NC}"
echo "  1) 🚀 Básicos - Lo esencial"
echo "  2) 🪟 Gestión de ventanas"
echo "  3) 🖥️  Workspaces"
echo "  4) 🛡️  Pentesting"
echo "  5) 🔐 VPN"
echo "  6) 🎯 Target Management"
echo "  7) 📸 Screenshots"
echo "  8) 🎨 Wallpapers"
echo "  9) 🎵 Multimedia"
echo "  0) 📋 Ver todos"
echo "  h) 📖 Abrir documentación completa"
echo "  q) Salir"
echo ""
read -p "Opción: " choice

show_basic() {
    show_category "BÁSICOS - Uso Diario"
    show_key "Super + Enter" "Terminal (Kitty)"
    show_key "Super + Shift + Enter" "Terminal flotante"
    show_key "Super + Space" "Launcher (Rofi)"
    show_key "Super + R" "Ejecutar comando"
    show_key "Alt + Tab" "Cambiar ventana"
    show_key "Alt + F4" "Cerrar ventana"
    show_key "Super + Q" "Forzar cierre"
    show_key "F11" "Fullscreen"
}

show_windows() {
    show_category "GESTIÓN DE VENTANAS"
    show_key "Super + ←/↓/↑/→" "Cambiar foco (flechas)"
    show_key "Super + H/J/K/L" "Cambiar foco (vim)"
    show_key "Super + Shift + ←/↓/↑/→" "Mover ventana"
    show_key "Super + Alt + ←/↓/↑/→" "Redimensionar (expandir)"
    show_key "Super + M" "Modo monocle"
    show_key "Super + T" "Modo tiled"
    show_key "Super + S" "Modo flotante"
    show_key "Super + F" "Fullscreen"
}

show_workspaces() {
    show_category "WORKSPACES"
    show_key "Super + 1-9, 0" "Cambiar a workspace 1-10"
    show_key "Super + Shift + 1-9, 0" "Mover ventana a workspace"
    show_key "Super + [" "Workspace anterior"
    show_key "Super + ]" "Workspace siguiente"
}

show_pentesting() {
    show_category "PENTESTING - Herramientas"
    show_key "Super + B" "Burpsuite"
    show_key "Super + Shift + P" "Wireshark"
    show_key "Super + Shift + M" "Metasploit"
    show_key "Super + G" "Ghidra"
    show_key "Super + N" "Zenmap"
}

show_vpn() {
    show_category "VPN - Gestión"
    show_key "Super + V" "Estado de VPN"
    show_key "Super + Shift + H" "Conectar HTB"
    show_key "Super + Shift + T" "Conectar THM"
    show_key "Super + Shift + D" "Desconectar VPN"
    show_key "Super + Shift + C, V" "Copiar IP VPN"
}

show_target() {
    show_category "TARGET - Gestión de Objetivos"
    show_key "Super + T" "Target Manager"
    show_key "Super + Shift + I" "Set target IP (quick)"
    show_key "Super + Shift + O" "Abrir carpeta target"
}

show_screenshots() {
    show_category "CAPTURAS DE PANTALLA"
    show_key "Print" "Screenshot interactivo"
    show_key "Super + Print" "Pantalla completa"
    show_key "Shift + Print" "Ventana actual"
    show_key "Ctrl + Print" "Con delay 5s"
    show_key "Super + O" "Screenshot + OCR"
}

show_wallpapers() {
    show_category "WALLPAPERS"
    show_key "Super + W, P" "Wallpaper Manager"
    show_key "Super + W, R" "Wallpaper aleatorio"
}

show_multimedia() {
    show_category "MULTIMEDIA"
    show_key "XF86AudioRaiseVolume" "Subir volumen"
    show_key "XF86AudioLowerVolume" "Bajar volumen"
    show_key "XF86AudioMute" "Mutear/Desmutear"
    show_key "XF86AudioPlay" "Play/Pause"
}

show_all() {
    show_basic
    show_windows
    show_workspaces
    show_pentesting
    show_vpn
    show_target
    show_screenshots
    show_wallpapers
    show_multimedia
    
    echo ""
    echo -e "${GREEN}━━━ SISTEMA ━━━${NC}"
    show_key "Super + Escape" "Recargar atajos (sxhkd)"
    show_key "Super + Shift + R" "Reiniciar bspwm"
    show_key "Super + E" "Explorador archivos"
    show_key "Super + W" "Navegador"
    show_key "Super + C" "VS Code"
}

case $choice in
    1) show_basic ;;
    2) show_windows ;;
    3) show_workspaces ;;
    4) show_pentesting ;;
    5) show_vpn ;;
    6) show_target ;;
    7) show_screenshots ;;
    8) show_wallpapers ;;
    9) show_multimedia ;;
    0) show_all ;;
    h|H)
        DOCS_PATH="$HOME/.config/bspwm/docs/KEYBINDINGS.md"
        if [[ -f "$DOCS_PATH" ]]; then
            if command -v bat &> /dev/null; then
                bat --style=grid --color=always "$DOCS_PATH"
            else
                less "$DOCS_PATH"
            fi
        else
            echo -e "${YELLOW}Documentación no encontrada en: $DOCS_PATH${NC}"
            echo "Buscando en proyecto..."
            PROJECT_DOCS="$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")/docs/KEYBINDINGS.md"
            if [[ -f "$PROJECT_DOCS" ]]; then
                less "$PROJECT_DOCS"
            else
                echo -e "${RED}No se encontró la documentación${NC}"
            fi
        fi
        ;;
    q|Q) exit 0 ;;
    *)
        echo -e "${RED}Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}💡 Tips:${NC}"
echo "  • Documentación completa: cat ~/.config/bspwm/docs/KEYBINDINGS.md"
echo "  • Editar atajos: nvim ~/.config/sxhkd/sxhkdrc"
echo "  • Recargar después: Super + Escape"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Presiona ENTER para salir..."
