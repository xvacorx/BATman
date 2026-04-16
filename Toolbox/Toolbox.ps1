# =========================================================
# TOOLBOX TECNICO PRO - ENGINE V11 (Data-Driven Architecture)
# Chroma Cat Studios - IT Division
# =========================================================

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
        $Raw = $Host.UI.RawUI; $Raw.BackgroundColor = "Black"; $Raw.ForegroundColor = "White"
        $Buffer = $Raw.BufferSize; $Buffer.Width = 110; $Buffer.Height = 3000; $Raw.BufferSize = $Buffer
        $Size = $Raw.WindowSize; $Size.Width = [math]::Min(110, $Raw.MaxWindowSize.Width); $Size.Height = [math]::Min(38, $Raw.MaxWindowSize.Height); $Raw.WindowSize = $Size
    } catch { }
}
[Console]::BackgroundColor = "Black"; [Console]::Clear(); [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 4. CARGA DE BASE DE DATOS E HIBRIDACION (JSON) ---
# ATENCION: Reemplaza esta URL por el enlace RAW de tu menu.json en GitHub
$jsonUrl = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/menu.json" 

$jsonPath = Join-Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition -ErrorAction SilentlyContinue) "menu.json" -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($jsonPath) -or -not (Test-Path $jsonPath)) { $jsonPath = ".\menu.json" }

if (Test-Path $jsonPath) {
    # MODO LOCAL (Pendrive / Desarrollo)
    try {
        $db = Get-Content -Raw -Path $jsonPath -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-Host "[!] FATAL ERROR: El archivo menu.json local tiene errores de sintaxis." -ForegroundColor Red; Pause; exit
    }
} else {
    # MODO NUBE (Ejecucion en memoria via irm | iex)
    Write-Host "Iniciando Motor V11. Descargando arquitectura desde la nube..." -ForegroundColor Cyan
    try {
        $db = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        # En algunas versiones de PS, Invoke-RestMethod devuelve un string en vez del objeto parseado.
        if ($db.GetType().Name -eq "String") { $db = $db | ConvertFrom-Json }
    } catch {
        Write-Host "[!] FATAL ERROR: No se pudo descargar la arquitectura menu.json desde GitHub." -ForegroundColor Red
        Write-Host "Verifica la conexion a internet o la URL del RAW en el script." -ForegroundColor Yellow
        Pause; exit
    }
}

if ($null -eq $global:lang) { $global:lang = $db.config.default_lang }

# --- 5. FUNCIONES GLOBALES ---
$logPath = "C:\Windows\Logs\Toolbox_Auditoria.log"
$PublicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')

function Write-ToolboxLog([string]$action) {
    try {
        if (-not (Test-Path "C:\Windows\Logs")) { New-Item -ItemType Directory -Path "C:\Windows\Logs" -Force | Out-Null }
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] [ADMIN] - $action" | Out-File -FilePath $logPath -Append -Encoding UTF8
    } catch { }
}

function Write-Centered {
    param([string]$text, [string]$color = "White", [string]$bg = "Black")
    $width = [Console]::WindowWidth; if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
}

function Play-FinishBeep { try { [System.Console]::Beep(800, 150); Start-Sleep -Milliseconds 50; [System.Console]::Beep(1200, 400) } catch { } }
function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") { try { if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop } else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop } } catch { if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue } else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue } } }
function Test-Internet { if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }; return $false }
function Pause-Menu { Write-Host "`n"; Write-Centered $db.diccionario.press_key.$global:lang "Gray"; try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 2 } }

# --- ACCIONES MAESTRAS (Motores) ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null }
    Write-ToolboxLog "Limpieza de Sistema (Temp, Papelera, TRIM)."
}

$Accion_Reparacion = { 
    if (Test-Internet) {
        Write-Centered "--- DISM ---" "Yellow"; dism /online /cleanup-image /restorehealth; Write-Host "`n"
        Write-Centered "--- SFC ---" "Yellow"; sfc /scannow
        Write-ToolboxLog "Reparacion Profunda (SFC/DISM)."
    } else { Write-Centered "SIN CONEXION: Omitiendo SFC/DISM" "Red" }
}

$Accion_Red = { ipconfig /release | Out-Null; netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null; ipconfig /renew | Out-Null }

# --- 6. REGISTRO DE COMANDOS (Action Map) ---
# Aquí es donde el motor mapea el "target" del JSON con el código real de PowerShell.
$Actions = @{
    # -- Diagnostico --
    "cmd_diag_sysinfo" = {
        Write-Centered "--- INFO ---" "Cyan"; Write-Host "`n"
        $sysInfo = Get-WmiCim "Win32_ComputerSystem"; $cpu = (Get-WmiCim "Win32_Processor").Name
        $os = Get-WmiCim "Win32_OperatingSystem"; try { $bootTime = $os.LastBootUpTime; if ($bootTime.GetType().Name -eq "String") { $bootTime = $os.ConvertToDateTime($bootTime) }; $timespan = New-TimeSpan -Start $bootTime -End (Get-Date); $uptimeStr = "$($timespan.Days) D, $($timespan.Hours) H" } catch { $uptimeStr = "?" }
        $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'"; if ($diskC) { $free = [math]::Round($diskC.FreeSpace / 1GB, 1); $total = [math]::Round($diskC.Size / 1GB, 1) }
        Write-Centered "PC: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
        Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk C: $free GB / $total GB" "White"
        Write-Centered "Uptime: $uptimeStr" "Green"
    }
    "cmd_diag_lic" = { cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" } }
    "cmd_diag_bsod" = { Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List }
    "cmd_diag_disk" = { if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table -AutoSize | Out-String -Stream | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Write-Centered $_.Trim() "White" } } else { Get-WmiCim "Win32_DiskDrive" | Select-Object Model, Status | Out-String -Stream | ForEach-Object { Write-Centered $_.Trim() "White" } } }
    "cmd_diag_batt" = { powercfg /batteryreport /output "$PublicDesktop\BatteryReport.html" | Out-Null; if (Test-Path "$PublicDesktop\BatteryReport.html") { Invoke-Item "$PublicDesktop\BatteryReport.html"; Write-Centered "OK" "Green" } }
    "cmd_diag_inv" = { "Inventario" | Out-File "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt" -Encoding UTF8; Write-Centered "OK" "Green" }
    "cmd_diag_logs" = { if (Test-Path $logPath) { Get-Content $logPath -Tail 15 | ForEach-Object { Write-Centered $_ "White" } } }

    # -- Reparacion --
    "cmd_rep_sfc" = { &$Accion_Reparacion; Play-FinishBeep }
    "cmd_rep_chkdsk" = { cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "OK" "Green" }
    "cmd_rep_restore" = { Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_rep_spool" = { Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue; Start-Service -Name Spooler -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_rep_icons" = { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue; Start-Process explorer; Write-Centered "OK" "Green" }
    "cmd_rep_time" = { Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" } }
    "cmd_rep_wu" = { Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }

    # -- Redes --
    "cmd_net_reset" = { &$Accion_Red; Write-Centered "OK" "Green" }
    "cmd_net_wifi" = { $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" } }
    "cmd_net_ip" = { if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) { Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed } else { Get-WmiCim Win32_NetworkAdapter | Where-Object NetConnectionStatus -eq 2 | Format-Table Name, MACAddress, Speed } }

    # -- Limpieza --
    "cmd_clean_temp" = { &$Accion_Limpieza; Write-Centered "OK" "Green" }
    "cmd_clean_logs" = { wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }; Write-Centered "OK" "Green" }
    "cmd_clean_winsxs" = { dism /online /cleanup-image /StartComponentCleanup | Out-Null; Play-FinishBeep; Write-Centered "OK" "Green" }

    # -- Software --
    "cmd_soft_install" = { if(Test-Winget){ winget install Google.Chrome AnyDesk.AnyDesk 7zip.7zip -e --disable-interactivity --accept-source-agreements --accept-package-agreements } }
    "cmd_soft_update" = { if(Test-Winget){ winget upgrade --all --include-unknown --disable-interactivity --accept-source-agreements --accept-package-agreements } }
    "cmd_soft_scan" = { if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) { Start-MpScan -ScanType QuickScan; Write-Centered "OK" "Green" } }
    "cmd_soft_startup" = { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table }
    "cmd_soft_safe" = { Write-Centered "1. Safe Mode ON | 2. Safe Mode OFF" "Yellow"; $sm = Read-Host; if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null }; if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null }; Write-Centered "OK" "Green" }

    # -- Optimizaciones --
    "cmd_opt_fastoff" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_opt_faston" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_opt_godmode" = { $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }; Write-Centered "OK" "Green" }
    "cmd_opt_bloat" = { if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) { $bloatware = @("*bing*", "*xboxapp*", "*gethelp*", "*solitaire*"); foreach ($app in $bloatware) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue } }; Write-Centered "OK" "Green" }
    "cmd_opt_cpl" = { Start-Process control }
    "cmd_opt_dev" = { Start-Process devmgmt.msc }
    "cmd_opt_net" = { Start-Process ncpa.cpl }
    "cmd_opt_app" = { Start-Process appwiz.cpl }

    # -- Modo Automático --
    "cmd_auto_run" = {
        Write-Centered ">> EJECUTANDO MANTENIMIENTO AUTOMATICO <<" "Green"; Write-Host "`n"
        Write-Centered "[ Paso 0 de 3 ] Punto de Restauracion..." "Yellow"
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Centered "[ Paso 1 de 3 ] Limpiando basura..." "Yellow"; &$Accion_Limpieza
        Write-Centered "[ Paso 2 de 3 ] Reparando SO..." "Yellow"; &$Accion_Reparacion
        Write-Centered "[ Paso 3 de 3 ] Reseteando red..." "Yellow"; &$Accion_Red
        Play-FinishBeep
    }
    "cmd_auto_run_exit" = {
        & $Actions["cmd_auto_run"]; [Console]::Clear(); exit
    }
    
    # -- Extras --
    "action_credits" = {
        Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"
        Write-Centered "Toolbox Tecnico Pro - By Viktor" "White"
        Write-Centered "Chroma Cat Studios" "Pink"
        Write-Host "`n"; Write-Centered "GitHub: github.com/xvacorx" "Cyan"
        Start-Process "https://github.com/xvacorx"
    }
}

# --- 7. MOTOR DE RENDERIZADO Y NAVEGACIÓN ---
$currentMenu = "principal"

while ($true) {
    [Console]::Clear()
    $l = $global:lang
    $menuData = $db.menus.$currentMenu

    # Header Fijo
    Write-Host "`n"
    Write-Centered "  _______ ____   ____  _      ____   ______  __ " "Cyan"
    Write-Centered " |__   __/ __ \ / __ \| |    |  _ \ / __ \ \/ / " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    | |_) | |  | \  /  " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    |  _ <| |  | /  \  " "Cyan"
    Write-Centered "    |_|  \____/ \____/|______|____/ \____/_/\_\ " "Cyan"
    Write-Host "`n"
    Write-Centered ("=" * 80) "Gray"
    Write-Centered "              $($db.diccionario.title.$l)              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    Write-Centered $db.diccionario.legend.$l "Gray"
    Write-Host "`n"

    # Título del Submenú Dinámico
    if ($null -ne $menuData.titulo) {
        Write-Centered "=== $($menuData.titulo.$l) ===" "Cyan"; Write-Host "`n"
    }

    # Render de Opciones Dinámico
    foreach ($op in $menuData.opciones) {
        $label = if ($l -eq 'es') { $op.label_es } else { $op.label_en }
        
        # Asignación visual de colores según tu estándar
        $color = "White"
        if ($op.tecla -eq 'A') { $color = "Green" }
        elseif ($op.tecla -eq 'L' -or $op.tecla -eq 'C') { $color = "Yellow" }
        elseif ($op.tecla -eq '0') { $color = "Gray" }

        Write-Centered " $($op.tecla). $label " $color
    }

    # Prompt
    Write-Host "`n"; Write-Centered ("-" * 80) "Gray"
    Write-Host (" " * 46) "+ $($db.diccionario.option.$l) " -ForegroundColor Gray -NoNewline
    
    # Input Hook
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    $key = $null
    while ($true) {
        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($keyInfo.Character -match '[a-zA-Z0-9]') { 
                $key = $keyInfo.Character.ToString().ToUpper()
                Write-Host $key -ForegroundColor Cyan
                break 
            }
        } catch { $key = (Read-Host).ToUpper(); break }
    }

    # Ruteo Lógico (El "Cerebro")
    $selectedOption = $null
    foreach ($op in $menuData.opciones) {
        if ($op.tecla.ToUpper() -eq $key) { $selectedOption = $op; break }
    }

    if ($selectedOption) {
        $target = $selectedOption.target

        # Reglas de ruteo
        if ($target -eq "sys_exit") {
            [Console]::Clear(); exit
        }
        elseif ($target -eq "sys_lang_toggle") {
            $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }
            Write-Centered "Switching language..." "Cyan"; Start-Sleep -Milliseconds 400
        }
        elseif ($target.StartsWith("cmd_") -or $target.StartsWith("action_")) {
            [Console]::Clear(); Show-Header
            if ($Actions.ContainsKey($target)) {
                & $Actions[$target]
            } else {
                Write-Centered "[!] Comando no encontrado en el motor PS1: $target" "Red"
            }
            Pause-Menu
        }
        elseif ($null -ne $db.menus.$target) {
            # Es un cambio de pantalla
            $currentMenu = $target
        }
    }
}