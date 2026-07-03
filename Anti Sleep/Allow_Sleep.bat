@echo off
:: Permite desactivar el Anti Sleep matando unicamente el proceso especifico
echo [i] Desactivando Anti Sleep y restaurando configuracion normal...

:: Mata solo las instancias de PowerShell que estan ejecutando el script de Anti Sleep (SetThreadExecutionState)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WmiObject Win32_Process -Filter \"Name='powershell.exe' AND CommandLine LIKE '%%SetThreadExecutionState%%'\" -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"

echo [OK] Anti Sleep detenido.
timeout /t 3 >nul
