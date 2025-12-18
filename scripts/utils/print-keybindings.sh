#!/bin/bash

##############################################################
# C3rb3rusDesktop - Print Quick Reference
# Imprime la cheatsheet rápida en terminal
##############################################################

QUICK_REF="$HOME/.config/bspwm/docs/QUICK_REFERENCE.txt"

if [[ -f "$QUICK_REF" ]]; then
    cat "$QUICK_REF"
else
    # Fallback si no existe en .config
    PROJECT_REF="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/docs/QUICK_REFERENCE.txt"
    if [[ -f "$PROJECT_REF" ]]; then
        cat "$PROJECT_REF"
    else
        echo "❌ Quick reference no encontrada"
        echo "Ubicación esperada: $QUICK_REF"
        exit 1
    fi
fi

echo ""
read -p "Presiona ENTER para cerrar..."
