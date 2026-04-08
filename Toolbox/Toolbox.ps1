# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V9.0 Architect's Cut)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. PROTOCOLOS Y SEGURIDAD ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- 1. ELEVACION INTELIGENTE Y FOCO DE VENTANA ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`""
    }
    exit
}

# Forzar foco en la ventana (Saltar al frente)
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
[Microsoft.VisualBasic.Interaction]::AppActivate($PID)

# --- 2. CONFIGURACION DE VENTANA ANTI-CRASH ---
if ($Host.Name -eq "ConsoleHost") {
    try {
        $Raw = $Host.UI.RawUI
        $Raw.BackgroundColor = "Black"
        $Raw.ForegroundColor = "White"
        
        $Buffer = $Raw.BufferSize
        $Buffer.Width = 110
        $Buffer.Height = 3000
        $Raw.BufferSize = $Buffer

        $Size = $Raw.WindowSize
        $Size.Width = [math]::Min(110, $Raw.MaxWindowSize.Width)
        $Size.Height = [math]::Min(38, $Raw.MaxWindowSize.Height)
        $Raw.WindowSize = $Size
    } catch { }
}
[Console]::BackgroundColor = "Black"
[Console]::Clear() 
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 3. FUNCIONES GLOBALES E INTERFAZ ---
$logPath = "C:\Windows\Logs\Toolbox_Auditoria.log"
$PublicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')

function Write-ToolboxLog([string]$action) {
    try {
        if (-not (Test-Path "C:\Windows\Logs")) { New-Item -ItemType Directory -Path "C:\Windows\Logs" -Force | Out-Null }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [ADMIN] - $action"
        $logEntry | Out-File -FilePath $logPath -Append -Encoding UTF8
        
        $logContent = Get-Content $logPath
        if ($logContent.Count -gt 500) { $logContent[-500..-1] | Set-Content $logPath -Encoding UTF8 }
    } catch { }
}

function Write-Centered {
    param([string]$text, [string]$color = "White", [string]$bg = "Black")
    $width = [Console]::WindowWidth
    if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
}

function Play-FinishBeep {
    try {
        [System.Console]::Beep(800, 150); Start-Sleep -Milliseconds 50
        [System.Console]::Beep(1000, 150); Start-Sleep -Milliseconds 50
        [System.Console]::Beep(1200, 400)
    } catch { }
}

function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") {
    try {
        if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop }
        else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop }
    } catch {
        if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue }
        else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue }
    }
}

function Test-Internet {
    if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }
    try {
        $req = Invoke-WebRequest -Uri "http://www.msftconnecttest.com/connecttest.txt" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        if ($req.Content -match "Microsoft Connect Test") { return $true }
    } catch { }
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
    Write-Centered "              TOOLBOX TECNICO PRO - By Viktor              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    
    if (Check-RebootPending) {
        Write-Centered "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]" "Red"
        Write-Host "`n"
    }

    $legendText = "[Blanco: Seguro/Info] | [Amarillo: Avanzado] | [Rojo: Reset/Borrado]"
    $width = [Console]::WindowWidth
    if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $legendText.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "Blanco: Seguro/Info" -ForegroundColor White -NoNewline
    Write-Host "] | [" -ForegroundColor Gray -NoNewline
    Write-Host "Amarillo: Avanzado" -ForegroundColor Yellow -NoNewline
    Write-Host "] | [" -ForegroundColor Gray -NoNewline
    Write-Host "Rojo: Reset/Borrado" -ForegroundColor Red -NoNewline
    Write-Host "]" -ForegroundColor Gray
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`n"
    Write-Centered "Presione cualquier tecla para volver al menu..." "Gray"
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 2 }
}

function Get-KeyPress {
    Write-Host "`n"
    Write-Host (" " * 46) + "Opcion: " -ForegroundColor Gray -NoNewline
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    while ($true) {
        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($keyInfo.Character -match '[a-zA-Z0-9]') {
                $key = $keyInfo.Character.ToString().ToUpper()
                Write-Host $key -ForegroundColor Cyan
                return $key
            }
        } catch {
            $key = Read-Host
            return $key.ToUpper()
        }
    }
}

function Test-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) { return $true }
    Write-Centered "[!] WINGET NO DETECTADO: El sistema no es compatible con esta funcion." "Yellow"
    return $false
}

# --- 4. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\`$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
    }
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
        Write-Centered "[!] SIN CONEXION: Omitiendo reparacion DISM/SFC" "Red"
        Write-ToolboxLog "Reparacion (SFC/DISM) omitida por falta de red."
    }
}

$Accion_Red = { 
    ipconfig /release | Out-Null
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null 
    ipconfig /renew | Out-Null
    Write-ToolboxLog "Ejecutado Reset de Red (Winsock, IP, DNS, Release/Renew)."
}

# --- 5. MENUS CATEGORIZADOS ---
$menus = @{
    "A" = { 
        $subAuto = $true
        while($subAuto){
            Show-Header; Write-Centered "[!] MANTENIMIENTO AUTOMATICO..." "Green"
            Write-Host "`n"
            Write-Centered "Esta herramienta desatendida realizara lo siguiente:" "Cyan"
            Write-Host "`n"
            Write-Centered "0. RESPALDO: Crea Punto de Restauracion automatico." "White"
            Write-Centered "1. ELIMINACION: Archivos Temporales, Cache, Prefetch y Papelera." "White"
            Write-Centered "2. OPTIMIZACION: Ejecuta comando TRIM en discos solidos (SSD)." "White"
            Write-Centered "3. REPARACION: Escaneo SFC y DISM (Requiere Internet)." "White"
            Write-Centered "4. REDES: Reset de IP, DNS y Winsock (Causara un micro-corte)." "White"
            Write-Host "`n"
            Write-Centered " 1. Ejecutar y Volver al Menu " "Yellow"
            Write-Centered " 2. Ejecutar y CERRAR Toolbox " "Red"
            Write-Host "`n"
            Write-Centered " 0. Volver " "Gray"
            
            $conf = Get-KeyPress
            if ($conf -eq '1' -or $conf -eq '2') {
                Show-Header
                Write-Centered ">> EJECUTANDO MANTENIMIENTO AUTOMATICO <<" "Green"
                Write-Host "`n"
                Write-ToolboxLog "--- INICIO DE MANTENIMIENTO AUTOMATICO ---"
                
                Write-Centered "[ Paso 0 de 3 ] Forzando y Creando Punto de Restauracion..." "Yellow"
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                Checkpoint-Computer -Description "Toolbox_Viktor_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                Write-Centered "OK" "Green"; Write-Host "`n"

                Write-Centered "[ Paso 1 de 3 ] Limpiando basura, papelera y optimizando SSD..." "Yellow"
                &$Accion_Limpieza
                Write-Centered "OK" "Green"; Write-Host "`n"

                Write-Centered "[ Paso 2 de 3 ] Reparando archivos del SO (Aguarde)..." "Yellow"
                &$Accion_Reparacion
                Write-Host "`n"

                Write-Centered "[ Paso 3 de 3 ] Reseteando stack de red..." "Yellow"
                &$Accion_Red
                Write-Centered "OK" "Green"; Write-Host "`n"
                
                $reportPath = "$PublicDesktop\Reporte_Mantenimiento.txt"
                "=== REPORTE DE MANTENIMIENTO ===" | Out-File -FilePath $reportPath -Encoding UTF8
                "Toolbox by Viktor" | Out-File -FilePath $reportPath -Append -Encoding UTF8
                "Fecha: $(Get-Date -Format 'dd/MM/yyyy a las HH:mm:ss')" | Out-File -FilePath $reportPath -Append -Encoding UTF8
                "--------------------------------" | Out-File -FilePath $reportPath -Append -Encoding UTF8
                "El equipo ha sido optimizado exitosamente. Se recomienda reiniciar." | Out-File -FilePath $reportPath -Append -Encoding UTF8
                
                Write-ToolboxLog "--- FIN DE MANTENIMIENTO AUTOMATICO ---"
                Write-Centered ("-" * 80) "Gray"
                Write-Centered "[OK] MANTENIMIENTO COMPLETADO CON EXITO" "Green"
                Write-Centered "Reporte guardado en el Escritorio publico." "Cyan"
                
                Play-FinishBeep
                
                if ($conf -eq '2') { [Console]::Clear(); exit }
                Pause-Menu; $subAuto = $false
            } elseif ($conf -eq '0') {
                $subAuto = $false
            }
        }
    }
    
    "C" = { 
        Show-Header; Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"
        Write-Centered "Toolbox Tecnico Pro ha sido desarrollado por Viktor." "White"
        Write-Host "`n"; Write-Centered "Repositorio Oficial:" "Gray"; Write-Centered "https://github.com/xvacorx" "Cyan"
        Write-Host "`n"; Write-Centered "Abriendo navegador..." "Yellow"
        Start-Process "https://github.com/xvacorx"
        Pause-Menu
    }
    
    "1" = { # DIAGNOSTICO
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== DIAGNOSTICO E INFO DE SISTEMA ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resumen de Sistema (Hardware, Alerta de Disco, Uptime)" "White"
            Write-Centered "2. Estado de Licencia (Activacion real)" "White"
            Write-Centered "3. Ver Ultimos Pantallazos Azules (BSOD)" "White"
            Write-Centered "4. Ver Salud de Discos y Tipo (SSD/HDD)" "White"
            Write-Centered "5. Generar Reporte de Bateria (HTML)" "Yellow"
            Write-Centered "6. Exportar Inventario de PC (TXT)" "Yellow"
            Write-Centered "7. Ver Historial de Auditoria Local (Logs)" "Cyan"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header; Write-Centered "--- RADIOGRAFIA DEL SISTEMA ---" "Cyan"; Write-Host "`n"
                    $sysInfo = Get-WmiCim "Win32_ComputerSystem"
                    $serial = (Get-WmiCim "Win32_Bios").SerialNumber
                    $cpu = (Get-WmiCim "Win32_Processor").Name
                    $ramObj = Get-WmiCim "Win32_PhysicalMemory"
                    if ($ramObj) { $ram = [Math]::Round(($ramObj | Measure-Object Capacity -Sum).Sum / 1GB) } else { $ram = "?" }
                    
                    $os = Get-WmiCim "Win32_OperatingSystem"
                    try {
                        $bootTime = $os.LastBootUpTime
                        if ($bootTime.GetType().Name -eq "String") { $bootTime = $os.ConvertToDateTime($bootTime) }
                        $timespan = New-TimeSpan -Start $bootTime -End (Get-Date)
                        $uptimeStr = "$($timespan.Days) Dias, $($timespan.Hours) Horas, $($timespan.Minutes) Minutos"
                        
                        if ($timespan.Days -ge 30) { $uptimeColor = "Red" }
                        elseif ($timespan.Days -ge 15) { $uptimeColor = "Yellow" }
                        else { $uptimeColor = "Green" }
                    } catch { $uptimeStr = "No se pudo calcular"; $uptimeColor = "White" }
                    
                    $bl = Get-WmiCim -Class "Win32_EncryptableVolume" -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -Filter "DriveLetter='C:'"
                    if ($bl) { if ($bl.ProtectionStatus -eq 1) { $blStatus = "Cifrado (ACTIVADO)" } else { $blStatus = "Desencriptado (DESACTIVADO)" } } else { $blStatus = "No Detectado" }

                    $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'"
                    if ($diskC) {
                        $free = [math]::Round($diskC.FreeSpace / 1GB, 1)
                        $total = [math]::Round($diskC.Size / 1GB, 1)
                        $pct = [math]::Round(($free / $total) * 100, 1)
                        if ($pct -lt 15) { $diskStr = "$free GB libres de $total GB [CRITICO]" } else { $diskStr = "$free GB libres de $total GB" }
                    } else { $diskStr = "No se pudo leer C:" }

                    Write-Centered "Fabricante/Modelo: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
                    Write-Centered "Procesador (CPU): $cpu" "White"
                    Write-Centered "Memoria RAM: $ram GB" "White"
                    if ($diskStr -match "CRITICO") { Write-Centered "Almacenamiento (C:): $diskStr" "Red" } else { Write-Centered "Almacenamiento (C:): $diskStr" "White" }
                    Write-Centered "Serial (BIOS): $serial" "White"
                    Write-Host "`n"
                    Write-Centered "Tiempo Encendido (Uptime): $uptimeStr" $uptimeColor
                    if($blStatus -match "ACTIVADO"){Write-Centered "Estado BitLocker (C:): $blStatus" "Red"}else{Write-Centered "Estado BitLocker (C:): $blStatus" "Green"}
                    
                    $keyObj = Get-WmiCim "SoftwareLicensingService"
                    if($keyObj -and $keyObj.OA3xOriginalProductKey){ Write-Centered "Licencia OEM BIOS: $($keyObj.OA3xOriginalProductKey)" "Green" }
                    Write-ToolboxLog "Consultado Resumen de Sistema."
                    Pause-Menu 
                }
                '2' { Show-Header; Write-Centered "--- ESTADO DE LICENCIA ---" "Cyan"; Write-Host "`n"; cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '3' { Show-Header; Write-Centered "--- ULTIMOS 5 ERRORES CRITICOS ---" "Red"; Write-Host "`n"; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List; Pause-Menu }
                '4' { 
                    Show-Header; Write-Centered "--- SALUD DEL DISCO ---" "Cyan"; Write-Host "`n"
                    if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) {
                        Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table -AutoSize | Out-String -Stream | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Write-Centered $_.Trim() "White" }
                    } else {
                        Get-WmiCim "Win32_DiskDrive" | Select-Object Model, Status | Out-String -Stream | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Write-Centered $_.Trim() "White" }
                    }
                    Pause-Menu 
                }
                '5' { 
                    Show-Header; Write-Centered "Generando reporte de bateria..." "Cyan"; Write-Host "`n"
                    $battery = Get-WmiCim "Win32_Battery"
                    if (-not $battery) {
                        Write-Centered "[!] Este equipo no posee bateria (PC de Escritorio)." "Yellow"
                    } else {
                        powercfg /batteryreport /output "$PublicDesktop\BatteryReport.html" | Out-Null
                        if (Test-Path "$PublicDesktop\BatteryReport.html") {
                            Invoke-Item "$PublicDesktop\BatteryReport.html"; Write-Centered "Reporte abierto desde el Escritorio publico." "Green"
                        } else {
                            Write-Centered "[!] El sistema operativo no soporta esta funcion (Win 8+ requerido)." "Yellow"
                        }
                    }
                    Pause-Menu 
                }
                '6' {
                    Show-Header; Write-Centered "Generando TXT con inventario..." "Cyan"
                    $inv = "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt"
                    $sysInfo = Get-WmiCim "Win32_ComputerSystem"
                    $ramObj = Get-WmiCim "Win32_PhysicalMemory"
                    if ($ramObj) { $ram = [Math]::Round(($ramObj | Measure-Object Capacity -Sum).Sum / 1GB) } else { $ram = "?" }
                    "=== INVENTARIO DE EQUIPO ===" | Out-File $inv -Encoding UTF8
                    "Nombre de PC: $env:COMPUTERNAME" | Out-File $inv -Append -Encoding UTF8
                    "Fabricante/Modelo: $($sysInfo.Manufacturer) $($sysInfo.Model)" | Out-File $inv -Append -Encoding UTF8
                    "Usuario: $env:USERNAME" | Out-File $inv -Append -Encoding UTF8
                    "Sistema: $((Get-WmiCim Win32_OperatingSystem).Caption)" | Out-File $inv -Append -Encoding UTF8
                    "CPU: $((Get-WmiCim Win32_Processor).Name)" | Out-File $inv -Append -Encoding UTF8
                    "RAM: $ram GB" | Out-File $inv -Append -Encoding UTF8
                    Write-Centered "Inventario guardado en Escritorio publico." "Green"; Write-ToolboxLog "Inventario exportado."; Pause-Menu
                }
                '7' {
                    Show-Header; Write-Centered "--- VISOR DE HISTORIAL DE TOOLBOX ---" "Cyan"; Write-Host "`n"
                    if (Test-Path $logPath) {
                        Get-Content $logPath -Tail 20 | ForEach-Object { Write-Centered $_ "White" }
                        Write-Host "`n"; Write-Centered "(Mostrando los ultimos 20 registros del equipo)" "Gray"
                    } else {
                        Write-Centered "No hay registros de auditoria previos en este equipo." "Yellow"
                    }
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "2" = { # REPARACION
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REPARACION Y SOLUCION DE ERRORES ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Reparar Imagen de Windows (SFC + DISM)" "Yellow"
            Write-Centered "2. Programar Reparacion de Disco (CHKDSK)" "Yellow"
            Write-Centered "3. Crear Punto de Restauracion Manual" "Yellow"
            Write-Centered "4. Destrabar Cola de Impresion" "Yellow"
            Write-Centered "5. Reconstruir Cache de Iconos" "Yellow"
            Write-Centered "6. Alternar Administrador Oculto" "Yellow"
            Write-Centered "7. Forzar Sincronizacion de Hora" "Yellow"
            Write-Centered "8. Hard Reset Windows Update" "Red"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Reparacion; Play-FinishBeep; Write-Host "`n"; Write-Centered "Listo." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "A. Escaneo Rapido (/f) | B. Profundo (/f /r)" "Yellow"
                    $chk = Get-KeyPress
                    if ($chk -eq 'A') { cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "Programado para reinicio." "Green"; Write-ToolboxLog "CHKDSK /f programado." }
                    if ($chk -eq 'B') { cmd.exe /c "echo S | chkdsk C: /f /r" | Out-Null; Write-Centered "Programado para reinicio." "Green"; Write-ToolboxLog "CHKDSK /f /r programado." }
                    Pause-Menu
                }
                '3' { 
                    Show-Header; Write-Centered "Habilitando proteccion y creando Punto de Restauracion..." "Cyan"; Write-Host "`n"
                    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                    Checkpoint-Computer -Description "Toolbox_Viktor_Respaldo" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
                    Write-Centered "Punto de Restauracion Creado." "Green"; Write-ToolboxLog "Punto de Restauracion manual creado."; Pause-Menu 
                }
                '4' { 
                    Show-Header; Write-Centered "Vaciando cola de impresion..." "Cyan"
                    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2 # Evita error de archivo bloqueado
                    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
                    Start-Service -Name Spooler -ErrorAction SilentlyContinue
                    Write-Centered "Cola vaciada." "Green"; Write-ToolboxLog "Cola de impresion vaciada."; Pause-Menu
                }
                '5' {
                    Show-Header; Write-Centered "Reiniciando Explorador y borrando cache..." "Cyan"
                    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
                    Start-Process explorer; Write-Centered "Escritorio recargado." "Green"; Write-ToolboxLog "Cache de iconos reconstruido."; Pause-Menu
                }
                '6' {
                    Show-Header; Write-Centered "A. Activar Administrador | B. Desactivar" "Yellow"
                    $adm = Get-KeyPress
                    if ($adm -eq 'A') { net user administrador /active:yes | Out-Null; net user administrator /active:yes | Out-Null; Write-Centered "Habilitada." "Green"; Write-ToolboxLog "Cuenta Admin habilitada." }
                    if ($adm -eq 'B') { net user administrador /active:no | Out-Null; net user administrator /active:no | Out-Null; Write-Centered "Deshabilitada." "Green"; Write-ToolboxLog "Cuenta Admin deshabilitada." }
                    Pause-Menu
                }
                '7' { Show-Header; Write-Centered "Sincronizando reloj..." "Cyan"; Write-Host "`n"; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Write-ToolboxLog "Reloj sincronizado."; Pause-Menu }
                '8' { 
                    Show-Header; Write-Centered "Reseteando Windows Update..." "Red"
                    Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 2 # Evita error de archivo bloqueado en SoftwareDistribution
                    Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                    Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue
                    Write-Centered "Servicios reseteados y cache purgado." "Green"; Write-ToolboxLog "Hard Reset Windows Update."; Pause-Menu 
                }
                '0' { $sub = $false }
            }
        }
    }

    "3" = { # REDES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REDES Y CONECTIVIDAD ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resetear Stack de Red Completo" "Yellow"
            Write-Centered "2. Extraer Claves Wi-Fi Guardadas" "White"
            Write-Centered "3. Test de Conectividad e Info IP" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Red; Write-Centered "Red reseteada y Direccion IP renovada." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "--- CLAVES WI-FI ---" "Cyan"; Write-Host "`n"
                    $wifiPath = "$PublicDesktop\Claves_WiFi.txt"
                    "=== CLAVES WI-FI HISTORICAS ===" | Out-File $wifiPath -Encoding UTF8
                    
                    $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                    foreach ($profile in $profiles) { 
                        $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }
                        Write-Centered "$profile : $pass" "Green"
                        "$profile : $pass" | Out-File $wifiPath -Append -Encoding UTF8
                    }
                    Write-Host "`n"; Write-Centered "Archivo Claves_WiFi guardado en Escritorio publico." "Yellow"
                    Write-ToolboxLog "Claves Wi-Fi extraidas y exportadas."; Pause-Menu 
                }
                '3' { 
                    Show-Header; Write-Centered "--- TEST DE CONECTIVIDAD ---" "Cyan"; Write-Host "`n"
                    Write-Centered "Testeando conexion a Internet..." "Yellow"
                    if (Test-Internet) { Write-Centered "[OK] Internet Detectado." "Green" } else { Write-Centered "[X] Sin Internet o bloqueado por Firewall." "Red" }
                    Write-Host ""
                    Write-Centered "Adaptadores Activos:" "Yellow"
                    if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) {
                        Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed
                    } else {
                        Get-WmiCim Win32_NetworkAdapter | Where-Object NetConnectionStatus -eq 2 | Format-Table Name, MACAddress, Speed
                    }
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "4" = { # LIMPIEZA
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== MANTENIMIENTO Y LIMPIEZA ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Borrar Archivos Temporales, Cache y Papelera" "Yellow"
            Write-Centered "2. Purgar Visor de Eventos (Borra TODOS los Logs)" "Red"
            Write-Centered "3. Limpieza Profunda de Windows Update (WinSxS)" "Red"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Limpieza; Write-Centered "Basura eliminada y disco optimizado." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "Borrando historial de eventos del sistema..." "Red"
                    wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
                    Write-Centered "Logs de Windows completamente limpios." "Green"; Write-ToolboxLog "Purgado Visor de Eventos de Windows."; Pause-Menu
                }
                '3' {
                    Show-Header; Write-Centered "Limpiando actualizaciones antiguas (Esto puede demorar)..." "Red"
                    dism /online /cleanup-image /StartComponentCleanup | Out-Null
                    Play-FinishBeep
                    Write-Centered "Carpeta WinSxS depurada. Gigabytes recuperados." "Green"; Write-ToolboxLog "Limpieza profunda WinSxS ejecutada."; Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "5" = { # SOFTWARE Y ARRANQUE
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== SOFTWARE Y ARRANQUE ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Gestor de Instalaciones (Apps y Utilidades)" "White"
            Write-Centered "2. Actualizador Global de Software (Winget)" "Yellow"
            Write-Centered "3. Escaneo Rapido Antivirus (Windows Defender)" "Yellow"
            Write-Centered "4. Ver Programas que Inician con Windows" "White"
            Write-Centered "5. Alternar Modo Seguro (Safe Mode)" "Yellow"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    if (-not (Test-Winget)) { Pause-Menu; break }
                    $subSoft = $true
                    while($subSoft) {
                        Show-Header; Write-Centered "-- GESTOR DE SOFTWARE --" "Cyan"; Write-Host "`n"
                        Write-Centered "[ PAQUETE BASICO ]" "Cyan"
                        Write-Centered " 1. Chrome | 2. AnyDesk | 3. 7-Zip | 4. TODOS (1-3)" "Yellow"
                        Write-Host "`n"
                        Write-Centered "[ HERRAMIENTAS OPCIONALES ]" "Cyan"
                        Write-Centered " 5. VLC Media | 6. Notepad++ | 7. Reader | 8. Zoom" "Yellow"
                        Write-Host "`n"
                        Write-Centered " 0. Volver" "Gray"
                        
                        $inst = Get-KeyPress
                        switch($inst) {
                            '1' { Show-Header; Write-Centered "Instalando Chrome..." "Yellow"; Write-Host "`n"; winget install Google.Chrome -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado Google Chrome."; Pause-Menu }
                            '2' { Show-Header; Write-Centered "Instalando AnyDesk..." "Yellow"; Write-Host "`n"; winget install AnyDesk.AnyDesk -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado AnyDesk."; Pause-Menu }
                            '3' { Show-Header; Write-Centered "Instalando 7-Zip..." "Yellow"; Write-Host "`n"; winget install 7zip.7zip -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado 7-Zip."; Pause-Menu }
                            '4' { Show-Header; Write-Centered "Instalando Paquete Basico..." "Yellow"; Write-Host "`n"; foreach($a in @("Google.Chrome","AnyDesk.AnyDesk","7zip.7zip")){winget install $a -e --disable-interactivity --accept-source-agreements --accept-package-agreements}; Write-ToolboxLog "Instalado Paquete Basico Soft."; Pause-Menu }
                            '5' { Show-Header; Write-Centered "Instalando VLC..." "Yellow"; Write-Host "`n"; winget install VideoLAN.VLC -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado VLC."; Pause-Menu }
                            '6' { Show-Header; Write-Centered "Instalando Notepad++..." "Yellow"; Write-Host "`n"; winget install Notepad++.Notepad++ -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado Notepad++."; Pause-Menu }
                            '7' { Show-Header; Write-Centered "Instalando Adobe Reader..." "Yellow"; Write-Host "`n"; winget install Adobe.Acrobat.Reader.64-bit -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado Adobe Reader."; Pause-Menu }
                            '8' { Show-Header; Write-Centered "Instalando Zoom..." "Yellow"; Write-Host "`n"; winget install Zoom.Zoom -e --disable-interactivity --accept-source-agreements --accept-package-agreements; Write-ToolboxLog "Instalado Zoom."; Pause-Menu }
                            '0' { $subSoft = $false }
                        }
                    }
                }
                '2' { 
                    Show-Header; Write-Centered "--- ACTUALIZADOR GLOBAL WINGET ---" "Yellow"; Write-Host "`n"
                    if (-not (Test-Winget)) { Pause-Menu; break }
                    if (Test-Internet) {
                        winget upgrade --all --include-unknown --disable-interactivity --accept-source-agreements --accept-package-agreements
                        Write-Host "`n"; Write-Centered "Actualizacion global finalizada." "Green"
                        Write-ToolboxLog "Ejecutada actualizacion global de Winget."
                    } else {
                        Write-Centered "[!] SIN CONEXION: Imposible buscar actualizaciones." "Red"
                    }
                    Pause-Menu
                }
                '3' { 
                    Show-Header; Write-Centered "--- ESCANEO DE WINDOWS DEFENDER ---" "Yellow"; Write-Host "`n"
                    if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) {
                        Start-MpScan -ScanType QuickScan; Write-Host "`n"; Write-Centered "Escaneo completado." "Green"
                        Write-ToolboxLog "Escaneo Defender ejecutado."
                    } else {
                        Write-Centered "[!] Windows Defender nativo no detectado en esta version de SO." "Yellow"
                    }
                    Pause-Menu 
                }
                '4' { Show-Header; Write-Centered "--- APLICACIONES DE INICIO ---" "Cyan"; Write-Host "`n"; Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table; Pause-Menu }
                '5' { 
                    Show-Header; Write-Centered "A. Activar Modo Seguro | B. Desactivar (Normal)" "Yellow"
                    $sm = Get-KeyPress
                    if ($sm -eq 'A') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered "Modo Seguro ACTIVADO." "Green"; Write-ToolboxLog "Modo Seguro Activado." }
                    if ($sm -eq 'B') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered "Modo Seguro DESACTIVADO." "Green"; Write-ToolboxLog "Modo Seguro Desactivado." }
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "6" = { # OPTIMIZACIONES Y ATAJOS
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== OPTIMIZACIONES Y ATAJOS CLASICOS ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Deshabilitar Inicio Rapido (Fast Startup)" "Yellow"
            Write-Centered "2. Habilitar Inicio Rapido (Fast Startup)" "Yellow"
            Write-Centered "3. Generar acceso 'God Mode' en Escritorio" "Yellow"
            Write-Centered "4. Aniquilar Bloatware (Desinstalar basura de Windows)" "Red"
            Write-Host "`n"
            Write-Centered "--- PANELES DE CONTROL ANTIGUOS ---" "Cyan"
            Write-Centered "5. Panel de Control Principal" "White"
            Write-Centered "6. Administrador de Dispositivos" "White"
            Write-Centered "7. Conexiones de Red (Adaptadores)" "White"
            Write-Centered "8. Programas y Caracteristicas (Desinstalar)" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Centered "Inicio Rapido DESHABILITADO. Apagados limpios activados." "Green"
                    Write-ToolboxLog "Fast Startup Deshabilitado."; Pause-Menu 
                }
                '2' { 
                    Show-Header
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue
                    Write-Centered "Inicio Rapido HABILITADO." "Green"
                    Write-ToolboxLog "Fast Startup Habilitado."; Pause-Menu 
                }
                '3' { 
                    Show-Header
                    $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
                    if (-not (Test-Path $path)) { 
                        New-Item -ItemType Directory -Path $path | Out-Null
                        Write-Centered "Carpeta 'God Mode' creada en Escritorio publico." "Green" 
                        Write-ToolboxLog "Acceso GodMode generado."
                    } else { Write-Centered "La carpeta 'God Mode' ya existe." "White" }
                    Pause-Menu 
                }
                '4' {
                    Show-Header; Write-Centered "--- DESINSTALANDO BLOATWARE ---" "Red"; Write-Host "`n"
                    if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) {
                        $bloatware = @("*bing*", "*zune*", "*xboxapp*", "*gethelp*", "*getstarted*", "*solitaire*", "*people*", "*yourphone*", "*skypeapp*")
                        foreach ($app in $bloatware) {
                            Write-Centered "-> Purgando paquete: $app" "Gray"
                            Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                        }
                        Write-Host "`n"; Write-Centered "Limpieza de Bloatware finalizada." "Green"
                        Write-ToolboxLog "Bloatware aniquilado exitosamente."
                    } else {
                        Write-Centered "[!] Tu version de Windows no usa paquetes Appx (No requiere limpieza)." "Yellow"
                    }
                    Pause-Menu
                }
                '5' { Start-Process control; Write-ToolboxLog "Abierto Panel de Control."; Write-Centered "Abriendo..." "Green"; Pause-Menu }
                '6' { Start-Process devmgmt.msc; Write-ToolboxLog "Abierto Adm. Dispositivos."; Write-Centered "Abriendo..." "Green"; Pause-Menu }
                '7' { Start-Process ncpa.cpl; Write-ToolboxLog "Abierto Conexiones de Red."; Write-Centered "Abriendo..." "Green"; Pause-Menu }
                '8' { Start-Process appwiz.cpl; Write-ToolboxLog "Abierto Programas y Caracteristicas."; Write-Centered "Abriendo..." "Green"; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }
}

# --- 6. BUCLE DEL MENU PRINCIPAL ---
do {
    Show-Header
    Write-Centered " 1. Diagnostico e Info de Sistema      " "White"
    Write-Centered " 2. Reparacion y Solucion de Errores   " "White"
    Write-Centered " 3. Redes y Conectividad               " "White"
    Write-Centered " 4. Limpieza y Mantenimiento           " "White"
    Write-Centered " 5. Gestor de Software y Arranque      " "White"
    Write-Centered " 6. Optimizaciones y Atajos Clasicos   " "White"
    Write-Host "`n"
    Write-Centered " A. MODO AUTOMATICO                    " "Green"
    Write-Centered " C. Creditos (GitHub)                  " "Cyan"
    Write-Host "`n"
    Write-Centered ("-" * 80) "Gray"
    Write-Centered " 0. Salir                              " "Gray"
    
    $choice = Get-KeyPress
    if ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "0")

# --- 7. CIERRE LIMPIO ---
[Console]::Clear()
exit
