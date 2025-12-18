#!/bin/bash

#############################################################
# C3rb3rusDesktop - Target IP Manager
# Descripción: Gestiona IP objetivo para pentesting
#############################################################

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Archivos
TARGET_FILE="$HOME/.config/bspwm/target_ip.txt"
TARGET_NAME_FILE="$HOME/.config/bspwm/target_name.txt"
TARGETS_DIR="$HOME/pentesting/targets"

mkdir -p "$TARGETS_DIR"
mkdir -p "$(dirname "$TARGET_FILE")"

#############################################################
# Funciones
#############################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

#############################################################
# Establecer target
#############################################################

set_target() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "          Set Target IP"
    echo "═══════════════════════════════════════════"
    echo ""
    
    # Pedir IP
    read -p "Enter target IP: " target_ip
    
    # Validar IP
    if [[ ! $target_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        log_error "Invalid IP format"
        return 1
    fi
    
    # Pedir nombre (opcional)
    read -p "Enter target name (optional): " target_name
    
    # Guardar
    echo "$target_ip" > "$TARGET_FILE"
    [[ -n "$target_name" ]] && echo "$target_name" > "$TARGET_NAME_FILE"
    
    # Crear directorio para el target
    local target_dir="$TARGETS_DIR/$target_ip"
    if [[ -n "$target_name" ]]; then
        target_dir="$TARGETS_DIR/${target_name}_${target_ip}"
    fi
    
    mkdir -p "$target_dir"/{nmap,exploits,loot,notes}
    
    # Crear archivo de notas
    if [[ ! -f "$target_dir/notes/notes.md" ]]; then
        cat > "$target_dir/notes/notes.md" << EOF
# Target: $target_name ($target_ip)

## Information Gathering
- OS: 
- Services:
- Interesting ports:

## Enumeration
\`\`\`bash
# Nmap scan
nmap -sC -sV -oA nmap/initial $target_ip

# Full port scan
nmap -p- -oA nmap/full $target_ip
\`\`\`

## Exploitation
- Vulnerability:
- Exploit:
- Access gained:

## Privilege Escalation
- Method:
- Root/SYSTEM obtained:

## Flags
- User: 
- Root: 

## Lessons Learned
EOF
    fi
    
    # Notificación
    notify-send "Target Set" "IP: $target_ip\nName: $target_name\nDirectory: $target_dir" -u normal -t 5000 2>/dev/null || true
    
    echo ""
    log_success "Target set: $target_ip"
    [[ -n "$target_name" ]] && log_info "Name: $target_name"
    log_info "Directory: $target_dir"
    echo ""
    
    # Hacer ping
    echo -e "${CYAN}Testing connectivity...${NC}"
    if ping -c 1 -W 2 "$target_ip" &>/dev/null; then
        log_success "Target is reachable"
    else
        log_error "Target is not responding to ping"
    fi
    
    echo ""
}

#############################################################
# Mostrar target actual
#############################################################

show_current_target() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "          Current Target"
    echo "═══════════════════════════════════════════"
    echo ""
    
    if [[ ! -f "$TARGET_FILE" ]]; then
        log_error "No target set"
        echo ""
        return 1
    fi
    
    local target_ip=$(cat "$TARGET_FILE")
    local target_name=""
    
    if [[ -f "$TARGET_NAME_FILE" ]]; then
        target_name=$(cat "$TARGET_NAME_FILE")
    fi
    
    echo -e "  ${GREEN}IP:${NC} $target_ip"
    [[ -n "$target_name" ]] && echo -e "  ${GREEN}Name:${NC} $target_name"
    
    # Verificar conectividad
    echo ""
    echo -e "${CYAN}Connectivity:${NC}"
    if ping -c 1 -W 2 "$target_ip" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Target is reachable"
    else
        echo -e "  ${RED}✗${NC} Target is not responding"
    fi
    
    # Encontrar directorio
    local target_dir=$(find "$TARGETS_DIR" -type d -name "*${target_ip}*" | head -1)
    if [[ -n "$target_dir" ]]; then
        echo ""
        echo -e "${CYAN}Working Directory:${NC}"
        echo -e "  $target_dir"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════"
    echo ""
}

#############################################################
# Listar targets guardados
#############################################################

list_targets() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "          Saved Targets"
    echo "═══════════════════════════════════════════"
    echo ""
    
    local targets=("$TARGETS_DIR"/*/)
    
    if [[ ! -e "${targets[0]}" ]]; then
        log_error "No saved targets found"
        echo ""
        return 1
    fi
    
    for target_dir in "${targets[@]}"; do
        local dir_name=$(basename "$target_dir")
        echo -e "  ${GREEN}→${NC} $dir_name"
    done
    
    echo ""
    echo "═══════════════════════════════════════════"
    echo ""
}

#############################################################
# Menú principal
#############################################################

show_menu() {
    clear
    echo ""
    echo "═══════════════════════════════════════════"
    echo "        Target Manager Menu"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "  1) Set new target"
    echo "  2) Show current target"
    echo "  3) List saved targets"
    echo "  4) Quick ping current target"
    echo "  5) Open target directory"
    echo "  0) Exit"
    echo ""
    echo "═══════════════════════════════════════════"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1) set_target ;;
        2) show_current_target ;;
        3) list_targets ;;
        4)
            if [[ -f "$TARGET_FILE" ]]; then
                local ip=$(cat "$TARGET_FILE")
                echo ""
                log_info "Pinging $ip..."
                ping -c 4 "$ip"
            else
                log_error "No target set"
            fi
            ;;
        5)
            if [[ -f "$TARGET_FILE" ]]; then
                local ip=$(cat "$TARGET_FILE")
                local target_dir=$(find "$TARGETS_DIR" -type d -name "*${ip}*" | head -1)
                if [[ -n "$target_dir" ]]; then
                    thunar "$target_dir" &
                    log_success "Opening $target_dir"
                fi
            else
                log_error "No target set"
            fi
            ;;
        0) exit 0 ;;
        *) log_error "Invalid option" ;;
    esac
    
    echo ""
    read -p "Press ENTER to continue..."
    show_menu
}

#############################################################
# Main
#############################################################

# Si se pasa un argumento, establecer como target directamente
if [[ $# -eq 1 ]]; then
    echo "$1" > "$TARGET_FILE"
    log_success "Target set: $1"
    exit 0
fi

# Mostrar menú
show_menu
