@echo off
setlocal
set "current_folder=%~dp0"
set "batch_file_name=%~nx0"
for /f "delims=" %%a in ('powershell -command "[Environment]::GetFolderPath('Startup')"') do set "startup_folder=%%a"

echo.
echo Copying files to the Startup folder: %startup_folder%
echo.

for %%f in ("%current_folder%*") do (
    set "filename=%%~nxf"
    if /i not "%%~nxf"=="%batch_file_name%" (
        if /i not "%%~nxf"=="README.txt" (
            echo Copying: %%~nxf
            copy "%%f" "%startup_folder%" >nul
        )
    )
)

echo.
echo Process completed.
pause
endlocal