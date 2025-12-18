#!/usr/bin/env bash

echo "═══════════════════════════════════════════════════════"
echo "  FIX DEFINITIVO - SESIÓN BSPWM"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "1. Verificando instalación de bspwm..."
if command -v bspwm &>/dev/null; then
    bspwm_path=$(which bspwm)
    echo "  ✓ bspwm instalado en: $bspwm_path"
else
    echo "  ✗ bspwm NO está instalado"
    echo "  Instálalo con: sudo apt install -y bspwm sxhkd"
    exit 1
fi

echo ""
echo "2. Eliminando wrapper antiguo si existe..."
sudo rm -f /usr/local/bin/bspwm-session 2>/dev/null && echo "  ✓ Wrapper eliminado" || echo "  ℹ No había wrapper"

echo ""
echo "3. Creando archivo de sesión correcto..."
sudo tee /usr/share/xsessions/bspwm.desktop > /dev/null << 'DESKTOP'
[Desktop Entry]
Name=C3rb3rus (bspwm)
Comment=C3rb3rusDesktop - Binary Space Partitioning Window Manager
Exec=/usr/bin/bspwm
Type=Application
DesktopNames=bspwm
DESKTOP
echo "  ✓ Sesión registrada: /usr/share/xsessions/bspwm.desktop"

echo ""
echo "4. Asegurando permisos correctos..."
chmod +x ~/.config/bspwm/bspwmrc 2>/dev/null && echo "  ✓ bspwmrc ejecutable" || echo "  ⚠ No existe ~/.config/bspwm/bspwmrc"
chmod +x ~/.config/sxhkd/sxhkdrc 2>/dev/null && echo "  ✓ sxhkdrc ejecutable" || echo "  ⚠ No existe sxhkdrc"
chmod +x ~/.config/polybar/launch.sh 2>/dev/null && echo "  ✓ polybar/launch.sh ejecutable" || true

echo ""
echo "5. Verificando sintaxis de configuraciones..."
if [[ -f ~/.config/bspwm/bspwmrc ]]; then
    if bash -n ~/.config/bspwm/bspwmrc 2>/dev/null; then
        echo "  ✓ Sintaxis de bspwmrc correcta"
    else
        echo "  ⚠ Error de sintaxis en bspwmrc"
        bash -n ~/.config/bspwm/bspwmrc
    fi
fi

echo ""
echo "6. Verificando componentes necesarios..."
for cmd in sxhkd polybar picom feh; do
    if command -v $cmd &>/dev/null; then
        echo "  ✓ $cmd instalado"
    else
        echo "  ⚠ $cmd NO instalado (no crítico pero recomendado)"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✓ CONFIGURACIÓN COMPLETADA"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "AHORA:"
echo "  1. Cierra sesión (logout) - NO reinicies"
echo "  2. En la pantalla de login, busca el ícono/menú de sesiones"
echo "  3. Selecciona: 'C3rb3rus (bspwm)'"
echo "  4. Inicia sesión"
echo ""
echo "ATAJOS PRINCIPALES:"
echo "  Super + Return       → Terminal (kitty)"
echo "  Super + d            → Rofi (launcher)"
echo "  Super + Shift + q    → Cerrar ventana"
echo "  Super + Shift + r    → Reiniciar bspwm"
echo "  Super + Shift + e    → Salir"
echo ""
echo "SI SIGUE SIN FUNCIONAR:"
echo "  - Verifica logs: cat ~/.xsession-errors"
echo "  - Prueba manual: startx /usr/bin/bspwm"
echo "  - Ejecuta diagnóstico: ./scripts/diagnose-bspwm.sh"
echo "═══════════════════════════════════════════════════════"
