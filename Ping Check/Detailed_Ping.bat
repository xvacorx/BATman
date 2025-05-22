@echo off
setlocal enabledelayedexpansion

set "file=ips.txt"

if not exist "%file%" (
    echo %file% not found.
    pause
    exit /b
)

echo Checking connections...
echo -------------------------- > result.txt

for /f "usebackq tokens=*" %%i in ("%file%") do (
    set "response_ip="
    set "mac="
    set "hostname="

    for /f "tokens=3 delims=: " %%a in ('ping -n 1 %%i ^| findstr /i "Reply from"') do (
        set "response_ip=%%a"
    )

    if defined response_ip (
        for /f "tokens=2 delims=: " %%H in ('nslookup !response_ip! ^| find "Name:"') do (
            set "hostname=%%H"
        )
        for /f "tokens=1,2" %%M in ('arp -a !response_ip! ^| findstr /i "!response_ip!"') do (
            set "mac=%%M"
        )
        echo %%i [OK] - Replied from !response_ip! - MAC: !mac! - Host: !hostname!
        echo %%i [OK] - Replied from !response_ip! - MAC: !mac! - Host: !hostname! >> result.txt
    ) else (
        echo %%i [FAILED]
        echo %%i [FAILED] >> result.txt
    )
)

echo --------------------------
echo Check completed. Review result.txt.
pause