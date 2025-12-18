# 🐺 C3rb3rusDesktop

**Instalador modular para Kali Linux con bspwm Window Manager orientado a Pentesting**

<div align="center">

![Kali Linux](https://img.shields.io/badge/Kali-268BEE?style=for-the-badge&logo=kalilinux&logoColor=white)
![bspwm](https://img.shields.io/badge/bspwm-Window_Manager-purple?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

</div>

---

## 📋 Descripción

C3rb3rusDesktop es un proyecto diseñado para transformar tu instalación de Kali Linux en un entorno de pentesting profesional con un window manager tiling (bspwm), herramientas VPN integradas, y un flujo de trabajo optimizado para plataformas como Hack The Box y TryHackMe.

### ✨ Características Principales

- ✅ **100% Compatible con Kali Linux** - No rompe XFCE ni el sistema base
- 🪟 **bspwm Window Manager** - Gestión eficiente de ventanas con atajos tipo Windows
- 🔐 **Herramientas VPN Integradas** - Conexión rápida a HTB/THM con monitoreo en Polybar
- 🛠️ **Meta-paquetes de Pentesting** - Suite completa de herramientas Kali
- 💻 **Entorno de Desarrollo** - Python, Neovim, VS Code, Kitty
- 🎨 **Interfaz Moderna** - Polybar, Rofi, Picom con tema Dracula
- 📦 **Instalación Modular** - Elige qué componentes instalar
- 🔄 **Totalmente Reversible** - Backups automáticos antes de cambios
- 🚫 **Nunca se ejecuta como root** - Buenas prácticas de seguridad

---

## 🚀 Instalación Rápida

### Opción 1: Menú Interactivo (Recomendado)
```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/C3rb3rusDesktop.git
cd C3rb3rusDesktop

# Ejecutar menú (NO como root)
./menu.sh
```

### Opción 2: Instalación Completa
```bash
# Instalar todos los módulos automáticamente
./install.sh --full
```
**00-checks.sh** - Validaciones del Sistema
- Detecta Kali Linux
- Previene ejecución como root
- Verifica permisos sudo
- Comprueba espacio en disco (5GB mínimo)
- Valida conexión a internet
- Verifica herramientas base (apt, git, curl, wget)
- Crea backups automáticos

### **10-system.sh** - Sistema Base
- Actualización segura (apt update/upgrade)
- Instalación de dependencias esenciales
- Configuración de repositorios oficiales de Kali
- Verificación de integridad del sistema
- Reparación de dependencias rotas

### **20-pentesting.sh** - Herramientas Pentesting
- **Meta-paquetes Kali**: top10, web, information-gathering, vulnerability, passwords, exploitation
- **Herramientas VPN**: OpenVPN, WireGuard, network-manager-openvpn
- **Red & Scanning**: nmap, masscan, wireshark, tcpdump, proxychains4
- **SecLists**: Wordlists completas para pentesting
- **Python Tools**: pwntools, impacket, scapy, shodan
- **Web Pentesting**: gobuster, ffuf, sqlmap, wpscan, burpsuite
- **Exploiting**: metasploit, gdb, radare2, ghidra, pwndbg
- **Workspace**: Estructura organizada en ~/pentesting/

### **30-dev.sh** - Entorno de Desarrollo
- **Python**: pip, venv, poetry, black, flake8, jupyter
- **Node.js & npm**: Configuración sin sudo
- **Neovim**: Configuración moderna con vim-plug y LSP
- **VS Code**: Extensiones para Python, C++, Git
- **Kitty Terminal**: Terminal moderna con soporte GPU
- **Herramientas**: fzf, bat, exa, tldr, oh-my-posh

### **40-bspwm.sh** - Window Manager Base
- Instalación de bspwm + sxhkd
- Polybar (con compilación si es necesario)
- Picom, Rofi, Feh, Dunst
- Nerd Fonts (JetBrainsMono, Hack)
- Thunar file manager
- Flameshot (screenshots)
- Sesión de login para bspwm

### **41-keybinds.sh** - Atajos de Teclado
- Configuración de sxhkd
- Atajos tipo Windows (Super+Enter, Alt+F4)
- Navegación con flechas y vim (hjkl)
- Shortcuts para pentesting (Burpsuite, Wireshark)
- Gestión de VPN y targets

### **42-polybar.sh** - Barra de Estado
- Configuración completa de Polybar
- Módulo VPN (muestra IP de tun0/tun1)
- Módulo Target IP (clickeable)
- Módulos de sistema (CPU, RAM, red)
- Scripts personalizados
- Tema Dracula integrado

### **43-picom.sh** - Compositor
- Configuración de Picom
- Transparencias y sombras
- Fading effects
- Configuración de Rofi
- Tema oscuro optimizado

### **50-zsh.sh** - Shell Moderno
- Instalación de Zsh
- Oh My Zsh framework
- Powerlevel10k theme
- Plugins: autosuggestions, syntax-highlighting, completions
- Aliases para pentesting
- Funciones personalizadas
- Cambio de shell por defecto

### **60-tweaks.sh** - Optimizaciones
- Parámetros de kernel optimizados
- BBR congestion control
- Límites del sistema aumentados
- DNS optimizados (Cloudflare + Google)
- I/O scheduler (SSD/HDD detection)
- Preload para carga rápida
- Desactivación de servicios innecesarios

### **99-cleanup.sh** - Limpieza Final
- Limpieza de caché de paquetes
- Eliminación de archivos temporales
- Limpieza de thumbnails
- Optimización de dpkg
- Logs antiguos eliminadosit
- **Kitty Terminal**: Terminal moderna con soporte GPU
- **Herramientas**: fzf, bat, exa, tldr, oh-my-posh

### 4. **Módulo bspwm** (`modules/bspwm.sh`)
- **Window Manager**: bspwm + sxhkd
- **Polybar**: Barra de estado con módulos personalizados
  - Monitor de VPN (tun0/tun1)
  - IP objetivo (Target IP)
  - CPU, RAM, Red, Batería
- **Compositor**: Picom (transparencias y sombras)
- **Launcher**: Rofi con tema personalizado
- **Atajos**: Tipo Windows (Super+Enter, Alt+F4, etc.)
- **Nerd Fonts**: JetBrainsMono y Hack

### 5. **Scripts de Utilidades VPN** (`scripts/vpn/`)
- `htb_connect.sh` - Conexión a Hack The Box
- `thm_connect.sh` - Conexión a TryHackMe
- `vpn_status.sh` - Monitor de estado VPN
- `target_manager.sh` - Gestor de IPs objetivo

---

## 🎯 Flujo de Trabajo para Pentesting

### 1. Conectar a VPN
```bash
# Hack The Box
~/.config/bspwm/scripts/htb_connect.sh

# TryHackMe
~/.config/bspwm/scripts/thm_connect.sh
```

### 2. Establecer Target
```bash
# Gestor interactivo
~/.config/bspwm/scripts/target_manager.sh

# O directamente
echo "10.10.10.123" > ~/.config/bspwm/target_ip.txt
```

### 3. Monitorear en Polybar
La barra superior mostrará automáticamente:
- 🔐 Estado VPN (IP de tun0/tun1)
- 🎯 IP objetivo actual
- 📊 Recursos del sistema

### 4. Workspace Organizado
```
~/pentesting/
├── htb/          # Máquinas Hack The Box
├── thm/          # Máquinas TryHackMe
├── targets/      # Targets con estructura automática
│   └── 10.10.10.123/
│       ├── nmap/
│       ├── exploits/
│       ├── loot/
│       └── notes/
└── tools/        # Herramientas custom
```

---

## ⌨️ Atajos de Teclado (bspwm)

### Básicos
- `Super + Enter` - Abrir terminal (Kitty)
- `Super + Space` - Launcher (Rofi)
- `Alt + F4` - Cerrar ventana
- `Super + E` - Explorador de archivos
- `Super + W` - Navegador

### Navegación de Ventanas
- `Super + ←↓↑→` - Cambiar foco
- `Super + Shift + ←↓↑→` - Mover ventana
- `Super + Alt + ←↓↑→` - Redimensionar ventana

### Workspaces
- `Super + [1-9]` - Cambiar a workspace
- `Super + Shift + [1-9]` - Mover ventana a workspace

### Pentesting
- `Super + V` - Ver estado VPN
- `Super + B` - Abrir Burpsuite
- `Super + Shift + W` - Abrir Wireshark
- `Print` - Screenshot (Flameshot)

---

## 🔧 Requisitos del Sistema

- **OS**: Kali Linux (rolling)
- **Espacio**: Mínimo 5GB libres
- **RAM**: 4GB recomendado
- **Internet**: Conexión activa
- **Permisos**: Usuario con acceso sudo (NO ejecutar como root)

---

## 🛡️ Seguridad y Buenas Prácticas

### ✅ Lo que hace el script:
- Valida que sea Kali Linux antes de ejecutar
- Previene ejecución como root
- Crea backups automáticos en `backup/`
- Instala bspwm como sesión alternativa (no reemplaza XFCE)
- Usa solo repositorios oficiales de Kali
- Verifica integridad del sistema post-instalación

### ❌ Lo que NO hace:
- No modifica el bootloader
- No elimina XFCE ni otros entornos
- No instala software de terceros sin verificación
- No ejecuta comandos destructivos

---

## 📁 Estructura del Proyecto

```
C3rb3rusDesktop/
├── install.sh                    # Instalador principal
├── menu.sh                       # Menú interactivo avanzado
├── uninstall.sh                  # Desinstalador seguro
│
├── modules/                      # Módulos numerados (ejecución ordenada)
│   ├── 00-checks.sh              # Validaciones del sistema
│   ├── 10-system.sh              # Actualización del sistema
│   ├── 20-pentesting.sh          # Herramientas pentesting + VPN
│   ├── 30-dev.sh                 # Entorno de desarrollo
│   ├── 40-bspwm.sh               # bspwm Window Manager base
│   ├── 41-keybinds.sh            # Configuración de atajos (sxhkd)
│   ├── 42-polybar.sh             # Polybar (barra de estado)
│   ├── 43-picom.sh               # Picom (compositor)
│   ├── 50-zsh.sh                 # Zsh + Powerlevel10k
│   ├── 60-tweaks.sh              # Optimizaciones del sistema
│   └── 99-cleanup.sh             # Limpieza post-instalación
│
├── config/                       # Plantillas de configuración
│   ├── bspwm/                    # Configuraciones bspwm
│   ├── sxhkd/                    # Atajos de teclado
│   ├── polybar/                  # Configuraciones Polybar
│   ├── picom/                    # Compositor
│   └── rofi/                     # Launcher
│
├── scripts/                      # Utilidades y scripts
│   └── vpn/
│       ├── htb_connect.sh        # Conexión Hack The Box
│       ├── thm_connect.sh        # Conexión TryHackMe
│    2.0.0 (2025-12-18)
- ✅ **Arquitectura modular mejorada** con numeración
- ✅ Separación de componentes bspwm (base, keybinds, polybar, picom)
- ✅ Módulo Zsh completo con Powerlevel10k
- ✅ Módulo de optimizaciones del sistema (tweaks)
- ✅ Script menu.sh con interfaz avanzada
- ✅ Script uninstall.sh para desinstalación segura
- ✅ Soporte para instalación: interactiva, completa y personalizada
- ✅ Mejoras en organización de carpetas (config/ en lugar de configs/)

### v1.0.0 (2025-12-18)
- ✅ Lanzamiento inicial
- ✅ Módulos básicos: system, pentesting, dev, bspwm
- ✅ Scripts VPN para HTB/THM
- ✅ Configuraciones de bspwm/polybar/picom
- ✅ Sistema de validación robusto
---

## 🎨 Personalización

### Cambiar Tema de Polybar
Edita `~/.config/polybar/config.ini` en la sección `[colors]`

### Modificar Atajos de Teclado
Edita `~/.config/sxhkd/sxhkdrc`

### Ajustar Espaciado de Ventanas
Edita `~/.config/bspwm/bspwmrc` - Variables `window_gap` y `border_width`

---

## 🐛 Troubleshooting

### El menú no aparece
```bash
sudo apt install whiptail dialog
```

### Polybar no arranca
```bash
~/.config/polybar/launch.sh
tail /tmp/polybar.log
```

### VPN no conecta
```bash
# Ver logs
tail -f /tmp/htb_vpn.log

# Verificar OpenVPN
sudo apt install openvpn --reinstall
```

### bspwm no aparece en login
```bash
# Verificar sesión
ls /usr/share/xsessions/bspwm.desktop

# Reinstalar
sudo apt install bspwm sxhkd
```

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📝 Changelog

### v1.0.0 (2025-12-18)
- ✅ Lanzamiento inicial
- ✅ Módulos: base, tools, dev, bspwm
- ✅ Scripts VPN para HTB/THM
- ✅ Configuraciones completas de bspwm/polybar
- ✅ Sistema de validación robusto
- ✅ Menú interactivo de instalación

---

## 📜 Licencia

Este proyecto está bajo la licencia MIT. Ver archivo `LICENSE` para más detalles.

---

## 👤 Autor

**C3rb3rus Team**

- GitHub: [@tu-usuario](https://github.com/tu-usuario)
- Email: tu@email.com

---

## ⭐ Agradecimientos

- Comunidad de Kali Linux
- Hack The Box y TryHackMe
- Desarrolladores de bspwm, polybar y todas las herramientas incluidas

---

<div align="center">

**¿Te gustó el proyecto? Dale una ⭐**

Made with ❤️ for the pentesting community

</div>
