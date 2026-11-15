@echo off
cd /d "%~dp0"
title 21 Days Server
set PORT=8021

rem Python vorhanden? Dann ist 21 Days auch im WLAN erreichbar (z. B. vom Handy).
python -c "import sys" >nul 2>nul
if %errorlevel%==0 goto python

rem Sonst: PowerShell-Server ohne Installation (nur auf diesem PC).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port %PORT%
goto :eof

:python
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^(127|169)\.' -and $_.InterfaceAlias -notmatch 'vEthernet|Loopback' } | Select-Object -First 1).IPAddress"`) do set IP=%%i
echo.
echo   21 Days laeuft auf http://localhost:%PORT%
if defined IP echo   Handy im selben WLAN:  http://%IP%:%PORT%
echo   Dieses Fenster offen lassen. Schliessen beendet den Server.
echo.
start "" /b powershell -NoProfile -Command "Start-Sleep -Milliseconds 800; Start-Process 'http://localhost:%PORT%/'"
python -m http.server %PORT% --bind 0.0.0.0
