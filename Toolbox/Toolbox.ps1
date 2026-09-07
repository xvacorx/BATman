# =========================================================
# TOOLBOX TECNICO PRO - v3.2.0
# =========================================================

# --- 1. PROTOCOLOS Y ELEVACION ---
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13 }
catch { [Net.SecurityProtocolType]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }

if ($null -eq $IsWindows) { $IsWindows = $true; $IsLinux = $false; $IsMacOS = $false }

if ($IsWindows) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $scriptPath = $MyInvocation.MyCommand.Path
        if ([string]::IsNullOrWhiteSpace($scriptPath)) { $scriptPath = $PSCommandPath }
        $isLocal = $false
        
        if (-not [string]::IsNullOrWhiteSpace($scriptPath)) {
            try {
                if (Test-Path -LiteralPath $scriptPath -PathType Leaf -ErrorAction SilentlyContinue) {
                    $isLocal = $true
                }
            } catch { }
        }

        $hostExe = (Get-Process -Id $PID -ErrorAction SilentlyContinue).Path
        if ([string]::IsNullOrWhiteSpace($hostExe) -or -not (Test-Path $hostExe)) {
            $hostExe = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
        }

        if (-not $isLocal) {
            # Usamos un bloque try-catch dentro del comando remoto para que la ventana NO se cierre si falla
            $remoteCmd = "try { iex (irm https://raw.githubusercontent.com/xvacorx/BATman/main/Toolbox/Toolbox.ps1) } catch { Write-Host '[!] Error Fatal en la elevacion: ' + `$_.Exception.Message -ForegroundColor Red; Read-Host 'Presiona Enter para cerrar' }"
            Start-Process $hostExe -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "`"$remoteCmd`""
        } else {
            Start-Process $hostExe -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`""
        }
        exit
    }
    try { [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic"); [Microsoft.VisualBasic.Interaction]::AppActivate($PID) } catch { }
} else {
    $uid = $(id -u)
    if ($uid -ne "0") {
        Write-Host "Elevando privilegios (sudo)..." -ForegroundColor Yellow
        if ($PSCommandPath) { sudo pwsh -NoProfile -File "$PSCommandPath" }
        else { sudo pwsh -NoProfile -Command "iex (irm https://raw.githubusercontent.com/xvacorx/BATman/main/Toolbox/Toolbox.ps1)" }
        exit
    }
}
# --- 2. CONFIGURACION DE VENTANA ---
if ($Host.Name -eq "ConsoleHost") {
    try {
        $Raw = $Host.UI.RawUI; $Raw.BackgroundColor = "Black"; $Raw.ForegroundColor = "White"
        $Buffer = $Raw.BufferSize; $Buffer.Width = 110; $Buffer.Height = 3000; $Raw.BufferSize = $Buffer
        $Size = $Raw.WindowSize; $Size.Width = [math]::Min(110, $Raw.MaxWindowSize.Width); $Size.Height = [math]::Min(38, $Raw.MaxWindowSize.Height); $Raw.WindowSize = $Size
    } catch { }
}
[Console]::BackgroundColor = "Black"; [Console]::Clear(); [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 3. FUNCIONES DE APOYO Y GLOBALES ---
$logPath = "C:\Windows\Logs\Toolbox_Auditoria.log"
$PublicDesktop = [Environment]::GetFolderPath('CommonDesktopDirectory')
if ([string]::IsNullOrWhiteSpace($PublicDesktop)) { $PublicDesktop = "$env:PUBLIC\Desktop" }

function Write-AuditLog([string]$action, [string]$status = "OK", [string]$details = "") {
    try {
        $logDir = [System.IO.Path]::GetDirectoryName($logPath)
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        $username = [Environment]::UserName
        $logEntry = "[$timestamp] [$username] [$status] - $action"
        if ([string]::IsNullOrWhiteSpace($details) -eq $false) { $logEntry += " ($details)" }
        Add-Content -Path $logPath -Value $logEntry -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch { }
}

function Write-Centered ($text, $color="White", $bg="Black") {
    $width = [Console]::WindowWidth; if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
}

# MOTOR DE TECLADO ZERO-ENTER
function Read-SingleKey {
    try {
        $Host.UI.RawUI.FlushInputBuffer()
        while ($true) {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($keyInfo.Character -match '^[a-zA-Z0-9]$') {
                return $keyInfo.Character.ToString().ToUpper()
            }
        }
    } catch {
        $input = Read-Host
        if ($input.Length -gt 0) { return $input.Substring(0,1).ToUpper() }
        return ""
    }
}

function Pause-Menu {
    Write-Host "`n"
    Write-Centered $db.diccionario.press_key.$global:lang "Gray"
    try {
        $Host.UI.RawUI.FlushInputBuffer()
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        $null = Read-Host
    }
}

function Show-Header {
    $l = $global:lang
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
}

function Play-FinishBeep { try { [System.Console]::Beep(800, 150); Start-Sleep -Milliseconds 50; [System.Console]::Beep(1200, 400) } catch { } }

function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") {
    try {
        if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop }
        else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop }
    } catch {
        if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue }
        else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue }
    }
}

function Test-Internet { if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }; return $false }

function Get-WingetPath {
    $cmd = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    
    $userApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Test-Path $userApps) { return $userApps }
    
    $winApps = Get-ChildItem -Path "C:\Program Files\WindowsApps" -Filter "winget.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($winApps) { return $winApps.FullName }
    
    $profileWinget = Get-ChildItem -Path "C:\Users" -Filter "winget.exe" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -like "*WindowsApps\winget.exe*" } | Select-Object -First 1
    if ($profileWinget) { return $profileWinget.FullName }
    
    return $null
}

function Invoke-SafeDownload {
    param(
        [string]$Uri,
        [string]$OutFile,
        [hashtable]$Headers = @{}
    )
    if ($null -eq $Headers) { $Headers = @{} }
    if (-not $Headers.ContainsKey("User-Agent")) {
        $Headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13 } catch { }

    $maxRetries = 3
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Headers $Headers -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
            if (Test-Path $OutFile) { return $true }
        } catch {
            $is429 = $_.Exception.Message -like "*429*" -or $_.Exception.Message -like "*Too Many Requests*"
            if ($attempt -lt $maxRetries) {
                $waitTime = $attempt * 3
                if ($is429) {
                    Write-Centered "   [!] HTTP 429 (Too Many Requests). Reintentando en ${waitTime}s (Intento $attempt/$maxRetries)..." "Yellow"
                } else {
                    Write-Centered "   [!] Reintentando descarga en ${waitTime}s (Intento $attempt/$maxRetries)..." "Yellow"
                }
                Start-Sleep -Seconds $waitTime
            } else {
                return $false
            }
        }
    }
    return $false
}

# --- 4. CARGA DE BASE DE DATOS (JSON) ---
$jsonUrl = "https://raw.githubusercontent.com/xvacorx/BATman/main/Toolbox/menu.json"

$jsonPath = ""
if (-not [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Definition)) {
    try {
        $jsonPath = Join-Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition -ErrorAction SilentlyContinue) "menu.json" -ErrorAction SilentlyContinue
    } catch {
        $jsonPath = ""
    }
}

$hasValidJsonPath = $false
if (-not [string]::IsNullOrWhiteSpace($jsonPath)) {
    try {
        if (Test-Path -Path $jsonPath -PathType Leaf -ErrorAction SilentlyContinue) {
            $hasValidJsonPath = $true
        }
    } catch { }
}

if (-not $hasValidJsonPath) {
    $jsonPath = ".\menu.json"
    try {
        if (Test-Path -Path $jsonPath -PathType Leaf -ErrorAction SilentlyContinue) {
            $hasValidJsonPath = $true
        }
    } catch { }
}

if ($hasValidJsonPath) {
    try { $db = Get-Content -Raw -Path $jsonPath -Encoding UTF8 | ConvertFrom-Json }
    catch { Write-Host "[!] FATAL ERROR: El archivo menu.json local tiene errores." -ForegroundColor Red; Pause; exit }
} else {
    Write-Host "Cargando motor v3.2.0 desde la nube..." -ForegroundColor Cyan
    try {
        $db = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        if ($db.GetType().Name -eq "String") { $db = $db | ConvertFrom-Json }
    } catch {
        Write-Host "[!] FATAL ERROR: Fallo la conexion con GitHub." -ForegroundColor Red; Pause; exit
    }
}

if ($null -eq $global:lang) {
    $sysLang = (Get-Culture).TwoLetterISOLanguageName
    if ($sysLang -eq 'es' -or $sysLang -eq 'en') { $global:lang = $sysLang } else { $global:lang = $db.config.default_lang }
}

# --- 5. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    if ($IsWindows) {
        $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
        foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-AuditLog "Accion_Limpieza" "OK"
    } else {
        Remove-Item "/tmp/*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:HOME/.cache/*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-AuditLog "Accion_Limpieza" "OK"
    }
}

$Accion_Reparacion = {
    if (Test-Internet) {
        Write-Centered "Ejecutando SFC & DISM..." "Yellow"
        if ($IsWindows) {
            dism /online /cleanup-image /restorehealth
            sfc /scannow
            Write-AuditLog "Accion_Reparacion" "OK"
        }
    } else {
        Write-Centered "[!] No hay conexion a internet para reparar via DISM. Ejecutando SFC..." "Yellow"
        if ($IsWindows) { sfc /scannow; Write-AuditLog "Accion_Reparacion" "OK" "Solo SFC" }
    }
}

# --- 6. REGISTRO DE COMANDOS ($Actions) ---
$Actions = @{
    # DIAGNOSTICO
    "cmd_diag_sysinfo" = {
        Write-Centered "--- INFO DE SISTEMA ---" "Cyan"; Write-Host "`n"
        if ($IsWindows) {
            $sysInfo = Get-WmiCim "Win32_ComputerSystem" | Select-Object -First 1
            $cpus = Get-WmiCim "Win32_Processor"
            $cpuName = if ($cpus) { ($cpus | Select-Object -First 1).Name.Trim() } else { "Desconocido" }
            
            $os = Get-WmiCim "Win32_OperatingSystem" | Select-Object -First 1
            $uptime = "?"
            try {
                $bt = $os.LastBootUpTime
                if ($bt) {
                    if ($bt -isnot [DateTime]) {
                        $bt = [System.Management.ManagementDateTimeConverter]::ToDateTime($bt.ToString())
                    }
                    $ts = New-TimeSpan -Start $bt -End (Get-Date)
                    $uptime = "$($ts.Days)d $($ts.Hours)h $($ts.Minutes)m"
                }
            } catch { $uptime = "?" }
            
            $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'" | Select-Object -First 1
            $free = "?"; $total = "?"
            if ($diskC -and $diskC.Size -gt 0) {
                $free = [math]::Round($diskC.FreeSpace / 1GB, 1)
                $total = [math]::Round($diskC.Size / 1GB, 1)
            }
            
            Write-Centered "PC: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
            Write-Centered "CPU: $cpuName" "White"
            Write-Centered "Disco C: $free GB libre de $total GB" "White"
            Write-Centered "Uptime: $uptime" "Green"
            Write-AuditLog "cmd_diag_sysinfo" "OK" "CPU: $cpuName | Uptime: $uptime"
        } elseif ($IsLinux) {
            $pc = hostname; $cpu = (lscpu | grep "Model name:" | sed 's/Model name: *//').Trim()
            $disk = df -h / | tail -n 1 | awk '{print $4 " / " $2}'
            $uptime = uptime -p
            Write-Centered "PC: $pc" "Yellow"; Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk /: $disk" "White"; Write-Centered "Uptime: $uptime" "Green"
            Write-AuditLog "cmd_diag_sysinfo" "OK"
        } elseif ($IsMacOS) {
            $pc = scutil --get ComputerName; $cpu = sysctl -n machdep.cpu.brand_string
            $disk = df -h / | tail -n 1 | awk '{print $4 " / " $2}'
            $uptime = uptime | awk -F'( |,|:)+' '{print $6 " H, " $7 " M"}'
            Write-Centered "PC: $pc" "Yellow"; Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk /: $disk" "White"; Write-Centered "Uptime: $uptime" "Green"
            Write-AuditLog "cmd_diag_sysinfo" "OK"
        }
    }
    "cmd_diag_lic" = {
        $slmgrPath = "$env:SystemRoot\System32\slmgr.vbs"
        if (Test-Path "$env:SystemRoot\SysNative\slmgr.vbs") { $slmgrPath = "$env:SystemRoot\SysNative\slmgr.vbs" }
        try {
            cscript //nologo $slmgrPath /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }
            Write-AuditLog "cmd_diag_lic" "OK"
        } catch {
            Write-Centered "[!] Error consultando estado de licencia." "Red"
            Write-AuditLog "cmd_diag_lic" "ERROR" $_.Exception.Message
        }
    }
    "cmd_diag_bsod" = {
        try {
            Write-Centered "Consultando eventos recientes de pantallazos azules (BugCheck / Kernel-Power)..." "Cyan"
            $events = Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001,41} -MaxEvents 5 -ErrorAction SilentlyContinue
            if ($events) {
                foreach ($evt in $events) {
                    Write-Centered "[$($evt.TimeCreated)] ID: $($evt.Id) - $($evt.ProviderName)" "Yellow"
                    $msgSnippet = if ($evt.Message) { $evt.Message.Substring(0, [math]::Min(120, $evt.Message.Length)) } else { "Sin detalles" }
                    Write-Centered "$msgSnippet" "White"
                    Write-Host "`n"
                }
            } else { Write-Centered "[OK] No se registraron eventos recientes de BSOD o reinicios inesperados." "Green" }
            Write-AuditLog "cmd_diag_bsod" "OK"
        } catch { Write-Centered "[!] Error consultando registro de eventos BSOD." "Red" }
    }
    "cmd_diag_disk" = {
        if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) {
            Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table -AutoSize | Out-String -Stream | ForEach-Object { Write-Centered $_.Trim() "White" }
            Write-AuditLog "cmd_diag_disk" "OK"
        } else {
            Write-Centered "Get-PhysicalDisk no disponible en este sistema." "Yellow"
        }
    }
    "cmd_diag_batt" = {
        $batt = Get-WmiCim "Win32_Battery" | Select-Object -First 1
        if (-not $batt) {
            Write-Centered "[INFO] Este equipo no cuenta con bateria (Es una PC de escritorio o VM)." "Yellow"
            Write-AuditLog "cmd_diag_batt" "OK" "Sin Bateria (Desktop/VM)"
            return
        }
        $reportPath = "$PublicDesktop\BatteryReport.html"
        powercfg /batteryreport /output "$reportPath" | Out-Null
        if (Test-Path $reportPath) {
            Invoke-Item "$reportPath"
            Write-Centered "[OK] Reporte generado y abierto en el Escritorio Publico." "Green"
            Write-AuditLog "cmd_diag_batt" "OK" "Reporte Generado"
        } else {
            Write-Centered "[!] No se pudo generar el reporte de bateria." "Red"
            Write-AuditLog "cmd_diag_batt" "ERROR"
        }
    }
    "cmd_diag_inv" = {
        $invPath = "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt"
        "Inventario Hardware y Sistema - $env:COMPUTERNAME" | Out-File $invPath -Encoding UTF8
        "Fecha: $(Get-Date)" | Out-File $invPath -Encoding UTF8 -Append
        Get-WmiCim "Win32_ComputerSystem" | Out-String | Out-File $invPath -Encoding UTF8 -Append
        Write-Centered "[OK] Inventario exportado a $invPath" "Green"
        Write-AuditLog "cmd_diag_inv" "OK"
    }
    "cmd_diag_logs" = {
        if (Test-Path $logPath) {
            Write-Centered "--- HISTORIAL DE AUDITORIA LOCAL ($logPath) ---" "Cyan"; Write-Host "`n"
            Get-Content $logPath -Tail 20 -Encoding UTF8 | ForEach-Object { Write-Centered $_ "White" }
        } else {
            Write-Centered "No hay registros de auditoria aun en $logPath" "Yellow"
        }
        Write-AuditLog "cmd_diag_logs" "OK"
    }

    # REPARACION
    "cmd_rep_sfc" = { &$Accion_Reparacion; Play-FinishBeep; Write-AuditLog "cmd_rep_sfc" "OK" }
    "cmd_rep_chkdsk" = {
        try {
            cmd.exe /c "echo S | chkdsk C: /f"
            Write-Centered "[OK] CHKDSK programado para el proximo reinicio." "Green"
            Write-AuditLog "cmd_rep_chkdsk" "OK"
        } catch {
            Write-Centered "Error ejecutando CHKDSK" "Red"
            Write-AuditLog "cmd_rep_chkdsk" "ERROR"
        }
    }
    "cmd_rep_restore" = {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "Toolbox_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Centered "[OK] Punto de restauracion creado." "Green"
        Write-AuditLog "cmd_rep_restore" "OK"
    }
    "cmd_rep_icons" = {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
        Start-Process explorer
        Write-Centered "[OK] Cache de iconos reconstruida." "Green"
        Write-AuditLog "cmd_rep_icons" "OK"
    }
    "cmd_rep_time" = {
        Restart-Service w32time -ErrorAction SilentlyContinue
        w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }
        Write-Centered "[OK] Hora sincronizada." "Green"
        Write-AuditLog "cmd_rep_time" "OK"
    }
    "cmd_rep_wu" = {
        Write-Centered "=== REINICIO COMPLETO DE WINDOWS UPDATE ===" "Yellow"
        Write-Centered "   [1/4] Deteniendo servicios (wuauserv, cryptSvc, bits, dosvc)..." "Cyan"
        Stop-Service wuauserv, cryptSvc, bits, dosvc -Force -ErrorAction SilentlyContinue

        Write-Centered "   [2/4] Limpiando carpetas SoftwareDistribution y Catroot2..." "Cyan"
        $sdPath = "$env:windir\SoftwareDistribution"
        $catPath = "$env:windir\System32\catroot2"

        for ($retry = 1; $retry -le 3; $retry++) {
            try {
                if (Test-Path $sdPath) { Remove-Item $sdPath -Recurse -Force -ErrorAction Stop }
                if (Test-Path $catPath) { Remove-Item $catPath -Recurse -Force -ErrorAction Stop }
                break
            } catch { Start-Sleep -Seconds 1 }
        }

        Write-Centered "   [3/4] Purgando cola de descargas BITS..." "Cyan"
        try { bitsadmin /reset /allusers | Out-Null } catch { }

        Write-Centered "   [4/4] Reiniciando servicios de Windows Update..." "Cyan"
        Start-Service wuauserv, cryptSvc, bits, dosvc -ErrorAction SilentlyContinue
        Write-Centered "[OK] Servicios y cache de Windows Update restablecidos completamente." "Green"
        Write-AuditLog "cmd_rep_wu" "OK"
    }

    # REDES Y RDP
    "cmd_net_reset" = {
        Write-Centered "--- RESET DE RED PROFUNDO ---" "Cyan"
        Write-Centered "ADVERTENCIA: Esto cortara cualquier conexion remota (AnyDesk/RDP) y requiere REINICIO." "Red"
        Write-Host (" " * 30) "+ Desea continuar? (S/N): " -ForegroundColor Gray -NoNewline

        $ans = Read-SingleKey
        Write-Host $ans -ForegroundColor Cyan

        if ($ans -eq 'S' -or $ans -eq 'Y') {
            Write-Centered "Liberando IP y limpiando DNS..." "Yellow"
            ipconfig /release | Out-Null
            ipconfig /flushdns | Out-Null

            Write-Centered "Reseteando Winsock y TCP/IP..." "Yellow"
            netsh winsock reset | Out-Null
            $resetLog = Join-Path $env:TEMP "resetlog.txt"
            netsh int ip reset $resetLog | Out-Null

            Write-Centered "Renovando IP local..." "Yellow"
            ipconfig /renew | Out-Null

            Write-Centered "OK! EL STACK ESTA LIMPIO. DEBES REINICIAR LA PC." "Green"
            Write-AuditLog "cmd_net_reset" "OK"
        } else {
            Write-Centered "Operacion cancelada por el usuario." "White"
            Write-AuditLog "cmd_net_reset" "CANCELLED"
        }
    }
    "cmd_net_wifi" = {
        $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
        foreach ($profile in $profiles) {
            $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }
            Write-Centered "$profile : $pass" "Green"
        }
        Write-AuditLog "cmd_net_wifi" "OK"
    }
    "cmd_net_ip" = {
        if ($IsWindows) { ipconfig | findstr "IPv4" | ForEach-Object { Write-Centered $_.Trim() "White" } }
        else { ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | ForEach-Object { Write-Centered $_ "White" } }
        Write-AuditLog "cmd_net_ip" "OK"
    }
    "cmd_net_gpupdate" = {
        Write-Centered "Actualizando Directivas de Grupo (GPO)..." "Yellow"
        gpupdate /force | Out-Null
        Write-Centered "[OK] GPO Actualizada." "Green"
        Write-AuditLog "cmd_net_gpupdate" "OK"
    }
    "cmd_net_rdp_on" = {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254.*" }).IPAddress | Select-Object -First 1
        if ($ip) { $ip | Set-Clipboard; Write-Centered "[OK] RDP Habilitado ($ip copiado al portapapeles)." "Green" }
        Write-AuditLog "cmd_net_rdp_on" "OK" "IP: $ip"
    }
    "cmd_net_rdp_off" = {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
        Disable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null
        Write-Centered "[OK] RDP Deshabilitado." "Red"
        Write-AuditLog "cmd_net_rdp_off" "OK"
    }

    # LIMPIEZA
    "cmd_clean_temp" = { &$Accion_Limpieza; Write-Centered "[OK] Limpieza de temporales completada." "Green"; Write-AuditLog "cmd_clean_temp" "OK" }
    "cmd_clean_logs" = {
        wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
        Write-Centered "[OK] Registros de eventos purgados." "Green"
        Write-AuditLog "cmd_clean_logs" "OK"
    }
    "cmd_clean_winsxs" = {
        Write-Centered "Ejecutando limpieza profunda de WinSxS (Puede demorar)..." "Yellow"
        dism /online /cleanup-image /StartComponentCleanup
        Write-Centered "[OK] Limpieza de WinSxS completada." "Green"
        Write-AuditLog "cmd_clean_winsxs" "OK"
    }

    # SOFTWARE CATALOGO
    "cmd_soft_scan" = {
        if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) {
            Write-Centered "Iniciando escaneo rapido con Windows Defender..." "Cyan"
            Start-MpScan -ScanType QuickScan
            Write-Centered "[OK] Escaneo rapido completado." "Green"
            Write-AuditLog "cmd_soft_scan" "OK"
        }
    }
    "cmd_soft_startup" = {
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table
        Write-AuditLog "cmd_soft_startup" "OK"
    }
    "cmd_soft_safe" = {
        Write-Host "`n"; Write-Centered "1. Safe Mode ON | 2. Safe Mode OFF | 0. Cancelar" "Yellow"
        $sm = Read-SingleKey
        if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null }
        if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null }
        Write-Centered "[OK] Configuracion de Modo Seguro modificada." "Green"
        Write-AuditLog "cmd_soft_safe" "OK" "Modo: $sm"
    }
    "cmd_soft_catalog" = {
        $wingetBin = Get-WingetPath
        if (-not $wingetBin) {
            Write-Centered "[!] ATENCION: Winget (App Installer) no se encuentra instalado en este equipo." "Red"
            Write-Host "`n"; Write-Host (" " * 20) "+ Deseas intentar instalar/actualizar Winget y PowerShell ahora? (S/N): " -ForegroundColor Yellow -NoNewline
            $ansW = Read-SingleKey
            Write-Host $ansW -ForegroundColor Cyan
            if ($ansW -eq 'S' -or $ansW -eq 'Y') {
                & $Actions["cmd_rep_win10_update"]
                $wingetBin = Get-WingetPath
            }
            if (-not $wingetBin) {
                Write-Centered "[INFO] Se activara el modo Descarga Directa de Respaldo para instalar aplicaciones." "Cyan"
                Start-Sleep -Seconds 2
            }
        }

        $apps = @(
            @{ID="1"; Name="Chrome"; Winget="Google.Chrome"; Url="https://dl.google.com/chrome/install/latest/chrome_installer.exe"; Args="/silent /install"},
            @{ID="2"; Name="Firefox"; Winget="Mozilla.Firefox"; Url="https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=es-ES"; Args="/qn"},
            @{ID="3"; Name="AnyDesk"; Winget="AnyDesk.AnyDesk"; Url="https://download.anydesk.com/AnyDesk.exe"; Args="--install `"C:\Program Files (x86)\AnyDesk`" --start-with-win --silent"},
            @{ID="4"; Name="7-Zip"; Winget="7zip.7zip"; Url="https://www.7-zip.org/a/7z2408-x64.exe"; Args="/S"},
            @{ID="5"; Name="VLC"; Winget="VideoLAN.VLC"; Url="https://get.videolan.org/vlc/3.0.21/win64/vlc-3.0.21-win64.exe"; Args="/L=1034 /S"},
            @{ID="6"; Name="Adobe Reader"; Winget="Adobe.Acrobat.Reader.64-bit"; Url="https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2400120604/AcroRdrDC2400120604_en_US.exe"; Args="/sAll /rs /msi EULA_ACCEPT=YES"},
            @{ID="7"; Name="Notepad++"; Winget="Notepad++.Notepad++"; Url="https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.9/npp.8.6.9.Installer.x64.exe"; Args="/S"},
            @{ID="8"; Name="Zoom"; Winget="Zoom.Zoom"; Url="https://zoom.us/client/latest/ZoomInstallerFull.exe"; Args="/silent"},
            @{ID="9"; Name="Rufus"; Winget="Rufus.Rufus"; Url="https://github.com/pbatard/rufus/releases/download/v4.5/rufus-4.5.exe"; Args=""},
            @{ID="A"; Name="Spotify"; Winget="Spotify.Spotify"; Url="https://download.scdn.co/SpotifySetup.exe"; Args="/silent"},
            @{ID="B"; Name="OBS Studio"; Winget="OBSProject.OBSStudio"; Url="https://github.com/obsproject/obs-studio/releases/download/32.2.1/OBS-Studio-32.2.1-Windows-x64-Installer.exe"; Args="/S"},
            @{ID="C"; Name="WinRAR"; Winget="RARLab.WinRAR"; Url="https://www.rarlab.com/rar/winrar-x64-701es.exe"; Args="/S"}
        )
        $selected = New-Object System.Collections.Generic.List[string]
        while ($true) {
            [Console]::Clear(); Write-Centered "--- CATALOGO INTERACTIVO DE SOFTWARE ---" "Cyan"; Write-Host "`n"

            $half = [math]::Ceiling($apps.Count / 2)
            for ($i = 0; $i -lt $half; $i++) {
                $app1 = $apps[$i]
                $app2 = if ($i + $half -lt $apps.Count) { $apps[$i + $half] } else { $null }

                $mark1 = if ($selected.Contains($app1.ID)) { "[X]" } else { "[ ]" }
                $color1 = if ($selected.Contains($app1.ID)) { "Green" } else { "White" }
                $str1 = "$mark1 $($app1.ID). $($app1.Name)"

                if ($app2) {
                    $mark2 = if ($selected.Contains($app2.ID)) { "[X]" } else { "[ ]" }
                    $color2 = if ($selected.Contains($app2.ID)) { "Green" } else { "White" }
                    $str2 = "$mark2 $($app2.ID). $($app2.Name)"

                    Write-Host (" " * 15) -NoNewline
                    Write-Host $str1.PadRight(35) -ForegroundColor $color1 -NoNewline
                    Write-Host $str2 -ForegroundColor $color2
                } else {
                    Write-Host (" " * 15) -NoNewline
                    Write-Host $str1 -ForegroundColor $color1
                }
            }

            Write-Host "`n"
            Write-Centered "E. Esenciales (Chrome, AnyDesk, 7-Zip, VLC, Notepad++)" "Yellow"
            Write-Centered "I. Instalar seleccionados | 0. Volver" "Yellow"
            Write-Host (" " * 30) "+ Opcion: " -NoNewline
            $inputKey = Read-SingleKey
            $inputKey = $inputKey.ToUpper()
            Write-Host $inputKey -ForegroundColor Cyan

            if ($inputKey -eq '0') { break }
            if ($inputKey -eq 'E') { $selected.Clear(); $selected.AddRange(@("1","3","4","5","7")) }
            if ($inputKey -eq 'I' -and $selected.Count -gt 0) {
                Write-Host "`n"
                $totalCount = $selected.Count
                $currentIndex = 0
                foreach ($id in $selected) {
                    $installed = $false
                    $currentIndex++
                    $app = $apps | Where-Object { $_.ID -eq $id }
                    if ($app) {
                        Write-Centered "[$currentIndex/$totalCount] Procesando instalacion de $($app.Name)..." "Cyan"
                        # Pre-verificacion especial para AnyDesk
                        if ($app.Name -eq "AnyDesk") {
                            $adPath1 = "${env:ProgramFiles(x86)}\AnyDesk\AnyDesk.exe"
                            $adPath2 = "$env:ProgramFiles\AnyDesk\AnyDesk.exe"
                            if ((Test-Path $adPath1) -or (Test-Path $adPath2)) {
                                Write-Centered "[OK] AnyDesk ya se encuentra instalado en este equipo." "Green"
                                Write-AuditLog "cmd_soft_catalog" "OK" "AnyDesk: Ya instalado"
                                $installed = $true
                            } else {
                                # Detener procesos portables o colgados en RAM que provocan error 11341828 (0x00AD0004)
                                Stop-Process -Name "anydesk" -Force -ErrorAction SilentlyContinue
                            }
                        }

                        # Plan A: Winget (con --source winget para OMITIR msstore y evitar fallos de tienda)
                        if (-not $installed -and $wingetBin) {
                            try {
                                Write-Centered "   [-] Intentando via Winget (Fuente: winget)..." "Gray"
                                $outFile = "$env:TEMP\winget_out_$($app.ID).txt"
                                $errFile = "$env:TEMP\winget_err_$($app.ID).txt"
                                $procW = Start-Process -FilePath $wingetBin -ArgumentList "install $($app.Winget) --source winget --silent --disable-interactivity --accept-source-agreements --accept-package-agreements" -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outFile -RedirectStandardError $errFile -ErrorAction SilentlyContinue

                                $outText = ""
                                if (Test-Path $outFile) {
                                    $outText += Get-Content $outFile -Raw -ErrorAction SilentlyContinue
                                    Remove-Item $outFile -Force -ErrorAction SilentlyContinue
                                }
                                if (Test-Path $errFile) {
                                    $outText += Get-Content $errFile -Raw -ErrorAction SilentlyContinue
                                    Remove-Item $errFile -Force -ErrorAction SilentlyContinue
                                }

                                $alreadyInstalledCodes = @(0, 3010, -1978234874, 2316632070, -1978234860, 2316632084, 11341828, 11341825)
                                $isAlreadyInstalledText = ($outText -like "*already installed*" -or $outText -like "*ya está instalado*" -or $outText -like "*ya se encuentra instalad*" -or $outText -like "*No newer package version*" -or $outText -like "*No se encontró ninguna versión más reciente*" -or $outText -like "*No update found*")

                                if ($procW -and ($alreadyInstalledCodes -contains $procW.ExitCode -or $isAlreadyInstalledText)) {
                                    if ($procW.ExitCode -eq 0 -or $procW.ExitCode -eq 3010) {
                                        Write-Centered "[OK] $($app.Name) instalado/actualizado correctamente via Winget." "Green"
                                    } else {
                                        Write-Centered "[OK] $($app.Name) ya se encuentra instalado o en ejecucion." "Green"
                                    }
                                    Write-AuditLog "cmd_soft_catalog" "OK" "Winget: $($app.Name)"
                                    $installed = $true
                                } else {
                                    Write-Centered "[!] Winget no pudo completar la instalacion. Probando descarga directa..." "Yellow"
                                }
                            } catch {
                                Write-Centered "[!] Excepcion en Winget. Probando descarga directa de respaldo..." "Yellow"
                            }
                        }

                        # Plan B: Descarga directa oficial de respaldo (EXE/MSI) con mitigacion de HTTP 429
                        if (-not $installed -and $app.Url) {
                            try {
                                Write-Centered "   [-] Descargando instalador oficial directo..." "Cyan"
                                $ext = if ($app.Url -like "*.msi*") { "msi" } else { "exe" }
                                $tempInstaller = "$env:TEMP\Installer_$($app.ID).$ext"

                                $downloadOk = Invoke-SafeDownload -Uri $app.Url -OutFile $tempInstaller

                                if ($downloadOk -and (Test-Path $tempInstaller)) {
                                    Write-Centered "   [-] Ejecutando instalacion silenciosa..." "Yellow"
                                    if ($ext -eq "msi") {
                                        $p = Start-Process msiexec.exe -ArgumentList "/i `"$tempInstaller`" /quiet /norestart" -Wait -PassThru -ErrorAction Stop
                                    } else {
                                        if ([string]::IsNullOrWhiteSpace($app.Args)) {
                                            $dest = Join-Path $PublicDesktop "$($app.Name).exe"
                                            Copy-Item -Path $tempInstaller -Destination $dest -Force
                                            $p = [PSCustomObject]@{ ExitCode = 0 }
                                        } else {
                                            $p = Start-Process -FilePath $tempInstaller -ArgumentList $app.Args -Wait -PassThru -ErrorAction Stop
                                        }
                                    }

                                    # Verificacion fisica especial para AnyDesk tras ejecucion de instalador directo
                                    if ($app.Name -eq "AnyDesk") {
                                        $targetPath1 = "${env:ProgramFiles(x86)}\AnyDesk\AnyDesk.exe"
                                        $targetPath2 = "$env:ProgramFiles\AnyDesk\AnyDesk.exe"
                                        if (-not (Test-Path $targetPath1) -and -not (Test-Path $targetPath2)) {
                                            Write-Centered "   [-] Desplegando binario AnyDesk en Program Files..." "Yellow"
                                            $destDir = "${env:ProgramFiles(x86)}\AnyDesk"
                                            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                                            $destExe = Join-Path $destDir "AnyDesk.exe"
                                            Copy-Item -Path $tempInstaller -Destination $destExe -Force -ErrorAction SilentlyContinue
                                            try {
                                                $wshell = New-Object -ComObject WScript.Shell
                                                $sc = $wshell.CreateShortcut("$PublicDesktop\AnyDesk.lnk")
                                                $sc.TargetPath = $destExe
                                                $sc.Save()
                                            } catch { }
                                        }
                                        if ((Test-Path $targetPath1) -or (Test-Path $targetPath2) -or (Test-Path "$PublicDesktop\AnyDesk.lnk")) {
                                            $p = [PSCustomObject]@{ ExitCode = 0 }
                                        }
                                    }

                                    $validInstallerCodes = @(0, 3010, 11341828, 11341825, -1978234874, 2316632070)
                                    if ($p -and ($validInstallerCodes -contains $p.ExitCode)) {
                                        Write-Centered "[OK] $($app.Name) instalado correctamente." "Green"
                                        Write-AuditLog "cmd_soft_catalog" "OK" "Directo: $($app.Name)"
                                        $installed = $true
                                    } else {
                                        Write-Centered "[!] Instalador finalizo con codigo: $($p.ExitCode)" "Red"
                                        Write-AuditLog "cmd_soft_catalog" "ERROR" "$($app.Name) ExitCode $($p.ExitCode)"
                                    }
                                    Remove-Item -Path $tempInstaller -Force -ErrorAction SilentlyContinue
                                } else {
                                    Write-Centered "[FALLO] No se pudo descargar el instalador directo de $($app.Name)." "Red"
                                    Write-AuditLog "cmd_soft_catalog" "ERROR" "$($app.Name): Download failed"
                                }
                            } catch {
                                Write-Centered "[FALLO] Error en descarga/instalacion directa de $($app.Name): $($_.Exception.Message)" "Red"
                                Write-AuditLog "cmd_soft_catalog" "ERROR" "$($app.Name): $($_.Exception.Message)"
                            }
                        }
                        Start-Sleep -Milliseconds 500
                    }
                }
                Write-Centered "`nInstalacion finalizada." "Green"
                Pause-Menu
                break
            }
            if ($selected.Contains($inputKey)) { $selected.Remove($inputKey) | Out-Null }
            elseif ($apps.ID -contains $inputKey) { $selected.Add($inputKey) }
        }
    }

    # OPTIMIZACIONES
    "cmd_opt_fastoff" = {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force
        Write-Centered "[OK] Inicio rapido deshabilitado." "Green"
        Write-AuditLog "cmd_opt_fastoff" "OK"
    }
    "cmd_opt_faston" = {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force
        Write-Centered "[OK] Inicio rapido habilitado." "Green"
        Write-AuditLog "cmd_opt_faston" "OK"
    }
    "cmd_opt_godmode" = {
        $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
        if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
        Write-Centered "[OK] GodMode creado en Escritorio." "Green"
        Write-AuditLog "cmd_opt_godmode" "OK"
    }
    "cmd_opt_bloat" = {
        Write-Centered "=== ANIQUILADOR DE BLOATWARE (WIN 10 / WIN 11) ===" "Yellow"
        $bloatPatterns = @(
            "*bing*", "*xboxapp*", "*gethelp*", "*solitaire*", "*people*", "*skype*",
            "*cortana*", "*3dviewer*", "*mixedreality*", "*zunevideo*", "*zunemusic*",
            "*yourphone*", "*clipchamp*", "*news*", "*weather*", "*feedbackhub*",
            "*microsoftstickynotes*", "*todos*", "*getstarted*", "*messaging*",
            "*powerautomatedesktop*", "*gamingapp*", "*windowsalarms*", "*windowsmaps*"
        )
        Write-Host " "
        if ($global:lang -eq 'es') {
            Write-Host " Se buscaran y eliminaran las siguientes aplicaciones (Usuario actual y Aprovisionados):" -ForegroundColor Cyan
        } else {
            Write-Host " The following apps will be removed (Current user and Provisioned packages):" -ForegroundColor Cyan
        }
        foreach ($b in $bloatPatterns) { Write-Host "   - $b" -ForegroundColor Gray }

        $confirmMsg = if ($global:lang -eq 'es') { "Deseas continuar? (S/N): " } else { "Continue? (Y/N): " }
        Write-Host "`n"; Write-Host (" " * 25) "+ $confirmMsg" -ForegroundColor Gray -NoNewline
        $ans = Read-SingleKey
        Write-Host $ans -ForegroundColor Cyan

        if ($ans -eq 'S' -or $ans -eq 'Y') {
            Write-Centered "`nProcesando remocion de Bloatware..." "Yellow"
            $removedCount = 0
            
            try {
                $allApps = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                if ($allApps) {
                    foreach ($app in $allApps) {
                        $appName = $app.Name
                        foreach ($pattern in $bloatPatterns) {
                            if ($appName -like $pattern) {
                                try {
                                    Write-Host "   [-] Removiendo App: $appName..." -ForegroundColor Gray
                                    Remove-AppxPackage -Package $app.PackageFullName -ErrorAction Stop
                                    $removedCount++
                                } catch { }
                                break
                            }
                        }
                    }
                }
            } catch { }

            try {
                $provApps = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
                if ($provApps) {
                    foreach ($papp in $provApps) {
                        $pName = $papp.DisplayName
                        foreach ($pattern in $bloatPatterns) {
                            if ($pName -like $pattern) {
                                try {
                                    Write-Host "   [-] Removiendo Aprovisionada: $pName..." -ForegroundColor Gray
                                    Remove-AppxProvisionedPackage -Online -PackageName $papp.PackageName -ErrorAction Stop | Out-Null
                                    $removedCount++
                                } catch { }
                                break
                            }
                        }
                    }
                }
            } catch { }

            Write-Centered "`n[OK] Desinstalacion finalizada ($removedCount elementos procesados)." "Green"
            Write-AuditLog "cmd_opt_bloat" "OK" "Removidos: $removedCount"
        } else {
            if ($global:lang -eq 'es') { Write-Centered "Operacion Cancelada." "Gray" } else { Write-Centered "Operation Canceled." "Gray" }
            Write-AuditLog "cmd_opt_bloat" "CANCELLED"
        }
    }
    "cmd_opt_visuals" = {
        Write-Centered "Ajustando rendimiento visual..." "Yellow"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Force -ErrorAction SilentlyContinue
        Write-Centered "[OK] Rendimiento visual optimizado (Requiere reiniciar o cerrar sesion)." "Green"
        Write-AuditLog "cmd_opt_visuals" "OK"
    }
    "cmd_opt_cpl" = { Start-Process control; Write-AuditLog "cmd_opt_cpl" "OK" }
    "cmd_opt_dev" = { Start-Process devmgmt.msc; Write-AuditLog "cmd_opt_dev" "OK" }
    "cmd_opt_net" = { Start-Process ncpa.cpl; Write-AuditLog "cmd_opt_net" "OK" }
    "cmd_opt_app" = { Start-Process appwiz.cpl; Write-AuditLog "cmd_opt_app" "OK" }
    "cmd_opt_rename_hostname" = {
        $promptMsg = if ($global:lang -eq 'es') { " Nuevo Hostname (nombre del equipo)" } else { " New Hostname (computer name)" }
        $n = Read-Host $promptMsg
        if ($n) {
            if ($IsWindows) {
                Rename-Computer -NewName $n -Force -ErrorAction SilentlyContinue
                Write-Centered "[OK] Equipo renombrado a '$n' (Requiere reiniciar)." "Yellow"
            } elseif ($IsLinux) {
                hostnamectl set-hostname $n
                Write-Centered "[OK] Hostname cambiado a '$n'." "Green"
            } elseif ($IsMacOS) {
                scutil --set ComputerName $n
                scutil --set LocalHostName $n
                scutil --set HostName $n
                Write-Centered "[OK] Hostname de Mac cambiado a '$n' (Puede requerir reinicio)." "Yellow"
            }
            Write-AuditLog "cmd_opt_rename_hostname" "OK" "NewHostname: $n"
        } else {
            $cancelMsg = if ($global:lang -eq 'es') { "Operacion cancelada." } else { "Operation cancelled." }
            Write-Centered $cancelMsg "Gray"
        }
    }
    "cmd_opt_rename_user" = {
        if ($IsWindows) {
            $promptUser = if ($global:lang -eq 'es') { " Nombre de usuario a renombrar" } else { " Username to rename" }
            $promptNew  = if ($global:lang -eq 'es') { " Nuevo nombre de usuario"        } else { " New username"         }
            Get-LocalUser | Select-Object Name, Enabled | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }
            $oldName = Read-Host $promptUser
            if ($oldName) {
                $newName = Read-Host $promptNew
                if ($newName) {
                    try {
                        Rename-LocalUser -Name $oldName -NewName $newName -ErrorAction Stop
                        Write-Centered "[OK] Usuario '$oldName' renombrado a '$newName'." "Green"
                        Write-AuditLog "cmd_opt_rename_user" "OK" "OldName: $oldName -> NewName: $newName"
                    } catch {
                        Write-Centered "[!] Error al renombrar el usuario: $($_.Exception.Message)" "Red"
                        Write-AuditLog "cmd_opt_rename_user" "ERROR" "OldName: $oldName | $($_.Exception.Message)"
                    }
                }
            }
        } elseif ($IsLinux) {
            $promptUser = if ($global:lang -eq 'es') { " Usuario actual a renombrar" } else { " Current username to rename" }
            $promptNew  = if ($global:lang -eq 'es') { " Nuevo nombre de usuario"    } else { " New username"               }
            $oldName = Read-Host $promptUser
            if ($oldName) {
                $newName = Read-Host $promptNew
                if ($newName) {
                    usermod -l $newName $oldName
                    usermod -d /home/$newName -m $newName
                    Write-Centered "[OK] Usuario '$oldName' renombrado a '$newName'. Cierra sesion para aplicar." "Yellow"
                    Write-AuditLog "cmd_opt_rename_user" "OK" "OldName: $oldName -> NewName: $newName"
                }
            }
        } elseif ($IsMacOS) {
            $promptUser = if ($global:lang -eq 'es') { " Usuario actual (shortname)" } else { " Current username (shortname)" }
            $promptNew  = if ($global:lang -eq 'es') { " Nuevo nombre de usuario"    } else { " New username"                  }
            $oldName = Read-Host $promptUser
            if ($oldName) {
                $newName = Read-Host $promptNew
                if ($newName) {
                    dscl . -change /Users/$oldName RecordName $oldName $newName
                    dscl . -change /Users/$newName UserShell /bin/bash /bin/bash
                    Write-Centered "[OK] Usuario '$oldName' renombrado a '$newName'. Reinicia para aplicar." "Yellow"
                    Write-AuditLog "cmd_opt_rename_user" "OK" "OldName: $oldName -> NewName: $newName"
                }
            }
        }
    }


    # IMPRESORAS
    "cmd_rep_spool" = {
        Stop-Service Spooler -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:windir\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service Spooler -ErrorAction SilentlyContinue
        Write-Centered "[OK] Cola de impresion destrabada." "Green"
        Write-AuditLog "cmd_rep_spool" "OK"
    }
    "cmd_print_folder" = {
        $p = "$PublicDesktop\Printers.{2227a280-3aea-1069-a2de-08002b30309d}"
        if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
        Write-Centered "[OK] Carpeta Maestra de Impresoras creada." "Green"
        Write-AuditLog "cmd_print_folder" "OK"
    }
    "cmd_print_del" = {
        $printers = @(Get-Printer -ErrorAction SilentlyContinue)
        if ($printers.Count -eq 0) { Write-Centered "No se encontraron impresoras en el sistema." "Yellow"; return }
        $i=1; foreach($p in $printers){ Write-Host "  $i. $($p.Name)" -ForegroundColor White; $i++ }
        $s = Read-Host "`n Borrar nro (0 cancelar)"
        if ($s -match '^\d+$') {
            $idx = [int]$s
            if ($idx -gt 0 -and $idx -le $printers.Count) {
                $targetP = $printers[$idx - 1]
                Remove-Printer -Name $targetP.Name -ErrorAction SilentlyContinue
                Write-Centered "[OK] Impresora $($targetP.Name) eliminada." "Green"
                Write-AuditLog "cmd_print_del" "OK" $targetP.Name
            }
        }
    }
    "cmd_print_driver" = {
        $drivers = @(Get-PrinterDriver -ErrorAction SilentlyContinue)
        if ($drivers.Count -eq 0) { Write-Centered "No se encontraron drivers de impresoras." "Yellow"; return }
        $i=1; foreach($d in $drivers){ Write-Host "  $i. $($d.Name)" -ForegroundColor White; $i++ }
        $s = Read-Host "`n Borrar nro (0 cancelar)"
        if ($s -match '^\d+$') {
            $idx = [int]$s
            if ($idx -gt 0 -and $idx -le $drivers.Count) {
                $targetD = $drivers[$idx - 1]
                Remove-PrinterDriver -Name $targetD.Name -ErrorAction SilentlyContinue
                Write-Centered "[OK] Driver $($targetD.Name) eliminado." "Green"
                Write-AuditLog "cmd_print_driver" "OK" $targetD.Name
            }
        }
    }
    "cmd_print_fw" = {
        Enable-NetFirewallRule -Name "FPS-ICMP4-ERQ-In" -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "Toolbox_PrintTCP" -Direction Inbound -Protocol TCP -LocalPort 139,445 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        Write-Centered "[OK] Reglas de firewall para comparticion de impresoras aplicadas." "Green"
        Write-AuditLog "cmd_print_fw" "OK"
    }

    # IDENTIDAD
    "cmd_user_admin_on" = { net user administrator /active:yes; Write-Centered "[OK] ADMIN ON." "Green"; Write-AuditLog "cmd_user_admin_on" "OK" }
    "cmd_user_admin_off" = { net user administrator /active:no; Write-Centered "[OK] ADMIN OFF." "White"; Write-AuditLog "cmd_user_admin_off" "OK" }
    "cmd_user_pass" = {
        Get-LocalUser | Select-Object Name, Enabled | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }
        $u = Read-Host "Usuario"
        if ($u) {
            $p = Read-Host "Nueva clave"
            if ($p) {
                try {
                    $secPass = ConvertTo-SecureString $p -AsPlainText -Force
                    Set-LocalUser -Name $u -Password $secPass -ErrorAction Stop
                    Write-Centered "[OK] Contraseña para $u actualizada." "Green"
                    Write-AuditLog "cmd_user_pass" "OK" "Usuario: $u"
                } catch {
                    try {
                        net user "$u" "$p" | Out-Null
                        Write-Centered "[OK] Contraseña para $u actualizada (net user)." "Green"
                        Write-AuditLog "cmd_user_pass" "OK" "Usuario: $u (net user)"
                    } catch {
                        Write-Centered "[!] Error al cambiar la contraseña." "Red"
                        Write-AuditLog "cmd_user_pass" "ERROR" "Usuario: $u"
                    }
                }
            }
        }
    }

    # MODO AUTOMATICO (8 PASOS - v3.2.0)
    "cmd_auto_run" = {
        Write-Centered ">> MANTENIMIENTO AUTOMATICO EN PROGRESO <<" "Green"; Write-Host "`n"
        Write-Centered "[ 1/8 ] Punto de Restauracion..." "Yellow"; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Centered "[ 2/8 ] Limpieza de Basura..." "Yellow"; &$Accion_Limpieza
        Write-Centered "[ 3/8 ] Reparacion de SO (SFC/DISM)..." "Yellow"; &$Accion_Reparacion
        Write-Centered "[ 4/8 ] Escaneo de Disco en Vivo (CHKDSK)..." "Yellow"; try { cmd.exe /c "chkdsk C: /scan" } catch { Write-Centered "Error ejecutando CHKDSK en vivo" "Red" }
        Write-Centered "[ 5/8 ] Limpieza Profunda WinSxS..." "Yellow"; dism /online /cleanup-image /StartComponentCleanup
        Write-Centered "[ 6/8 ] Purgando Visor de Eventos..." "Yellow"; wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
        Write-Centered "[ 7/8 ] Forzando Politicas (GPO)..." "Yellow"; gpupdate /force | Out-Null
        Write-Centered "[ 8/8 ] Sincronizando Hora..." "Yellow"; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-Null
        Play-FinishBeep; Write-Centered "MANTENIMIENTO FINALIZADO" "Green"
        Write-AuditLog "cmd_auto_run" "OK"
    }
    "cmd_auto_run_exit" = { & $Actions["cmd_auto_run"]; [Console]::Clear(); exit }

    "action_credits" = {
        Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"; Write-Centered "Toolbox Tecnico Pro - By Viktor" "White"
        Write-Centered "Vik Tools" "Magenta"; Write-Host "`n"; Write-Centered "GitHub: github.com/xvacorx" "Cyan"; Start-Process "https://github.com/xvacorx"
        Write-AuditLog "action_credits" "OK"
    }

    # UTILIDADES EXTRAS (Modules)
    "cmd_util_antisleep" = {
        Write-Centered "=== ANTI SLEEP ===" "Yellow"
        Write-Host "`n"
        Write-Centered "1. Activar | 2. Desactivar | 0. Volver" "White"
        $ans = Read-SingleKey
        if ($ans -eq '1') {
            $psCmdB64 = "JABjAG8AZABlACAAPQAgACcAWwBEAGwAbABJAG0AcABvAHIAdAAoACIAawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAIgApAF0AIABwAHUAYgBsAGkAYwAgAHMAdABhAHQAaQBjACAAZQB4AHQAZQByAG4AIAB1AGkAbgB0ACAAUwBlAHQAVABoAHIAZQBhAGQARQB4AGUAYwB1AHQAaQBvAG4AUwB0AGEAdABlACgAdQBpAG4AdAAgAGUAcwBGAGwAYQBnAHMAKQA7ACcAOwAgACQAdAB5AHAAZQAgAD0AIABBAGQAZAAtAFQAeQBwAGUAIAAtAE0AZQBtAGIAZQByAEQAZQBmAGkAbgBpAHQAaQBvAG4AIAAkAGMAbwBkAGUAIAAtAE4AYQBtAGUAIAAnAFcAaQBuADMAMgAnACAALQBOAGEAbQBlAHMAcABhAGMAZQAgACcAUwB5AHMAdABlAG0AJwAgAC0AUABhAHMAcwBUAGgAcgB1ADsAIAB3AGgAaQBsAGUAIAAoACQAdAByAHUAZQApACAAewAgACQAdAB5AHAAZQA6ADoAUwBlAHQAVABoAHIAZQBhAGQARQB4AGUAYwB1AHQAaQBvAG4AUwB0AGEAdABlACgAMAB4ADgAMAAwADAAMAAwADAAMwApADsAIABTAHQAYQByAHQALQBTAGwAZQBlAHAAIAAtAFMAZQBjAG8AbgBkAHMAIAA6ADAAIAB9AA=="
            Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $psCmdB64
            Write-Centered "[OK] Anti Sleep Activado (Bloqueando suspension de sistema y pantalla)." "Green"
            Write-AuditLog "cmd_util_antisleep" "OK" "ON"
        } elseif ($ans -eq '2') {
            Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%SetThreadExecutionState%'" -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
            Write-Centered "[OK] Anti Sleep Desactivado." "Green"
            Write-AuditLog "cmd_util_antisleep" "OK" "OFF"
        }
    }
    "cmd_util_ping" = {
        Write-Centered "=== PING CHECK ===" "Cyan"
        Write-Host "`n"
        Write-Centered "Ingresa una IP o Hostname (o 'bulk' para usar ips.txt en el escritorio):" "Yellow"
        $target = Read-Host "Target"
        if ($target) {
            if ($target.ToLower() -eq 'bulk') {
                $file = "$PublicDesktop\ips.txt"
                if (Test-Path $file) {
                    Write-Centered "Procesando $file ..." "Yellow"
                    Get-Content $file | ForEach-Object {
                        $ip = $_.Trim()
                        if ($ip) {
                            $res = Test-Connection $ip -Count 1 -ErrorAction SilentlyContinue
                            if ($res) {
                                $resolvedIp = $res.IPv4Address.IPAddressToString; if (-not $resolvedIp) { $resolvedIp = $res.ProtocolAddress }
                                $hostName = "?"; try { $hostName = [System.Net.Dns]::GetHostEntry($resolvedIp).HostName } catch { }
                                $mac = "?"; try { $arp = arp -a $resolvedIp | Select-String -Pattern $resolvedIp; if ($arp) { $mac = ($arp -split '\s+')[2] } } catch { }
                                Write-Centered "$ip [OK] - IP: $resolvedIp - MAC: $mac - Host: $hostName" "Green"
                            } else {
                                Write-Centered "$ip [FAILED]" "Red"
                            }
                        }
                    }
                } else {
                    Write-Centered "No se encontro el archivo $file." "Red"
                    Write-Centered "Crea un archivo de texto llamado ips.txt en el Escritorio Publico." "Yellow"
                }
            } else {
                $res = Test-Connection $target -Count 1 -ErrorAction SilentlyContinue
                if ($res) {
                    $resolvedIp = $res.IPv4Address.IPAddressToString; if (-not $resolvedIp) { $resolvedIp = $res.ProtocolAddress }
                    $hostName = "?"; try { $hostName = [System.Net.Dns]::GetHostEntry($resolvedIp).HostName } catch { }
                    $mac = "?"; try { $arp = arp -a $resolvedIp | Select-String -Pattern $resolvedIp; if ($arp) { $mac = ($arp -split '\s+')[2] } } catch { }
                    Write-Centered "$target [OK] - IP: $resolvedIp - MAC: $mac - Host: $hostName" "Green"
                } else {
                    Write-Centered "$target [FAILED] - Sin Respuesta" "Red"
                }
            }
            Write-AuditLog "cmd_util_ping" "OK" "Target: $target"
        }
    }
    "cmd_util_hash" = {
        Write-Centered "=== GENERADOR DE HASH ===" "Magenta"
        Write-Host "`n"
        Write-Centered "1. Sacar MD5/SHA de un archivo | 2. Extraer Hardware Hash (CSV) | 0. Volver" "White"
        $ans = Read-SingleKey
        if ($ans -eq '1') {
            $path = Read-Host "Ruta del archivo (Arrastra el archivo aqui)"
            if ($path) {
                $path = $path.Trim('"')
                if (Test-Path $path -PathType Leaf) {
                    Write-Centered "MD5:" "Yellow"; (Get-FileHash $path -Algorithm MD5).Hash | Write-Centered -color "White"
                    Write-Centered "SHA1:" "Yellow"; (Get-FileHash $path -Algorithm SHA1).Hash | Write-Centered -color "White"
                    Write-Centered "SHA256:" "Yellow"; (Get-FileHash $path -Algorithm SHA256).Hash | Write-Centered -color "White"
                    Write-AuditLog "cmd_util_hash" "OK" "File Hash"
                } else { Write-Centered "Archivo no encontrado." "Red" }
            }
        } elseif ($ans -eq '2') {
            try {
                $devDetail = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'" -ErrorAction Stop
                $serial = (Get-CimInstance -Class Win32_BIOS).SerialNumber
                $product = (Get-CimInstance -Class Win32_OperatingSystem).SerialNumber
                $csvPath = "$PublicDesktop\HardwareHash.csv"
                "Device Serial Number,Windows Product ID,Hardware Hash" | Out-File -FilePath $csvPath -Encoding utf8
                "$serial,$product,$($devDetail.DeviceHardwareData)" | Out-File -FilePath $csvPath -Encoding utf8 -Append
                Write-Centered "[OK] CSV generado exitosamente en el Escritorio." "Green"
                Write-AuditLog "cmd_util_hash" "OK" "Hardware Hash CSV"
            } catch {
                Write-Centered "[!] Error al extraer Hardware Hash. Requiere permisos de administrador." "Red"
                Write-Centered $_.Exception.Message "White" "Red"
                Write-AuditLog "cmd_util_hash" "ERROR" $_.Exception.Message
            }
        }
    }
    "cmd_util_startup" = {
        Write-Centered "=== GESTOR DE INICIO (STARTUP) ===" "Cyan"
        Write-Host "`n"
        Write-Centered "Crea un acceso directo en la carpeta de Inicio de Windows." "Yellow"
        $path = Read-Host "Arrastra un archivo aqui para iniciar con Windows"
        if ($path) {
            $path = $path.Trim('"')
            if (Test-Path $path) {
                try {
                    $wshell = New-Object -ComObject WScript.Shell
                    $startupFolder = [Environment]::GetFolderPath('Startup')
                    $shortcutPath = Join-Path $startupFolder (([System.IO.Path]::GetFileNameWithoutExtension($path)) + ".lnk")
                    $shortcut = $wshell.CreateShortcut($shortcutPath)
                    $shortcut.TargetPath = $path
                    $shortcut.Save()
                    if (Test-Path $shortcutPath) {
                        Write-Centered "[OK] Acceso directo creado en Startup." "Green"
                        Write-AuditLog "cmd_util_startup" "OK" $path
                    } else {
                        Write-Centered "[!] Error al crear el acceso directo." "Red"
                    }
                } catch {
                    Write-Centered "[!] Error: $($_.Exception.Message)" "Red"
                }
            } else {
                Write-Centered "Archivo no encontrado." "Red"
            }
        }
    }
    "cmd_util_shutdown" = {
        Write-Centered "=== PROGRAMADOR DE APAGADO ===" "Red"
        Write-Host "`n"
        Write-Centered "1. Apagar en X minutos | 2. Cancelar Apagado | 0. Volver" "White"
        $ans = Read-SingleKey
        if ($ans -eq '1') {
            $mins = Read-Host "Minutos para apagar"
            if ($mins -match '^\d+$') {
                $secs = [int]$mins * 60
                shutdown /s /f /t $secs
                Write-Centered "[OK] Apagado programado en $mins minutos." "Green"
                Write-AuditLog "cmd_util_shutdown" "OK" "En $mins min"
            }
        } elseif ($ans -eq '2') {
            shutdown /a | Out-Null
            Write-Centered "[OK] Apagado programado cancelado." "Yellow"
            Write-AuditLog "cmd_util_shutdown" "OK" "Cancelado"
        }
    }
    "cmd_rep_win10_update" = {
        Write-Centered "=== INSTALAR / ACTUALIZAR WINGET Y POWERSHELL 7 (PWSH) ===" "Cyan"
        Write-Host "`n"
        Write-Centered "Este proceso descargara e instalara/actualizara Winget (AppInstaller) y PowerShell Core 7 (pwsh)." "Yellow"
        Write-Centered "Resuelve dependencias faltantes (WindowsAppRuntime 1.8, VCLibs) sin requerir Microsoft Store." "White"
        Write-Host "`n"; Write-Host (" " * 30) "+ Deseas continuar? (S/N): " -ForegroundColor Gray -NoNewline
        $ans = Read-SingleKey
        Write-Host $ans -ForegroundColor Cyan

        if ($ans -eq 'S' -or $ans -eq 'Y') {
            try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13 } catch { }
            $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) PowerShell/5.1" }

            $is64 = [Environment]::Is64BitOperatingSystem
            $procArch = $env:PROCESSOR_ARCHITECTURE
            $arch = if ($is64) {
                if ($procArch -like "*ARM*") { "arm64" } else { "x64" }
            } else {
                "x86"
            }

            Write-Centered "1/2 Descargando e Instalando AppInstaller (Winget) y Dependencias..." "Cyan"
            
            # Descarga del paquete oficial de dependencias de winget-cli (WindowsAppRuntime 1.8, VCLibs UWP)
            $depsUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip"
            $depsZip = "$env:TEMP\winget_deps.zip"
            $depsDir = "$env:TEMP\winget_deps"
            $installedDeps = @()

            if (Test-Path $depsDir) { Remove-Item $depsDir -Recurse -Force -ErrorAction SilentlyContinue }

            Write-Centered "   [-] Descargando dependencias oficiales (VCLibs & WindowsAppRuntime)..." "Gray"
            $dDepsOk = Invoke-SafeDownload -Uri $depsUrl -OutFile $depsZip -Headers $headers

            if ($dDepsOk -and (Test-Path $depsZip)) {
                try {
                    if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
                        Expand-Archive -Path $depsZip -DestinationPath $depsDir -Force -ErrorAction Stop
                    } else {
                        Add-Type -AssemblyName System.IO.Compression.FileSystem
                        [System.IO.Compression.ZipFile]::ExtractToDirectory($depsZip, $depsDir)
                    }

                    $archDir = Join-Path $depsDir $arch
                    if (-not (Test-Path $archDir)) { $archDir = Join-Path $depsDir "x64" }

                    if (Test-Path $archDir) {
                        $depPackages = Get-ChildItem -Path $archDir -Filter "*.appx" -ErrorAction SilentlyContinue
                        foreach ($depPkg in $depPackages) {
                            Write-Centered "   [-] Instalando $($depPkg.Name)..." "Gray"
                            try {
                                Add-AppxPackage -Path $depPkg.FullName -ErrorAction Stop
                            } catch { }
                            $installedDeps += $depPkg.FullName
                        }
                    }
                } catch {
                    Write-Centered "   [!] Advertencia al procesar dependencias: $($_.Exception.Message)" "Yellow"
                }
            }

            # Respaldo de dependencias individuales si el zip no estuvo disponible
            if ($installedDeps.Count -eq 0) {
                try {
                    Write-Centered "   [-] Descargando dependencias individuales de respaldo..." "Gray"
                    $vcLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
                    $vcLibsPath = "$env:TEMP\VCLibs.appx"
                    Invoke-WebRequest -Uri $vcLibsUrl -OutFile $vcLibsPath -Headers $headers -UseBasicParsing -ErrorAction SilentlyContinue
                    if (Test-Path $vcLibsPath) { Add-AppxPackage -Path $vcLibsPath -ErrorAction SilentlyContinue; $installedDeps += $vcLibsPath }

                    $uiXamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
                    $uiXamlPath = "$env:TEMP\UI.Xaml.appx"
                    Invoke-WebRequest -Uri $uiXamlUrl -OutFile $uiXamlPath -Headers $headers -UseBasicParsing -ErrorAction SilentlyContinue
                    if (Test-Path $uiXamlPath) { Add-AppxPackage -Path $uiXamlPath -ErrorAction SilentlyContinue; $installedDeps += $uiXamlPath }
                } catch { }
            }

            # Descarga e instalacion del paquete DesktopAppInstaller (Winget)
            try {
                $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
                $wingetPath = "$env:TEMP\winget.msixbundle"
                Write-Centered "   [-] Descargando DesktopAppInstaller..." "Gray"
                $dOk = Invoke-SafeDownload -Uri $wingetUrl -OutFile $wingetPath -Headers $headers
                if (-not $dOk) { throw "Fallo la descarga de DesktopAppInstaller" }
                
                if ($installedDeps.Count -gt 0) {
                    Add-AppxPackage -Path $wingetPath -DependencyPath $installedDeps -ForceApplicationShutdown -ForceUpdateFromAnyVersion -ErrorAction Stop
                } else {
                    Add-AppxPackage -Path $wingetPath -ForceApplicationShutdown -ForceUpdateFromAnyVersion -ErrorAction Stop
                }
                Write-Centered "[OK] Winget Instalado/Actualizado correctamente." "Green"
                Write-AuditLog "cmd_rep_win10_update" "OK" "Winget Actualizado"
            } catch {
                Write-Centered "[WARN] Add-AppxPackage directo fallo: $($_.Exception.Message)" "Yellow"
                
                # Comprobacion estricta de existencia de Microsoft Store para evitar modal del sistema
                $hasStore = $false
                try {
                    if (Test-Path "HKCR:\ms-windows-store") { $hasStore = $true }
                } catch { }

                if ($hasStore) {
                    Write-Centered "Intentando instalacion asistida mediante Microsoft Store..." "White"
                    try {
                        Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1" -ErrorAction SilentlyContinue
                        Write-Centered "[INFO] Abriendo Microsoft Store para actualizar App Installer." "Cyan"
                    } catch { }
                } else {
                    Write-Centered "[INFO] Microsoft Store no esta disponible o registrado en esta edicion de Windows." "Yellow"
                    Write-Centered "Se omitio la apertura de Store para evitar carteles de error del sistema." "Gray"
                }
                Write-AuditLog "cmd_rep_win10_update" "WARN" "Winget Fallback"
            }

            Write-Centered "`n2/2 Descargando e Instalando PowerShell Core 7 (pwsh)..." "Cyan"
            $pwshInstalledSuccessfully = $false
            $pwshBinFound = ""

            try {
                $msiPattern = if ($arch -eq "arm64") { "PowerShell-*-win-arm64.msi" } elseif ($arch -eq "x86") { "PowerShell-*-win-x86.msi" } else { "PowerShell-*-win-x64.msi" }
                $pwshMsiUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi"
                
                try {
                    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases/latest" -Headers $headers -UseBasicParsing -ErrorAction Stop
                    $asset = $releaseInfo.assets | Where-Object { $_.name -like $msiPattern } | Select-Object -First 1
                    if ($asset) { $pwshMsiUrl = $asset.browser_download_url }
                } catch { }

                $pwshPath = "$env:TEMP\pwsh.msi"
                Write-Centered "Descargando desde GitHub: $pwshMsiUrl" "Gray"
                
                $downloadSuccess = Invoke-SafeDownload -Uri $pwshMsiUrl -OutFile $pwshPath -Headers $headers
                if (-not $downloadSuccess) {
                    $fallbackUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi"
                    Write-Centered "Reintentando descarga con URL de respaldo..." "Yellow"
                    $downloadSuccess = Invoke-SafeDownload -Uri $fallbackUrl -OutFile $pwshPath -Headers $headers
                }

                if ($downloadSuccess -and (Test-Path $pwshPath)) {
                    Write-Centered "Ejecutando MSI de PowerShell Core 7..." "Yellow"
                    $msiArgs = "/i `"$pwshPath`" /quiet /norestart ADD_PATH=1 REGISTER_MANIFEST=1 /log `"$env:TEMP\pwsh_install.log`""
                    $proc = Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -PassThru -ErrorAction Stop
                    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010) {
                        $pwshInstalledSuccessfully = $true
                    } else {
                        Write-Centered "[!] MSI finalizo con codigo: $($proc.ExitCode)" "Yellow"
                        Write-AuditLog "cmd_rep_win10_update" "WARN" "MSI ExitCode $($proc.ExitCode)"
                    }
                }
            } catch {
                Write-Centered "[WARN] Fallo el instalador MSI directo: $($_.Exception.Message)" "Yellow"
                $wBin = Get-WingetPath
                if ($wBin) {
                    Write-Centered "Intentando instalar PowerShell via Winget..." "Yellow"
                    try {
                        & $wBin install --id Microsoft.PowerShell --source winget --silent --accept-package-agreements --accept-source-agreements
                        $pwshInstalledSuccessfully = $true
                        Write-AuditLog "cmd_rep_win10_update" "OK" "PowerShell via Winget"
                    } catch {
                        Write-Centered "[FALLO] Error actualizando PowerShell Core: $($_.Exception.Message)" "Red"
                        Write-AuditLog "cmd_rep_win10_update" "ERROR" $_.Exception.Message
                    }
                } else {
                    Write-Centered "[FALLO] Error actualizando PowerShell Core: $($_.Exception.Message)" "Red"
                    Write-AuditLog "cmd_rep_win10_update" "ERROR" $_.Exception.Message
                }
            }

            # Refrescar PATH de entorno en el proceso activo
            try {
                $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
                $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
                $env:Path = "$machinePath;$userPath"
            } catch { }

            # Localizar el ejecutable pwsh.exe instalado
            $defaultPwshPath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
            if (Test-Path $defaultPwshPath) {
                $pwshBinFound = $defaultPwshPath
            } else {
                $cmdPwsh = Get-Command "pwsh.exe" -ErrorAction SilentlyContinue
                if ($cmdPwsh) { $pwshBinFound = $cmdPwsh.Source }
            }

            if ($pwshBinFound -or $pwshInstalledSuccessfully) {
                $verString = ""
                if ($pwshBinFound) {
                    try { $verString = (& $pwshBinFound -v 2>$null).Trim() } catch { }
                }
                if ([string]::IsNullOrWhiteSpace($verString)) { $verString = "Core 7" }

                Write-Centered "[OK] PowerShell $verString instalado/actualizado correctamente." "Green"
                if ($pwshBinFound) { Write-Centered "Ubicacion: $pwshBinFound" "Cyan" }
                Write-Centered "[INFO] Nota: Windows PowerShell 5.1 (powershell.exe) se mantiene intacto" "White"
                Write-Centered "por diseño de Microsoft para preservar compatibilidad de Windows." "White"
                Write-AuditLog "cmd_rep_win10_update" "OK" "PowerShell $verString"

                Write-Host "`n"; Write-Host (" " * 24) "+ Deseas relanzar la Toolbox en PowerShell 7 ahora? (S/N): " -ForegroundColor Yellow -NoNewline
                $ansR = Read-SingleKey
                Write-Host $ansR -ForegroundColor Cyan
                if ($ansR -eq 'S' -or $ansR -eq 'Y') {
                    $targetPwsh = if ($pwshBinFound) { $pwshBinFound } else { "pwsh.exe" }
                    $scriptP = $MyInvocation.MyCommand.Path
                    if ([string]::IsNullOrWhiteSpace($scriptP)) { $scriptP = $PSCommandPath }
                    if (-not [string]::IsNullOrWhiteSpace($scriptP) -and (Test-Path $scriptP)) {
                        Start-Process $targetPwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptP`""
                        [Console]::Clear()
                        exit
                    } else {
                        Start-Process $targetPwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm https://raw.githubusercontent.com/xvacorx/BATman/main/Toolbox/Toolbox.ps1)`""
                        [Console]::Clear()
                        exit
                    }
                }
            }
        }
    }
    "cmd_rep_win_pro" = {
        Write-Centered "=== FORZAR UPGRADE A WINDOWS PRO (OFFLINE) ===" "Yellow"
        Write-Host "`n"
        Write-Centered "Esta funcion intentara actualizar Windows a la version Pro." "White"
        Write-Centered "Para que funcione, es fundamental que la PC este OFFLINE." "Red"
        Write-Host "`n"; Write-Host (" " * 20) "+ Deseas deshabilitar la red temporalmente y aplicar la clave? (S/N): " -ForegroundColor Gray -NoNewline
        $ans = Read-SingleKey
        Write-Host $ans -ForegroundColor Cyan

        if ($ans -eq 'S' -or $ans -eq 'Y') {
            # Registrar mecanismo de restauracion de red persistente en caso de reinicio de la PC durante el upgrade
            $restoreCmd = 'Get-NetAdapter | Enable-NetAdapter -Confirm:$false; Unregister-ScheduledTask -TaskName "Toolbox_EnableNet" -Confirm:$false -ErrorAction SilentlyContinue; Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name "ToolboxEnableNet" -ErrorAction SilentlyContinue'
            try {
                $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$restoreCmd`""
                $trigger = New-ScheduledTaskTrigger -AtStartup
                Register-ScheduledTask -TaskName "Toolbox_EnableNet" -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM" -RunLevel Highest -Force | Out-Null
            } catch { }

            try {
                Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'ToolboxEnableNet' -Value 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Get-NetAdapter | Enable-NetAdapter -Confirm:$false"' -ErrorAction SilentlyContinue
            } catch { }

            Write-Centered "Deshabilitando adaptadores de red..." "Yellow"
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
            foreach ($a in $adapters) { Disable-NetAdapter -Name $a.Name -Confirm:$false }

            Write-Centered "Aplicando clave VK7JG-NPHTM-C97JM-9MPGT-3V66T..." "Cyan"
            try {
                $slmgrPath = "$env:SystemRoot\System32\slmgr.vbs"
                if (Test-Path "$env:SystemRoot\SysNative\slmgr.vbs") { $slmgrPath = "$env:SystemRoot\SysNative\slmgr.vbs" }
                cscript //nologo $slmgrPath /ipk VK7JG-NPHTM-C97JM-9MPGT-3V66T | Out-Null
                Start-Process -FilePath "changepk.exe" -ArgumentList "/ProductKey VK7JG-NPHTM-C97JM-9MPGT-3V66T" -Wait -NoNewWindow
                Write-Centered "[OK] Proceso completado. La PC podria reiniciarse automaticamente." "Green"
                Write-AuditLog "cmd_rep_win_pro" "OK"
            } catch {
                Write-Centered "[FALLO] Error al aplicar clave: $($_.Exception.Message)" "Red"
                Write-AuditLog "cmd_rep_win_pro" "ERROR" $_.Exception.Message
            }

            Write-Centered "Restaurando adaptadores de red..." "Yellow"
            foreach ($a in $adapters) { Enable-NetAdapter -Name $a.Name -Confirm:$false }
            try { Get-NetAdapter | Enable-NetAdapter -Confirm:$false } catch { }
            Write-Centered "Red restaurada." "Green"

            # Si la ejecucion continua en la misma sesion sin reinicio inmediato, limpiamos los registros de arranque
            try { Unregister-ScheduledTask -TaskName "Toolbox_EnableNet" -Confirm:$false -ErrorAction SilentlyContinue } catch { }
            try { Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'ToolboxEnableNet' -ErrorAction SilentlyContinue } catch { }
        }
    }
    "cmd_soft_mas" = {
        Write-Centered "=== ACTIVADOR MAS (MASSGRAVE) ===" "Cyan"
        Write-Host "`n"
        Write-Centered "Abriendo script oficial de Massgrave (irm get.activated.win | iex)..." "Yellow"
        try {
            Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "`"irm get.activated.win | iex`""
            Write-Centered "[OK] Script ejecutado en nueva ventana." "Green"
            Write-AuditLog "cmd_soft_mas" "OK"
        } catch {
            Write-Centered "[FALLO] No se pudo lanzar el script: $($_.Exception.Message)" "Red"
            Write-AuditLog "cmd_soft_mas" "ERROR" $_.Exception.Message
        }
    }
}

# --- 7. MOTOR DE RENDERIZADO Y NAVEGACIÓN ---
$currentMenu = "principal"

while ($true) {
    $ProgressPreference = 'SilentlyContinue'
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    [Console]::Clear()
    $l = $global:lang
    $menuData = $db.menus.$currentMenu

    Show-Header

    if ($null -ne $menuData.titulo) { Write-Centered "=== $($menuData.titulo.$l) ===" "Cyan"; Write-Host "`n" }

    if ($null -ne $menuData.info) {
        foreach ($line in $menuData.info) {
            $textInfo = if ($l -eq 'es') { $line.es } else { $line.en }
            Write-Centered $textInfo "Yellow"
        }
        Write-Host "`n"
    }

    $currentOS = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "MacOS" } else { "Unknown" }
    $validOps = @()
    foreach ($op in $menuData.opciones) {
        if ($null -eq $op.os -or $op.os -contains $currentOS) {
            $validOps += $op
        }
    }

    $mainOps = @()
    $extraOps = @()
    foreach ($op in $validOps) {
        if ($op.tecla -match '^[1-9]$') { $mainOps += $op }
        else { $extraOps += $op }
    }

    foreach ($op in $mainOps) {
        $label = if ($l -eq 'es') { $op.label_es } else { $op.label_en }
        $color = if ($op.color) { $op.color } else { "White" }
        Write-Centered " $($op.tecla). $label " $color
    }

    if ($extraOps.Count -gt 0) {
        Write-Host "`n"
        foreach ($op in $extraOps) {
            $label = if ($l -eq 'es') { $op.label_es } else { $op.label_en }
            $color = if ($op.color) { $op.color } else { "White" }
            Write-Centered " $($op.tecla). $label " $color
        }
    }

    Write-Host "`n"; Write-Centered ("-" * 80) "Gray"
    Write-Host (" " * 46) "+ $($db.diccionario.option.$l) " -ForegroundColor Gray -NoNewline

    $key = Read-SingleKey
    Write-Host $key -ForegroundColor Cyan
    Start-Sleep -Milliseconds 150

    $selectedOption = $null
    foreach ($op in $validOps) {
        if ($op.tecla.ToUpper() -eq $key) { $selectedOption = $op; break }
    }

    if ($selectedOption) {
        $target = $selectedOption.target
        $labelName = if ($l -eq 'es') { $selectedOption.label_es } else { $selectedOption.label_en }

        if ($selectedOption.color -eq "Red" -and $target -ne "cmd_net_reset") {
            [Console]::Clear(); Show-Header
            $warnText = if ($l -eq 'es') { "ADVERTENCIA: Vas a ejecutar una accion destructiva o de reseteo." } else { "WARNING: You are about to execute a destructive or reset action." }
            $askText = if ($l -eq 'es') { "Deseas continuar? (S/N): " } else { "Do you want to continue? (Y/N): " }
            Write-Centered $warnText "Red"
            Write-Centered "-> $labelName" "Yellow"
            Write-Host "`n"; Write-Host (" " * 30) "+ $askText" -ForegroundColor Gray -NoNewline
            $ans = Read-SingleKey
            Write-Host $ans -ForegroundColor Cyan
            if ($ans -ne 'S' -and $ans -ne 'Y') {
                Write-Centered $(if($l -eq 'es'){"Operacion cancelada por el usuario."}else{"Operation cancelled by user."}) "White"
                Start-Sleep -Seconds 1
                continue
            }
        }

        if ($target -eq "sys_exit") { [Console]::Clear(); exit }
        elseif ($target -eq "sys_lang_toggle") { $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }; Write-Centered "Switching language..." "Cyan"; Start-Sleep -Milliseconds 400 }
        elseif ($target.StartsWith("cmd_") -or $target.StartsWith("action_")) {
            [Console]::Clear(); Show-Header
            Write-Centered "=== $labelName ===" "Magenta"; Write-Host "`n"
            if ($Actions.ContainsKey($target)) {
                try {
                    & $Actions[$target]
                } catch {
                    Write-Host "`n"
                    Write-Centered "[!] SE DETECTO UN ERROR EN LA EJECUCION:" "Red"
                    Write-Centered $_.Exception.Message "White" "Red"
                    Write-AuditLog $target "CRASH" $_.Exception.Message
                }
            }
            else { Write-Centered "[!] Comando no encontrado en el motor PS1: $target" "Red" }
            Pause-Menu
        }
        elseif ($null -ne $db.menus.$target) { $currentMenu = $target }
    }
}
