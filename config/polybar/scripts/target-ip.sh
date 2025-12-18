#!/bin/bash

#############################################################
# Polybar Module: Target IP
# Muestra la IP objetivo con indicador de conectividad
#############################################################

TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"

if [[ -f "$TARGET_FILE" ]]; then
    TARGET=$(cat "$TARGET_FILE" | xargs)
    if [[ -n "$TARGET" ]] && [[ "$TARGET" != "No target" ]]; then
        # Verificar si está activo (ping rápido en background cada 30s)
        if [[ -f "/tmp/target_${TARGET}_active" ]]; then
            echo "🎯 $TARGET"
        else
            echo "🎯 $TARGET"
        fi
    else
        echo "❌ No target"
    fi
else
    echo "❌ No target"
fi
