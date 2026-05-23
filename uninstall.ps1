# zergling uninstaller - Windows PowerShell
#
# Removes the zergling skill from the Claude Code skills directory.
# Does NOT touch %USERPROFILE%\.claude\zergling-world\ (your generated frames,
# history, manifest, shell) unless -PurgeWorld is passed.
#
# Usage:
#   .\uninstall.ps1                  remove the skill, keep the world
#   .\uninstall.ps1 -PurgeWorld      also delete %USERPROFILE%\.claude\zergling-world\
#   .\uninstall.ps1 -DryRun          show what would happen, change nothing
#   .\uninstall.ps1 -Help            help
[CmdletBinding()]
param(
  [switch]$PurgeWorld,
  [switch]$DryRun,
  [switch]$Help
)

if ($Help) {
@"
uninstall.ps1 - remove the zergling skill

  usage:
    .\uninstall.ps1                  remove the skill only (keeps your world)
    .\uninstall.ps1 -PurgeWorld      also delete %USERPROFILE%\.claude\zergling-world\
                                     (current.html, frame.html, version.js,
                                      history\, manifest.json - all of it)
    .\uninstall.ps1 -DryRun          print actions without changing anything
                                     (combinable with -PurgeWorld)
"@ | Write-Host
  exit 0
}

$ErrorActionPreference = "Stop"

$skillDir = Join-Path $env:USERPROFILE ".claude\skills\zergling"
$worldDir = Join-Path $env:USERPROFILE ".claude\zergling-world"

function Invoke-Action {
  param([scriptblock]$Action, [string]$Describe)
  if ($DryRun) {
    Write-Host "  [dry] $Describe"
  } else {
    & $Action
  }
}

function Write-Done { param([string]$Msg) if (-not $DryRun) { Write-Host "  $Msg" } }

Write-Host "uninstalling zergling"
if ($DryRun) { Write-Host "  (dry run - no files will be modified)" }
Write-Host ""

if (Test-Path $skillDir) {
  Invoke-Action { Remove-Item -Recurse -Force $skillDir } "remove $skillDir"
  Write-Done "removed  $skillDir   (skill)"
} else {
  Write-Host "  skip     $skillDir   (skill was not installed)"
}

if ($PurgeWorld) {
  if (Test-Path $worldDir) {
    Invoke-Action { Remove-Item -Recurse -Force $worldDir } "remove $worldDir"
    Write-Done "purged   $worldDir   (world deleted)"
  } else {
    Write-Host "  skip     $worldDir   (no world to purge)"
  }
} else {
  if (Test-Path $worldDir) {
    Write-Host "  kept     $worldDir   (world preserved; pass -PurgeWorld to delete)"
  }
}

Write-Host ""
Write-Host "  done."
