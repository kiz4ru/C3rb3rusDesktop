#!/usr/bin/env bash

# Script rápido para solucionar bspwm bloqueado
echo "═══════════════════════════════════════════════════════"
echo "  FIX BSPWM BLOQUEADO"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "1. Verificando qué está corriendo..."
if pgrep -x bspwm &>/dev/null; then
    echo "  ✓ bspwm corriendo"
else
    echo "  ✗ bspwm NO está corriendo"
fi

if pgrep -x sxhkd &>/dev/null; then
    echo "  ✓ sxhkd corriendo"
else
    echo "  ✗ sxhkd NO está corriendo - PROBLEMA PROBABLE"
    echo ""
    echo "🔧 Solución: Iniciando sxhkd..."
    sxhkd -c ~/.config/sxhkd/sxhkdrc &
    echo "  ✓ sxhkd iniciado"
    echo ""
    echo "Ahora prueba: Super + Return (abrir terminal)"
fi

if pgrep -x polybar &>/dev/null; then
    echo "  ✓ polybar corriendo"
else
    echo "  ⚠ polybar NO está corriendo"
    echo "🔧 Iniciando polybar..."
    ~/.config/polybar/launch.sh &
fi

echo ""
echo "2. Haciendo configs ejecutables..."
chmod +x ~/.config/bspwm/bspwmrc 2>/dev/null && echo "  ✓ bspwmrc ejecutable"
chmod +x ~/.config/sxhkd/sxhkdrc 2>/dev/null && echo "  ✓ sxhkdrc ejecutable"
chmod +x ~/.config/polybar/launch.sh 2>/dev/null && echo "  ✓ launch.sh ejecutable"

echo ""
echo "3. Verificando wallpaper..."
if feh --version &>/dev/null; then
    wallpaper="$HOME/.config/bspwm/wallpapers/current.jpg"
    if [[ -f "$wallpaper" ]]; then
        feh --bg-fill "$wallpaper" &
        echo "  ✓ Wallpaper aplicado"
    else
        echo "  ⚠ No hay wallpaper current.jpg"
    fi
else
    echo "  ⚠ feh no instalado"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ATAJOS DE TECLADO PRINCIPALES:"
echo "═══════════════════════════════════════════════════════"
echo "  Super + Return       → Terminal"
echo "  Super + d            → Rofi (launcher)"
echo "  Super + Shift + q    → Cerrar ventana"
echo "  Super + Shift + r    → Reiniciar bspwm"
echo "  Super + Shift + e    → Salir"
echo ""
echo "Si nada funciona:"
echo "  Ctrl + Alt + F2      → TTY"
echo "  killall bspwm"
echo "  Ctrl + Alt + F7      → Volver a X"
echo "═══════════════════════════════════════════════════════"
