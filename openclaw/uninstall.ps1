# ============================================================
# OpenClaw Uninstaller (UCP v0.1, Windows)
# ============================================================
# Removes the agent home dir created by install.ps1.
# Per UCP §4 (uninstall.preserve_user_data=true), this only
# stops processes and removes binary install. The cleanup_dirs
# in agent.toml controls what gets actually deleted — that
# logic lives in sdk-rust install::uninstall(), not here.
# ============================================================

$ErrorActionPreference = "Continue"

$AGENT_ID = "openclaw"
$AGENT_HOME = "$env:USERPROFILE\.uclaw\agents\$AGENT_ID"

Write-Host "[ucp] OpenClaw uninstall starting"
Write-Host "[ucp] AGENT_HOME = $AGENT_HOME"

# 1. Stop running gateway (best effort)
try {
    Write-Host "[ucp] Stopping any running OpenClaw gateway"
    Get-Process node -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and $_.Path.StartsWith($AGENT_HOME)
    } | ForEach-Object {
        Write-Host "[ucp] Killing PID $($_.Id) ($($_.Path))"
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Host "[ucp] (no running processes)" -ForegroundColor Yellow
}

# 2. Remove binary install dir (but keep workspace/logs/config — sdk-rust does that based on preserve_user_data)
$BINARY_DIR = "$AGENT_HOME\core"
$RUNTIME_DIR = "$AGENT_HOME\runtime"

foreach ($dir in @($BINARY_DIR, $RUNTIME_DIR)) {
    if (Test-Path $dir) {
        Write-Host "[ucp] Removing $dir"
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
    }
}

# 3. Remove start.bat / similar shortcuts the upstream installer made
$SHORTCUTS = @(
    "$AGENT_HOME\start.bat",
    "$AGENT_HOME\Windows-Start.bat",
    "$AGENT_HOME\uninstall.bat"
)
foreach ($f in $SHORTCUTS) {
    if (Test-Path $f) { Remove-Item -Force $f -ErrorAction SilentlyContinue }
}

Write-Host "[ucp] OpenClaw uninstall completed (user data preserved at $AGENT_HOME)" -ForegroundColor Green
exit 0
