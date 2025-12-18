# 🎨 Sistema de Wallpapers - C3rb3rusDesktop

## 📁 Estructura

```
C3rb3rusDesktop/
├── wallpapers/              ← Plantillas del proyecto
│   ├── README.md           ← Instrucciones
│   └── wallpaper.jpg       ← Tu wallpaper (agrégalo aquí)
│
└── (después de instalar) ~/.config/bspwm/wallpapers/
    ├── wallpaper.jpg       ← Wallpaper ACTIVO
    ├── backup_1.jpg        ← Tus alternativas
    └── backup_2.png
```

## 🚀 Cómo Funciona

### 1. **Sistema Simple**
- bspwm busca automáticamente: `~/.config/bspwm/wallpapers/wallpaper.jpg`
- Si no existe, busca: `wallpaper.png`
- Si no hay ninguno, usa gradient oscuro

### 2. **Cambiar Wallpaper (3 métodos)**

#### Método 1: Reemplazar directamente (más simple)
```bash
# Copia tu imagen con el nombre correcto
cp /ruta/a/mi-imagen.jpg ~/.config/bspwm/wallpapers/wallpaper.jpg

# Reinicia bspwm (Super + Shift + R) o aplica directo:
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg
```

#### Método 2: Wallpaper Manager (GUI interactiva)
```bash
# Ejecutar script
~/.config/bspwm/scripts/wallpaper-manager.sh

# O desde teclado: Super + W, luego P
```

**Opciones del manager:**
1. Listar wallpapers actuales
2. Cambiar wallpaper (seleccionar de lista)
3. Agregar nuevo desde archivo
4. Descargar desde URL
5. Aplicar wallpaper actual (reload)
6. Abrir carpeta en file manager

#### Método 3: Wallpaper aleatorio
```bash
# Desde terminal
find ~/.config/bspwm/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1 | xargs feh --bg-fill

# Desde teclado: Super + W, luego R
```

## ⌨️ Atajos de Teclado

| Atajo | Acción |
|-------|--------|
| `Super + W, P` | Abrir Wallpaper Manager |
| `Super + W, R` | Wallpaper aleatorio |
| `Super + Shift + R` | Reiniciar bspwm (reload wallpaper) |

## 💡 Tips y Trucos

### Formatos Soportados
- ✅ JPG/JPEG (recomendado, menor tamaño)
- ✅ PNG (alta calidad, mayor tamaño)

### Resoluciones Recomendadas
- 1920x1080 (Full HD)
- 2560x1440 (2K)
- 3840x2160 (4K)

### Aesthetic Recomendado
- 🟢 Matrix / Código verde
- 🔵 Cyberpunk / Neon
- ⚫ Hacker / Minimal dark
- 🌃 Cityscape nocturno

### Descargar Wallpapers

**Unsplash (gratis, alta calidad):**
```bash
# Matrix code
wget "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1920" -O ~/.config/bspwm/wallpapers/matrix.jpg

# Cyberpunk
wget "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1920" -O ~/.config/bspwm/wallpapers/cyber.jpg

# Code screen
wget "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=1920" -O ~/.config/bspwm/wallpapers/code.jpg
```

**Wallhaven (especializado en wallpapers):**
- https://wallhaven.cc/search?q=cyberpunk
- https://wallhaven.cc/search?q=matrix
- https://wallhaven.cc/search?q=hacking

### Organizar Colección

```bash
cd ~/.config/bspwm/wallpapers

# Renombrar para tener múltiples opciones
mv matrix.jpg wallpaper.jpg          # Activo
mv cyber.jpg wallpaper_cyber.jpg     # Backup 1
mv code.jpg wallpaper_code.jpg       # Backup 2

# Cambiar entre ellos
cp wallpaper_cyber.jpg wallpaper.jpg
feh --bg-fill wallpaper.jpg
```

## 🔧 Troubleshooting

### El wallpaper no cambia
```bash
# Verificar que feh está instalado
which feh

# Verificar que el archivo existe
ls -lh ~/.config/bspwm/wallpapers/wallpaper.jpg

# Aplicar manualmente
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg

# Reiniciar bspwm
Super + Shift + R
```

### Wallpaper se ve estirado/pixelado
```bash
# Usar --bg-fill en lugar de --bg-scale
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg

# O usa --bg-center para centrar sin escalar
feh --bg-center ~/.config/bspwm/wallpapers/wallpaper.jpg
```

### Quiero un slideshow de wallpapers
```bash
# Crear script de rotación (cada 30 min)
cat > ~/.config/bspwm/scripts/wallpaper-rotate.sh << 'EOF'
#!/bin/bash
while true; do
    WALL=$(find ~/.config/bspwm/wallpapers -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    feh --bg-fill "$WALL"
    sleep 1800  # 30 minutos
done
EOF

chmod +x ~/.config/bspwm/scripts/wallpaper-rotate.sh

# Agregar a bspwmrc:
# ~/.config/bspwm/scripts/wallpaper-rotate.sh &
```

## 📝 Notas Técnicas

### Cómo funciona internamente

**En bspwmrc:**
```bash
WALLPAPER_DIR="$HOME/.config/bspwm/wallpapers"

if [[ -f "$WALLPAPER_DIR/wallpaper.jpg" ]]; then
    feh --bg-fill "$WALLPAPER_DIR/wallpaper.jpg"
elif [[ -f "$WALLPAPER_DIR/wallpaper.png" ]]; then
    feh --bg-fill "$WALLPAPER_DIR/wallpaper.png"
else
    xsetroot -solid '#0a0e14'  # Fallback oscuro
fi
```

### Ventajas del sistema

✅ **No requiere editar código** - Solo cambias la imagen  
✅ **Múltiples formatos** - JPG y PNG automáticos  
✅ **Fallback seguro** - Siempre tendrás un fondo  
✅ **Organización simple** - Una carpeta, múltiples opciones  
✅ **Scripts incluidos** - Manager + setup automático  

## 🎯 Ejemplo de Workflow

```bash
# 1. Descargar varios wallpapers
cd ~/Downloads
wget "URL1" -O matrix.jpg
wget "URL2" -O cyber.jpg
wget "URL3" -O hacker.jpg

# 2. Copiar a la carpeta
cp *.jpg ~/.config/bspwm/wallpapers/

# 3. Activar uno
cp ~/.config/bspwm/wallpapers/matrix.jpg ~/.config/bspwm/wallpapers/wallpaper.jpg
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg

# 4. Cambiar cuando quieras
cp ~/.config/bspwm/wallpapers/cyber.jpg ~/.config/bspwm/wallpapers/wallpaper.jpg
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg
```

---

**🎨 Personaliza tu C3rb3rusDesktop sin tocar una sola línea de código!**
