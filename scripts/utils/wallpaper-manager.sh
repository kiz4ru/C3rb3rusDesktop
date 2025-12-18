#!/bin/bash

##############################################################
# C3rb3rusDesktop - Wallpaper Manager
# Cambia wallpapers fácilmente sin tocar código
##############################################################

set -euo pipefail

WALLPAPER_DIR="$HOME/.config/bspwm/wallpapers"
ACTIVE_WALLPAPER="$WALLPAPER_DIR/wallpaper.jpg"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════╗"
echo "║     C3rb3rusDesktop Wallpaper Manager     ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Verificar que existe el directorio
mkdir -p "$WALLPAPER_DIR"

# Función para listar wallpapers disponibles
list_wallpapers() {
    echo -e "${CYAN}📁 Wallpapers disponibles en $WALLPAPER_DIR:${NC}"
    echo ""
    
    local count=0
    local -a files=()
    
    # Buscar imágenes
    while IFS= read -r file; do
        ((count++))
        files+=("$file")
        local name=$(basename "$file")
        local size=$(du -h "$file" | cut -f1)
        
        if [[ "$file" == "$ACTIVE_WALLPAPER" ]] || [[ "$file" == "${ACTIVE_WALLPAPER%.jpg}.png" ]]; then
            echo -e "  ${GREEN}[$count] $name ($size) ← ACTIVO${NC}"
        else
            echo -e "  [$count] $name ($size)"
        fi
    done < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort)
    
    echo ""
    
    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  No hay wallpapers en la carpeta${NC}"
        echo -e "   Copia imágenes a: $WALLPAPER_DIR"
        return 1
    fi
    
    return 0
}

# Función para aplicar wallpaper
apply_wallpaper() {
    local source_file="$1"
    local extension="${source_file##*.}"
    local target="$WALLPAPER_DIR/wallpaper.$extension"
    
    # Copiar como wallpaper activo
    cp "$source_file" "$target"
    
    # Si es PNG pero el sistema busca JPG primero, crear symlink
    if [[ "$extension" == "png" ]]; then
        rm -f "${target%.png}.jpg"
    fi
    
    # Aplicar con feh
    if command -v feh &> /dev/null; then
        feh --bg-fill "$target" && \
        echo -e "${GREEN}✅ Wallpaper aplicado exitosamente${NC}" && \
        echo -e "   Archivo activo: wallpaper.$extension"
    else
        echo -e "${RED}❌ feh no está instalado${NC}"
        return 1
    fi
}

# Menú principal
main_menu() {
    echo -e "${CYAN}Opciones:${NC}"
    echo "  1) Listar wallpapers actuales"
    echo "  2) Cambiar wallpaper (seleccionar de lista)"
    echo "  3) Agregar nuevo wallpaper desde archivo"
    echo "  4) Descargar wallpaper desde URL"
    echo "  5) Aplicar wallpaper actual (reload)"
    echo "  6) Abrir carpeta en file manager"
    echo "  7) Salir"
    echo ""
    read -p "Selecciona [1-7]: " choice
    
    case $choice in
        1)
            list_wallpapers || true
            echo ""
            read -p "Presiona ENTER para continuar..."
            main_menu
            ;;
        2)
            if list_wallpapers; then
                echo ""
                read -p "Número de wallpaper a activar: " num
                
                local selected=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort | sed -n "${num}p")
                
                if [[ -n "$selected" ]]; then
                    apply_wallpaper "$selected"
                else
                    echo -e "${RED}❌ Selección inválida${NC}"
                fi
            fi
            echo ""
            read -p "Presiona ENTER para continuar..."
            main_menu
            ;;
        3)
            echo ""
            read -e -p "Ruta del archivo: " filepath
            filepath="${filepath/#\~/$HOME}"
            
            if [[ -f "$filepath" ]]; then
                local ext="${filepath##*.}"
                if [[ "$ext" =~ ^(jpg|jpeg|png)$ ]]; then
                    # Copiar a wallpapers con nombre único
                    local basename=$(basename "$filepath")
                    local target="$WALLPAPER_DIR/$basename"
                    cp "$filepath" "$target"
                    echo -e "${GREEN}✅ Wallpaper copiado a $target${NC}"
                    
                    read -p "¿Activar ahora? [S/n]: " activate
                    if [[ "$activate" != "n" ]] && [[ "$activate" != "N" ]]; then
                        apply_wallpaper "$target"
                    fi
                else
                    echo -e "${RED}❌ Formato no soportado. Usa JPG o PNG${NC}"
                fi
            else
                echo -e "${RED}❌ Archivo no encontrado${NC}"
            fi
            echo ""
            read -p "Presiona ENTER para continuar..."
            main_menu
            ;;
        4)
            echo ""
            read -p "URL de la imagen: " url
            
            if [[ -n "$url" ]]; then
                echo -e "${YELLOW}⬇️  Descargando...${NC}"
                local filename="downloaded_$(date +%s).jpg"
                
                if wget -q "$url" -O "$WALLPAPER_DIR/$filename"; then
                    echo -e "${GREEN}✅ Descargado como $filename${NC}"
                    
                    read -p "¿Activar ahora? [S/n]: " activate
                    if [[ "$activate" != "n" ]] && [[ "$activate" != "N" ]]; then
                        apply_wallpaper "$WALLPAPER_DIR/$filename"
                    fi
                else
                    echo -e "${RED}❌ Error descargando imagen${NC}"
                fi
            fi
            echo ""
            read -p "Presiona ENTER para continuar..."
            main_menu
            ;;
        5)
            echo ""
            if [[ -f "$ACTIVE_WALLPAPER" ]]; then
                feh --bg-fill "$ACTIVE_WALLPAPER"
                echo -e "${GREEN}✅ Wallpaper reaplicado${NC}"
            elif [[ -f "${ACTIVE_WALLPAPER%.jpg}.png" ]]; then
                feh --bg-fill "${ACTIVE_WALLPAPER%.jpg}.png"
                echo -e "${GREEN}✅ Wallpaper reaplicado${NC}"
            else
                echo -e "${RED}❌ No hay wallpaper activo${NC}"
            fi
            echo ""
            read -p "Presiona ENTER para continuar..."
            main_menu
            ;;
        6)
            if command -v thunar &> /dev/null; then
                thunar "$WALLPAPER_DIR" &
            elif command -v nautilus &> /dev/null; then
                nautilus "$WALLPAPER_DIR" &
            else
                xdg-open "$WALLPAPER_DIR" &
            fi
            echo -e "${GREEN}✅ Abriendo $WALLPAPER_DIR${NC}"
            sleep 1
            main_menu
            ;;
        7)
            echo -e "${CYAN}👋 Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            sleep 1
            main_menu
            ;;
    esac
}

# Inicio
main_menu
