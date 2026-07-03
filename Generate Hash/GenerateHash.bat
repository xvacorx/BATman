@echo off
setlocal
NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [i] Solicitando permisos de administrador para lectura completa...
    powershell -NoProfile -Command "Start-Process cmd.exe -ArgumentList '/c', '\"%~s0\"' -Verb RunAs"
    goto :eof
)

:MENU
cls
echo ==============================================
echo [ GENERADOR DE HASH ]
echo ==============================================
echo 1. Sacar MD5/SHA de un archivo
echo 2. Extraer Hardware Hash (Autopilot/Intune CSV)
echo 0. Salir
echo.
set /p "opt=Selecciona una opcion: "

if "%opt%"=="1" goto :FILEHASH
if "%opt%"=="2" goto :HWHASH
if "%opt%"=="0" goto :eof
goto :MENU

:FILEHASH
echo.
set /p "file_path=Arrastra el archivo aqui: "
:: Remove quotes
set "file_path=%file_path:"=%"

if not exist "%file_path%" (
    echo [!] Archivo no encontrado.
    timeout /t 3 >nul
    goto :MENU
)

echo.
echo [i] Calculando Hashes...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'MD5: ' -NoNewline -ForegroundColor Yellow; (Get-FileHash -Path '%file_path%' -Algorithm MD5).Hash; Write-Host 'SHA1: ' -NoNewline -ForegroundColor Yellow; (Get-FileHash -Path '%file_path%' -Algorithm SHA1).Hash; Write-Host 'SHA256: ' -NoNewline -ForegroundColor Yellow; (Get-FileHash -Path '%file_path%' -Algorithm SHA256).Hash;"

echo.
echo Presiona cualquier tecla para volver al menu.
pause >nul
goto :MENU

:HWHASH
echo.
echo [i] Extrayendo Hardware Hash (WMI Nativo)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; try { $devDetail = (Get-CimInstance -CimSession (New-CimSession) -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter \"InstanceID='Ext' AND ParentID='./DevDetail'\"); $serial = (Get-CimInstance -Class Win32_BIOS).SerialNumber; $product = (Get-CimInstance -Class Win32_OperatingSystem).SerialNumber; $csvPath = Join-Path [Environment]::GetFolderPath('Desktop') 'HardwareHash.csv'; 'Device Serial Number,Windows Product ID,Hardware Hash' | Out-File -FilePath $csvPath -Encoding utf8; \"$serial,$product,$($devDetail.DeviceHardwareData)\" | Out-File -FilePath $csvPath -Encoding utf8 -Append; Write-Host '[OK] CSV generado exitosamente en el Escritorio:' -ForegroundColor Green; Write-Host $csvPath -ForegroundColor Cyan } catch { Write-Host '[!] Error al extraer Hardware Hash:' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor White }"

echo.
echo Presiona cualquier tecla para volver al menu.
pause >nul
goto :MENU
