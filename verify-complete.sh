#!/usr/bin/env bash

# Script de verificación completa
cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════"
echo "  C3RB3RUS DESKTOP - VERIFICACIÓN COMPLETA"
echo "════════════════════════════════════════════════════"
echo ""

echo "1. Verificando sintaxis de archivos bash..."
error_count=0
for f in modules/*.sh install.sh menu.sh; do
    if ! bash -n "$f" 2>/dev/null; then
        echo "  ✗ Error de sintaxis en: $f"
        ((error_count++))
    else
        echo "  ✓ $f"
    fi
done

echo ""
echo "2. Verificando que existan archivos de configuración..."
config_files=(
    "config/bspwm/bspwmrc"
    "config/sxhkd/sxhkdrc"
    "config/polybar/config.ini"
    "config/kitty/kitty.conf"
    "config/picom/picom.conf"
    "config/rofi/config.rasi"
)

for f in "${config_files[@]}"; do
    if [[ -f "$f" ]]; then
        echo "  ✓ $f"
    else
        echo "  ✗ Falta: $f"
        ((error_count++))
    fi
done

echo ""
echo "3. Verificando estructura de módulos..."
for i in {00..99}; do
    module="modules/${i}-*.sh"
    if compgen -G "$module" > /dev/null; then
        echo "  ✓ Módulo $i existe"
    fi
done

echo ""
echo "4. Verificando variables en 00-checks.sh..."
if grep -q "readonly RED=" modules/00-checks.sh; then
    echo "  ✓ Variables de color definidas"
fi
if grep -q "log_info()" modules/00-checks.sh; then
    echo "  ✓ Funciones de logging definidas"
fi
if grep -q "validate_system()" modules/00-checks.sh; then
    echo "  ✓ Función de validación definida"
fi

echo ""
echo "════════════════════════════════════════════════════"
if [[ $error_count -eq 0 ]]; then
    echo "  ✓ TODOS LOS CHECKS PASARON"
    echo "  Estado: LISTO PARA EJECUTAR"
else
    echo "  ✗ SE ENCONTRARON $error_count ERRORES"
    echo "  Estado: REQUIERE CORRECCIONES"
fi
echo "════════════════════════════════════════════════════"

exit $error_count
