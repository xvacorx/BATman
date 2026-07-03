@echo off
setlocal enabledelayedexpansion

set "file=ips.txt"
set "result=result.txt"

if not exist "%file%" (
    echo %file% not found. Create ips.txt with one IP/hostname per line.
    pause
    goto :eof
)

echo Checking connections...
echo -------------------------- > "%result%"

for /f "usebackq tokens=*" %%i in ("%file%") do (
    set "target=%%i"
    set "response_ip="

    for /f "tokens=3 delims=: " %%a in ('ping -n 1 "!target!" ^| findstr /i /c:"Reply from"') do (
        set "response_ip=%%a"
    )

    if defined response_ip (
        echo !target! [OK] - Replied from !response_ip!
        echo !target! [OK] - Replied from !response_ip! >> "%result%"
    ) else (
        echo !target! [FAILED]
        echo !target! [FAILED] >> "%result%"
    )
)

echo --------------------------
echo Check completed. Review %result%.
pause
