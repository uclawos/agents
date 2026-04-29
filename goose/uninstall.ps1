# ============================================================
# Goose Uninstaller (UCP v0.1, Windows)
# ============================================================

$ErrorActionPreference = "Continue"

$AGENT_ID = "goose"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"

Write-Host "[ucp] Goose uninstall starting"

# 1. 停 goose serve（如果在跑）
try {
    Get-Process goose -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and $_.Path.StartsWith($AGENT_HOME)
    } | ForEach-Object {
        Write-Host "[ucp] Killing goose PID $($_.Id)"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
} catch {}

# 2. 删 bin/（保留 config/logs，sdk-rust 按 preserve_user_data 决定要不要清）
$BIN_DIR = "$AGENT_HOME\bin"
if (Test-Path $BIN_DIR) {
    Write-Host "[ucp] Removing $BIN_DIR"
    Remove-Item -Recurse -Force $BIN_DIR -ErrorAction SilentlyContinue
}

Write-Host "[ucp] Goose uninstall completed" -ForegroundColor Green
exit 0
