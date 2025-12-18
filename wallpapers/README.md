# 🎨 Wallpapers - C3rb3rusDesktop

Esta carpeta contiene los wallpapers del sistema.

## 🔄 Cómo cambiar el wallpaper

**Método simple (recomendado):**
1. Pon tu imagen en esta carpeta
2. Renómbrala a `wallpaper.jpg` o `wallpaper.png`
3. Reinicia bspwm: `Super + Shift + R`

**Formatos soportados:**
- `wallpaper.jpg` (prioridad)
- `wallpaper.png` (fallback)
- Cualquier resolución (se escala automáticamente)

## 📁 Estructura

```
wallpapers/
├── wallpaper.jpg          ← El wallpaper activo (cambia este)
├── wallpaper.png          ← Alternativa PNG
├── backup_1.jpg           ← Tus backups/alternativas
├── backup_2.png
└── README.md
```

## 💡 Tips

- **No edites bspwmrc** - Solo cambia la imagen
- Usa imágenes oscuras para mejor contraste con Polybar
- Resolución recomendada: 1920x1080 o superior
- Aesthetic recomendado: cyberpunk, matrix, hacker, minimal dark

## 🎯 Wallpapers recomendados

**Unsplash (gratis):**
- Matrix: https://unsplash.com/s/photos/matrix-code
- Cyberpunk: https://unsplash.com/s/photos/cyberpunk
- Hacker: https://unsplash.com/s/photos/hacker-dark

**Wallhaven (HD):**
- https://wallhaven.cc/search?q=cyberpunk&categories=111&purity=100&sorting=relevance&order=desc

**Comando rápido para descargar:**
```bash
# Descargar wallpaper de Unsplash
wget "URL_DE_LA_IMAGEN" -O ~/.config/bspwm/wallpapers/wallpaper.jpg

# Aplicar inmediatamente
feh --bg-fill ~/.config/bspwm/wallpapers/wallpaper.jpg
```
