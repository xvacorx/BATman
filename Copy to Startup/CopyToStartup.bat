@echo off
setlocal
echo.
echo ==============================================
echo [ COPY TO STARTUP ]
echo ==============================================
echo Crea un acceso directo en la carpeta de Inicio de Windows.
echo Instrucciones: Arrastra y suelta un archivo sobre esta consola.
echo.

set "target_file=%~1"

if "%target_file%"=="" (
    set /p "target_file=Ingresa o arrastra la ruta del archivo que quieres iniciar con Windows: "
    echo.
)

:: Remove quotes if any
set "target_file=%target_file:"=%"

if not exist "%target_file%" (
    echo [!] Error: El archivo "%target_file%" no existe.
    timeout /t 3 >nul
    goto :eof
)

echo [i] Procesando archivo: "%target_file%"

:: Execute PowerShell to create the shortcut
powershell -NoProfile -ExecutionPolicy Bypass -Command "$wshell = New-Object -ComObject WScript.Shell; $startupFolder = [Environment]::GetFolderPath('Startup'); $shortcutPath = Join-Path $startupFolder (([System.IO.Path]::GetFileNameWithoutExtension('%target_file%')) + '.lnk'); $shortcut = $wshell.CreateShortcut($shortcutPath); $shortcut.TargetPath = '%target_file%'; $shortcut.Save(); if (Test-Path $shortcutPath) { Write-Host '[OK] Acceso directo creado en:' -ForegroundColor Green; Write-Host $shortcutPath -ForegroundColor Cyan } else { Write-Host '[!] Error al crear el acceso directo.' -ForegroundColor Red }"

echo.
timeout /t 3 >nul
endlocal
