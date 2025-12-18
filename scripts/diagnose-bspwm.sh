#!/usr/bin/env bash

# Script de diagnóstico para bspwm
echo "═══════════════════════════════════════════════════════"
echo "  DIAGNÓSTICO BSPWM"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "1. Verificando instalación de paquetes..."
for pkg in bspwm sxhkd polybar picom feh kitty rofi; do
    if command -v $pkg &>/dev/null; then
        echo "  ✓ $pkg instalado"
    else
        echo "  ✗ $pkg NO INSTALADO"
    fi
done

echo ""
echo "2. Verificando configuraciones..."
configs=(
    "$HOME/.config/bspwm/bspwmrc"
    "$HOME/.config/sxhkd/sxhkdrc"
    "$HOME/.config/polybar/config.ini"
    "$HOME/.config/picom/picom.conf"
)

for config in "${configs[@]}"; do
    if [[ -f "$config" ]]; then
        if [[ -x "$config" ]] || [[ "$config" == *".ini" ]] || [[ "$config" == *".conf" ]]; then
            echo "  ✓ $config existe y es correcto"
        else
            echo "  ⚠ $config existe pero NO es ejecutable"
        fi
    else
        echo "  ✗ $config NO EXISTE"
    fi
done

echo ""
echo "3. Verificando procesos en ejecución..."
for proc in bspwm sxhkd polybar picom; do
    if pgrep -x $proc &>/dev/null; then
        echo "  ✓ $proc corriendo (PID: $(pgrep -x $proc))"
    else
        echo "  ✗ $proc NO está corriendo"
    fi
done

echo ""
echo "4. Verificando wallpapers..."
wallpaper_dir="$HOME/.config/bspwm/wallpapers"
if [[ -d "$wallpaper_dir" ]]; then
    count=$(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" \) | wc -l)
    echo "  ✓ Directorio wallpapers existe ($count imágenes)"
    if [[ -L "$wallpaper_dir/current.jpg" ]] || [[ -f "$wallpaper_dir/current.jpg" ]]; then
        echo "  ✓ Wallpaper actual: $(readlink -f $wallpaper_dir/current.jpg 2>/dev/null || echo $wallpaper_dir/current.jpg)"
    else
        echo "  ⚠ No hay wallpaper 'current.jpg' configurado"
    fi
else
    echo "  ✗ Directorio wallpapers NO existe"
fi

echo ""
echo "5. Verificando display..."
echo "  DISPLAY: $DISPLAY"
if xrandr &>/dev/null; then
    echo "  ✓ X11 funcionando"
else
    echo "  ✗ X11 no responde"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  SOLUCIONES SI BSPWM SE CONGELA:"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Si estás en una pantalla negra/congelada:"
echo "  1. Presiona: Ctrl+Alt+F2 (terminal tty)"
echo "  2. Login con tu usuario"
echo "  3. Ejecuta: killall bspwm"
echo "  4. Regresa: Ctrl+Alt+F7"
echo ""
echo "Para reiniciar bspwm (si tienes acceso a terminal):"
echo "  Super+Shift+r (atajo de teclado)"
echo "  O ejecuta: bspc wm -r"
echo ""
echo "Para abrir terminal en bspwm:"
echo "  Super+Return  (kitty)"
echo ""
echo "Si sxhkd no funciona (sin atajos):"
echo "  pkill sxhkd && sxhkd &"
echo ""
