@echo off
DEL "%TEMP%\shutdown_log.txt" 2>nul
DEL "%TEMP%\last_activity_timestamp.txt" 2>nul
DEL "%TEMP%\warning_sent_flag.txt" 2>nul
DEL "%TEMP%\shutdown_monitor_test_status.txt" 2>nul
echo All related temporary files have been removed.
timeout /t 3 /nobreak >nul
