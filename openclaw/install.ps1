# ============================================================
# OpenClaw Installer (UCP v0.1, Windows)
# ============================================================
# Wraps the upstream u-claw installer to comply with UCP §7
# sandboxing conventions: install into ~/.uclaw/agents/openclaw/
# instead of ~/.uclaw/ (so multiple agents don't collide).
#
# Strategy:
#   1. Set UCP-specific env vars (UCLAW_AGENT_DIR, etc.)
#   2. Pull upstream install.ps1 from u-claw repo (or local cache)
#   3. Run it; it respects $env:UCLAW_DIR if set
#   4. Verify by hitting health endpoint
#
# Run by sdk-rust install module, which captures stdout/stderr
# as InstallEvent::Log streams.
# ============================================================

$ErrorActionPreference = "Stop"

# UTF-8 encoding (中文用户名 / 中文 path)
try {
    $null = cmd /c chcp 65001
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
} catch {}

# ---- UCP sandbox paths (per agent.toml) ----
$AGENT_ID = "openclaw"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"
$AGENT_WORKSPACE = "$AGENT_HOME\workspace"
$AGENT_LOGS = "$AGENT_HOME\logs"
$AGENT_CONFIG = "$AGENT_HOME\config"

# Make sure dirs exist
New-Item -ItemType Directory -Force -Path $AGENT_HOME, $AGENT_WORKSPACE, $AGENT_LOGS, $AGENT_CONFIG | Out-Null

Write-Host "[ucp] OpenClaw install starting" -ForegroundColor Cyan
Write-Host "[ucp] AGENT_HOME = $AGENT_HOME"
Write-Host "[ucp] AGENT_WORKSPACE = $AGENT_WORKSPACE"

# ---- Hand off to upstream installer ----
# v0.1 stays simple: assume upstream installer is reachable via:
#   1. Local cache (if Phase 4 offline bundle is unpacked)
#   2. Upstream URL (https://u-claw.org/install.ps1)
#
# Upstream installer respects $env:UCLAW_DIR if we set it.

$env:UCLAW_DIR = $AGENT_HOME
$env:OPENCLAW_HOME = "$AGENT_HOME\data"
$env:OPENCLAW_STATE_DIR = "$AGENT_HOME\data\.openclaw"
$env:OPENCLAW_CONFIG_PATH = "$AGENT_HOME\data\.openclaw\openclaw.json"

# Mirror config for npm (unblock China users without VPN)
$env:NPM_REGISTRY = "https://registry.npmmirror.com"

# Try upstream (production)
$UPSTREAM_URL = "https://u-claw.org/install.ps1"
$LOCAL_CACHE = "$AGENT_HOME\install-upstream.ps1"

try {
    Write-Host "[ucp] Fetching upstream installer from $UPSTREAM_URL"
    Invoke-WebRequest -Uri $UPSTREAM_URL -OutFile $LOCAL_CACHE -UseBasicParsing -TimeoutSec 30
    Write-Host "[ucp] Cached to $LOCAL_CACHE"
}
catch {
    Write-Host "[ucp] Upstream fetch failed: $_" -ForegroundColor Yellow
    if (Test-Path $LOCAL_CACHE) {
        Write-Host "[ucp] Falling back to existing local cache"
    }
    else {
        Write-Host "[ucp] No local cache. Use offline bundle." -ForegroundColor Red
        exit 2
    }
}

# Run it
& powershell -ExecutionPolicy Bypass -File $LOCAL_CACHE
$installExit = $LASTEXITCODE

if ($installExit -ne 0) {
    Write-Host "[ucp] Upstream installer failed with exit $installExit" -ForegroundColor Red
    exit $installExit
}

Write-Host "[ucp] OpenClaw install completed under $AGENT_HOME" -ForegroundColor Green
exit 0
