#!/bin/bash

# ===========================================
# 🗑️  Remove script de comando global
# ===========================================
# Uso: ./uninstall <script>
# Exemplo: ./uninstall audit
# ===========================================

if [ -z "$1" ]; then
    echo "❌ Uso: ./uninstall <script>"
    exit 1
fi

SCRIPT_NAME=$(basename "$1")
TARGET="/usr/local/bin/$SCRIPT_NAME"

# Verifica se existe
if [ ! -e "$TARGET" ]; then
    echo "❌ '$SCRIPT_NAME' não está instalado em /usr/local/bin/"
    exit 1
fi

# Verifica se é um symlink
if [ ! -L "$TARGET" ]; then
    echo "⚠️  '$TARGET' existe mas não é um symlink"
    echo "   Por segurança, não será removido automaticamente"
    echo "   Se quiser remover manualmente: sudo rm $TARGET"
    exit 1
fi

# Mostra destino do symlink antes de remover
LINK_TARGET=$(readlink "$TARGET")
echo "🔗 Link encontrado: $TARGET -> $LINK_TARGET"

# Remove o symlink
sudo rm "$TARGET"

if [ $? -eq 0 ]; then
    echo "✅ '$SCRIPT_NAME' removido de /usr/local/bin/"
else
    echo "❌ Erro ao remover '$SCRIPT_NAME'"
    exit 1
fi
