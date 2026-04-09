# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V10.3 Ultimate Global Edition)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. DICCIONARIO Y DETECCION DE IDIOMA ---
if ($null -eq $global:lang) { $global:lang = if ((Get-Culture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' } }

$msg = @{
    'es' = @{
        'title'      = "TOOLBOX TECNICO PRO - By Viktor"
        'legend'     = "[Blanco: Seguro/Info] | [Amarillo: Avanzado] | [Rojo: Borrado/Reset]"
        'reboot'     = "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]"
        'press_key'  = "Presione cualquier tecla para volver al menu..."
        'option'     = "Opcion: "
        'no_internet'= "[!] SIN CONEXION: Omitiendo accion por falta de red."
        'm_auto'     = "A. MODO AUTOMATICO"
        'm_lang'     = "L. CAMBIAR IDIOMA (ES/EN)"
        'm_cred'     = "C. Creditos (GitHub)"
        'm_exit'     = "0. Salir"
        'm1' = "1. Diagnostico e Info de Sistema"; 'm2' = "2. Reparacion y Solucion de Errores"
        'm3' = "3. Redes y Conectividad";          'm4' = "4. Limpieza y Mantenimiento"
        'm5' = "5. Gestor de Software y Arranque"; 'm6' = "6. Optimizaciones y Atajos Clasicos"
        
        # Textos Modo Automatico
        'auto_title' = "[!] MANTENIMIENTO AUTOMATICO..."
        'auto_desc'  = "Esta herramienta desatendida realizara lo siguiente:"
        'auto_i0'    = "0. RESPALDO: Crea Punto de Restauracion automatico."
        'auto_i1'    = "1. ELIMINACION: Archivos Temporales, Cache, Prefetch y Papelera."
        'auto_i2'    = "2. OPTIMIZACION: Ejecuta comando TRIM en discos solidos (SSD)."
        'auto_i3'    = "3. REPARACION: Escaneo SFC y DISM (Requiere Internet)."
        'auto_i4'    = "4. REDES: Reset de IP, DNS y Winsock (Causara un micro-corte)."
        'auto_opt1'  = "1. Ejecutar y Volver al Menu"
        'auto_opt2'  = "2. Ejecutar y CERRAR Toolbox"
        'auto_opt0'  = "0. Volver"
        'auto_run'   = ">> EJECUTANDO MANTENIMIENTO AUTOMATICO <<"
        'auto_step0' = "[ Paso 0 de 3 ] Forzando y Creando Punto de Restauracion..."
        'auto_step1' = "[ Paso 1 de 3 ] Limpiando basura, papelera y optimizando SSD..."
        'auto_step2' = "[ Paso 2 de 3 ] Reparando archivos del SO (Aguarde)..."
        'auto_step3' = "[ Paso 3 de 3 ] Reseteando stack de red..."
        'auto_done'  = "[OK] MANTENIMIENTO COMPLETADO CON EXITO"
        'auto_rep'   = "Reporte guardado en el Escritorio publico."
        
        # Submenús Generales
        'back'       = "0. Volver al Menu Principal"
        'working'    = "Ejecutando / Trabajando..."
        'done'       = "Listo / Completado con exito."
        
        # Diag (1)
        'd_sub'      = "=== DIAGNOSTICO E INFO DE SISTEMA ==="
        'd_1'        = "1. Resumen de Sistema (Hardware, Alerta Disco, Uptime)"
        'd_2'        = "2. Estado de Licencia (Activacion real)"
        'd_3'        = "3. Ver Ultimos Pantallazos Azules (BSOD)"
        'd_4'        = "4. Ver Salud de Discos y Tipo (SSD/HDD)"
        'd_5'        = "5. Generar Reporte de Bateria (HTML)"
        'd_6'        = "6. Exportar Inventario de PC (TXT)"
        'd_7'        = "7. Ver Historial de Auditoria Local (Logs)"
        
        # Repair (2)
        'r_sub'      = "=== REPARACION Y SOLUCION DE ERRORES ==="
        'r_1'        = "1. Reparar Imagen de Windows (SFC + DISM)"
        'r_2'        = "2. Programar Reparacion de Disco (CHKDSK)"
        'r_3'        = "3. Crear Punto de Restauracion Manual"
        'r_4'        = "4. Destrabar Cola de Impresion"
        'r_5'        = "5. Reconstruir Cache de Iconos"
        'r_6'        = "6. Alternar Administrador Oculto"
        'r_7'        = "7. Forzar Sincronizacion de Hora"
        'r_8'        = "8. Hard Reset Windows Update"
        
        # Net (3)
        'n_sub'      = "=== REDES Y CONECTIVIDAD ==="
        'n_1'        = "1. Resetear Stack de Red Completo"
        'n_2'        = "2. Extraer Claves Wi-Fi Guardadas"
        'n_3'        = "3. Test de Conectividad e Info IP"
        
        # Clean (4)
        'c_sub'      = "=== MANTENIMIENTO Y LIMPIEZA ==="
        'c_1'        = "1. Borrar Archivos Temporales, Cache y Papelera"
        'c_2'        = "2. Purgar Visor de Eventos (Borra TODOS los Logs)"
        'c_3'        = "3. Limpieza Profunda de Windows Update (WinSxS)"
        
        # Soft (5)
        's_sub'      = "=== SOFTWARE Y ARRANQUE ==="
        's_1'        = "1. Gestor de Instalaciones (Apps y Utilidades)"
        's_2'        = "2. Actualizador Global de Software (Winget)"
        's_3'        = "3. Escaneo Rapido Antivirus (Windows Defender)"
        's_4'        = "4. Ver Programas que Inician con Windows"
        's_5'        = "5. Alternar Modo Seguro (Safe Mode)"
        
        # Opt (6)
        'o_sub'      = "=== OPTIMIZACIONES Y ATAJOS CLASICOS ==="
        'o_1'        = "1. Deshabilitar Inicio Rapido (Fast Startup)"
        'o_2'        = "2. Habilitar Inicio Rapido (Fast Startup)"
        'o_3'        = "3. Generar acceso 'God Mode' en Escritorio"
        'o_4'        = "4. Aniquilar Bloatware (Desinstalar basura de Windows)"
        'o_cpl'      = "--- PANELES DE CONTROL ANTIGUOS ---"
    }
    'en' = @{
        'title'      = "TECH TOOLBOX PRO - By Viktor"
        'legend'     = "[White: Safe/Info] | [Yellow: Advanced] | [Red: Delete/Reset]"
        'reboot'     = "[!] ATTENTION: SYSTEM REBOOT PENDING [!]"
        'press_key'  = "Press any key to return to menu..."
        'option'     = "Option: "
        'no_internet'= "[!] NO CONNECTION: Action skipped due to missing network."
        'm_auto'     = "A. AUTOMATIC MODE"
        'm_lang'     = "L. CHANGE LANGUAGE (ES/EN)"
        'm_cred'     = "C. Credits (GitHub)"
        'm_exit'     = "0. Exit"
        'm1' = "1. Diagnostics & System Info";   'm2' = "2. Repair & Error Solutions"
        'm3' = "3. Network & Connectivity";      'm4' = "4. Cleaning & Maintenance"
        'm5' = "5. Software & Startup Manager";  'm6' = "6. Optimizations & Classic Shortcuts"
        
        # Textos Modo Automatico
        'auto_title' = "[!] AUTOMATIC MAINTENANCE..."
        'auto_desc'  = "This unattended tool will perform the following:"
        'auto_i0'    = "0. BACKUP: Creates an automatic System Restore Point."
        'auto_i1'    = "1. CLEANUP: Clears Temp files, Cache, Prefetch, and Trash."
        'auto_i2'    = "2. OPTIMIZE: Executes TRIM command on Solid State Drives (SSD)."
        'auto_i3'    = "3. REPAIR: Runs SFC and DISM scans (Requires Internet)."
        'auto_i4'    = "4. NETWORK: Resets IP, DNS, and Winsock (Causes micro-disconnect)."
        'auto_opt1'  = "1. Run and Return to Menu"
        'auto_opt2'  = "2. Run and CLOSE Toolbox"
        'auto_opt0'  = "0. Go Back"
        'auto_run'   = ">> RUNNING AUTOMATIC MAINTENANCE <<"
        'auto_step0' = "[ Step 0 of 3 ] Forcing and Creating System Restore Point..."
        'auto_step1' = "[ Step 1 of 3 ] Cleaning junk, trash, and optimizing SSD..."
        'auto_step2' = "[ Step 2 of 3 ] Repairing OS files (Please wait)..."
        'auto_step3' = "[ Step 3 of 3 ] Resetting network stack..."
        'auto_done'  = "[OK] MAINTENANCE COMPLETED SUCCESSFULLY"
        'auto_rep'   = "Report saved to the Public Desktop."
        
        # Submenús Generales
        'back'       = "0. Return to Main Menu"
        'working'    = "Executing / Working..."
        'done'       = "Done / Completed successfully."
        
        # Diag (1)
        'd_sub'      = "=== DIAGNOSTICS & SYSTEM INFO ==="
        'd_1'        = "1. System Summary (Hardware, Disk Alert, Uptime)"
        'd_2'        = "2. License Status (Actual Activation)"
        'd_3'        = "3. View Last Blue Screens (BSOD)"
        'd_4'        = "4. View Disk Health and Type (SSD/HDD)"
        'd_5'        = "5. Generate Battery Report (HTML)"
        'd_6'        = "6. Export PC Inventory (TXT)"
        'd_7'        = "7. View Local Audit History (Logs)"
        
        # Repair (2)
        'r_sub'      = "=== REPAIR & ERROR SOLUTIONS ==="
        'r_1'        = "1. Repair Windows Image (SFC + DISM)"
        'r_2'        = "2. Schedule Disk Repair (CHKDSK)"
        'r_3'        = "3. Create Manual Restore Point"
        'r_4'        = "4. Clear Print Spooler (Unjam Printer)"
        'r_5'        = "5. Rebuild Icon Cache"
        'r_6'        = "6. Toggle Hidden Administrator Account"
        'r_7'        = "7. Force Clock Synchronization"
        'r_8'        = "8. Hard Reset Windows Update"
        
        # Net (3)
        'n_sub'      = "=== NETWORK & CONNECTIVITY ==="
        'n_1'        = "1. Full Network Stack Reset"
        'n_2'        = "2. Extract Saved Wi-Fi Passwords"
        'n_3'        = "3. Connectivity Test & IP Info"
        
        # Clean (4)
        'c_sub'      = "=== CLEANING & MAINTENANCE ==="
        'c_1'        = "1. Clear Temp Files, Cache & Trash"
        'c_2'        = "2. Purge Event Viewer (Clears ALL Logs)"
        'c_3'        = "3. Deep Windows Update Cleanup (WinSxS)"
        
        # Soft (5)
        's_sub'      = "=== SOFTWARE & STARTUP ==="
        's_1'        = "1. App Installation Manager (Winget)"
        's_2'        = "2. Global Software Updater (Winget)"
        's_3'        = "3. Quick Antivirus Scan (Windows Defender)"
        's_4'        = "4. View Programs that Start with Windows"
        's_5'        = "5. Toggle Safe Mode"
        
        # Opt (6)
        'o_sub'      = "=== OPTIMIZATIONS & CLASSIC SHORTCUTS ==="
        'o_1'        = "1. Disable Fast Startup (Clean reboots)"
        'o_2'        = "2. Enable Fast Startup"
        'o_3'        = "3. Generate 'God Mode' shortcut on Desktop"
        'o_4'        = "4. Annihilate Bloatware (Uninstall Windows junk)"
        'o_cpl'      = "--- CLASSIC CONTROL PANELS ---"
    }
}

# --- 1. PROTOCOLOS Y SEGURIDAD ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- 2. ELEVACION Y FOCO ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" }
    else { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`"" }
    exit
}
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
[Microsoft.VisualBasic.Interaction]::AppActivate($PID)

# --- 3. CONFIGURACION DE VENTANA ---
if ($Host.Name -eq "ConsoleHost") {
    try {
        $Raw = $Host.UI.RawUI
        $Raw.BackgroundColor = "Black"; $Raw.ForegroundColor = "White"
        $Buffer = $Raw.BufferSize; $Buffer.Width = 110; $Buffer.Height = 3000; $Raw.BufferSize = $Buffer
        $Size = $Raw.WindowSize; $Size.Width = [math]::Min(110, $Raw.MaxWindowSize.Width); $Size.Height = [math]::Min(38, $Raw.MaxWindowSize.Height); $Raw.WindowSize = $Size
    } catch { }
}
[Console]::BackgroundColor = "Black"; [Console]::Clear(); [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 4. FUNCIONES GLOBALES ---
$logPath = "C:\Windows\Logs\Toolbox_Auditoria.log"
$PublicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')

function Write-ToolboxLog([string]$action) {
    try {
        if (-not (Test-Path "C:\Windows\Logs")) { New-Item -ItemType Directory -Path "C:\Windows\Logs" -Force | Out-Null }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] [ADMIN] - $action" | Out-File -FilePath $logPath -Append -Encoding UTF8
        $logContent = Get-Content $logPath
        if ($logContent.Count -gt 500) { $logContent[-500..-1] | Set-Content $logPath -Encoding UTF8 }
    } catch { }
}

function Write-Centered {
    param([string]$text, [string]$color = "White", [string]$bg = "Black")
    $width = [Console]::WindowWidth; if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
}

function Play-FinishBeep {
    try { [System.Console]::Beep(800, 150); Start-Sleep -Milliseconds 50; [System.Console]::Beep(1000, 150); Start-Sleep -Milliseconds 50; [System.Console]::Beep(1200, 400) } catch { }
}

function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") {
    try { if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop } else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop } }
    catch { if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue } else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue } }
}

function Test-Internet {
    if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }
    try { $req = Invoke-WebRequest -Uri "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop; if ($req.Content -match "Microsoft Connect Test") { return $true } } catch { }
    return $false
}

function Check-RebootPending {
    $r1 = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $r2 = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    $r3 = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue)
    return ($r1 -or $r2 -or $null -ne $r3)
}

function Show-Header {
    [Console]::Clear()
    Write-Host "`n"
    Write-Centered "  _______ ____   ____  _      ____   ______  __ " "Cyan"
    Write-Centered " |__   __/ __ \ / __ \| |    |  _ \ / __ \ \/ / " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    | |_) | |  | \  /  " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    |  _ <| |  | /  \  " "Cyan"
    Write-Centered "    |_|  \____/ \____/|______|____/ \____/_/\_\ " "Cyan"
    Write-Host "`n"
    Write-Centered ("=" * 80) "Gray"
    Write-Centered "              $($msg[$global:lang]['title'])              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    if (Check-RebootPending) { Write-Centered $msg[$global:lang]['reboot'] "Red"; Write-Host "`n" }
    Write-Centered $msg[$global:lang]['legend'] "Gray"
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`n"; Write-Centered $msg[$global:lang]['press_key'] "Gray"
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 2 }
}

function Get-KeyPress {
    Write-Host "`n"; Write-Host (" " * 46) + $msg[$global:lang]['option'] -ForegroundColor Gray -NoNewline
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    while ($true) {
        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($keyInfo.Character -match '[a-zA-Z0-9]') { $key = $keyInfo.Character.ToString().ToUpper(); Write-Host $key -ForegroundColor Cyan; return $key }
        } catch { $key = Read-Host; return $key.ToUpper() }
    }
}

function Test-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return $true }
    Write-Centered "[!] WINGET NOT DETECTED / NO DETECTADO." "Yellow"
    return $false
}
# --- 5. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\`$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
    }
    Write-ToolboxLog "Ejecutada Limpieza de Sistema / System Cleanup Executed."
}

$Accion_Reparacion = { 
    Write-Host "`n"
    if (Test-Internet) {
        Write-Centered "--- DISM ---" "Yellow"
        dism /online /cleanup-image /restorehealth
        Write-Host "`n"
        Write-Centered "--- SFC ---" "Yellow"
        sfc /scannow
        Write-ToolboxLog "Ejecutada Reparacion Profunda / Deep Repair Executed."
    } else {
        Write-Centered $msg[$global:lang]['no_internet'] "Red"
        Write-ToolboxLog "Reparacion omitida por falta de red / Repair skipped (No net)."
    }
}

$Accion_Red = { 
    ipconfig /release | Out-Null
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null 
    ipconfig /renew | Out-Null
    Write-ToolboxLog "Ejecutado Reset de Red / Network Reset Executed."
}

# --- 6. MENUS CATEGORIZADOS ---
$menus = @{
    "A" = { 
        $subAuto = $true
        while($subAuto){
            Show-Header
            Write-Centered $msg[$global:lang]['auto_title'] "Green"
            Write-Host "`n"
            Write-Centered $msg[$global:lang]['auto_desc'] "Cyan"
            Write-Host "`n"
            Write-Centered $msg[$global:lang]['auto_i0'] "White"
            Write-Centered $msg[$global:lang]['auto_i1'] "White"
            Write-Centered $msg[$global:lang]['auto_i2'] "White"
            Write-Centered $msg[$global:lang]['auto_i3'] "White"
            Write-Centered $msg[$global:lang]['auto_i4'] "White"
            Write-Host "`n"
            Write-Centered $msg[$global:lang]['auto_opt1'] "Yellow"
            Write-Centered $msg[$global:lang]['auto_opt2'] "Red"
            Write-Host "`n"
            Write-Centered $msg[$global:lang]['auto_opt0'] "Gray"
            
            $conf = Get-KeyPress
            if ($conf -eq '1' -or $conf -eq '2') {
                Show-Header
                Write-Centered $msg[$global:lang]['auto_run'] "Green"
                Write-Host "`n"
                Write-ToolboxLog "--- INICIO DE MANTENIMIENTO AUTOMATICO ---"
                
                Write-Centered $msg[$global:lang]['auto_step0'] "Yellow"
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                Checkpoint-Computer -Description "Toolbox_Vik_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                Write-Centered $msg[$global:lang]['done'] "Green"; Write-Host "`n"

                Write-Centered $msg[$global:lang]['auto_step1'] "Yellow"
                &$Accion_Limpieza
                Write-Centered $msg[$global:lang]['done'] "Green"; Write-Host "`n"

                Write-Centered $msg[$global:lang]['auto_step2'] "Yellow"
                &$Accion_Reparacion
                Write-Host "`n"

                Write-Centered $msg[$global:lang]['auto_step3'] "Yellow"
                &$Accion_Red
                Write-Centered $msg[$global:lang]['done'] "Green"; Write-Host "`n"
                
                $reportPath = "$PublicDesktop\Reporte_Mantenimiento.txt"
                "=== REPORTE / REPORT ===" | Out-File -FilePath $reportPath -Encoding UTF8
                "Toolbox by Viktor" | Out-File -FilePath $reportPath -Append -Encoding UTF8
                "Fecha / Date: $(Get-Date -Format 'dd/MM/yyyy a las HH:mm:ss')" | Out-File -FilePath $reportPath -Append -Encoding UTF8
                
                Write-ToolboxLog "--- FIN DE MANTENIMIENTO AUTOMATICO ---"
                Write-Centered ("-" * 80) "Gray"
                Write-Centered $msg[$global:lang]['auto_done'] "Green"
                Write-Centered $msg[$global:lang]['auto_rep'] "Cyan"
                
                Play-FinishBeep
                
                if ($conf -eq '2') { [Console]::Clear(); exit }
                Pause-Menu; $subAuto = $false
            } elseif ($conf -eq '0') {
                $subAuto = $false
            }
        }
    }
    
    "C" = { 
        Show-Header; Write-Centered "=== CREDITOS / CREDITS ===" "Cyan"; Write-Host "`n"
        Write-Centered "Toolbox Tecnico Pro ha sido desarrollado por Viktor." "White"
        Write-Host "`n"; Write-Centered "GitHub: github.com/xvacorx" "Cyan"
        Start-Process "https://github.com/xvacorx"; Pause-Menu
    }
"1" = { # DIAGNOSTICO
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['d_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['d_1'] "White"
            Write-Centered $msg[$global:lang]['d_2'] "White"
            Write-Centered $msg[$global:lang]['d_3'] "White"
            Write-Centered $msg[$global:lang]['d_4'] "White"
            Write-Centered $msg[$global:lang]['d_5'] "Yellow"
            Write-Centered $msg[$global:lang]['d_6'] "Yellow"
            Write-Centered $msg[$global:lang]['d_7'] "Cyan"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header; Write-Centered "--- INFO ---" "Cyan"; Write-Host "`n"
                    $sysInfo = Get-WmiCim "Win32_ComputerSystem"; $cpu = (Get-WmiCim "Win32_Processor").Name
                    $os = Get-WmiCim "Win32_OperatingSystem"; try { $bootTime = $os.LastBootUpTime; if ($bootTime.GetType().Name -eq "String") { $bootTime = $os.ConvertToDateTime($bootTime) }; $timespan = New-TimeSpan -Start $bootTime -End (Get-Date); $uptimeStr = "$($timespan.Days) D, $($timespan.Hours) H" } catch { $uptimeStr = "?" }
                    $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'"; if ($diskC) { $free = [math]::Round($diskC.FreeSpace / 1GB, 1); $total = [math]::Round($diskC.Size / 1GB, 1) }
                    Write-Centered "PC: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
                    Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk C: $free GB / $total GB" "White"
                    Write-Centered "Uptime: $uptimeStr" "Green"; Pause-Menu 
                }
                '2' { Show-Header; cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '3' { Show-Header; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List; Pause-Menu }
                '4' { Show-Header; if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table -AutoSize | Out-String -Stream | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Write-Centered $_.Trim() "White" } } else { Get-WmiCim "Win32_DiskDrive" | Select-Object Model, Status | Out-String -Stream | ForEach-Object { Write-Centered $_.Trim() "White" } }; Pause-Menu }
                '5' { Show-Header; powercfg /batteryreport /output "$PublicDesktop\BatteryReport.html" | Out-Null; if (Test-Path "$PublicDesktop\BatteryReport.html") { Invoke-Item "$PublicDesktop\BatteryReport.html"; Write-Centered $msg[$global:lang]['done'] "Green" }; Pause-Menu }
                '6' { Show-Header; "Inventario de PC" | Out-File "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt" -Encoding UTF8; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '7' { Show-Header; if (Test-Path $logPath) { Get-Content $logPath -Tail 15 | ForEach-Object { Write-Centered $_ "White" } }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "2" = { # REPARACION
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['r_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['r_1'] "Yellow"
            Write-Centered $msg[$global:lang]['r_2'] "Yellow"
            Write-Centered $msg[$global:lang]['r_3'] "Yellow"
            Write-Centered $msg[$global:lang]['r_4'] "Yellow"
            Write-Centered $msg[$global:lang]['r_5'] "Yellow"
            Write-Centered $msg[$global:lang]['r_6'] "Yellow"
            Write-Centered $msg[$global:lang]['r_7'] "Yellow"
            Write-Centered $msg[$global:lang]['r_8'] "Red"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Reparacion; Play-FinishBeep; Pause-Menu }
                '2' { Show-Header; cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '3' { Show-Header; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Vik_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '4' { Show-Header; Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue; Start-Service -Name Spooler -ErrorAction SilentlyContinue; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '5' { Show-Header; Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue; Start-Process explorer; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '6' { Show-Header; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '7' { Show-Header; Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "3" = { # REDES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['n_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['n_1'] "Yellow"
            Write-Centered $msg[$global:lang]['n_2'] "White"
            Write-Centered $msg[$global:lang]['n_3'] "White"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Red; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '2' { Show-Header; $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" }; Pause-Menu }
                '3' { Show-Header; if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) { Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed } else { Get-WmiCim Win32_NetworkAdapter | Where-Object NetConnectionStatus -eq 2 | Format-Table Name, MACAddress, Speed }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "4" = { # LIMPIEZA
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['c_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['c_1'] "Yellow"
            Write-Centered $msg[$global:lang]['c_2'] "Red"
            Write-Centered $msg[$global:lang]['c_3'] "Red"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Limpieza; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '2' { Show-Header; wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '3' { Show-Header; dism /online /cleanup-image /StartComponentCleanup | Out-Null; Play-FinishBeep; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "5" = { # SOFTWARE
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['s_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['s_1'] "White"
            Write-Centered $msg[$global:lang]['s_2'] "Yellow"
            Write-Centered $msg[$global:lang]['s_3'] "Yellow"
            Write-Centered $msg[$global:lang]['s_4'] "White"
            Write-Centered $msg[$global:lang]['s_5'] "Yellow"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; if(Test-Winget){ winget install Google.Chrome AnyDesk.AnyDesk 7zip.7zip -e --disable-interactivity --accept-source-agreements --accept-package-agreements }; Pause-Menu }
                '2' { Show-Header; if(Test-Winget){ winget upgrade --all --include-unknown --disable-interactivity --accept-source-agreements --accept-package-agreements }; Pause-Menu }
                '3' { Show-Header; if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) { Start-MpScan -ScanType QuickScan; Write-Centered $msg[$global:lang]['done'] "Green" }; Pause-Menu }
                '4' { Show-Header; Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table; Pause-Menu }
                '5' { Show-Header; Write-Centered "1. Safe Mode ON | 2. Safe Mode OFF (Normal)" "Yellow"; $sm = Get-KeyPress; if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered $msg[$global:lang]['done'] "Green" }; if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered $msg[$global:lang]['done'] "Green" }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "6" = { # OPTIMIZACIONES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered $msg[$global:lang]['o_sub'] "Cyan"; Write-Host "`n"
            Write-Centered $msg[$global:lang]['o_1'] "Yellow"
            Write-Centered $msg[$global:lang]['o_2'] "Yellow"
            Write-Centered $msg[$global:lang]['o_3'] "Yellow"
            Write-Centered $msg[$global:lang]['o_4'] "Red"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['o_cpl'] "Cyan"
            Write-Centered "5. Panel Control / Control Panel" "White"
            Write-Centered "6. Adm Dispositivos / Device Manager" "White"
            Write-Centered "7. Redes / Network Adapters" "White"
            Write-Centered "8. Programas / Uninstall Programs" "White"
            Write-Host "`n"; Write-Centered $msg[$global:lang]['back'] "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '2' { Show-Header; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '3' { Show-Header; $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null; Write-Centered $msg[$global:lang]['done'] "Green" } else { Write-Centered $msg[$global:lang]['done'] "White" }; Pause-Menu }
                '4' { Show-Header; if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) { $bloatware = @("*bing*", "*xboxapp*", "*gethelp*", "*solitaire*"); foreach ($app in $bloatware) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue } }; Write-Centered $msg[$global:lang]['done'] "Green"; Pause-Menu }
                '5' { Start-Process control; Pause-Menu }
                '6' { Start-Process devmgmt.msc; Pause-Menu }
                '7' { Start-Process ncpa.cpl; Pause-Menu }
                '8' { Start-Process appwiz.cpl; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }
} # <-- Cierre maestro de la variable $menus

# --- 7. BUCLE PRINCIPAL DE LA HERRAMIENTA ---
do {
    Show-Header
    Write-Centered " $($msg[$global:lang]['m1']) " "White"
    Write-Centered " $($msg[$global:lang]['m2']) " "White"
    Write-Centered " $($msg[$global:lang]['m3']) " "White"
    Write-Centered " $($msg[$global:lang]['m4']) " "White"
    Write-Centered " $($msg[$global:lang]['m5']) " "White"
    Write-Centered " $($msg[$global:lang]['m6']) " "White"
    Write-Host "`n"
    Write-Centered " $($msg[$global:lang]['m_auto']) " "Green"
    Write-Centered " $($msg[$global:lang]['m_lang']) " "Yellow"
    Write-Centered " $($msg[$global:lang]['m_cred']) " "Cyan"
    Write-Host "`n"
    Write-Centered ("-" * 80) "Gray"
    Write-Centered " $($msg[$global:lang]['m_exit']) " "Gray"
    
    $choice = Get-KeyPress
    
    if ($choice -eq 'L') {
        $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }
        Write-Centered "Cambiando idioma / Switching language..." "Cyan"
        Start-Sleep -Milliseconds 600
    }
    elseif ($menus.ContainsKey($choice)) { 
        & $menus[$choice] 
    }
} while ($choice -ne "0")

# --- 8. CIERRE LIMPIO ---
[Console]::Clear()
exit
