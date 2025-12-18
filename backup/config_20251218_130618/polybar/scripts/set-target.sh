#!/bin/bash
TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
mkdir -p "$(dirname "$TARGET_FILE")"
NEW_TARGET=$(echo "" | rofi -dmenu -p "Target IP:")
if [[ -n "$NEW_TARGET" ]]; then
    echo "$NEW_TARGET" > "$TARGET_FILE"
    notify-send "Target Set" "New target: $NEW_TARGET"
fi
