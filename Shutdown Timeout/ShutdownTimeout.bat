@echo off
SET "LOG_FILE=%TEMP%\shutdown_log.txt"
SET "LAST_ACTIVITY_FILE=%TEMP%\last_activity_timestamp.txt"
SET "WARNING_SENT_FILE=%TEMP%\warning_sent_flag.txt"

SET "CHECK_INTERVAL=60"
SET "ACTIVITY_SIM_INTERVAL=300"
SET "WARNING_THRESHOLD=3300"
SET "SHUTDOWN_THRESHOLD=3600"

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