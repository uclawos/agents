# ============================================================
# Hermes Uninstaller (UCP v0.1, Windows)
# ============================================================

$ErrorActionPreference = "Continue"

$AGENT_ID = "hermes"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"

Write-Host "[ucp] Hermes uninstall starting"

# 1. 停 hermes gateway 进程
try {
    Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and $_.Path.StartsWith("$AGENT_HOME\venv")
    } | ForEach-Object {
        Write-Host "[ucp] Killing hermes-related python PID $($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
} catch {}

# 2. 删 venv
$VENV_DIR = "$AGENT_HOME\venv"
if (Test-Path $VENV_DIR) {
    Write-Host "[ucp] Removing $VENV_DIR"
    Remove-Item -Recurse -Force $VENV_DIR -ErrorAction SilentlyContinue
}

Write-Host "[ucp] Hermes uninstall completed (config/logs preserved)" -ForegroundColor Green
exit 0
