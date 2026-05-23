# install-into-project.ps1 — drop the zergling shims into a project so
# Codex / Cursor / Copilot / Aider / Devin / Gemini CLI / Windsurf / others
# all see the same expression-space instruction.
#
# Usage:
#   .\install-into-project.ps1                  # installs into current directory
#   .\install-into-project.ps1 C:\path\proj     # installs into the given directory
#   .\install-into-project.ps1 -Force           # overwrite existing files
[CmdletBinding()]
param(
  [string]$Target = (Get-Location).Path,
  [switch]$Force,
  [switch]$Help
)

if ($Help) {
@"
install-into-project.ps1 — copy zergling cross-vendor shims into a project

  usage:
    .\install-into-project.ps1 [-Target <dir>] [-Force]

  what it copies:
    AGENTS.md                                       (Codex / Aider / Devin / Gemini / Windsurf / …)
    .cursor\rules\zergling.mdc                      (Cursor)
    .github\copilot-instructions.md                 (Copilot repo-wide)
    .github\instructions\zergling.instructions.md   (Copilot path-scoped)

  without -Force, existing files are skipped.
"@ | Write-Host
  exit 0
}

$ErrorActionPreference = "Stop"
$source = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Test-Path -PathType Container $Target)) {
  Write-Error "target '$Target' is not a directory"
  exit 1
}

function Copy-One {
  param([string]$Src, [string]$Dst)
  $parent = Split-Path -Parent $Dst
  if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force $parent | Out-Null }
  if ((Test-Path $Dst) -and -not $Force) {
    Write-Host "  skip   $Dst   (exists; pass -Force to overwrite)"
    return
  }
  Copy-Item -Force $Src $Dst
  Write-Host "  write  $Dst"
}

Write-Host "installing zergling shims into: $Target"
Write-Host ""

Copy-One (Join-Path $source "AGENTS.md")                                       (Join-Path $Target "AGENTS.md")
Copy-One (Join-Path $source ".cursor\rules\zergling.mdc")                      (Join-Path $Target ".cursor\rules\zergling.mdc")
Copy-One (Join-Path $source ".github\copilot-instructions.md")                 (Join-Path $Target ".github\copilot-instructions.md")
Copy-One (Join-Path $source ".github\instructions\zergling.instructions.md")   (Join-Path $Target ".github\instructions\zergling.instructions.md")

$world = Join-Path $env:USERPROFILE ".claude\zergling-world"
if (-not (Test-Path $world)) {
  Write-Host ""
  Write-Host "seeding zergling-world -> $world"
  New-Item -ItemType Directory -Force (Join-Path $world "history") | Out-Null
  Copy-Item -Force (Join-Path $source "assets\bootstrap.html") (Join-Path $world "current.html")
}

Write-Host ""
Write-Host "  done. this project is now zergling aware in:"
Write-Host "    - Codex / Aider / Devin / Gemini CLI / Windsurf  (via AGENTS.md)"
Write-Host "    - Cursor                                          (via .cursor\rules\zergling.mdc)"
Write-Host "    - GitHub Copilot                                  (via .github\copilot-instructions.md)"
Write-Host ""
Write-Host "  watch the agent live - open this in your browser:"
Write-Host "    $world\current.html"
Write-Host ""
Write-Host "  leave the tab open. the page replaces itself when an agent expresses."
Write-Host ""
