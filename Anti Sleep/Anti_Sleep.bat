@echo off
:: Anti Sleep - Mantiene la PC y pantalla activas usando SetThreadExecutionState (C# via PowerShell)
:: Constantes:
:: ES_CONTINUOUS = 0x80000000
:: ES_SYSTEM_REQUIRED = 0x00000001
:: ES_DISPLAY_REQUIRED = 0x00000002
:: Total: 0x80000003

echo [i] Activando Anti Sleep (Bloqueando suspension de sistema y pantalla)...
powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command "$code = '[DllImport(\"kernel32.dll\")] public static extern uint SetThreadExecutionState(uint esFlags);'; $type = Add-Type -MemberDefinition $code -Name 'Win32' -Namespace 'System' -PassThru; while ($true) { $type::SetThreadExecutionState(0x80000003); Start-Sleep -Seconds 60 }"
echo [i] Anti Sleep activado en segundo plano.
timeout /t 3 >nul
