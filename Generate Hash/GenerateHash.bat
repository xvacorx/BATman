@echo off
setlocal

for %%P in ("%~dp0.") do set "current_drive=%%~dP"

for /f "tokens=2 delims==" %%s in ('wmic bios get serialnumber /value ^| find "SerialNumber="') do set "serial_number=%%s"

set "cab_path=%current_drive%%serial_number%.cab"

MDMDiagnosticsTool -area autopilot -cab "%cab_path%"

endlocal
pause