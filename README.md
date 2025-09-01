# Ollama's Weights
This script organizes the blobs of an Ollama model (for example Gemma3) into separate files:
- `model_quant.gguf`
- `params.txt`
- `license.txt`
- `template.txt`
- `config.json`

⚠️ **Important:**  
This repository **DOES NOT include the model weights**. You must download them legally from Ollama or another official source.  
Use of the models and derivatives is subject to the [Gemma Terms of Use](https://ai.google.dev/gemma/terms).

## Requirements
- Bash
- `jq` to process the manifest

## Usage
```bash
chmod +x extract_blobs.sh
./extract_blobs.sh
```
