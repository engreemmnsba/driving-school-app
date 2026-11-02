# Starts the local Firebase server (Auth + Firestore + Functions) for development.
# Usage (from E:\driving_school_app):  .\emulators.ps1
# Data is kept between runs in .emulator-data
Set-Location $PSScriptRoot
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path
# Loading the functions can take more than the default 10 s on this PC.
$env:FUNCTIONS_DISCOVERY_TIMEOUT = "60"
Push-Location "$PSScriptRoot\functions"
npm run build
Pop-Location
$args2 = @("emulators:start", "--only", "auth,firestore,functions", "--export-on-exit", ".emulator-data")
if (Test-Path "$PSScriptRoot\.emulator-data\firebase-export-metadata.json") { $args2 += @("--import", ".emulator-data") }
firebase @args2
