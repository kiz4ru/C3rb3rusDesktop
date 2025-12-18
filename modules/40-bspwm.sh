#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo bspwm Base
# Descripción: Instala paquetes base para bspwm
#############################################################

set -euo pipefail

# Cargar funciones de logging
# SCRIPT_DIR y PROJECT_DIR vienen de install.sh cuando se ejecuta con source

#############################################################
# Instalar bspwm y componentes base
#############################################################

install_bspwm_base() {
    log_info "Instalando bspwm y componentes base..."
    
    local bspwm_packages=(
        # Window manager y hotkey daemon
        "bspwm"
        "sxhkd"
        
        # Compositor (transparencias y efectos)
        "picom"
        
        # Launcher / menú
        "rofi"
        
        # Wallpaper
        "feh"
        "nitrogen"
        
        # Terminal
        "kitty"
        
        # Sistema
        "xdotool"
        "wmctrl"
        "xclip"
        "xsel"
        
        # Fonts
        "fonts-font-awesome"
        "fonts-powerline"
        "fonts-noto-color-emoji"
        
        # Screenshot
        "scrot"
        "flameshot"
        
        # Notificaciones
        "dunst"
        "libnotify-bin"
        
        # File manager
        "thunar"
        "thunar-archive-plugin"
        "thunar-volman"
        
        # Sistema de archivos
        "gvfs"
        "gvfs-backends"
        
        # Temas y apariencia
        "lxappearance"
        "gtk2-engines-murrine"
        "gtk2-engines-pixbuf"
    )
    
    log_info "Instalando ${#bspwm_packages[@]} paquetes para bspwm..."
    sudo apt install -y "${bspwm_packages[@]}" 2>&1 | grep -E "Setting up|already" || true
    
    log_success "Paquetes base de bspwm instalados"
}

#############################################################
# Instalar Polybar
#############################################################

install_polybar() {
    log_info "Instalando Polybar..."
    
    if sudo apt install -y polybar 2>&1 | grep -E "Setting up|already"; then
        log_success "Polybar instalado desde repositorios"
        return 0
    fi
    
    log_warning "Polybar no encontrado en repos, compilando desde fuentes..."
    
    local polybar_deps=(
        "cmake" "cmake-data" "pkg-config" "libcairo2-dev" "libxcb1-dev"
        "libxcb-util0-dev" "libxcb-randr0-dev" "libxcb-composite0-dev"
        "python3-xcbgen" "xcb-proto" "libxcb-image0-dev" "libxcb-ewmh-dev"
        "libxcb-icccm4-dev" "libxcb-xkb-dev" "libxcb-xrm-dev" "libxcb-cursor-dev"
        "libasound2-dev" "libpulse-dev" "libjsoncpp-dev" "libmpdclient-dev"
        "libcurl4-openssl-dev" "libnl-genl-3-dev"
    )
    
    sudo apt install -y "${polybar_deps[@]}"
    
    cd /tmp
    git clone --depth 1 --branch 3.6.3 https://github.com/polybar/polybar.git
    cd polybar && mkdir build && cd build
    cmake .. && make -j$(nproc) && sudo make install
    
    log_success "Polybar compilado e instalado"
}

#############################################################
# Instalar Nerd Fonts
#############################################################

install_nerd_fonts() {
    log_info "Instalando Nerd Fonts..."
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    if [[ ! -d "$fonts_dir/JetBrainsMono" ]]; then
        log_info "Descargando JetBrainsMono Nerd Font..."
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d "$fonts_dir/JetBrainsMono"
        rm JetBrainsMono.zip
    fi
    
    if [[ ! -d "$fonts_dir/Hack" ]]; then
        log_info "Descargando Hack Nerd Font..."
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
        unzip -q Hack.zip -d "$fonts_dir/Hack"
        rm Hack.zip
    fi
    
    fc-cache -fv >/dev/null 2>&1
    log_success "Nerd Fonts instaladas"
}

#############################################################
# Crear configuración base de bspwm
#############################################################

create_bspwm_config() {
    log_info "Creando configuración base de bspwm..."
    
    local bspwm_dir="$HOME/.config/bspwm"
    local config_source="$PROJECT_DIR/config/bspwm"
    local wallpaper_source="$PROJECT_DIR/wallpapers"
    local docs_source="$PROJECT_DIR/docs"
    
    mkdir -p "$bspwm_dir"
    
    # Si existe config en el proyecto, copiarla
    if [[ -d "$config_source" ]] && [[ "$(ls -A $config_source 2>/dev/null)" ]]; then
        cp -r "$config_source"/* "$bspwm_dir/"
        log_success "Configuración copiada desde $config_source"
        
        # Copiar carpeta de wallpapers
        if [[ -d "$wallpaper_source" ]]; then
            mkdir -p "$bspwm_dir/wallpapers"
            cp -r "$wallpaper_source"/* "$bspwm_dir/wallpapers/" 2>/dev/null || true
            log_info "Carpeta wallpapers copiada a ~/.config/bspwm/wallpapers"
            log_info "💡 Para cambiar wallpaper: edita ~/.config/bspwm/wallpapers/wallpaper.jpg"
        fi
        
        # Copiar documentación
        if [[ -d "$docs_source" ]]; then
            mkdir -p "$bspwm_dir/docs"
            cp -r "$docs_source"/* "$bspwm_dir/docs/" 2>/dev/null || true
            log_info "📖 Documentación copiada a ~/.config/bspwm/docs"
            log_info "💡 Ver atajos: Super + Shift + K"
        fi
    else
        # Crear configuración básica
        cat > "$bspwm_dir/bspwmrc" << 'EOF'
#!/bin/bash

#############################################################
# C3rb3rusDesktop - bspwm Configuration
#############################################################

# Autostart
pgrep -x sxhkd > /dev/null || sxhkd &
pgrep -x polybar > /dev/null || ~/.config/polybar/launch.sh &
pgrep -x picom > /dev/null || picom --config ~/.config/picom/picom.conf &
pgrep -x dunst > /dev/null || dunst &

# Set wallpaper
feh --bg-scale ~/.config/bspwm/wallpaper.jpg 2>/dev/null || nitrogen --restore &

# Workspaces
bspc monitor -d 1 2 3 4 5 6 7 8 9 10

# Window settings
bspc config border_width         2
bspc config window_gap          10
bspc config top_padding         35
bspc config bottom_padding       0
bspc config left_padding         0
bspc config right_padding        0

# Colors
bspc config normal_border_color   "#44475a"
bspc config active_border_color   "#bd93f9"
bspc config focused_border_color  "#ff79c6"
bspc config presel_feedback_color "#6272a4"

# Layout
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config single_monocle       false

# Mouse
bspc config click_to_focus            true
bspc config focus_follows_pointer     true
bspc config pointer_follows_focus     false
bspc config pointer_follows_monitor   true

# Rules para aplicaciones
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a Firefox desktop='^2'
bspc rule -a Chromium desktop='^2'
bspc rule -a Burpsuite state=floating
bspc rule -a Wireshark desktop='^6'
bspc rule -a Pavucontrol state=floating
bspc rule -a Lxappearance state=floating

# VPN notification
if ip addr show tun0 &>/dev/null; then
    notify-send "VPN Status" "Connected to VPN (tun0)" -u normal -t 5000
fi
EOF
        chmod +x "$bspwm_dir/bspwmrc"
        log_success "Configuración básica de bspwm creada"
    fi
}

#############################################################
# Crear sesión de login
#############################################################

create_bspwm_session() {
    log_info "Creando sesión de login para bspwm..."
    
    sudo tee /usr/share/xsessions/bspwm.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=bspwm
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Icon=bspwm
Type=Application
DesktopNames=bspwm
EOF
    
    log_success "Sesión de bspwm disponible en login screen"
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo 40 - bspwm Base Installation"
    echo "=============================================="
    echo ""
    
    install_bspwm_base
    install_polybar
    install_nerd_fonts
    create_bspwm_config
    create_bspwm_session
    
    echo ""
    log_success "Módulo bspwm base completado"
    echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
