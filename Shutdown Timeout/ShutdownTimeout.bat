@echo off
SETLOCAL EnableDelayedExpansion

SET "LOG_FILE=%TEMP%\shutdown_log.txt"
SET "LAST_ACTIVITY_FILE=%TEMP%\last_activity_timestamp.txt"
SET "WARNING_SENT_FILE=%TEMP%\warning_sent_flag.txt"
SET "TEST_STATUS_FILE=%TEMP%\shutdown_monitor_test_status.txt"

SET "CHECK_INTERVAL=60"
SET "WARNING_THRESHOLD=2400"
SET "SHUTDOWN_THRESHOLD=2700"

if exist "%TEST_STATUS_FILE%" (
    findstr /B /C:"STATUS: OK" "%TEST_STATUS_FILE%" >nul
    if !errorlevel! equ 0 (
        goto main_operation
    ) else (
        goto run_tests
    )
) else (
    goto run_tests
)

:run_tests
set "ALL_TESTS_OK=true"

echo [%%date%% %%time%%] Test: Write access. > "%LOG_FILE%" 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 1: File system access OK. >> "%LOG_FILE%"
) else (
    set "ALL_TESTS_OK=false"
)

:: Test 2: powershell.exe availability by executing a simple command
powershell.exe -NoProfile -Command "Exit 0" >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 2: powershell.exe found OK. >> "%LOG_FILE%"
) else (
    set "ALL_TESTS_OK=false"
)

:: Test 3: msg command availability by checking its help output
msg /? >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 3: msg command found OK. >> "%LOG_FILE%"
) else (
    set "ALL_TESTS_OK=false"
)

:: Test 4: shutdown command availability by checking its help output
shutdown /? >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 4: shutdown command found OK. >> "%LOG_FILE%"
) else (
    set "ALL_TESTS_OK=false"
)

if "%ALL_TESTS_OK%"=="true" (
    echo STATUS: OK > "%TEST_STATUS_FILE%"
    goto main_operation
) else (
    echo STATUS: FAILED > "%TEST_STATUS_FILE%"
    echo.
    echo ERROR: Uno o más componentes críticos no están o son inaccesibles.
    echo Por favor, revisa el archivo de registro "%LOG_FILE%" para más detalles.
    echo El script se cerrará ahora.
    echo.
    exit /b 1
)

:main_operation
echo 0 > "%LAST_ACTIVITY_FILE%"
del "%WARNING_SENT_FILE%" 2>nul

:loop
powershell.exe -NoProfile -Command "& { ^
    Add-Type -TypeDefinition ' ^
      using System; ^
      using System.Runtime.InteropServices; ^
      public class UserActivity { ^
        [StructLayout(LayoutKind.Sequential)] ^
        struct LASTINPUTINFO { ^
          public uint cbSize; ^
          public uint dwTime; ^
        } ^
        [DllImport(\"user32.dll\")] ^
        public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii); ^
        public static long GetIdleTime() { ^
          LASTINPUTINFO lastInputInfo = new LASTINPUTINFO(); ^
          lastInputInfo.cbSize = (uint)Marshal.SizeOf(lastInputInfo); ^
          GetLastInputInfo(ref lastInputInfo); ^
          return Environment.TickCount - lastInputInfo.dwTime; ^
        } ^
      } ^
    '; ^
    $idleMs = [UserActivity]::GetIdleTime(); ^
    $idleSec = [int]($idleMs / 1000); ^
    Write-Output $idleSec; ^
}" > "%LAST_ACTIVITY_FILE%"

set /p INACTIVITY_SECONDS=<"%LAST_ACTIVITY_FILE%"

if %INACTIVITY_SECONDS% GEQ %WARNING_THRESHOLD% (
    if not exist "%WARNING_SENT_FILE%" (
        msg * "ATTENTION: No activity detected in the last 40 minutes. The computer will shut down in 5 more minutes if no activity is detected."
        echo true > "%WARNING_SENT_FILE%"
    )
    if %INACTIVITY_SECONDS% GEQ %SHUTDOWN_THRESHOLD% (
        shutdown /s /f /t 0
    )
) else (
    if exist "%WARNING_SENT_FILE%" (
        del "%WARNING_SENT_FILE%" 2>nul
    )
)

timeout /t %CHECK_INTERVAL% /nobreak >nul
goto loop
