@echo off
setlocal

set "DELAY_BEFORE_WARNING_SECONDS=3300"
set "WARNING_DURATION_SECONDS=300"

:main_loop
    timeout /t %DELAY_BEFORE_WARNING_SECONDS% /nobreak >nul

    echo.
    echo.
    echo =======================================================
    echo               ATTENTION! - Shutdown Imminent!
    echo =======================================================
    echo.
    echo If you do not close this window within 5 minutes,
    echo the computer will automatically shut down.
    echo.
    echo Close this window to reset the timer.
    echo.
    echo =======================================================
    echo.

    for /f "tokens=2" %%i in ('tasklist /nh /fi "imagename eq cmd.exe" /fi "windowtitle eq cmd.exe" ^| findstr /i "%CD%"') do set "MY_PID=%%i"

    set "START_TIME=%TIME%"
    set /a "ELAPSED_TIME=0"

    :check_window_loop
        tasklist /fi "pid eq %MY_PID%" /nh | findstr /i "cmd.exe" >nul
        if %errorlevel% neq 0 (
            goto main_loop
        )

        for /f "tokens=1-3 delims=:" %%a in ("%TIME%") do (
            set /a "CURRENT_SECONDS = %%a * 3600 + %%b * 60 + %%c"
        )
        for /f "tokens=1-3 delims=:" %%a in ("%START_TIME%") do (
            set /a "START_SECONDS = %%a * 3600 + %%b * 60 + %%c"
        )
        if %CURRENT_SECONDS% lss %START_SECONDS% (
            set /a "ELAPSED_TIME = (86400 - %START_SECONDS%) + %CURRENT_SECONDS%"
        ) else (
            set /a "ELAPSED_TIME = %CURRENT_SECONDS% - %START_SECONDS%"
        )

        if %ELAPSED_TIME% geq %WARNING_DURATION_SECONDS% (
            shutdown /s /t 0 /c "Automatic shutdown due to inactivity." /f
            goto :eof
        )

        timeout /t 5 /nobreak >nul
        goto check_window_loop

:eof
endlocal
