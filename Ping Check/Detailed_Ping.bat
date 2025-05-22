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
    rem Reiniciar las variables en cada iteración
    set "respuesta="
    set "mac="
    set "hostname="

    rem Ejecutar ping y extraer la IP de respuesta usando "Reply from"
    for /f "tokens=3 delims=: " %%a in ('ping -n 1 %%i ^| findstr /i "Reply from"') do (
        set "respuesta=%%a"
    )

    rem Si se obtuvo respuesta, se procede a buscar el hostname y la MAC
    if defined respuesta (
        rem Obtener el nombre de host usando nslookup
        for /f "tokens=2 delims=: " %%H in ('nslookup !respuesta! ^| find "Name:"') do (
            set "hostname=%%H"
        )
        rem Obtener la dirección MAC a partir del ARP cache
        for /f "tokens=1,2" %%M in ('arp -a !respuesta! ^| findstr /i "!respuesta!"') do (
            set "mac=%%M"
        )
        echo %%i [OK] - Respondió desde !respuesta! - MAC: !mac! - Host: !hostname!
        echo %%i [OK] - Respondió desde !respuesta! - MAC: !mac! - Host: !hostname! >> resultado.txt
    ) else (
        echo %%i [FALLÓ]
        echo %%i [FALLÓ] >> resultado.txt
    )
)

echo --------------------------
echo Verificación finalizada. Revisa el archivo resultado.txt.
pause
