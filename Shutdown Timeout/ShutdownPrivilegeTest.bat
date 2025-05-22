@echo off
echo Iniciando prueba de permisos para apagado...
echo Intentando iniciar un apagado en 20 segundos...
shutdown /s /t 20 /c "Prueba de permisos: El apagado sera cancelado automaticamente."

REM Espera un momento para asegurar que el comando shutdown se ha iniciado
timeout /t 5 > nul

echo Intentando cancelar el apagado...
shutdown /a

echo Proceso de prueba finalizado. Si no se apago, los permisos funcionan.
pause