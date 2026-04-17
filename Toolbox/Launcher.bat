@echo off
TITLE Iniciando Toolbox Tecnico Pro...
COLOR 0B

:: Forzar a la consola a ubicarse en la ruta exacta de este archivo .bat (útil en USBs)
cd /d "%~dp0"

echo.
echo Iniciando motor PowerShell...
echo Por favor, acepta los permisos de Administrador si se solicitan.

:: Ejecutar el script saltando cualquier restricción de ejecución local
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Toolbox.ps1"

exit
