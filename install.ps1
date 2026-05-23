# agent-mirror installer - Windows PowerShell
$ErrorActionPreference = "Stop"

$dest  = Join-Path $env:USERPROFILE ".claude\skills\agent-mirror"
$world = Join-Path $env:USERPROFILE ".claude\agent-world"

Write-Host "installing agent-mirror skill -> $dest"
New-Item -ItemType Directory -Force -Path (Join-Path $dest "assets") | Out-Null
Copy-Item -Force "SKILL.md" -Destination (Join-Path $dest "SKILL.md")
Copy-Item -Force "assets\bootstrap.html" -Destination (Join-Path $dest "assets\bootstrap.html")

if (-not (Test-Path $world)) {
  Write-Host "seeding agent-world -> $world"
  New-Item -ItemType Directory -Force -Path (Join-Path $world "history") | Out-Null
  Copy-Item -Force "assets\bootstrap.html" -Destination (Join-Path $world "current.html")
}

Write-Host ""
Write-Host "  installed."
Write-Host ""
Write-Host "  next:"
Write-Host "    1. open this in your browser (leave the tab open):"
Write-Host "         $world\current.html"
Write-Host "    2. tell any new Claude session:  use the agent-mirror skill"
Write-Host "    3. (optional) make it always-on - append to $env:USERPROFILE\.claude\CLAUDE.md:"
Write-Host "         You have a personal expression space. Use the agent-mirror"
Write-Host "         skill before every action you take."
Write-Host ""
