# Publishes everything to the REAL Firebase project (Blaze must be on).
# Usage (from E:\driving_school_app):  .\deploy.ps1
# First time only:  firebase login
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host "1/4 Server: build + tests" -ForegroundColor Cyan
Push-Location functions
npm ci
npm test
Pop-Location

Write-Host "2/4 App (web): release build" -ForegroundColor Cyan
Push-Location app
flutter build web --release -t lib/main_direct.dart
Pop-Location

Write-Host "3/4 Copy the web app next to the download page" -ForegroundColor Cyan
# robocopy exit codes below 8 mean success
robocopy app\build\web hosting /E /NFL /NDL /NJH /NJS /XD download | Out-Null
if ($LASTEXITCODE -ge 8) { throw "copy failed" }
$global:LASTEXITCODE = 0

Write-Host "4/4 Deploy: functions + Firestore rules/indexes + hosting" -ForegroundColor Cyan
firebase deploy --project your-firebase-project --only "functions,firestore,hosting"

Write-Host "Done: https://your-firebase-project.web.app" -ForegroundColor Green
