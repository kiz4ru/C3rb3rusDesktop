#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo de Validación
# Descripción: Valida que el sistema cumple los requisitos
#              antes de ejecutar la instalación
#############################################################

set -euo pipefail

# Colores para mensajes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Variables globales
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
readonly MIN_DISK_SPACE_GB=5

#############################################################
# Funciones de utilidad
#############################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

#############################################################
# Validación: Sistema operativo es Kali Linux
#############################################################

check_kali_linux() {
    log_info "Verificando si el sistema es Kali Linux..."
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        
        if [[ "$ID" == "kali" ]] || [[ "$ID_LIKE" == *"debian"* && "$NAME" == *"Kali"* ]]; then
            log_success "Sistema Kali Linux detectado: $PRETTY_NAME"
            return 0
        fi
    fi
    
    log_error "Este script está diseñado específicamente para Kali Linux"
    log_error "Sistema actual: $(uname -s) - $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Desconocido')"
    return 1
}

#############################################################
# Validación: No ejecutar como root
#############################################################

check_not_root() {
    log_info "Verificando que no se ejecuta como root..."
    
    if [[ $EUID -eq 0 ]]; then
        log_error "Este script NO debe ejecutarse como root"
        log_error "Por seguridad, ejecuta: ./install.sh (como usuario normal)"
        log_error "El script pedirá sudo solo cuando sea necesario"
        return 1
    fi
    
    log_success "Ejecutando como usuario: $USER (UID: $EUID)"
    return 0
}

#############################################################
# Validación: Usuario tiene permisos sudo
#############################################################

check_sudo_access() {
    log_info "Verificando acceso a sudo..."
    
    if ! sudo -n true 2>/dev/null; then
        log_warning "Necesitas permisos sudo para esta instalación"
        log_info "Se solicitará la contraseña..."
        
        if ! sudo -v; then
            log_error "No se pudo obtener acceso sudo"
            return 1
        fi
    fi
    
    log_success "Acceso sudo confirmado"
    return 0
}

#############################################################
# Validación: Espacio en disco suficiente
#############################################################

check_disk_space() {
    log_info "Verificando espacio en disco..."
    
    local available_gb
    available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [[ $available_gb -lt $MIN_DISK_SPACE_GB ]]; then
        log_error "Espacio insuficiente en disco"
        log_error "Disponible: ${available_gb}GB - Requerido: ${MIN_DISK_SPACE_GB}GB"
        return 1
    fi
    
    log_success "Espacio disponible: ${available_gb}GB"
    return 0
}

#############################################################
# Validación: Conexión a internet
#############################################################

check_internet() {
    log_info "Verificando conexión a internet..."
    
    local test_hosts=("8.8.8.8" "1.1.1.1" "http.kali.org")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            log_success "Conexión a internet disponible (ping a $host)"
            return 0
        fi
    done
    
    log_error "No se detectó conexión a internet"
    log_error "Asegúrate de tener conexión activa antes de continuar"
    return 1
}

#############################################################
# Validación: Herramientas base del sistema
#############################################################

check_base_tools() {
    log_info "Verificando herramientas base necesarias..."
    
    local required_tools=("apt" "dpkg" "wget" "curl" "git")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Herramientas faltantes: ${missing_tools[*]}"
        log_error "Instala con: sudo apt install ${missing_tools[*]}"
        return 1
    fi
    
    log_success "Todas las herramientas base están disponibles"
    return 0
}

#############################################################
# Validación: Verifica que whiptail/dialog están disponibles
#############################################################

check_dialog_tool() {
    log_info "Verificando herramientas de interfaz..."
    
    if command -v whiptail &>/dev/null; then
        log_success "whiptail disponible para menús interactivos"
        return 0
    elif command -v dialog &>/dev/null; then
        log_success "dialog disponible para menús interactivos"
        return 0
    else
        log_warning "whiptail/dialog no encontrados, instalando..."
        if sudo apt install -y whiptail 2>/dev/null; then
            log_success "whiptail instalado correctamente"
            return 0
        else
            log_error "No se pudo instalar whiptail"
            return 1
        fi
    fi
}

#############################################################
# Validación: Estado del gestor de paquetes
#############################################################

check_package_manager() {
    log_info "Verificando estado del gestor de paquetes..."
    
    # Verificar si hay un proceso apt corriendo
    if sudo fuser /var/lib/dpkg/lock-frontend &>/dev/null; then
        log_error "Otro proceso está usando APT"
        log_error "Espera a que termine o ciérralo antes de continuar"
        return 1
    fi
    
    # Verificar integridad de dpkg
    if ! dpkg --audit &>/dev/null; then
        log_warning "Hay problemas con el gestor de paquetes"
        log_info "Intentando reparar..."
        sudo dpkg --configure -a
    fi
    
    log_success "Gestor de paquetes disponible"
    return 0
}

#############################################################
# Validación: Backup de configuraciones existentes
#############################################################

check_and_create_backup() {
    log_info "Verificando necesidad de backup de configuraciones..."
    
    local backup_dir="$PROJECT_DIR/backup/config_$(date +%Y%m%d_%H%M%S)"
    local configs_to_backup=(
        "$HOME/.config/bspwm"
        "$HOME/.config/sxhkd"
        "$HOME/.config/polybar"
        "$HOME/.config/kitty"
        "$HOME/.config/rofi"
        "$HOME/.config/picom"
        "$HOME/.zshrc"
        "$HOME/.bashrc"
    )
    
    local need_backup=false
    for config in "${configs_to_backup[@]}"; do
        if [[ -e "$config" ]]; then
            need_backup=true
            break
        fi
    done
    
    if [[ "$need_backup" == true ]]; then
        log_warning "Se detectaron configuraciones existentes"
        mkdir -p "$backup_dir"
        
        for config in "${configs_to_backup[@]}"; do
            if [[ -e "$config" ]]; then
                local config_name=$(basename "$config")
                cp -r "$config" "$backup_dir/$config_name" 2>/dev/null || true
                log_info "Backup creado: $config_name"
            fi
        done
        
        log_success "Backup guardado en: $backup_dir"
        echo "$backup_dir" > "$PROJECT_DIR/backup/last_backup.txt"
    else
        log_success "No hay configuraciones previas que respaldar"
    fi
    
    return 0
}

#############################################################
# Función principal de validación
#############################################################

validate_system() {
    local validation_failed=false
    
    echo ""
    echo "=============================================="
    echo "  C3rb3rusDesktop - Validación del Sistema"
    echo "=============================================="
    echo ""
    
    # Ejecutar todas las validaciones
    check_kali_linux || validation_failed=true
    check_not_root || validation_failed=true
    check_sudo_access || validation_failed=true
    check_disk_space || validation_failed=true
    check_internet || validation_failed=true
    check_base_tools || validation_failed=true
    check_dialog_tool || validation_failed=true
    check_package_manager || validation_failed=true
    check_and_create_backup || validation_failed=true
    
    echo ""
    
    if [[ "$validation_failed" == true ]]; then
        log_error "Las validaciones del sistema fallaron"
        log_error "Corrige los errores antes de continuar"
        return 1
    fi
    
    log_success "Todas las validaciones pasaron correctamente"
    echo ""
    
    return 0
}

#############################################################
# Exportar funciones para uso externo
#############################################################

# Si el script se ejecuta directamente, validar
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_system
    exit $?
fi

# Si se hace source, solo exportar funciones
export -f log_info log_success log_warning log_error
export -f validate_system
