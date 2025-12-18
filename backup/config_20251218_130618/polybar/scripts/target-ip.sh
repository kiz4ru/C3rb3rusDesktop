#!/bin/bash
TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
if [[ -f "$TARGET_FILE" ]]; then
    cat "$TARGET_FILE"
else
    echo "No target"
fi
