#!/usr/bin/env bash

echo "═══════════════════════════════════════════════════════"
echo "  REPARACIÓN BSPWM - Fix de Inicio"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "1. Haciendo bspwmrc ejecutable..."
chmod +x ~/.config/bspwm/bspwmrc 2>/dev/null
if [[ -x ~/.config/bspwm/bspwmrc ]]; then
    echo "  ✓ bspwmrc ahora es ejecutable"
else
    echo "  ✗ Error: bspwmrc no existe"
    exit 1
fi

echo ""
echo "2. Creando wrapper de sesión (requiere sudo)..."
sudo tee /usr/local/bin/bspwm-session > /dev/null << 'WRAPPER'
#!/bin/bash
# C3rb3rusDesktop - bspwm session wrapper

# Cargar configuración de usuario
if [ -f "$HOME/.config/bspwm/bspwmrc" ]; then
    exec "$HOME/.config/bspwm/bspwmrc"
else
    # Fallback a config por defecto
    exec /usr/bin/bspwm
fi
WRAPPER

sudo chmod +x /usr/local/bin/bspwm-session
echo "  ✓ Wrapper /usr/local/bin/bspwm-session creado"

echo ""
echo "3. Actualizando archivo de sesión..."
sudo tee /usr/share/xsessions/bspwm.desktop > /dev/null << 'DESKTOP'
[Desktop Entry]
Name=bspwm
Comment=Binary Space Partitioning Window Manager
Exec=/usr/local/bin/bspwm-session
Icon=bspwm
Type=Application
DesktopNames=bspwm
DESKTOP
echo "  ✓ Sesión actualizada en /usr/share/xsessions/bspwm.desktop"

echo ""
echo "4. Verificando configuraciones..."
bash -n ~/.config/bspwm/bspwmrc && echo "  ✓ Sintaxis de bspwmrc correcta" || echo "  ✗ Error de sintaxis"
[[ -x ~/.config/sxhkd/sxhkdrc ]] && echo "  ✓ sxhkdrc ejecutable" || chmod +x ~/.config/sxhkd/sxhkdrc
[[ -x ~/.config/polybar/launch.sh ]] && echo "  ✓ polybar ejecutable" || chmod +x ~/.config/polybar/launch.sh 2>/dev/null

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✓ REPARACIÓN COMPLETADA"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Ahora:"
echo "  1. Cierra sesión (logout)"
echo "  2. En el login, selecciona 'bspwm' en el menú de sesiones"
echo "  3. Inicia sesión"
echo ""
echo "Atajos una vez dentro:"
echo "  Super + Return    → Terminal"
echo "  Super + d         → Rofi"
echo "  Super + Shift + r → Reiniciar bspwm"
echo "═══════════════════════════════════════════════════════"
