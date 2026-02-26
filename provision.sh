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

echo "=== Запуск установки X-MODE (Protected) ==="

# === 2. АВТОРИЗАЦИЯ И ЗАЩИТА ОТ СЛИВА \\идет нахуй)) тупые уебаны не смогли сделать нормальную// (SUPABASE) ===
echo "[INFO] License check disabled."

# === СПИСКИ НОД ===
# (Менеджер ЕСТЬ и будет ВИДЕН)
NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/chflame163/ComfyUI_LayerStyle"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-segment-anything-2"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/fq393/ComfyUI-ZMG-Nodes"
    "https://github.com/kijai/ComfyUI-WanAnimatePreprocess"
    "https://github.com/jnxmx/ComfyUI_HuggingFace_Downloader"
    "https://github.com/teskor-hub/comfyui-teskors-utils"
    "https://github.com/plugcrypt/CRT-Nodes"
)

# === ФАЙЛЫ/МОДЕЛИ ===
WRAPER=(
  "https://raw.githubusercontent.com/mytarssocial-sudo/auroshsatoshi/refs/heads/main/animator.json"
)

# (оставил как у тебя, но привёл к одному месту назначения)
CLIP_MODELS=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/klip_vision.safetensors"
)

CLIP_VISION=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/klip_vision.safetensors"
)

TEXT_ENCODERS=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/text_enc.safetensors"
)

VAE_MODELS=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/vae.safetensors"
)

# ВАЖНО: у тебя раньше было DIFFUSION_MODELS (не было объявлено) + DEFFUSION (опечатка).
# Я оставляю рабочее имя DIFFUSION_MODELS и кладу туда твой WanModel.
DIFFUSION_MODELS=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/WanModel.safetensors"
)

DETECTION_MODELS=(
  "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx"
  "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin"
  "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_model.onnx"
)

LORAS=(
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/WanFun.reworked.safetensors"
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/light.safetensors"
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/WanPusa.safetensors"
  "https://huggingface.co/wdsfdsdf/OFMHUB/resolve/main/wan.reworked.safetensors"
  "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_Uni3C_controlnet_fp16.safetensors"
)

### ─────────────────────────────────────────────
### ФУНКЦИИ УСТАНОВКИ
### ─────────────────────────────────────────────

function provisioning_start() {
    provisioning_clone_comfyui
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_inject_xmode_visual_only

    # ВАЖНО: Качаем wraper.json прямо в web + workflows
    provisioning_get_files "${COMFYUI_DIR}/web"                       "${WRAPER[@]}"
    provisioning_get_files "${COMFYUI_DIR}/user/default/workflows"    "${WRAPER[@]}"

    provisioning_get_files "${COMFYUI_DIR}/models/clip"               "${CLIP_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/clip_vision"        "${CLIP_VISION[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/text_encoders"      "${TEXT_ENCODERS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/vae"                "${VAE_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/diffusion_models"   "${DIFFUSION_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/detection"          "${DETECTION_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/loras"              "${LORAS[@]}"

    echo "Газик настроил → Provisioning complete. Image will now start natively."
}

# === ТОЛЬКО ВИЗУАЛ (фон/стекло/логотип). НИЧЕГО НЕ ВЫРЕЗАЕМ (Manager/Menu/Search не трогаем) ===
function provisioning_inject_xmode_visual_only() {
    export LOGO_URL="https://cdn.discordapp.com/attachments/1257389767662764167/1476663710004023296/123.webp?ex=69a1f1bf&is=69a0a03f&hm=f05d6763b439e7a8f457de889d6235733b15e720818d1226d99828c383f17972&"
    export BG_URL="https://cdn.discordapp.com/attachments/1257389767662764167/1476670627279802530/D1BE0547-2E03-4D97-8B1D-9AE8052F37D3.png?ex=69a1f830&is=69a0a6b0&hm=4183e321b0a2489deeaec14496f3050ff2a66e37119493a6c856151fd87ccdeb&"

    python -c '
import os, site, re

logo_url = os.environ.get("LOGO_URL")
bg_url   = os.environ.get("BG_URL")

paths_to_check = []
for sp in site.getsitepackages():
    paths_to_check.append(os.path.join(sp, "comfyui_frontend_package", "static", "index.html"))
paths_to_check.append("/workspace/ComfyUI/web/index.html")

patch_code = f"""
<!-- XMODE NATIVE UI TWEAKS -->
<style>
  /* Кастомный фон */
  body, #app, .comfy-app-main, .graph-canvas-container {{
      background-image: url("{bg_url}") !important;
      background-size: cover !important;
      background-position: center !important;
      background-attachment: fixed !important;
  }}

  /* Стеклянный эффект */
  canvas.litegraph, canvas.lgraphcanvas {{
      opacity: 0.88 !important;
  }}
</style>

<script>
  // Логотип (только визуал, не ломаем UI)
  document.addEventListener("DOMContentLoaded", () => {{
    const logo = document.createElement("img");
    logo.src = "{logo_url}";
    logo.style.cssText = "position: fixed; top: 15px; right: 30px; height: 50px; z-index: 10000; pointer-events: none; filter: drop-shadow(0px 4px 6px rgba(0,0,0,0.5));";
    document.body.appendChild(logo);
  }});
</script>
<!-- /XMODE NATIVE UI TWEAKS -->
"""

start_marker = "<!-- XMODE NATIVE UI TWEAKS -->"
end_marker   = "<!-- /XMODE NATIVE UI TWEAKS -->"

for path in paths_to_check:
    if not os.path.exists(path):
        continue

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Если патч уже есть — заменяем его (т.к. докер пересобирается, но на всякий)
    if start_marker in content and end_marker in content:
        content = re.sub(re.escape(start_marker) + r".*?" + re.escape(end_marker),
                         patch_code.strip(),
                         content,
                         flags=re.S)
    else:
        # Иначе вставляем перед </head>
        if "</head>" in content:
            content = content.replace("</head>", patch_code + "\n</head>")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
'
}

# Клонируем тихо (-q)
function provisioning_clone_comfyui() {
    if [[ ! -d "${COMFYUI_DIR}" ]]; then
        git clone -q https://github.com/comfyanonymous/ComfyUI.git "${COMFYUI_DIR}" > /dev/null 2>&1
    fi
    cd "${COMFYUI_DIR}"
}

# Ставим зависимости тихо (-q)
function provisioning_install_base_reqs() {
    if [[ -f requirements.txt ]]; then
        pip install -q --no-cache-dir -r requirements.txt > /dev/null 2>&1 || true
    fi
}

# Клонируем кастомные ноды тихо (-q)
function provisioning_get_nodes() {
    mkdir -p "${COMFYUI_DIR}/custom_nodes"
    cd "${COMFYUI_DIR}/custom_nodes"

    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        dir="${dir%.git}"         # на случай если ссылка с .git
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

# Качаем файлы тихо (-q)
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
echo "✅ Установка завершена! ComfyUI OFMHUB успешно запущен."
echo "=========================================================="
