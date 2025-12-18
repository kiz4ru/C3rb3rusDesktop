#!/bin/bash

#############################################################
# C3rb3rusDesktop - Módulo Base
# Descripción: Actualización segura del sistema Kali Linux
#############################################################

set -euo pipefail

# Cargar funciones de logging
# SCRIPT_DIR viene de install.sh cuando se ejecuta con source

#############################################################
# Actualización de repositorios
#############################################################

update_repositories() {
    log_info "Actualizando lista de repositorios..."
    
    # Mantener timeout corto para evitar bloqueos
    sudo apt update -o Acquire::http::Timeout=30 -o Acquire::ftp::Timeout=30 2>&1 | \
        grep -E "Hit|Get|Err" || true
    
    log_success "Repositorios actualizados"
}

#############################################################
# Upgrade completo del sistema
#############################################################

upgrade_system() {
    log_info "Actualizando paquetes del sistema..."
    log_warning "Esto puede tardar varios minutos dependiendo de tu conexión..."
    echo -e "${BLUE}[●●●●●●●●●●] Procesando actualizaciones...${NC}"
    
    # Usar full-upgrade para Kali (recomendado oficialmente)
    # -y: aceptar automáticamente
    # --allow-downgrades: permitir downgrade si es necesario
    sudo apt full-upgrade -y --allow-downgrades 2>&1 | \
        tee /tmp/c3rb3rus_upgrade.log | \
        while IFS= read -r line; do
            echo "$line" | grep -qE "(Preparing|Unpacking|Setting up|Processing)" && echo -ne "\r${BLUE}[▓▓▓▓▓▓▓▓▓▓] $line${NC}\033[K" || echo "$line"
        done
    echo ""
    
    log_success "Sistema actualizado correctamente"
}

#############################################################
# Instalar dependencias base esenciales
#############################################################

install_base_dependencies() {
    log_info "Instalando dependencias base esenciales..."
    
    local base_packages=(
        # Herramientas de compilación
        "build-essential"
        "cmake"
        "make"
        "gcc"
        "g++"
        
        # Bibliotecas de desarrollo
        "libssl-dev"
        "libffi-dev"
        "libxml2-dev"
        "libxslt1-dev"
        "zlib1g-dev"
        
        # Herramientas de red
        "net-tools"
        "dnsutils"
        "traceroute"
        "curl"
        "wget"
        
        # Utilidades del sistema
        "git"
        "vim"
        "htop"
        "tmux"
        "unzip"
        "p7zip-full"
        "tree"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        
        # Interfaz de usuario
        "whiptail"
        "dialog"
    )
    
    log_info "Instalando ${#base_packages[@]} paquetes base..."
    sudo apt install -y "${base_packages[@]}" 2>&1 | \
        grep -E "Setting up|already the newest" || true
    
    log_success "Dependencias base instaladas"
}

#############################################################
# Configurar sources.list para Kali
#############################################################

configure_kali_sources() {
    log_info "Verificando configuración de repositorios de Kali..."
    
    local sources_file="/etc/apt/sources.list"
    local sources_backup="/etc/apt/sources.list.backup_$(date +%Y%m%d)"
    
    # Backup del sources.list actual
    if [[ ! -f "$sources_backup" ]]; then
        sudo cp "$sources_file" "$sources_backup"
        log_info "Backup de sources.list creado"
    fi
    
    # Verificar que los repos oficiales de Kali estén presentes
    if ! grep -q "http.kali.org/kali" "$sources_file"; then
        log_warning "Repositorios oficiales de Kali no encontrados"
        log_info "Agregando repositorios oficiales..."
        
        echo "" | sudo tee -a "$sources_file" > /dev/null
        echo "# Official Kali repositories - Added by C3rb3rusDesktop" | sudo tee -a "$sources_file" > /dev/null
        echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" | sudo tee -a "$sources_file" > /dev/null
        
        log_success "Repositorios oficiales agregados"
    else
        log_success "Repositorios de Kali ya configurados correctamente"
    fi
}

#############################################################
# Limpiar paquetes huérfanos y caché
#############################################################

clean_system() {
    log_info "Limpiando sistema..."
    
    # Autoremove paquetes no necesarios
    sudo apt autoremove -y 2>&1 | grep -E "Removing|removed" || true
    
    # Limpiar caché de APT
    sudo apt autoclean -y
    
    log_success "Sistema limpio"
}

#############################################################
# Verificar integridad del sistema
#############################################################

verify_system_integrity() {
    log_info "Verificando integridad del sistema..."
    
    # Verificar dpkg
    if ! sudo dpkg --audit &>/dev/null; then
        log_warning "Detectados problemas con dpkg, reparando..."
        sudo dpkg --configure -a
    fi
    
    # Verificar dependencias rotas
    if sudo apt --fix-broken install -y 2>&1 | grep -q "0 upgraded"; then
        log_success "No hay dependencias rotas"
    else
        log_info "Dependencias reparadas"
    fi
}

#############################################################
# Función principal
#############################################################

main() {
    echo ""
    echo "=============================================="
    echo "  Módulo Base - Actualización del Sistema"
    echo "=============================================="
    echo ""
    
    configure_kali_sources
    update_repositories
    upgrade_system
    install_base_dependencies
    verify_system_integrity
    clean_system
    
    echo ""
    log_success "Módulo base completado exitosamente"
    echo ""
}

# Ejecutar si se invoca directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
