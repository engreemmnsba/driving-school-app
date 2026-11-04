# Saves the public (hiring) copy on GitHub. Run from E:\driving-school-app:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force ; .\public_push.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
git add -A
git commit -m "Fixes from QA and UI testing, screenshots in README" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01LnerUi9tJoUNFNxCPyboMM"
git push
Write-Host "Done: https://github.com/engreemmnsba/driving-school-app" -ForegroundColor Green
