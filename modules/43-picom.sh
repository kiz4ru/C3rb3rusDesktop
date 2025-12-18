#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Picom
# Descripción: Configura compositor Picom
#############################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
source "$SCRIPT_DIR/00-checks.sh"

#############################################################
# Crear configuración de Picom
#############################################################

create_picom_config() {
    log_info "Creando configuración de Picom..."
    
    local picom_dir="$HOME/.config/picom"
    local config_source="$PROJECT_DIR/config/picom"
    
    mkdir -p "$picom_dir"
    
    if [[ -d "$config_source" ]] && [[ -f "$config_source/picom.conf" ]]; then
        cp -r "$config_source"/* "$picom_dir/"
        log_success "Configuración copiada desde $config_source"
    else
        cat > "$picom_dir/picom.conf" << 'EOF'
# C3rb3rusDesktop - Picom Configuration

# Backend
backend = "glx";
glx-no-stencil = true;
glx-copy-from-front = false;

# Opacity
inactive-opacity = 0.95;
active-opacity = 1.0;
frame-opacity = 1.0;
inactive-opacity-override = false;

# Fading
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;

# Blur
blur-background = false;

# Shadow
shadow = true;
shadow-radius = 12;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.7;

shadow-exclude = [
    "name = 'Notification'",
    "class_g = 'Conky'",
    "class_g ?= 'Notify-osd'",
    "class_g = 'Cairo-clock'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Window rules
wintypes:
{
    tooltip = { fade = true; shadow = true; opacity = 0.95; focus = true; };
    dock = { shadow = false; }
    dnd = { shadow = false; }
    popup_menu = { opacity = 0.95; }
    dropdown_menu = { opacity = 0.95; }
};
EOF
        log_success "Configuración de Picom creada"
    fi
}

#############################################################
# Crear configuración de Rofi
#############################################################

create_rofi_config() {
    log_info "Creando configuración de Rofi..."
    
    local rofi_dir="$HOME/.config/rofi"
    local config_source="$PROJECT_DIR/config/rofi"
    
    mkdir -p "$rofi_dir"
    
    if [[ -d "$config_source" ]] && [[ -f "$config_source/config.rasi" ]]; then
        cp -r "$config_source"/* "$rofi_dir/"
        log_success "Configuración copiada desde $config_source"
    else
        cat > "$rofi_dir/config.rasi" << 'EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    display-drun: "Applications:";
    display-run: "Run:";
    display-window: "Windows:";
    drun-display-format: "{name}";
    font: "JetBrainsMono Nerd Font 10";
}

@theme "/usr/share/rofi/themes/Arc-Dark.rasi"
EOF
        log_success "Configuración de Rofi creada"
    fi
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 43 - Picom & Rofi Configuration"
    echo "=============================================="
    echo ""
    
    create_picom_config
    create_rofi_config
    
    echo ""
    log_success "Módulo Picom completado"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
