@echo off
rem Starts the local Firebase server and the app (web) in two windows.
start "Emulators" powershell -NoExit -ExecutionPolicy Bypass -Command "Set-Location E:\driving_school_app; .\emulators.ps1"
start "App" powershell -NoExit -ExecutionPolicy Bypass -Command "Set-Location E:\driving_school_app; Write-Host Waiting for emulators...; Start-Sleep 60; Set-Location app; flutter run -d web-server --web-port 5500 -t lib/main_direct.dart --dart-define=EMULATOR=true"
