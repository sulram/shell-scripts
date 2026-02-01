#!/bin/bash

# ===========================================
# 📦 Instala script como comando global
# ===========================================
# Uso: ./install <script>
# Exemplo: ./install audit
# ===========================================

if [ -z "$1" ]; then
    echo "❌ Uso: ./install <script>"
    exit 1
fi

SCRIPT="$1"
SCRIPT_NAME=$(basename "$SCRIPT")

if [ ! -f "$SCRIPT" ]; then
    echo "❌ Arquivo '$SCRIPT' não encontrado"
    exit 1
fi

# Garante permissão de execução
chmod +x "$SCRIPT"

# Cria symlink
sudo ln -sf "$(pwd)/$SCRIPT" "/usr/local/bin/$SCRIPT_NAME"

echo "✅ '$SCRIPT_NAME' instalado em /usr/local/bin/$SCRIPT_NAME"
