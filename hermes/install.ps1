# ============================================================
# Hermes Installer (UCP v0.1, Windows)
# ============================================================
# 装 hermes-agent (NousResearch / 中文社区版) 到 UCP 沙箱目录的
# Python 虚拟环境里。
#
# 复用 v2/u-hermes-pro 的 pip 装机方式：
#   1. 找系统 Python 3.10+
#   2. python -m venv ~/.uclaw/agents/hermes/venv
#   3. venv/Scripts/pip install hermes-agent (走清华镜像)
#   4. 验证 hermes --version
#
# 不动用户已有的 ~/AppData/Local/hermes/ —— 那是其他 hermes 装法，
# 与 UCP 沙箱目录平行存在。
# ============================================================

$ErrorActionPreference = "Stop"

try {
    $null = cmd /c chcp 65001
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$AGENT_ID = "hermes"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"
$VENV_DIR = "$AGENT_HOME\venv"
$AGENT_CONFIG = "$AGENT_HOME\config"
$AGENT_LOGS = "$AGENT_HOME\logs"

New-Item -ItemType Directory -Force -Path $AGENT_HOME, $AGENT_CONFIG, $AGENT_LOGS | Out-Null

Write-Host "[ucp] Hermes install starting"
Write-Host "[ucp] AGENT_HOME = $AGENT_HOME"

# Step 1: 找 Python
$PythonCmd = $null
foreach ($candidate in @("python", "python3", "py")) {
    try {
        $ver = & $candidate --version 2>&1
        if ($ver -match "Python (\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            if ($major -eq 3 -and $minor -ge 10) {
                $PythonCmd = $candidate
                Write-Host "[ucp] Found Python: $candidate -> $ver"
                break
            }
        }
    } catch {}
}

if (-not $PythonCmd) {
    Write-Host "[ucp] Python 3.10+ not found. Install from https://www.python.org/" -ForegroundColor Red
    Write-Host "[ucp] (UCP v0.1 不自动装 Python；v0.2 加内嵌 runtime)" -ForegroundColor Yellow
    exit 2
}

# Step 2: 建 venv
if (-not (Test-Path "$VENV_DIR\Scripts\python.exe")) {
    Write-Host "[ucp] Creating venv at $VENV_DIR"
    & $PythonCmd -m venv $VENV_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ucp] venv creation failed" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} else {
    Write-Host "[ucp] venv exists at $VENV_DIR (reusing)"
}

$VenvPython = "$VENV_DIR\Scripts\python.exe"
$VenvPip = "$VENV_DIR\Scripts\pip.exe"

# Step 3: pip install hermes-agent (走清华镜像)
$Mirror = "https://pypi.tuna.tsinghua.edu.cn/simple"
Write-Host "[ucp] Installing hermes-agent via $Mirror"

& $VenvPip install --upgrade pip -i $Mirror
& $VenvPip install --upgrade hermes-agent -i $Mirror
if ($LASTEXITCODE -ne 0) {
    # 退一步，试官方源
    Write-Host "[ucp] 镜像失败，尝试官方源" -ForegroundColor Yellow
    & $VenvPip install --upgrade hermes-agent
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ucp] pip install hermes-agent failed" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# Step 4: 验证
$VenvHermes = "$VENV_DIR\Scripts\hermes.exe"
if (-not (Test-Path $VenvHermes)) {
    Write-Host "[ucp] hermes.exe not found in venv after install" -ForegroundColor Red
    exit 3
}

$Version = & $VenvHermes --version 2>&1 | Select-Object -First 1
Write-Host "[ucp] hermes --version: $Version"

Write-Host "[ucp] Hermes install completed under $AGENT_HOME" -ForegroundColor Green
exit 0
