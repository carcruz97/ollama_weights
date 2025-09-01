#!/bin/bash
# =========================================================
# ⚠️ This script does NOT distribute weights. It only organizes local files.
# Requires proper permissions and Ollama to be installed.
# Usage: ./extract_ollama_blobs.sh
# =========================================================

# Destination folder where final files will be saved
DEST_DIR="${HOME}/model_quant_folder"
mkdir -p "$DEST_DIR"
echo "Destination folder: $DEST_DIR"

# Ollama blobs folder (uses environment variable if it exists, otherwise default value)
OLLAMA_DIR="${OLLAMA_DIR:-$HOME/.ollama/models/blobs}"
if [ ! -d "$OLLAMA_DIR" ]; then
    echo "Blobs folder not found: $OLLAMA_DIR"
    exit 1
fi
echo "Blobs folder detected: $OLLAMA_DIR"

# Automatically detect model manifest (searches for the first available model)
MANIFEST_PATH=$(find "$HOME/.ollama/models/manifests/registry.ollama.ai/library/" -name "manifest.json" | head -n 1)
if [ -z "$MANIFEST_PATH" ]; then
    echo "No model manifest found in Ollama."
    exit 1
fi
echo "Manifest detected: $MANIFEST_PATH"

# Verify that jq is installed (to read JSON)
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Install it to continue."
    exit 1
fi

echo "Processing manifest..."

# Read each layer from the manifest and map to final filename
jq -r '.layers[] | "\(.digest) \(.mediaType)"' "$MANIFEST_PATH" | while read digest mediaType; do
    # Get blob filename in Ollama
    blob_file="$OLLAMA_DIR/${digest#sha256-}"
    
    # Determine final filename based on type
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
            echo "Unknown type $mediaType, skipping..."
            continue
            ;;
    esac
    
    # Copy the blob to destination if it exists
    if [ -f "$blob_file" ]; then
        cp "$blob_file" "$dest_file"
        echo "Copied $blob_file → $dest_file"
    else
        echo "Blob $blob_file not found, will be skipped."
    fi
done

echo "====================================================="
echo "Extraction completed. Files organized in $DEST_DIR"
echo "⚠️ Remember: Gemma3 weights are NOT included in this repository."
echo "Check the Gemma Terms of Use: https://ai.google.dev/gemma/terms"
