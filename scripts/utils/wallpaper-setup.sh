#!/bin/bash

##############################################################
# C3rb3rusDesktop - Wallpaper Setup Script
# Descarga wallpapers cyberpunk/hacker aesthetic
##############################################################

WALLPAPER_DIR="$HOME/.config/bspwm/wallpapers"
CURRENT_WALLPAPER="$HOME/.config/bspwm/wallpaper.jpg"

# Crear directorio
mkdir -p "$WALLPAPER_DIR"

echo "🎨 C3rb3rusDesktop Wallpaper Setup"
echo "=================================="
echo ""

# Lista de wallpapers cyberpunk/hacker
declare -A WALLPAPERS=(
    ["1"]="https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1920"  # Matrix code
    ["2"]="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1920"  # Matrix green
    ["3"]="https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1920"  # Code dark
    ["4"]="https://images.unsplash.com/photo-1542831371-29b0f74f9713?w=1920"  # Cyber dark
    ["5"]="https://images.unsplash.com/photo-1518770660439-4636190af475?w=1920"  # Tech blue
)

echo "Wallpapers disponibles:"
echo "  1) Matrix Code (verde)"
echo "  2) Matrix Digital (verde neón)"
echo "  3) Code Screen (oscuro)"
echo "  4) Cyberpunk Dark"
echo "  5) Tech Blue"
echo "  6) Usar wallpaper personalizado"
echo "  7) Gradient oscuro (sin descargar)"
echo ""

read -p "Selecciona [1-7]: " CHOICE

case $CHOICE in
    [1-5])
        echo "⬇️  Descargando wallpaper..."
        wget -q --show-progress "${WALLPAPERS[$CHOICE]}" -O "$CURRENT_WALLPAPER"
        
        if [[ $? -eq 0 ]]; then
            echo "✅ Wallpaper descargado"
            feh --bg-fill "$CURRENT_WALLPAPER" 2>/dev/null
            echo "🎨 Wallpaper aplicado"
        else
            echo "❌ Error descargando wallpaper"
            exit 1
        fi
        ;;
    6)
        echo ""
        read -p "Ruta del wallpaper: " CUSTOM_PATH
        if [[ -f "$CUSTOM_PATH" ]]; then
            cp "$CUSTOM_PATH" "$CURRENT_WALLPAPER"
            feh --bg-fill "$CURRENT_WALLPAPER" 2>/dev/null
            echo "✅ Wallpaper personalizado aplicado"
        else
            echo "❌ Archivo no encontrado"
            exit 1
        fi
        ;;
    7)
        echo "🎨 Usando gradient oscuro"
        xsetroot -solid '#0a0e14'
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac

# Agregar a autostart de bspwm
if ! grep -q "feh --bg-fill" "$HOME/.config/bspwm/bspwmrc" 2>/dev/null; then
    echo ""
    echo "💡 Tip: El wallpaper se cargará automáticamente en bspwmrc"
fi

echo ""
echo "✨ Setup completado!"
