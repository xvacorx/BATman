# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V10.2 Global Edition - FULL)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. DICCIONARIO Y DETECCION DE IDIOMA ---
if ($null -eq $global:lang) { 
    $global:lang = if ((Get-Culture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' } 
}

$msg = @{
    'es' = @{
        'title'      = "TOOLBOX TECNICO PRO - By Viktor"
        'legend'     = "[Blanco: Seguro/Info] | [Amarillo: Avanzado] | [Rojo: Borrado/Reset]"
        'reboot'     = "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]"
        'press_key'  = "Presione cualquier tecla para volver al menu..."
        'option'     = "Opcion: "
        'no_internet'= "[!] SIN CONEXION: Omitiendo reparacion DISM/SFC"
        'm_auto'     = "A. MODO AUTOMATICO"
        'm_lang'     = "L. CAMBIAR IDIOMA (ES/EN)"
        'm_cred'     = "C. Creditos (GitHub)"
        'm_exit'     = "0. Salir"
        'm1' = "1. Diagnostico e Info de Sistema"
        'm2' = "2. Reparacion y Solucion de Errores"
        'm3' = "3. Redes y Conectividad"
        'm4' = "4. Limpieza y Mantenimiento"
        'm5' = "5. Gestor de Software y Arranque"
        'm6' = "6. Optimizaciones y Atajos Clasicos"
    }
    'en' = @{
        'title'      = "TECH TOOLBOX PRO - By Viktor"
        'legend'     = "[White: Safe/Info] | [Yellow: Advanced] | [Red: Delete/Reset]"
        'reboot'     = "[!] ATTENTION: SYSTEM REBOOT PENDING [!]"
        'press_key'  = "Press any key to return to menu..."
        'option'     = "Option: "
        'no_internet'= "[!] NO CONNECTION: Skipping DISM/SFC repair"
        'm_auto'     = "A. AUTOMATIC MODE"
        'm_lang'     = "L. CHANGE LANGUAGE (ES/EN)"
        'm_cred'     = "C. Credits (GitHub)"
        'm_exit'     = "0. Exit"
        'm1' = "1. Diagnostics & System Info"
        'm2' = "2. Repair & Error Solutions"
        'm3' = "3. Network & Connectivity"
        'm4' = "4. Cleaning & Maintenance"
        'm5' = "5. Software & Startup Manager"
        'm6' = "6. Optimizations & Classic Shortcuts"
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
            if ($keyInfo.Character -match '[a-zA-Z0-9]') { 
                $key = $keyInfo.Character.ToString().ToUpper()
                Write-Host $key -ForegroundColor Cyan
                return $key 
            }
        } catch { $key = Read-Host; return $key.ToUpper() }
    }
}

function Test-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return $true }
    Write-Centered "[!] WINGET NOT DETECTED." "Yellow"
    return $false
}

# --- 5. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\`$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null }
    Write-ToolboxLog "Ejecutada Limpieza de Sistema (Temp, Prefetch, Papelera, TRIM)."
}

$Accion_Reparacion = { 
    Write-Host "`n"
    if (Test-Internet) {
        Write-Centered "--- REPARANDO IMAGEN DEL SISTEMA (DISM) ---" "Yellow"
        dism /online /cleanup-image /restorehealth
        Write-Host "`n"
        Write-Centered "--- COMPROBANDO INTEGRIDAD DE ARCHIVOS (SFC) ---" "Yellow"
        sfc /scannow
        Write-ToolboxLog "Ejecutada Reparacion Profunda (SFC/DISM)."
    } else {
        Write-Centered $msg[$global:lang]['no_internet'] "Red"
        Write-ToolboxLog "Reparacion (SFC/DISM) omitida por falta de red."
    }
}

$Accion_Red = { 
    ipconfig /release | Out-Null; netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null; ipconfig /renew | Out-Null
    Write-ToolboxLog "Ejecutado Reset de Red."
}

# --- 6. MENUS CATEGORIZADOS ---
$menus = @{
    "A" = { 
        $subAuto = $true
        while($subAuto){
            Show-Header; Write-Centered "[!] $($msg[$global:lang]['m_auto'])..." "Green"
            Write-Host "`n"; Write-Centered " 1. Ejecutar / Run | 0. Volver / Back" "Yellow"
            $conf = Get-KeyPress
            if ($conf -eq '1') {
                Show-Header; Write-Centered ">> EJECUTANDO / WORKING <<" "Green"; Write-Host "`n"
                Write-Centered "[ Paso 0 de 3 ] Punto de Restauracion / Restore Point..." "Yellow"
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Vik_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                Write-Centered "[ Paso 1 de 3 ] Limpiando basura / Cleaning junk..." "Yellow"; &$Accion_Limpieza
                Write-Centered "[ Paso 2 de 3 ] Reparando SO / Repairing OS..." "Yellow"; &$Accion_Reparacion
                Write-Centered "[ Paso 3 de 3 ] Reseteando red / Resetting network..." "Yellow"; &$Accion_Red
                Play-FinishBeep; Pause-Menu; $subAuto = $false
            } elseif ($conf -eq '0') { $subAuto = $false }
        }
    }
    
    "C" = { 
        Show-Header; Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"
        Write-Centered "Toolbox Tecnico Pro ha sido desarrollado por Viktor." "White"
        Write-Host "`n"; Write-Centered "GitHub: github.com/xvacorx" "Cyan"
        Start-Process "https://github.com/xvacorx"; Pause-Menu
    }
    
    "1" = { # DIAGNOSTICO
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m1']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resumen de Sistema / System Summary" "White"
            Write-Centered "2. Estado de Licencia / License Status" "White"
            Write-Centered "3. Ver Errores / Show BSODs" "White"
            Write-Centered "4. Salud de Discos / Disk Health" "White"
            Write-Centered "5. Reporte Bateria / Battery Report" "Yellow"
            Write-Centered "6. Inventario PC / PC Inventory" "Yellow"
            Write-Centered "7. Ver Logs / View Logs" "Cyan"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
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
                '5' { Show-Header; powercfg /batteryreport /output "$PublicDesktop\BatteryReport.html" | Out-Null; if (Test-Path "$PublicDesktop\BatteryReport.html") { Invoke-Item "$PublicDesktop\BatteryReport.html"; Write-Centered "Reporte generado / Report generated" "Green" }; Pause-Menu }
                '6' { Show-Header; "Inventario de PC" | Out-File "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt" -Encoding UTF8; Write-Centered "Inventario guardado / Inventory saved" "Green"; Pause-Menu }
                '7' { Show-Header; if (Test-Path $logPath) { Get-Content $logPath -Tail 15 | ForEach-Object { Write-Centered $_ "White" } } else { Write-Centered "No logs" "Yellow" }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "2" = { # REPARACION
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m2']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Reparar Imagen / Repair OS (SFC+DISM)" "Yellow"
            Write-Centered "2. Reparar Disco / Check Disk (CHKDSK)" "Yellow"
            Write-Centered "3. Punto Restauracion / Restore Point" "Yellow"
            Write-Centered "4. Destrabar Cola Impresion / Clear Print Spooler" "Yellow"
            Write-Centered "5. Reconstruir Iconos / Rebuild Icon Cache" "Yellow"
            Write-Centered "6. Sync Reloj / Sync Clock" "Yellow"
            Write-Centered "7. Reset Windows Update" "Red"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Reparacion; Play-FinishBeep; Pause-Menu }
                '2' { Show-Header; cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "Programado para reinicio / Scheduled for reboot." "Green"; Pause-Menu }
                '3' { Show-Header; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Vik_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Write-Centered "OK" "Green"; Pause-Menu }
                '4' { Show-Header; Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue; Start-Service -Name Spooler -ErrorAction SilentlyContinue; Write-Centered "OK" "Green"; Pause-Menu }
                '5' { Show-Header; Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue; Start-Process explorer; Write-Centered "OK" "Green"; Pause-Menu }
                '6' { Show-Header; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '7' { Show-Header; Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue; Write-Centered "OK" "Green"; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "3" = { # REDES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m3']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resetear Stack Red / Reset Network Stack" "Yellow"
            Write-Centered "2. Extraer Claves Wi-Fi / Extract Wi-Fi Keys" "White"
            Write-Centered "3. Info IP / IP Info" "White"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Red; Write-Centered "OK" "Green"; Pause-Menu }
                '2' { Show-Header; $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" }; Pause-Menu }
                '3' { Show-Header; if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) { Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed } else { Get-WmiCim Win32_NetworkAdapter | Where-Object NetConnectionStatus -eq 2 | Format-Table Name, MACAddress, Speed }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "4" = { # LIMPIEZA
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m4']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Borrar Temporales / Clear Temp Files" "Yellow"
            Write-Centered "2. Purgar Eventos / Clear Event Logs" "Red"
            Write-Centered "3. Limpieza WinSxS / WinSxS Cleanup" "Red"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Limpieza; Write-Centered "OK" "Green"; Pause-Menu }
                '2' { Show-Header; wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }; Write-Centered "OK" "Green"; Pause-Menu }
                '3' { Show-Header; dism /online /cleanup-image /StartComponentCleanup | Out-Null; Play-FinishBeep; Write-Centered "OK" "Green"; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "5" = { # SOFTWARE
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m5']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Apps Basicas / Basic Apps (Winget)" "Yellow"
            Write-Centered "2. Actualizar Todo / Update All (Winget)" "Yellow"
            Write-Centered "3. Escaneo Defender / Defender Scan" "Yellow"
            Write-Centered "4. Apps de Inicio / Startup Apps" "White"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; if(Test-Winget){ winget install Google.Chrome AnyDesk.AnyDesk 7zip.7zip -e --disable-interactivity --accept-source-agreements --accept-package-agreements }; Pause-Menu }
                '2' { Show-Header; if(Test-Winget){ winget upgrade --all --include-unknown --disable-interactivity --accept-source-agreements --accept-package-agreements }; Pause-Menu }
                '3' { Show-Header; if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) { Start-MpScan -ScanType QuickScan; Write-Centered "OK" "Green" }; Pause-Menu }
                '4' { Show-Header; Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "6" = { # OPTIMIZACIONES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== $($msg[$global:lang]['m6']) ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Deshabilitar Fast Startup / Disable Fast Boot" "Yellow"
            Write-Centered "2. Habilitar Fast Startup / Enable Fast Boot" "Yellow"
            Write-Centered "3. Eliminar Bloatware / Remove Bloatware" "Red"
            Write-Centered "4. Panel Control / Control Panel" "White"
            Write-Centered "5. Adm Dispositivos / Device Manager" "White"
            Write-Host "`n"; Write-Centered "0. Volver / Back" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green"; Pause-Menu }
                '2' { Show-Header; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green"; Pause-Menu }
                '3' { Show-Header; if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) { $bloatware = @("*bing*", "*xboxapp*", "*gethelp*", "*solitaire*"); foreach ($app in $bloatware) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue } }; Write-Centered "OK" "Green"; Pause-Menu }
                '4' { Start-Process control; Pause-Menu }
                '5' { Start-Process devmgmt.msc; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }
}

# --- 7. BUCLE PRINCIPAL ---
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
    Write-Host "`n"
    Write-Centered " $($msg[$global:lang]['m_lang']) " "Yellow"
    Write-Host "`n"
    Write-Centered " $($msg[$global:lang]['m_cred']) " "Cyan"
    Write-Host "`n"; Write-Centered ("-" * 80) "Gray"
    Write-Centered " $($msg[$global:lang]['m_exit']) " "Gray"
    
    $choice = Get-KeyPress
    
    if ($choice -eq 'L') {
        $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }
        Write-Centered "Cambiando idioma / Switching language..." "Cyan"
        Start-Sleep -Milliseconds 600
    }
    elseif ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "0")

[Console]::Clear(); exit
