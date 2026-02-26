#!/bin/bash
set -e

# === 1. ПОДГОТОВКА ОКРУЖЕНИЯ ===
if [ -f "/venv/main/bin/activate" ]; then
  source /venv/main/bin/activate
elif [ -f "/opt/venv/bin/activate" ]; then
  source /opt/venv/bin/activate
fi

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"

echo "=== Запуск provisioning (local, no license gate) ==="
echo "[INFO] License/token checks disabled."

# === СПИСКИ ПАКЕТОВ И МОДЕЛЕЙ ===
NODES=(
  "https://github.com/ltdrdata/ComfyUI-Manager"
  "https://github.com/kijai/ComfyUI-WanVideoWrapper"
  "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
  "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
  "https://github.com/chflame163/ComfyUI_LayerStyle"
  "https://github.com/rgthree/rgthree-comfy"
  "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
  "https://github.com/cubiq/ComfyUI_essentials"
  "https://github.com/ClownsharkBatwing/RES4LYF"
  "https://github.com/chrisgoringe/cg-use-everywhere"
  "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
  "https://github.com/Smirnov75/ComfyUI-mxToolkit"
  "https://github.com/TheLustriVA/ComfyUI-Image-Size-Tools"
  "https://github.com/ZhiHui6/zhihui_nodes_comfyui"
  "https://github.com/kijai/ComfyUI-KJNodes"
  "https://github.com/crystian/ComfyUI-Crystools"
  "https://github.com/jnxmx/ComfyUI_HuggingFace_Downloader"
  "https://github.com/plugcrypt/CRT-Nodes"
  "https://github.com/EllangoK/ComfyUI-post-processing-nodes"
  "https://github.com/Fannovel16/comfyui_controlnet_aux"
  "https://github.com/teskor-hub/comfyui-teskors-utils"
)

WRAPER=("https://raw.githubusercontent.com/mytarssocial-sudo/auroshsatoshi/refs/heads/main/xmode.json")

CLIP_MODELS=("https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors")
CKPT_MODELS=("https://huggingface.co/cyberdelia/CyberRealisticPony/resolve/main/CyberRealisticPony_V15.0_FP32.safetensors")
FUN_MODELS=("https://huggingface.co/arhiteector/zimage/resolve/main/Z-Image-Turbo-Fun-Controlnet-Union.safetensors")
TEXT_ENCODERS=("https://huggingface.co/UmeAiRT/ComfyUI-Auto_installer/resolve/refs%2Fpr%2F5/models/clip/umt5-xxl-encoder-fp8-e4m3fn-scaled.safetensors")
UNET_MODELS=("https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors")
VAE_MODELS=("https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors")
DIFFUSION_MODELS=("https://huggingface.co/T5B/Z-Image-Turbo-FP8/resolve/main/z-image-turbo-fp8-e4m3fn.safetensors")
BBOX_0=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/face_yolov8s.pt")
BBOX_1=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/femaleBodyDetection_yolo26.pt")
BBOX_2=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/female_breast-v4.2.pt")

BBOX_3=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/nipples_yolov8s.pt")
BBOX_4=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/vagina-v4.2.pt")
BBOX_5=("https://huggingface.co/gazsuv/xmode/resolve/main/assdetailer.pt")
BBOX_6=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/Eyeful_v2-Paired.pt")
BBOX_7=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/Eyes.pt")
BBOX_8=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/FacesV1.pt")
BBOX_9=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/hand_yolov8s.pt")
# FIX: blob -> resolve (иначе скачается HTML)
BBOX_10=("https://huggingface.co/AunyMoons/loras-pack/resolve/main/foot-yolov8l.pt")

SAM_PTH=("https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/sams/sam_vit_b_01ec64.pth")

QWEN3VL_1=(
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/added_tokens.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/chat_template.jinja"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/config.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/generation_config.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/merges.txt"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/model.safetensors.index.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/preprocessor_config.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/special_tokens_map.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/tokenizer.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/tokenizer_config.json"
  "https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/vocab.json"
)
QWEN3VL_2=("https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/model-00001-of-00002.safetensors")
QWEN3VL_3=("https://huggingface.co/svjack/Qwen3-VL-4B-Instruct-heretic-7refusal/resolve/main/model-00002-of-00002.safetensors")

UPSCALER_MODELS=("https://huggingface.co/gazsuv/pussydetectorv4/resolve/main/4xUltrasharp_4xUltrasharpV10.pt")

### ─────────────────────────────────────────────
### ФУНКЦИИ УСТАНОВКИ
### ─────────────────────────────────────────────

function provisioning_start() {
  provisioning_clone_comfyui
  provisioning_install_base_reqs
  provisioning_get_nodes
  provisioning_apply_ui_design

  # workflow json
  provisioning_get_files "${COMFYUI_DIR}/web"                        "${WRAPER[@]}"
  provisioning_get_files "${COMFYUI_DIR}/user/default/workflows"     "${WRAPER[@]}"

  # models
  provisioning_get_files "${COMFYUI_DIR}/models/clip"                "${CLIP_MODELS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/text_encoders"       "${TEXT_ENCODERS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/unet"                "${UNET_MODELS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/vae"                 "${VAE_MODELS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ckpt"                "${CKPT_MODELS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/model_patches"       "${FUN_MODELS[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/diffusion_models"    "${DIFFUSION_MODELS[@]}"

  # bbox / ultralytics
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_0[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_1[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_2[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_3[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_4[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_5[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_6[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_7[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_8[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_9[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/ultralytics/bbox"     "${BBOX_10[@]}"

  # SAM
  provisioning_get_files "${COMFYUI_DIR}/models/sams"                "${SAM_PTH[@]}"

  # Prompt generator model files
  provisioning_get_files "${COMFYUI_DIR}/models/prompt_generator/Qwen3-VL-4B-Instruct-heretic-7refusal" "${QWEN3VL_1[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/prompt_generator/Qwen3-VL-4B-Instruct-heretic-7refusal" "${QWEN3VL_2[@]}"
  provisioning_get_files "${COMFYUI_DIR}/models/prompt_generator/Qwen3-VL-4B-Instruct-heretic-7refusal" "${QWEN3VL_3[@]}"

  # upscaler
  provisioning_get_files "${COMFYUI_DIR}/models/upscale_models"      "${UPSCALER_MODELS[@]}"

  echo "Provisioning complete. Image will now start natively."
}

# === UI DESIGN ONLY (NO LOCKDOWN) ===
function provisioning_apply_ui_design() {
  export LOGO_URL="https://cdn.discordapp.com/attachments/1257389767662764167/1476663710004023296/123.webp?ex=69a1f1bf&is=69a0a03f&hm=f05d6763b439e7a8f457de889d6235733b15e720818d1226d99828c383f17972&"
  export BG_URL="https://cdn.discordapp.com/attachments/1257389767662764167/1476694800815362089/87299620-D169-414C-9E93-4BADC89A3779.png?ex=69a20eb4&is=69a0bd34&hm=3502eb0e91e8bceced8ad958172b8a33646585f9a62495e771c48deda84df4ac&"

  python - <<'PY'
import os, site

logo_url = os.environ.get("LOGO_URL")
bg_url   = os.environ.get("BG_URL")

paths = []
for sp in site.getsitepackages():
    paths.append(os.path.join(sp, "comfyui_frontend_package", "static", "index.html"))
paths.append("/workspace/ComfyUI/web/index.html")

patch = f"""
<!-- UI DESIGN TWEAKS (NO LOCKDOWN) -->
<style>
  body, #app, .comfy-app-main, .graph-canvas-container {{
      background-image: url("{bg_url}") !important;
      background-size: cover !important;
      background-position: center !important;
      background-attachment: fixed !important;
  }}
  canvas.litegraph, canvas.lgraphcanvas {{
      opacity: 0.88 !important;
  }}
</style>
<script>
  document.addEventListener("DOMContentLoaded", () => {{
    const logo = document.createElement("img");
    logo.src = "{logo_url}";
    logo.style.cssText = "position: fixed; top: 15px; right: 30px; height: 50px; z-index: 10000; pointer-events: none; filter: drop-shadow(0px 4px 6px rgba(0,0,0,0.5));";
    document.body.appendChild(logo);
  }});
</script>
<!-- /UI DESIGN TWEAKS -->
"""

for p in paths:
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            html = f.read()
        if "UI DESIGN TWEAKS (NO LOCKDOWN)" not in html:
            html = html.replace("</head>", patch + "\n</head>")
            with open(p, "w", encoding="utf-8") as f:
                f.write(html)
PY
}

function provisioning_clone_comfyui() {
  if [[ ! -d "${COMFYUI_DIR}" ]]; then
    git clone -q https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}" > /dev/null 2>&1
  fi
  cd "${COMFYUI_DIR}"
}

function provisioning_install_base_reqs() {
  if [[ -f requirements.txt ]]; then
    pip install -q --no-cache-dir -r requirements.txt > /dev/null 2>&1 || true
  fi
}

function provisioning_get_nodes() {
  mkdir -p "${COMFYUI_DIR}/custom_nodes"
  cd "${COMFYUI_DIR}/custom_nodes"

  for repo in "${NODES[@]}"; do
    dir="${repo##*/}"
    path="./${dir}"

    if [[ -d "$path" ]]; then
      (cd "$path" && git pull -q --ff-only > /dev/null 2>&1 || { git fetch -q > /dev/null 2>&1 && git reset -q --hard origin/main > /dev/null 2>&1; })
    else
      git clone -q "$repo" "$path" --recursive > /dev/null 2>&1 || true
    fi

    requirements="${path}/requirements.txt"
    if [[ -f "$requirements" ]]; then
      pip install -q --no-cache-dir -r "$requirements" > /dev/null 2>&1 || true
    fi
  done
}

function provisioning_get_files() {
  if [[ $# -lt 2 ]]; then return; fi
  local dir="$1"
  shift
  local files=("$@")

  mkdir -p "$dir"

  for url in "${files[@]}"; do
    if [[ -n "$HF_TOKEN" && "$url" =~ huggingface\.co ]]; then
      wget --header="Authorization: Bearer $HF_TOKEN" -q -nc --content-disposition -P "$dir" "$url" || true
    elif [[ -n "$CIVITAI_TOKEN" && "$url" =~ civitai\.com ]]; then
      wget --header="Authorization: Bearer $CIVITAI_TOKEN" -q -nc --content-disposition -P "$dir" "$url" || true
    else
      wget -q -nc --content-disposition -P "$dir" "$url" || true
    fi
  done
}

# Запуск provisioning
if [[ ! -f /.noprovisioning ]]; then
  provisioning_start
fi

echo "=========================================================="
echo "✅ Установка завершена! ComfyUI успешно подготовлен."
echo "=========================================================="
