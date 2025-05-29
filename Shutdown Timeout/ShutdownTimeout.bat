@echo off
SETLOCAL EnableDelayedExpansion

SET "LOG_FILE=%TEMP%\shutdown_log.txt"
SET "LAST_ACTIVITY_FILE=%TEMP%\last_activity_timestamp.txt"
SET "WARNING_SENT_FILE=%TEMP%\warning_sent_flag.txt"
SET "TEST_STATUS_FILE=%TEMP%\shutdown_monitor_test_status.txt"

SET "CHECK_INTERVAL=60"
SET "ACTIVITY_SIM_INTERVAL=300"
SET "WARNING_THRESHOLD=3300"
SET "SHUTDOWN_THRESHOLD=3600"

if exist "%TEST_STATUS_FILE%" (
    findstr /B /C:"STATUS: OK" "%TEST_STATUS_FILE%" >nul
    if !errorlevel! equ 0 (
        echo [%%date%% %%time%%] Previous tests passed. Skipping tests and proceeding to main operation. >> "%LOG_FILE%"
        goto main_operation
    ) else (
        echo [%%date%% %%time%%] Previous tests failed or incomplete. Re-running tests. >> "%LOG_FILE%"
        goto run_tests
    )
) else (
    echo [%%date%% %%time%%] First run detected. Executing initial tests. >> "%LOG_FILE%"
    goto run_tests
)

:run_tests
echo [%%date%% %%time%%] Starting functionality tests... >> "%LOG_FILE%"
set "ALL_TESTS_OK=true"

echo [%%date%% %%time%%] Test 1: File system write access for LOG_FILE. >> "%LOG_FILE%"
echo [%%date%% %%time%%] Test: Write access. > "%LOG_FILE%" 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 1: File system access OK. >> "%LOG_FILE%"
) else (
    echo [%%date%% %%time%%] Test 1: File system access FAILED. Error code: !errorlevel! >> "%LOG_FILE%"
    set "ALL_TESTS_OK=false"
)

echo [%%date%% %%time%%] Test 2: powershell.exe availability. >> "%LOG_FILE%"
where powershell.exe >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 2: powershell.exe found OK. >> "%LOG_FILE%"
) else (
    echo [%%date%% %%time%%] Test 2: powershell.exe NOT found. Error code: !errorlevel! >> "%LOG_FILE%"
    set "ALL_TESTS_OK=false"
)

echo [%%date%% %%time%%] Test 3: msg command availability. >> "%LOG_FILE%"
where msg >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 3: msg command found OK. >> "%LOG_FILE%"
) else (
    echo [%%date%% %%time%%] Test 3: msg command NOT found. Error code: !errorlevel! >> "%LOG_FILE%"
    set "ALL_TESTS_OK=false"
)

echo [%%date%% %%time%%] Test 4: shutdown command availability. >> "%LOG_FILE%"
where shutdown >nul 2>&1
if !errorlevel! equ 0 (
    echo [%%date%% %%time%%] Test 4: shutdown command found OK. >> "%LOG_FILE%"
) else (
    echo [%%date%% %%time%%] Test 4: shutdown command NOT found. Error code: !errorlevel! >> "%LOG_FILE%"
    set "ALL_TESTS_OK=false"
)

if "%ALL_TESTS_OK%"=="true" (
    echo [%%date%% %%time%%] All functionality tests passed. >> "%LOG_FILE%"
    echo STATUS: OK > "%TEST_STATUS_FILE%"
    goto main_operation
) else (
    echo [%%date%% %%time%%] One or more functionality tests FAILED. The script will not continue. >> "%LOG_FILE%"
    echo STATUS: FAILED > "%TEST_STATUS_FILE%"
    echo.
    echo ERROR: One or more critical components are missing or inaccessible.
    echo Please check the log file "%LOG_FILE%" for more details.
    echo The script will now close.
    echo.
    exit /b 1
)

:main_operation
echo [%%date%% %%time%%] Starting inactivity monitoring. > "%LOG_FILE%"
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
echo [%%date%% %%time%%] Inactivity seconds: %INACTIVITY_SECONDS% >> "%LOG_FILE%"

if %INACTIVITY_SECONDS% GEQ %ACTIVITY_SIM_INTERVAL% (
  echo [%%date%% %%time%%] 5 minutes inactivity. Moving mouse. >> "%LOG_FILE%"
  powershell.exe -NoProfile -Command "& { ^
    $pos = [System.Windows.Forms.Cursor]::Position; ^
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($pos.X + 1, $pos.Y + 1); ^
    [System.Windows.Forms.Cursor]::Position = $pos; ^
  }"
)

if %INACTIVITY_SECONDS% GEQ %WARNING_THRESHOLD% (
  if not exist "%WARNING_SENT_FILE%" (
    echo [%%date%% %%time%%] ALERT: 55 minutes inactivity. >> "%LOG_FILE%"
    msg * "ATTENTION: No activity detected in the last 55 minutes. The computer will shut down in 5 minutes if no activity is detected."
    echo true > "%WARNING_SENT_FILE%"
  )
  if %INACTIVITY_SECONDS% GEQ %SHUTDOWN_THRESHOLD% (
    echo [%%date%% %%time%%] MAXIMUM INACTIVITY REACHED (1 HOUR). Shutting down. >> "%LOG_FILE%"
    shutdown /s /f /t 0
  )
) else (
  if exist "%WARNING_SENT_FILE%" (
    echo [%%date%% %%time%%] Activity detected. Resetting counter. >> "%LOG_FILE%"
    del "%WARNING_SENT_FILE%" 2>nul
  )
)

timeout /t %CHECK_INTERVAL% /nobreak >nul
goto loop
