#!/bin/bash
# =========================================================
# ⚠️ Este script NO distribuye los pesos. Solo organiza archivos locales.
# Requiere permisos adecuados y que Ollama esté instalado.
# Uso: ./extract_ollama_blobs.sh
# =========================================================

# Carpeta destino donde se guardarán los archivos finales
DEST_DIR="${HOME}/model_quant_folder"
mkdir -p "$DEST_DIR"
echo "Carpeta destino: $DEST_DIR"

# Carpeta de blobs de Ollama (usa variable de entorno si existe, sino valor por defecto)
OLLAMA_DIR="${OLLAMA_DIR:-$HOME/.ollama/models/blobs}"
if [ ! -d "$OLLAMA_DIR" ]; then
    echo "No se encontró la carpeta de blobs: $OLLAMA_DIR"
    exit 1
fi
echo "Carpeta de blobs detectada: $OLLAMA_DIR"

# Detectar automáticamente el manifest del modelo (busca el primer modelo disponible)
MANIFEST_PATH=$(find "$HOME/.ollama/models/manifests/registry.ollama.ai/library/" -name "manifest.json" | head -n 1)
if [ -z "$MANIFEST_PATH" ]; then
    echo "No se encontró ningún manifest de modelo en Ollama."
    exit 1
fi
echo "Manifest detectado: $MANIFEST_PATH"

# Verificar que jq esté instalado (para leer JSON)
if ! command -v jq &> /dev/null; then
    echo "jq no está instalado. Instálalo para continuar."
    exit 1
fi

echo "Procesando manifest..."
# Leer cada layer del manifest y mapear al nombre de archivo final
jq -r '.layers[] | "\(.digest) \(.mediaType)"' "$MANIFEST_PATH" | while read digest mediaType; do
    # Obtener nombre de archivo de blob en Ollama
    blob_file="$OLLAMA_DIR/${digest#sha256-}"
    
    # Determinar nombre de archivo final según tipo
    case "$mediaType" in
        "application/vnd.ollama.image.model")
            dest_file="$DEST_DIR/model_quant.gguf"
            ;;
        "application/vnd.ollama.image.params")
            dest_file="$DEST_DIR/params.txt"
            ;;
        "application/vnd.ollama.image.license")
            dest_file="$DEST_DIR/license.txt"
            ;;
        "application/vnd.ollama.image.template")
            dest_file="$DEST_DIR/template.txt"
            ;;
        "application/vnd.docker.container.image.v1+json")
            dest_file="$DEST_DIR/config.json"
            ;;
        *)
            echo "Tipo desconocido $mediaType, saltando..."
            continue
            ;;
    esac

    # Copiar el blob al destino si existe
    if [ -f "$blob_file" ]; then
        cp "$blob_file" "$dest_file"
        echo "Copiado $blob_file → $dest_file"
    else
        echo "No se encontró blob $blob_file, se omitirá."
    fi
done

echo "====================================================="
echo "Extracción completada. Archivos organizados en $DEST_DIR"
echo "⚠️ Recuerda: Los pesos de Gemma3 NO se incluyen en este repositorio."
echo "Consulta los Gemma Terms of Use: https://ai.google.dev/gemma/terms"
