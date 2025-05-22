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

    for /f "tokens=3 delims=: " %%a in ('ping -n 1 %%i ^| findstr /i "Reply from"') do (
        set "response_ip=%%a"
    )

    if defined response_ip (
        echo %%i [OK] - Replied from !response_ip!
        echo %%i [OK] - Replied from !response_ip! >> result.txt
    ) else (
        echo %%i [FAILED]
        echo %%i [FAILED] >> result.txt
    )
)

echo --------------------------
echo Check completed. Review result.txt.
pause