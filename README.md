# Ollama's Weights

Este script organiza los blobs de un modelo de Ollama (por ejemplo Gemma3) en archivos separados:
- `model_quant.gguf`
- `params.txt`
- `license.txt`
- `template.txt`
- `config.json`

⚠️ **Importante:**  
Este repositorio **NO incluye los pesos** del modelo. Debes descargarlos legalmente desde Ollama u otra fuente oficial.  
El uso de los modelos y derivados está sujeto a los [Gemma Terms of Use](https://ai.google.dev/gemma/terms).

## Requisitos
- Bash
- `jq` para procesar el manifest

## Uso
```bash
chmod +x extract_blobs.sh
./extract_blobs.sh
