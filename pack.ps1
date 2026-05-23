# pack.ps1 - rebuild zergling.skill from tracked source files.
#
# The .skill is a ZIP archive whose root entry is a single
# `zergling\` directory. Rebuild ensures the packaged copy
# is in sync with the working tree.
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$python = (Get-Command python -ErrorAction SilentlyContinue).Source
if (-not $python) { $python = (Get-Command python3 -ErrorAction SilentlyContinue).Source }
if (-not $python) {
  Write-Error "pack.ps1 needs python (python or python3) on PATH to build the ZIP"
  exit 1
}

$builder = Join-Path $scriptDir "tools\build_skill.py"
& $python $builder @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "  done."
