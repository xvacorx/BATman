@echo off
setlocal enabledelayedexpansion

rem Archivo con la lista de IPs
set "file=ips.txt"

rem Verificar si el archivo existe
if not exist "%file%" (
    echo No se encontró el archivo %file%
    pause
    exit /b
)

echo Verificando conexiones...
echo -------------------------- > resultado.txt

rem Procesar cada IP/hostname del archivo
for /f "usebackq tokens=*" %%i in ("%file%") do (
    rem Reiniciar la variable de respuesta en cada iteración
    set "respuesta="

    rem Ejecutar ping y extraer la IP de respuesta usando "Reply from"
    for /f "tokens=3 delims=: " %%a in ('ping -n 1 %%i ^| findstr /i "Reply from"') do (
        set "respuesta=%%a"
    )

    rem Si se obtuvo respuesta, la variable 'respuesta' estará definida
    if defined respuesta (
        echo %%i [OK] - Respondió desde !respuesta!
        echo %%i [OK] - Respondió desde !respuesta! >> resultado.txt
    ) else (
        echo %%i [FALLÓ]
        echo %%i [FALLÓ] >> resultado.txt
    )
)

echo --------------------------
echo Verificación finalizada. Revisa el archivo resultado.txt.
pause
