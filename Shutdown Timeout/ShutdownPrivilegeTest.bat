@echo off
echo Starting shutdown permissions test...
echo Attempting to initiate a shutdown in 20 seconds...
shutdown /s /t 20 /c "Permissions test: The shutdown will be automatically canceled."

timeout /t 5 > nul

echo Attempting to cancel the shutdown...
shutdown /a

echo Test process finished. If it didn't shut down, permissions are working.
pause