@echo off
setlocal enabledelayedexpansion

set "file=ips.txt"
set "result=result.txt"

if not exist "%file%" (
    echo [!] No se encontro el archivo %file%.
    echo Por favor, crea un archivo ips.txt con una IP o Hostname por linea.
    timeout /t 3 >nul
    goto :eof
)

echo [i] Iniciando Ping Check (Hostnames y MAC)...
echo -------------------------- > "%result%"

for /f "usebackq tokens=*" %%i in ("%file%") do (
    set "target=%%i"
    set "response_ip="
    set "mac="
    set "hostname="

    for /f "tokens=3 delims=: " %%a in ('ping -n 1 "!target!" ^| findstr /i /c:"Reply from"') do (
        set "response_ip=%%a"
    )

    if defined response_ip (
        for /f "tokens=2 delims=: " %%H in ('nslookup !response_ip! 2^>nul ^| find "Name:"') do (
            set "hostname=%%H"
        )
        for /f "tokens=1,2" %%M in ('arp -a !response_ip! 2^>nul ^| findstr /i /c:"!response_ip!"') do (
            set "mac=%%M"
        )
        echo !target! [OK] - IP: !response_ip! - MAC: !mac! - Host: !hostname!
        echo !target! [OK] - IP: !response_ip! - MAC: !mac! - Host: !hostname! >> "%result%"
    ) else (
        echo !target! [FAILED]
        echo !target! [FAILED] >> "%result%"
    )
)

echo --------------------------
echo [i] Check completado. Revisa %result%.
timeout /t 3 >nul
