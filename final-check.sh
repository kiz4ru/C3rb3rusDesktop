#!/usr/bin/env bash

# Reporte final de verificación completa
cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════════"
echo "  C3RB3RUS DESKTOP - VERIFICACIÓN FINAL COMPLETA"
echo "═══════════════════════════════════════════════════════════════"
echo ""

total_errors=0

# 1. SINTAXIS DE SCRIPTS
echo "1️⃣  VERIFICANDO SINTAXIS DE SCRIPTS..."
error_count=0
for script in $(find . -name "*.sh" -type f); do
    if ! bash -n "$script" 2>/dev/null; then
        echo "  ✗ Error de sintaxis: $script"
        ((error_count++))
    fi
done
if [[ $error_count -eq 0 ]]; then
    echo "  ✓ Todos los scripts tienen sintaxis correcta"
else
    echo "  ✗ $error_count scripts con errores de sintaxis"
    ((total_errors+=error_count))
fi

# 2. PERMISOS EJECUTABLES
echo ""
echo "2️⃣  VERIFICANDO PERMISOS EJECUTABLES..."
required_executables=(
    "install.sh"
    "menu.sh"
    "config/bspwm/bspwmrc"
    "config/sxhkd/sxhkdrc"
    "config/polybar/launch.sh"
)

error_count=0
for file in "${required_executables[@]}"; do
    if [[ -f "$file" ]]; then
        if [[ -x "$file" ]]; then
            echo "  ✓ $file es ejecutable"
        else
            echo "  ✗ $file NO es ejecutable"
            chmod +x "$file" 2>/dev/null && echo "    → Corregido" || ((error_count++))
        fi
    else
        echo "  ✗ $file NO EXISTE"
        ((error_count++))
    fi
done
if [[ $error_count -gt 0 ]]; then
    ((total_errors+=error_count))
fi

# 3. ARCHIVOS DE CONFIGURACIÓN
echo ""
echo "3️⃣  VERIFICANDO ARCHIVOS DE CONFIGURACIÓN..."
config_files=(
    "config/bspwm/bspwmrc"
    "config/sxhkd/sxhkdrc"
    "config/polybar/config.ini"
    "config/kitty/kitty.conf"
    "config/picom/picom.conf"
    "config/rofi/config.rasi"
)

error_count=0
for file in "${config_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  ✓ $file"
    else
        echo "  ✗ FALTA: $file"
        ((error_count++))
    fi
done
if [[ $error_count -gt 0 ]]; then
    ((total_errors+=error_count))
fi

# 4. ESTRUCTURA DE MÓDULOS
echo ""
echo "4️⃣  VERIFICANDO MÓDULOS..."
modules=(
    "modules/00-checks.sh"
    "modules/10-system.sh"
    "modules/20-pentesting.sh"
    "modules/30-dev.sh"
    "modules/40-bspwm.sh"
    "modules/41-keybinds.sh"
    "modules/42-polybar.sh"
    "modules/43-picom.sh"
    "modules/50-zsh.sh"
    "modules/60-tweaks.sh"
    "modules/99-cleanup.sh"
)

error_count=0
for module in "${modules[@]}"; do
    if [[ -f "$module" ]]; then
        # Verificar que tenga función main
        if grep -q "^main()" "$module" 2>/dev/null; then
            echo "  ✓ $module (con función main)"
        else
            echo "  ⚠ $module (sin función main - puede ser normal para 00-checks.sh)"
        fi
    else
        echo "  ✗ FALTA: $module"
        ((error_count++))
    fi
done
if [[ $error_count -gt 0 ]]; then
    ((total_errors+=error_count))
fi

# 5. REFERENCIAS INCORRECTAS
echo ""
echo "5️⃣  BUSCANDO REFERENCIAS A ARCHIVOS INEXISTENTES..."
if grep -r "validation\.sh" modules/ 2>/dev/null | grep -v "Binary"; then
    echo "  ✗ Encontradas referencias a validation.sh (debería ser 00-checks.sh)"
    ((total_errors++))
else
    echo "  ✓ No hay referencias a validation.sh"
fi

if grep -r "bash.*MODULES_DIR" install.sh menu.sh 2>/dev/null; then
    echo "  ✗ Encontradas ejecuciones con 'bash' (debería ser 'source')"
    ((total_errors++))
else
    echo "  ✓ Módulos se ejecutan con 'source' correctamente"
fi

# 6. WALLPAPERS
echo ""
echo "6️⃣  VERIFICANDO WALLPAPERS..."
if [[ -d "wallpapers" ]]; then
    count=$(find wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) 2>/dev/null | wc -l)
    echo "  ✓ Directorio wallpapers existe ($count imágenes)"
    
    if [[ -L "wallpapers/current.jpg" ]] || [[ -f "wallpapers/current.jpg" ]]; then
        echo "  ✓ Wallpaper predeterminado: current.jpg"
    else
        echo "  ⚠ No hay wallpaper predeterminado configurado"
        if [[ $count -gt 0 ]]; then
            first=$(find wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | head -1)
            ln -sf "$(basename "$first")" "wallpapers/current.jpg" 2>/dev/null && echo "    → Creado current.jpg"
        fi
    fi
else
    echo "  ✗ Directorio wallpapers NO existe"
    ((total_errors++))
fi

# 7. DOCUMENTACIÓN
echo ""
echo "7️⃣  VERIFICANDO DOCUMENTACIÓN..."
docs=(
    "README.md"
    "docs/KEYBINDINGS.md"
    "docs/WALLPAPERS.md"
)

for doc in "${docs[@]}"; do
    if [[ -f "$doc" ]]; then
        echo "  ✓ $doc"
    else
        echo "  ⚠ $doc no existe (opcional)"
    fi
done

# 8. SESIÓN DE BSPWM
echo ""
echo "8️⃣  VERIFICANDO SESIÓN DE BSPWM..."
if [[ -f "/usr/share/xsessions/bspwm.desktop" ]]; then
    echo "  ✓ Sesión registrada en /usr/share/xsessions/bspwm.desktop"
    if grep -q "Exec=/usr/bin/bspwm" /usr/share/xsessions/bspwm.desktop; then
        echo "  ✓ Sesión apunta a /usr/bin/bspwm correctamente"
    else
        echo "  ⚠ Sesión puede tener configuración incorrecta"
    fi
else
    echo "  ⚠ Sesión bspwm.desktop no existe (ejecuta fix-session-definitivo.sh)"
fi

# RESUMEN FINAL
echo ""
echo "═══════════════════════════════════════════════════════════════"
if [[ $total_errors -eq 0 ]]; then
    echo "  ✅ PROYECTO COMPLETAMENTE VERIFICADO Y CORRECTO"
    echo "  Estado: LISTO PARA PRODUCCIÓN"
else
    echo "  ⚠️  SE ENCONTRARON $total_errors PROBLEMAS"
    echo "  Estado: REQUIERE ATENCIÓN"
fi
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 SIGUIENTE PASO:"
echo "  ./install.sh --full    # Instalación completa"
echo "  ./menu.sh              # Menú interactivo"
echo ""

exit $total_errors
