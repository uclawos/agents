# ============================================================
# Goose Installer (UCP v0.1, Windows)
# ============================================================
# Goose 已经预置在虾盘管家仓库 binaries/goose-package/goose.exe
# 这个 installer 只做"复制到 UCP 沙箱 + PATH 注册"。
#
# 离线友好：不下载任何东西。
# 调用方 = sdk-rust install module，cwd 设在 agents/goose/，
# binaries 在 ../../binaries/goose-package/
# ============================================================

$ErrorActionPreference = "Stop"

# UTF-8 编码（防中文用户名乱码）
try {
    $null = cmd /c chcp 65001
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

$AGENT_ID = "goose"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"
$AGENT_BIN = "$AGENT_HOME\bin"
$AGENT_CONFIG = "$AGENT_HOME\config"
$AGENT_LOGS = "$AGENT_HOME\logs"

New-Item -ItemType Directory -Force -Path $AGENT_HOME, $AGENT_BIN, $AGENT_CONFIG, $AGENT_LOGS | Out-Null

Write-Host "[ucp] Goose install starting"
Write-Host "[ucp] AGENT_HOME = $AGENT_HOME"

# 找仓库内的 binaries/goose-package/goose.exe
# 调用方设了 cwd = agents/goose/，所以仓库根 = ../..
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\")
$SourceExe = Join-Path $RepoRoot "binaries\goose-package\goose.exe"

if (-not (Test-Path $SourceExe)) {
    Write-Host "[ucp] Source binary not found at $SourceExe" -ForegroundColor Red
    Write-Host "[ucp] Try running: pnpm run binaries:goose" -ForegroundColor Yellow
    exit 2
}

Write-Host "[ucp] Source: $SourceExe"
$TargetExe = Join-Path $AGENT_BIN "goose.exe"

# 复制（覆盖）
Copy-Item -Force $SourceExe $TargetExe
Write-Host "[ucp] Copied to $TargetExe"

# 写一个 ~/.uclaw/agents/goose/bin/goose.cmd shim 到 PATH（用户级 PATH）
# 但 v0.1 不动用户 PATH（防止误污染）—— 让 startup_cmd 用绝对路径调
# Phase 4 NSIS installer 时再考虑 PATH 注册
Write-Host "[ucp] Note: goose.exe 仅装到 sandbox，未注册到全局 PATH" -ForegroundColor Cyan
Write-Host "[ucp] startup_cmd 应使用绝对路径 $TargetExe"

# 验证
$Version = & $TargetExe --version 2>&1
Write-Host "[ucp] goose --version: $Version"

Write-Host "[ucp] Goose install completed under $AGENT_HOME" -ForegroundColor Green
exit 0
