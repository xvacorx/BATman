@echo off
TITLE Iniciando Toolbox Tecnico Pro...
COLOR 0B

:: Forzar a la consola a ubicarse en la ruta exacta de este archivo .bat (útil en USBs)
cd /d "%~dp0"

echo.
echo Iniciando motor de la Toolbox...
echo Por favor, acepta los permisos de Administrador si se solicitan.

:: 1. Prioridad: PowerShell 7 (pwsh.exe) si está en PATH o instalado en Program Files
where pwsh.exe >nul 2>nul
if %errorlevel% equ 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "Toolbox.ps1"
    exit /b
)

if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
    "%ProgramFiles%\PowerShell\7\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "Toolbox.ps1"
    exit /b
)

if exist "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" (
    "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "Toolbox.ps1"
    exit /b
)

:: 2. Fallback: Windows PowerShell 5.1 clásico
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Toolbox.ps1"

exit /b

