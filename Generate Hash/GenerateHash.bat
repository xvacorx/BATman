@echo off
setlocal

NET SESSION >NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    goto :UACPrompt
) ELSE (
    echo Running with administrative privileges.
)

:UACPrompt
IF %ERRORLEVEL% NEQ 0 (
    ECHO Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\elevate.vbs"
    ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%TEMP%\elevate.vbs"
    START "" "%TEMP%\elevate.vbs"
    DEL "%TEMP%\elevate.vbs"
    EXIT /B
)

for %%P in ("%~dp0.") do set "current_drive=%%~dP"

set "log_folder=%current_drive%\MDMLogs"

if not exist "%log_folder%" (
    echo Creating folder: %log_folder%
    md "%log_folder%"
)

for /f "tokens=2 delims==" %%s in ('wmic bios get serialnumber /value ^| find "SerialNumber="') do set "serial_number=%%s"

set "cab_path=%log_folder%\%serial_number%.cab"

echo Collecting diagnostics into: "%cab_path%"
MDMDiagnosticsTool -area autopilot -cab "%cab_path%"

endlocal
pause