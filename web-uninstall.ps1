# zergling - one-line uninstaller for Windows PowerShell.
#
# Usage:
#   irm https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.ps1 | iex
#
# Default: removes the skill at %USERPROFILE%\.claude\skills\zergling\.
#          Your drawings under %USERPROFILE%\.claude\zergling-world\ are KEPT.
#
# To also delete the world (drawings, history, manifest):
#   $env:ZERGLING_PURGE_WORLD = "1"
#   irm https://raw.githubusercontent.com/tjrtm/zergling/main/web-uninstall.ps1 | iex
#
# (We use an env var instead of a parameter because PowerShell's `iex`
#  pipeline doesn't support argument passing the way bash does with `-s --`.)

$ErrorActionPreference = "Stop"

$purgeWorld = ($env:ZERGLING_PURGE_WORLD -eq "1") -or ($env:ZERGLING_PURGE_WORLD -eq "true")
$skill      = Join-Path $env:USERPROFILE ".claude\skills\zergling"
$world      = Join-Path $env:USERPROFILE ".claude\zergling-world"

Write-Host "uninstalling zergling"
Write-Host ""

if (Test-Path $skill) {
  Remove-Item -Recurse -Force $skill
  Write-Host "  removed  $skill   (skill)"
} else {
  Write-Host "  skip     $skill   (skill was not installed)"
}

if ($purgeWorld) {
  if (Test-Path $world) {
    Remove-Item -Recurse -Force $world
    Write-Host "  purged   $world   (world deleted)"
  } else {
    Write-Host "  skip     $world   (no world to purge)"
  }
} else {
  if (Test-Path $world) {
    Write-Host "  kept     $world   (world preserved; set `$env:ZERGLING_PURGE_WORLD=1 and re-run to delete)"
  }
}

Write-Host ""
Write-Host "  done."
