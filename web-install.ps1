# zergling - one-line installer for Windows PowerShell.
#
# Usage:
#   irm https://raw.githubusercontent.com/tjrtm/zergling/main/web-install.ps1 | iex
#
# Installs to:
#   %USERPROFILE%\.claude\skills\zergling\     (the skill - Claude Code reads this)
#   %USERPROFILE%\.claude\zergling-world\      (the agent's world - open current.html)
#
# Re-running is safe: skill files and the timelapse player refresh; the world
# (current.html, frame.html, version.js, history\, manifest.json) is preserved
# if it already exists.
#
# Override the source (advanced - for testing a fork or branch):
#   $env:ZERGLING_BASE = "https://raw.githubusercontent.com/youruser/zergling/yourbranch"
#   irm $env:ZERGLING_BASE/web-install.ps1 | iex

$ErrorActionPreference = "Stop"

$base  = if ($env:ZERGLING_BASE) { $env:ZERGLING_BASE } else { "https://raw.githubusercontent.com/tjrtm/zergling/main" }
$skill = Join-Path $env:USERPROFILE ".claude\skills\zergling"
$world = Join-Path $env:USERPROFILE ".claude\zergling-world"

function Fetch([string]$RelPath, [string]$Dest) {
  Invoke-WebRequest -UseBasicParsing -Uri "$base/$RelPath" -OutFile $Dest | Out-Null
}

function Fetch-IfMissing([string]$RelPath, [string]$Dest) {
  if (Test-Path $Dest) {
    Write-Host "  keep   $Dest  (already present)"
  } else {
    Fetch $RelPath $Dest
    Write-Host "  seed   $Dest"
  }
}

Write-Host "installing zergling"
Write-Host "  source: $base"
Write-Host ""

# Skill - always refresh
New-Item -ItemType Directory -Force -Path (Join-Path $skill "assets") | Out-Null
Write-Host "skill -> $skill"
Fetch "SKILL.md"              (Join-Path $skill "SKILL.md")              ; Write-Host "  wrote  SKILL.md"
Fetch "INSTALL.md"            (Join-Path $skill "INSTALL.md")            ; Write-Host "  wrote  INSTALL.md"
Fetch "assets/bootstrap.html" (Join-Path $skill "assets\bootstrap.html") ; Write-Host "  wrote  assets\bootstrap.html"

# World - seed only if missing; always refresh timelapse player
Write-Host ""
Write-Host "world -> $world"
New-Item -ItemType Directory -Force -Path (Join-Path $world "history") | Out-Null
Fetch-IfMissing "assets/shell.html"             (Join-Path $world "current.html")
Fetch-IfMissing "assets/bootstrap.html"         (Join-Path $world "frame.html")
Fetch-IfMissing "assets/version.js"             (Join-Path $world "version.js")
Fetch           "assets/timelapse-index.html"   (Join-Path $world "history\index.html")
Write-Host      "  wrote  history\index.html  (timelapse player - always refreshed)"
Fetch-IfMissing "assets/timelapse-playlist.js"  (Join-Path $world "history\playlist.js")

Write-Host ""
Write-Host "  installed."
Write-Host ""
Write-Host "  next:"
Write-Host "    1. open this page in your browser and leave the tab open:"
Write-Host "         file:///$($world.Replace('\','/'))/current.html"
Write-Host ""
Write-Host "    2. in any new Claude Code session, type:"
Write-Host "         use the zergling skill        (or:  /zergling)"
Write-Host ""
Write-Host "  watch the agent live. enjoy."
Write-Host ""
