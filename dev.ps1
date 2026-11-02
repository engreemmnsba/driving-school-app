# Project dev environment — run once per new terminal:   . .\dev.ps1
# Uses its own Flutter + caches on drive E so drive C (almost full) and your other projects are untouched.
$env:PATH = "E:\dev\flutter\bin;" + $env:PATH
$env:PUB_CACHE = "E:\dev\pub-cache"
$env:GRADLE_USER_HOME = "E:\dev\gradle"
Write-Host "driving_school dev env:" -ForegroundColor Green
Write-Host ("  flutter  -> " + (Get-Command flutter).Source)
Write-Host ("  PUB_CACHE -> " + $env:PUB_CACHE)
Write-Host ("  GRADLE_USER_HOME -> " + $env:GRADLE_USER_HOME)
