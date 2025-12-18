#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Keybindings (sxhkd)
# Descripción: Configura atajos de teclado
#############################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/00-checks.sh"

#############################################################
# Crear configuración de sxhkd
#############################################################

create_sxhkd_config() {
    log_info "Creando configuración de sxhkd (atajos de teclado)..."
    
    local sxhkd_dir="$HOME/.config/sxhkd"
    local config_source="$PROJECT_DIR/config/sxhkd"
    
    mkdir -p "$sxhkd_dir"
    
    if [[ -d "$config_source" ]] && [[ "$(ls -A $config_source 2>/dev/null)" ]]; then
        cp -r "$config_source"/* "$sxhkd_dir/"
        log_success "Configuración copiada desde $config_source"
    else
        cat > "$sxhkd_dir/sxhkdrc" << 'EOF'
#############################################################
# C3rb3rusDesktop - sxhkd Configuration
# Atajos estilo Windows + Pentesting shortcuts
#############################################################

# Terminal (Super + Enter)
super + Return
    kitty

# Launcher (Super)
super + @space
    rofi -show drun

# Run command (Super + R)
super + r
    rofi -show run

# Window switcher (Alt + Tab)
alt + Tab
    rofi -show window

# Reload sxhkd
super + Escape
    pkill -USR1 -x sxhkd && notify-send "sxhkd" "Config reloaded"

# Quit/restart bspwm
super + shift + {q,r}
    bspc {quit,wm -r}

# Close window (Alt + F4)
alt + F4
    bspc node -c

# Kill window (Super + Shift + Q)
super + shift + q
    bspc node -k

# Toggle monocle layout (Super + M)
super + m
    bspc desktop -l next

# Set window state
super + {t,shift + t,s,f}
    bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

# Focus window (Super + arrows)
super + {Left,Down,Up,Right}
    bspc node -f {west,south,north,east}

# Focus window (Super + hjkl - vim style)
super + {h,j,k,l}
    bspc node -f {west,south,north,east}

# Move window (Super + Shift + arrows)
super + shift + {Left,Down,Up,Right}
    bspc node -s {west,south,north,east}

# Resize window (Super + Alt + arrows)
super + alt + {Left,Down,Up,Right}
    bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

# Resize window contrario (Super + Alt + Shift + arrows)
super + alt + shift + {Left,Down,Up,Right}
    bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

# Preselect direction
super + ctrl + {Left,Down,Up,Right}
    bspc node -p {west,south,north,east}

# Cancel preselection
super + ctrl + space
    bspc node -p cancel

# Switch workspace (Super + number)
super + {1-9,0}
    bspc desktop -f '^{1-9,10}'

# Move window to workspace (Super + Shift + number)
super + shift + {1-9,0}
    bspc node -d '^{1-9,10}' --follow

# Screenshot (Print Screen)
Print
    flameshot gui

# Screenshot full screen (Super + Print)
super + Print
    flameshot full -c -p ~/Pictures/screenshots

# File manager (Super + E)
super + e
    thunar

# Browser (Super + W)
super + w
    firefox

# Volume control
XF86AudioRaiseVolume
    amixer -q sset Master 5%+

XF86AudioLowerVolume
    amixer -q sset Master 5%-

XF86AudioMute
    amixer -q sset Master toggle

# Media controls
XF86AudioPlay
    playerctl play-pause

XF86AudioNext
    playerctl next

XF86AudioPrev
    playerctl previous

# Brightness control
XF86MonBrightnessUp
    xbacklight -inc 10

XF86MonBrightnessDown
    xbacklight -dec 10

# Pentesting shortcuts

# Burpsuite (Super + B)
super + b
    burpsuite

# Wireshark (Super + Shift + W)
super + shift + w
    wireshark

# Check VPN status (Super + V)
super + v
    kitty -e bash -c '~/C3rb3rusDesktop/scripts/vpn/vpn_status.sh; read -p "Press ENTER to close..."'

# Target Manager (Super + T)
super + t
    kitty -e ~/C3rb3rusDesktop/scripts/vpn/target_manager.sh
EOF
        chmod +x "$sxhkd_dir/sxhkdrc"
        log_success "Configuración de sxhkd creada"
    fi
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 41 - Keybindings (sxhkd)"
    echo "=============================================="
    echo ""
    
    create_sxhkd_config
    
    echo ""
    log_success "Módulo keybindings completado"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
