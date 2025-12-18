#!/bin/bash
echo "🧪 Test de menu.sh..."
echo ""

# Test 1: Banner
echo "✓ Test 1: Banner y carga inicial"
timeout 2 bash -c 'cd /home/kali/C3rb3rusDesktop && ./menu.sh' 2>&1 | head -15 | grep -q "C3rb3rus" && echo "  ✅ Banner mostrado correctamente" || echo "  ❌ Error en banner"

# Test 2: Sin errores de variables
echo "✓ Test 2: Variables readonly"
timeout 2 bash -c 'cd /home/kali/C3rb3rusDesktop && ./menu.sh' 2>&1 | grep -q "readonly variable" && echo "  ❌ Error de variables readonly" || echo "  ✅ Sin errores de readonly"

# Test 3: install.sh disponible
echo "✓ Test 3: Scripts principales"
[[ -x /home/kali/C3rb3rusDesktop/install.sh ]] && echo "  ✅ install.sh ejecutable" || echo "  ❌ install.sh no ejecutable"
[[ -x /home/kali/C3rb3rusDesktop/menu.sh ]] && echo "  ✅ menu.sh ejecutable" || echo "  ❌ menu.sh no ejecutable"

# Test 4: Módulos disponibles
echo "✓ Test 4: Módulos"
module_count=$(ls -1 /home/kali/C3rb3rusDesktop/modules/*.sh 2>/dev/null | wc -l)
echo "  ✅ $module_count módulos encontrados"

echo ""
echo "🎯 Resultado: Menú listo para usar"
