#!/bin/bash

#############################################################
# Polybar Module: Set Target IP
# Establece una nueva IP objetivo
#############################################################

TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
mkdir -p "$(dirname "$TARGET_FILE")"

NEW_TARGET=$(echo "" | rofi -dmenu -p "Target IP:")

if [[ -n "$NEW_TARGET" ]]; then
    echo "$NEW_TARGET" > "$TARGET_FILE"
    notify-send "🎯 Target Set" "New target: $NEW_TARGET" -u normal -t 3000
fi
