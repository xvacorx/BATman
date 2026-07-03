@echo off
taskkill /FI "WINDOWTITLE eq Administrator: Windows PowerShell" /IM "powershell.exe" /F >nul 2>&1
taskkill /IM "powershell.exe" /F >nul 2>&1
echo AntiSleep stopped.
pause
