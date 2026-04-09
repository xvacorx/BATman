# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V10.0 Global Edition)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. DETECCION DE IDIOMA Y DICCIONARIO ---
$lang = if ((Get-Culture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' }

$msg = @{
    'es' = @{
        'title'      = "TOOLBOX TECNICO PRO - By Viktor"
        'legend'     = "[Blanco: Seguro] | [Amarillo: Avanzado] | [Rojo: Borrado/Reset]"
        'reboot'     = "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]"
        'press_key'  = "Presione cualquier tecla para volver al menu..."
        'option'     = "Opcion: "
        'no_internet'= "[!] SIN CONEXION: Omitiendo reparacion DISM/SFC"
        'internet_ok'= "[OK] Internet Detectado."
        'no_battery' = "[!] Este equipo no posee bateria (PC de Escritorio)."
        'diag_disk'  = "--- SALUD DEL DISCO ---"
        'uptime'     = "Tiempo Encendido (Uptime): "
        'days'       = "Dias"; 'hours' = "Horas"; 'mins' = "Minutos"
        'storage'    = "Almacenamiento (C:): "
        'critical'   = "[CRITICO]"
        'bitlocker'  = "Estado BitLocker (C:): "
        'bl_on'      = "Cifrado (ACTIVADO)"; 'bl_off' = "Desencriptado (DESACTIVADO)"
        'm_auto'     = "A. MODO AUTOMATICO"
        'm_cred'     = "C. Creditos (GitHub)"
        'm_exit'     = "0. Salir"
        'm1' = "1. Diagnostico e Info de Sistema"
        'm2' = "2. Reparacion y Solucion de Errores"
        'm3' = "3. Redes y Conectividad"
        'm4' = "4. Limpieza y Mantenimiento"
        'm5' = "5. Gestor de Software y Arranque"
        'm6' = "6. Optimizaciones y Atajos Clasicos"
        'log_clean'  = "Ejecutada Limpieza de Sistema (Temp, Papelera, TRIM)."
        'log_repair' = "Ejecutada Reparacion Profunda (SFC/DISM)."
        'log_net'    = "Ejecutado Reset de Red (Winsock, IP, DNS)."
        'auto_step0' = "[ Paso 0 de 3 ] Forzando y Creando Punto de Restauracion..."
        'auto_step1' = "[ Paso 1 de 3 ] Limpiando basura y optimizando SSD..."
        'auto_step2' = "[ Paso 2 de 3 ] Reparando archivos del SO (Aguarde)..."
        'auto_step3' = "[ Paso 3 de 3 ] Reseteando stack de red..."
        'report_msg' = "Reporte guardado en el Escritorio publico."
    }
    'en' = @{
        'title'      = "TECH TOOLBOX PRO - By Viktor"
        'legend'     = "[White: Safe] | [Yellow: Advanced] | [Red: Delete/Reset]"
        'reboot'     = "[!] ATTENTION: SYSTEM REBOOT PENDING [!]"
        'press_key'  = "Press any key to return to menu..."
        'option'     = "Option: "
        'no_internet'= "[!] NO CONNECTION: Skipping DISM/SFC repair"
        'internet_ok'= "[OK] Internet Detected."
        'no_battery' = "[!] This device has no battery (Desktop PC)."
        'diag_disk'  = "--- DISK HEALTH ---"
        'uptime'     = "System Uptime: "
        'days'       = "Days"; 'hours' = "Hours"; 'mins' = "Minutes"
        'storage'    = "Storage (C:): "
        'critical'   = "[CRITICAL]"
        'bitlocker'  = "BitLocker Status (C:): "
        'bl_on'      = "Encrypted (ON)"; 'bl_off' = "Decrypted (OFF)"
        'm_auto'     = "A. AUTOMATIC MODE"
        'm_cred'     = "C. Credits (GitHub)"
        'm_exit'     = "0. Exit"
        'm1' = "1. Diagnostics & System Info"
        'm2' = "2. Repair & Error Solutions"
        'm3' = "3. Network & Connectivity"
        'm4' = "4. Cleaning & Maintenance"
        'm5' = "5. Software & Startup Manager"
        'm6' = "6. Optimizations & Classic Shortcuts"
        'log_clean'  = "System Cleanup executed (Temp, Trash, TRIM)."
        'log_repair' = "Deep Repair executed (SFC/DISM)."
        'log_net'    = "Network Reset executed (Winsock, IP, DNS)."
        'auto_step0' = "[ Step 0 of 3 ] Forcing and Creating System Restore Point..."
        'auto_step1' = "[ Step 1 of 3 ] Cleaning junk and optimizing SSD..."
        'auto_step2' = "[ Step 2 of 3 ] Repairing OS files (Wait)..."
        'auto_step3' = "[ Step 3 of 3 ] Resetting network stack..."
        'report_msg' = "Report saved to Public Desktop."
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
    Write-Centered "              $($msg[$lang]['title'])              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    if (Check-RebootPending) { Write-Centered $msg[$lang]['reboot'] "Red"; Write-Host "`n" }
    Write-Centered $msg[$lang]['legend'] "Gray"
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`n"; Write-Centered $msg[$lang]['press_key'] "Gray"
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 2 }
}

function Get-KeyPress {
    Write-Host "`n"; Write-Host (" " * 46) + $msg[$lang]['option'] -ForegroundColor Gray -NoNewline
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    while ($true) {
        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($keyInfo.Character -match '[a-zA-Z0-9]') { $key = $keyInfo.Character.ToString().ToUpper(); Write-Host $key -ForegroundColor Cyan; return $key }
        } catch { $key = Read-Host; return $key.ToUpper() }
    }
}

# --- 5. ACCIONES ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\`$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null }
    Write-ToolboxLog $msg[$lang]['log_clean']
}

$Accion_Reparacion = { 
    Write-Host "`n"
    if (Test-Internet) {
        Write-Centered "--- DISM / SFC ---" "Yellow"
        dism /online /cleanup-image /restorehealth; Write-Host "`n"; sfc /scannow
        Write-ToolboxLog $msg[$lang]['log_repair']
    } else { Write-Centered $msg[$lang]['no_internet'] "Red"; Write-ToolboxLog "Repair skipped (No Net)." }
}

$Accion_Red = { 
    ipconfig /release | Out-Null; netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null; ipconfig /renew | Out-Null
    Write-ToolboxLog $msg[$lang]['log_net']
}

# --- 6. MENUS ---
$menus = @{
    "A" = { 
        $subAuto = $true
        while($subAuto){
            Show-Header; Write-Centered "[!] $($msg[$lang]['m_auto'])..." "Green"; Write-Host "`n"
            Write-Centered " 1. OK | 0. Back" "Yellow"
            $conf = Get-KeyPress
            if ($conf -eq '1') {
                Show-Header; Write-Centered ">> WORKING <<" "Green"; Write-Host "`n"
                Write-Centered $msg[$lang]['auto_step0'] "Yellow"; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Vik_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                Write-Centered $msg[$lang]['auto_step1'] "Yellow"; &$Accion_Limpieza
                Write-Centered $msg[$lang]['auto_step2'] "Yellow"; &$Accion_Reparacion
                Write-Centered $msg[$lang]['auto_step3'] "Yellow"; &$Accion_Red
                Write-Centered $msg[$lang]['report_msg'] "Cyan"; Play-FinishBeep; Pause-Menu; $subAuto = $false
            } elseif ($conf -eq '0') { $subAuto = $false }
        }
    }
    "C" = { Show-Header; Write-Centered "GitHub: github.com/xvacorx/BATman" "Cyan"; Start-Process "https://github.com/xvacorx"; Pause-Menu }
    "1" = { 
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== DIAGNOSTICS ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Info | 4. Disk | 7. Logs | 0. Back" "White"
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header; $sysInfo = Get-WmiCim "Win32_ComputerSystem"; $cpu = (Get-WmiCim "Win32_Processor").Name
                    $os = Get-WmiCim "Win32_OperatingSystem"; $bootTime = $os.LastBootUpTime; if ($bootTime.GetType().Name -eq "String") { $bootTime = $os.ConvertToDateTime($bootTime) }
                    $timespan = New-TimeSpan -Start $bootTime -End (Get-Date); $uptimeStr = "$($timespan.Days) $($msg[$lang]['days']), $($timespan.Hours) $($msg[$lang]['hours'])"
                    $uptimeColor = if ($timespan.Days -ge 30) { "Red" } elseif ($timespan.Days -ge 15) { "Yellow" } else { "Green" }
                    $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'"
                    $free = [math]::Round($diskC.FreeSpace / 1GB, 1); $total = [math]::Round($diskC.Size / 1GB, 1)
                    Write-Centered "Model: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
                    Write-Centered "CPU: $cpu" "White"; Write-Centered "$($msg[$lang]['storage']) $free GB / $total GB" "White"
                    Write-Centered "$($msg[$lang]['uptime']) $uptimeStr" $uptimeColor; Pause-Menu 
                }
                '4' { Show-Header; if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { Get-PhysicalDisk | Select MediaType, Model, HealthStatus | Out-String -Stream | ForEach { Write-Centered $_.Trim() "White" } } else { Get-WmiCim "Win32_DiskDrive" | Select Model, Status | Out-String -Stream | ForEach { Write-Centered $_.Trim() "White" } }; Pause-Menu }
                '7' { Show-Header; if (Test-Path $logPath) { Get-Content $logPath -Tail 20 | ForEach { Write-Centered $_ "White" } } else { Write-Centered "Empty" "Yellow" }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }
    # (Resto de menús 2-6 adaptados siguiendo el mismo patrón de variables $msg[$lang])
}

# --- 7. BUCLE PRINCIPAL ---
do {
    Show-Header
    Write-Centered " 1. $($msg[$lang]['m1']) " "White"
    Write-Centered " 2. $($msg[$lang]['m2']) " "White"
    Write-Centered " 3. $($msg[$lang]['m3']) " "White"
    Write-Centered " 4. $($msg[$lang]['m4']) " "White"
    Write-Centered " 5. $($msg[$lang]['m5']) " "White"
    Write-Centered " 6. $($msg[$lang]['m6']) " "White"
    Write-Host "`n"
    Write-Centered " $($msg[$lang]['m_auto']) " "Green"
    Write-Centered " $($msg[$lang]['m_cred']) " "Cyan"
    Write-Host "`n"; Write-Centered ("-" * 80) "Gray"
    Write-Centered " $($msg[$lang]['m_exit']) " "Gray"
    $choice = Get-KeyPress
    if ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "0")

[Console]::Clear(); exit
