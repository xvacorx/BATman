@echo off
setlocal
set "current_folder=%~dp0"
set "batch_file_name=%~nx0"
for /f "delims=" %%a in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Startup')"') do set "startup_folder=%%a"

echo.
echo Copying files to the Startup folder: %startup_folder%
echo.

for %%f in ("%current_folder%*") do (
    set "filename=%%~nxf"
    if /i not "%%~nxf"=="%batch_file_name%" (
        if /i not "%%~nxf"=="README.md" (
            echo Copying: %%~nxf
            copy "%%f" "%startup_folder%" >nul 2>&1
            if errorlevel 1 (
                echo [FAILED] Could not copy %%~nxf
            ) else (
                echo [OK] Copied %%~nxf
            )
        )
    )
)

echo.
echo Process completed.
pause
endlocal
