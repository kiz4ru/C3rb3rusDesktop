#!/bin/bash
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     C3rb3rusDesktop - Verificación Rápida               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

errors=0

echo "🔍 Verificando sintaxis..."
for script in install.sh menu.sh uninstall.sh; do
    if bash -n "$script" 2>/dev/null; then
        echo "  ✅ $script"
    else
        echo "  ❌ $script (ERROR)"
        ((errors++))
    fi
done

echo ""
echo "🔍 Verificando módulos..."
for module in modules/*.sh; do
    if bash -n "$module" 2>/dev/null; then
        echo "  ✅ $(basename $module)"
    else
        echo "  ❌ $(basename $module) (ERROR)"
        ((errors++))
    fi
done

echo ""
if [[ $errors -eq 0 ]]; then
    echo "✅ TODO OK - Listo para ejecutar!"
    echo ""
    echo "Para instalar:"
    echo "  ./menu.sh          (menú interactivo)"
    echo "  ./install.sh --full (instalación completa)"
else
    echo "❌ Se encontraron $errors errores"
    exit 1
fi
