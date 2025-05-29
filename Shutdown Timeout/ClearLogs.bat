@echo off
DEL "%TEMP%\shutdown_log.txt" 2>nul
DEL "%TEMP%\last_activity_timestamp.txt" 2>nul
DEL "%TEMP%\warning_sent_flag.txt" 2>nul
DEL "%TEMP%\shutdown_monitor_test_status.txt" 2>nul

:: Attempt to delete ShutdownTimeout.bat from the Startup folder
SET "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
DEL "%STARTUP_FOLDER%\ShutdownTimeout.bat" 2>nul

echo All related temporary files and the startup script have been removed.
timeout /t 3 /nobreak >nul
