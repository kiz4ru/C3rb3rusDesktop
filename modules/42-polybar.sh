#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Polybar
# Descripción: Configura Polybar con módulos VPN/Target
#############################################################

set -euo pipefail

# SCRIPT_DIR y PROJECT_DIR vienen de install.sh cuando se ejecuta con source

#############################################################
# Crear configuración de Polybar
#############################################################

create_polybar_config() {
    log_info "Creando configuración de Polybar..."
    
    local polybar_dir="$HOME/.config/polybar"
    local config_source="$PROJECT_DIR/config/polybar"
    
    mkdir -p "$polybar_dir/scripts"
    
    if [[ -d "$config_source" ]] && [[ -f "$config_source/config.ini" ]]; then
        cp -r "$config_source"/* "$polybar_dir/"
        log_success "Configuración copiada desde $config_source"
    else
        # Script de lanzamiento
        cat > "$polybar_dir/launch.sh" << 'EOF'
#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar main 2>&1 | tee -a /tmp/polybar.log & disown
echo "Polybar launched..."
EOF
        chmod +x "$polybar_dir/launch.sh"
        
        # Configuración principal
        cat > "$polybar_dir/config.ini" << 'EOF'
;==========================================================
; C3rb3rusDesktop - Polybar Configuration
;==========================================================

[colors]
background = #282a36
background-alt = #44475a
foreground = #f8f8f2
primary = #bd93f9
secondary = #6272a4
alert = #ff5555
success = #50fa7b
warning = #ffb86c
cyan = #8be9fd

[bar/main]
width = 100%
height = 30
radius = 0
fixed-center = true

background = ${colors.background}
foreground = ${colors.foreground}

line-size = 2
line-color = ${colors.primary}

padding-left = 1
padding-right = 1

module-margin-left = 1
module-margin-right = 1

font-0 = JetBrainsMono Nerd Font:size=10;2
font-1 = Font Awesome 6 Free:style=Solid:size=10;2
font-2 = Font Awesome 6 Brands:size=10;2

modules-left = bspwm xwindow
modules-center = date
modules-right = vpn-status target-ip eth wlan cpu memory filesystem pulseaudio powermenu

tray-position = right
tray-padding = 2

cursor-click = pointer
cursor-scroll = ns-resize

[module/bspwm]
type = internal/bspwm

label-focused = %name%
label-focused-background = ${colors.primary}
label-focused-foreground = ${colors.background}
label-focused-padding = 2

label-occupied = %name%
label-occupied-padding = 2

label-urgent = %name%!
label-urgent-background = ${colors.alert}
label-urgent-padding = 2

label-empty = %name%
label-empty-foreground = ${colors.secondary}
label-empty-padding = 2

[module/xwindow]
type = internal/xwindow
label = %title:0:60:...%
label-foreground = ${colors.cyan}

[module/date]
type = internal/date
interval = 1
date = %Y-%m-%d
time = %H:%M:%S
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %date% %time%

[module/vpn-status]
type = custom/script
exec = ~/.config/polybar/scripts/vpn-status.sh
interval = 5
format-prefix = "🔐 "
format-prefix-foreground = ${colors.success}

[module/target-ip]
type = custom/script
exec = ~/.config/polybar/scripts/target-ip.sh
interval = 10
format-prefix = "🎯 "
format-prefix-foreground = ${colors.warning}
click-left = ~/.config/polybar/scripts/set-target.sh

[module/eth]
type = internal/network
interface = eth0
interval = 3.0
format-connected-prefix = " "
format-connected-prefix-foreground = ${colors.success}
label-connected = %local_ip%
format-disconnected =

[module/wlan]
type = internal/network
interface = wlan0
interval = 3.0
format-connected-prefix = " "
format-connected-prefix-foreground = ${colors.success}
label-connected = %essid% %local_ip%
format-disconnected =

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.warning}
label = %percentage_used%%

[module/filesystem]
type = internal/fs
interval = 25
mount-0 = /
label-mounted =  %percentage_used%%
label-mounted-foreground = ${colors.cyan}

[module/pulseaudio]
type = internal/pulseaudio
format-volume-prefix = " "
format-volume-prefix-foreground = ${colors.primary}
label-volume = %percentage%%
label-muted =  muted
label-muted-foreground = ${colors.secondary}

[module/powermenu]
type = custom/menu
expand-right = true
format-spacing = 1
label-open = 
label-open-foreground = ${colors.alert}
label-close =  cancel
label-close-foreground = ${colors.secondary}
label-separator = |
label-separator-foreground = ${colors.secondary}
menu-0-0 = reboot
menu-0-0-exec = systemctl reboot
menu-0-1 = power off
menu-0-1-exec = systemctl poweroff

[settings]
screenchange-reload = true

[global/wm]
margin-top = 0
margin-bottom = 0
EOF
        log_success "Configuración de Polybar creada"
    fi
}

#############################################################
# Crear scripts de Polybar
#############################################################

create_polybar_scripts() {
    log_info "Creando scripts para Polybar..."
    
    local scripts_dir="$HOME/.config/polybar/scripts"
    mkdir -p "$scripts_dir"
    
    # VPN Status
    cat > "$scripts_dir/vpn-status.sh" << 'EOF'
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
EOF
    
    # Target IP
    cat > "$scripts_dir/target-ip.sh" << 'EOF'
#!/bin/bash
TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
if [[ -f "$TARGET_FILE" ]]; then
    cat "$TARGET_FILE"
else
    echo "No target"
fi
EOF
    
    # Set Target
    cat > "$scripts_dir/set-target.sh" << 'EOF'
#!/bin/bash
TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
mkdir -p "$(dirname "$TARGET_FILE")"
NEW_TARGET=$(echo "" | rofi -dmenu -p "Target IP:")
if [[ -n "$NEW_TARGET" ]]; then
    echo "$NEW_TARGET" > "$TARGET_FILE"
    notify-send "Target Set" "New target: $NEW_TARGET"
fi
EOF
    
    chmod +x "$scripts_dir"/*.sh
    log_success "Scripts de Polybar creados"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 42 - Polybar Configuration"
    echo "=============================================="
    echo ""
    
    create_polybar_config
    create_polybar_scripts
    
    echo ""
    log_success "Módulo Polybar completado"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
