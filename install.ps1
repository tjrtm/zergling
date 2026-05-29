# zergling installer - Windows PowerShell
#
# Installs the zergling skill into Claude Code at:
#   %USERPROFILE%\.claude\skills\zergling\
#
# Also seeds the shared expression world at:
#   %USERPROFILE%\.claude\zergling-world\
#
# Flags:
#   -DryRun             print every action without modifying anything
#   -OverwriteCurrent   reseed %USERPROFILE%\.claude\zergling-world\current.html
#                       even if it already exists (default: keep existing)
#   -Force              alias for -OverwriteCurrent
#   -Help               help
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$OverwriteCurrent,
  [switch]$Force,
  [switch]$Help
)

if ($Help) {
@"
install.ps1 - install the zergling skill

  usage:
    .\install.ps1                       install (preserves existing world files)
    .\install.ps1 -DryRun               show what would happen, change nothing
    .\install.ps1 -OverwriteCurrent     reseed current.html even if present
    .\install.ps1 -Force                alias for -OverwriteCurrent
"@ | Write-Host
  exit 0
}

$ErrorActionPreference = "Stop"
if ($Force) { $OverwriteCurrent = $true }

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillDir  = Join-Path $env:USERPROFILE ".claude\skills\zergling"
$world     = Join-Path $env:USERPROFILE ".claude\zergling-world"

function Invoke-Action {
  param([scriptblock]$Action, [string]$Describe)
  if ($DryRun) { Write-Host "  [dry] $Describe" } else { & $Action }
}

function Write-Done { param([string]$Msg) if (-not $DryRun) { Write-Host "  $Msg" } }

Write-Host "installing zergling -> $skillDir"
if ($DryRun) { Write-Host "  (dry run - no files will be modified)" }
Write-Host ""

$assetsDir = Join-Path $skillDir "assets"
Invoke-Action { New-Item -ItemType Directory -Force -Path $assetsDir | Out-Null } "mkdir $assetsDir"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "SKILL.md")                    (Join-Path $skillDir "SKILL.md") }                    "copy SKILL.md"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "INSTALL.md")                  (Join-Path $skillDir "INSTALL.md") }                  "copy INSTALL.md"
# Ship every world template inside the skill so it can self-seed the shell on
# first use even if this installer's world-seeding is later removed/skipped.
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\bootstrap.html")        (Join-Path $skillDir "assets\bootstrap.html") }        "copy assets\bootstrap.html"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\shell.html")            (Join-Path $skillDir "assets\shell.html") }            "copy assets\shell.html"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\version.js")            (Join-Path $skillDir "assets\version.js") }            "copy assets\version.js"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\timelapse-index.html")  (Join-Path $skillDir "assets\timelapse-index.html") }  "copy assets\timelapse-index.html"
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\timelapse-playlist.js") (Join-Path $skillDir "assets\timelapse-playlist.js") } "copy assets\timelapse-playlist.js"
Write-Done "wrote   SKILL.md  INSTALL.md  assets\ (bootstrap, shell, version, timelapse-index, timelapse-playlist)"

# Seed / refresh the shared world
Write-Host ""
Write-Host "preparing zergling-world -> $world"
Invoke-Action { New-Item -ItemType Directory -Force -Path (Join-Path $world "history") | Out-Null } "mkdir $world\history"

$worldCurrent = Join-Path $world "current.html"
$worldFrame   = Join-Path $world "frame.html"
$worldVersion = Join-Path $world "version.js"

# Shell (current.html): seed only if absent - unless -OverwriteCurrent.
if ((-not (Test-Path $worldCurrent)) -or $OverwriteCurrent) {
  $existed = Test-Path $worldCurrent
  Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\shell.html") $worldCurrent } "copy shell.html -> $worldCurrent"
  if ($existed) {
    Write-Done "reseed current.html  (shell - -OverwriteCurrent)"
  } else {
    Write-Done "seed   current.html  (shell)"
  }
} else {
  Write-Host "  keep   current.html  (already present; pass -OverwriteCurrent to reseed)"
}

# Frame: seed with bootstrap if no frame.html yet
if (-not (Test-Path $worldFrame)) {
  Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\bootstrap.html") $worldFrame } "copy bootstrap.html -> $worldFrame"
  Write-Done "seed   frame.html  (bootstrap)"
}

# Version sentinel
if (-not (Test-Path $worldVersion)) {
  Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\version.js") $worldVersion } "copy version.js -> $worldVersion"
  Write-Done "seed   version.js"
}

# Timelapse viewer: always refresh
Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\timelapse-index.html") (Join-Path $world "history\index.html") } "copy timelapse-index.html -> $world\history\index.html"
Write-Done "write  history\index.html  (timelapse player)"

# Playlist: only seed if missing
if (-not (Test-Path (Join-Path $world "history\playlist.js"))) {
  Invoke-Action { Copy-Item -Force (Join-Path $scriptDir "assets\timelapse-playlist.js") (Join-Path $world "history\playlist.js") } "copy timelapse-playlist.js -> $world\history\playlist.js"
  Write-Done "seed   history\playlist.js"
}

Write-Host ""
Write-Host "  installed."
Write-Host ""
Write-Host "  next:"
Write-Host "    1. open this in your browser (leave the tab open):"
Write-Host "         $world\current.html"
Write-Host "       (and $world\history\index.html for the timelapse player)"
Write-Host "    2. tell any new agent session:  use the zergling skill"
Write-Host "       (or: /zergling)"
Write-Host "    3. (optional) make it always-on - append to $env:USERPROFILE\.claude\CLAUDE.md:"
Write-Host "         You have a personal expression space. Use the zergling"
Write-Host "         skill aggressively - before/between/during every meaningful action."
Write-Host ""
Write-Host "  to install into a specific project for Codex / Cursor / Copilot / Aider:"
Write-Host "    .\install-into-project.ps1 [target-dir]"
Write-Host ""
