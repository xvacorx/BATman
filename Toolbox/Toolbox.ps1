# =========================================================
# TOOLBOX TECNICO PRO - ENGINE V11 MASTER (v2.2.2)
# =========================================================

# --- 1. PROTOCOLOS Y ELEVACION ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" }
    else { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`"" }
    exit
}
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
[Microsoft.VisualBasic.Interaction]::AppActivate($PID)

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

function Write-Centered ($text, $color="White", $bg="Black") {
    $width = [Console]::WindowWidth; if ($width -le 0) { $width = 110 }
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
}

# NUEVO MOTOR ZERO-ENTER BLINDADO
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
        # Fallback de emergencia si el entorno no soporta ReadKey
        $input = Read-Host
        if ($input.Length -gt 0) { return $input.Substring(0,1).ToUpper() }
        return ""
    }
}

function Pause-Menu { 
    Write-Host "`n"
    Write-Centered $db.diccionario.press_key.$global:lang "Gray"
    $null = Read-SingleKey
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
function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") { try { if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop } else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop } } catch { if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue } else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue } } }
function Test-Internet { if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }; return $false }

# --- 4. CARGA DE BASE DE DATOS (JSON) ---
$jsonUrl = "https://raw.githubusercontent.com/xvacorx/BATman/refs/heads/main/Toolbox/menu.json" 

$jsonPath = Join-Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition -ErrorAction SilentlyContinue) "menu.json" -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($jsonPath) -or -not (Test-Path $jsonPath)) { $jsonPath = ".\menu.json" }

if (Test-Path $jsonPath) {
    try { $db = Get-Content -Raw -Path $jsonPath -Encoding UTF8 | ConvertFrom-Json } 
    catch { Write-Host "[!] FATAL ERROR: El archivo menu.json local tiene errores." -ForegroundColor Red; Pause; exit }
} else {
    Write-Host "Iniciando Motor V11. Descargando arquitectura desde la nube..." -ForegroundColor Cyan
    try {
        $db = Invoke-RestMethod -Uri $jsonUrl -ErrorAction Stop
        if ($db.GetType().Name -eq "String") { $db = $db | ConvertFrom-Json }
    } catch {
        Write-Host "[!] FATAL ERROR: No se pudo descargar menu.json desde GitHub." -ForegroundColor Red; Pause; exit
    }
}

if ($null -eq $global:lang) { 
    $sysLang = (Get-Culture).TwoLetterISOLanguageName
    if ($sysLang -eq 'es' -or $sysLang -eq 'en') { $global:lang = $sysLang } else { $global:lang = $db.config.default_lang }
}

# --- 5. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) { Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null }
}

$Accion_Reparacion = { 
    if (Test-Internet) {
        Write-Centered "--- DISM ---" "Yellow"; dism /online /cleanup-image /restorehealth; Write-Host "`n"
        Write-Centered "--- SFC ---" "Yellow"; sfc /scannow
    } else { Write-Centered "SIN CONEXION: Omitiendo SFC/DISM" "Red" }
}

$Accion_Red = { ipconfig /release | Out-Null; netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null; ipconfig /renew | Out-Null }

# --- 6. REGISTRO DE COMANDOS ($Actions) ---
$Actions = @{
    # ==========================================
    # DIAGNOSTICO E INFORMACION
    # ==========================================
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

    # ==========================================
    # REPARACION
    # ==========================================
    "cmd_rep_sfc" = { &$Accion_Reparacion; Play-FinishBeep }
    "cmd_rep_chkdsk" = { cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "OK" "Green" }
    "cmd_rep_restore" = { Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_rep_icons" = { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue; Start-Process explorer; Write-Centered "OK" "Green" }
    "cmd_rep_time" = { Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" } }
    "cmd_rep_wu" = { Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }

    # ==========================================
    # REDES Y RDP
    # ==========================================
    "cmd_net_reset" = { &$Accion_Red; Write-Centered "OK" "Green" }
    "cmd_net_wifi" = { $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" } }
    "cmd_net_ip" = { if (Get-Command Get-NetAdapter -ErrorAction SilentlyContinue) { Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed } else { Get-WmiCim Win32_NetworkAdapter | Where-Object NetConnectionStatus -eq 2 | Format-Table Name, MACAddress, Speed } }
    "cmd_net_gpupdate" = { Write-Centered "Actualizando Directivas (GPO)..." "Yellow"; gpupdate /force }
    
    "cmd_net_rdp_on" = {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress | Select-Object -First 1
        if ($ip) { $ip | Set-Clipboard; Write-Centered "RDP Habilitado. IP Local ($ip) copiada al portapapeles." "Green" } else { Write-Centered "RDP Habilitado, pero no se detecto IP." "Yellow" }
    }
    "cmd_net_rdp_off" = {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
        Disable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null
        Write-Centered "RDP Deshabilitado." "Red"
    }

    # ==========================================
    # LIMPIEZA
    # ==========================================
    "cmd_clean_temp" = { &$Accion_Limpieza; Write-Centered "OK" "Green" }
    "cmd_clean_logs" = { wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }; Write-Centered "OK" "Green" }
    "cmd_clean_winsxs" = { dism /online /cleanup-image /StartComponentCleanup | Out-Null; Play-FinishBeep; Write-Centered "OK" "Green" }

    # ==========================================
    # SOFTWARE Y ARRANQUE
    # ==========================================
    "cmd_soft_scan" = { if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) { Start-MpScan -ScanType QuickScan; Write-Centered "OK" "Green" } }
    "cmd_soft_startup" = { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table }
    
    "cmd_soft_safe" = { 
        Write-Host "`n"; Write-Centered "1. Safe Mode ON | 2. Safe Mode OFF | 0. Cancelar" "Yellow"
        Write-Host (" " * 46) "+ $($db.diccionario.option.$global:lang) " -ForegroundColor Gray -NoNewline
        $sm = Read-SingleKey
        Write-Host $sm -ForegroundColor Cyan
        if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered "OK" "Green" }
        if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered "OK" "Green" }
    }
    
    "cmd_soft_catalog" = {
        $apps = @(
            @{ID="1"; Name="Google Chrome"; Winget="Google.Chrome"},
            @{ID="2"; Name="Mozilla Firefox"; Winget="Mozilla.Firefox"},
            @{ID="3"; Name="AnyDesk"; Winget="AnyDesk.AnyDesk"},
            @{ID="4"; Name="7-Zip"; Winget="7zip.7zip"},
            @{ID="5"; Name="VLC Media Player"; Winget="VideoLAN.VLC"},
            @{ID="6"; Name="Adobe Acrobat Reader"; Winget="Adobe.Acrobat.Reader.64-bit"},
            @{ID="7"; Name="Zoom"; Winget="Zoom.Zoom"}
        )
        $selected = New-Object System.Collections.Generic.List[string]
        
        while ($true) {
            [Console]::Clear()
            Write-Centered "--- CATALOGO INTERACTIVO DE SOFTWARE ---" "Cyan"; Write-Host "`n"
            
            foreach ($app in $apps) {
                $mark = if ($selected.Contains($app.ID)) { "[X]" } else { "[ ]" }
                $color = if ($selected.Contains($app.ID)) { "Green" } else { "White" }
                Write-Host (" " * 30 + "$mark $($app.ID). $($app.Name)") -ForegroundColor $color
            }
            
            Write-Host "`n"; Write-Centered "E. Instalar Esenciales (Chrome, AnyDesk, 7-Zip)" "Yellow"
            Write-Centered "I. Iniciar Instalacion de seleccionados" "Green"
            Write-Centered "0. Cancelar y Volver" "Gray"
            
            Write-Host "`n"
            Write-Host (" " * 30) "+ $($db.diccionario.option.$global:lang) " -ForegroundColor Gray -NoNewline
            
            $input = Read-SingleKey
            Write-Host $input -ForegroundColor Cyan
            Start-Sleep -Milliseconds 150
            
            if ($input -eq '0') { break }
            if ($input -eq 'E') { $selected.Clear(); $selected.AddRange(@("1","3","4")) }
            if ($input -eq 'I') {
                if ($selected.Count -gt 0) {
                    foreach ($id in $selected) {
                        $app = $apps | Where-Object { $_.ID -eq $id }
                        Write-Host "`n>> Instalando $($app.Name)..." -ForegroundColor Cyan
                        winget install $app.Winget --disable-interactivity --accept-source-agreements --accept-package-agreements
                    }
                    Write-Centered "Proceso finalizado." "Green"; Pause-Menu; break
                } else { Write-Centered "No seleccionaste nada." "Yellow"; Start-Sleep -Seconds 1 }
            }
            if ($selected.Contains($input)) { $selected.Remove($input) | Out-Null }
            elseif ($apps.ID -contains $input) { $selected.Add($input) }
        }
    }

    # ==========================================
    # OPTIMIZACIONES
    # ==========================================
    "cmd_opt_fastoff" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_opt_faston" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_opt_godmode" = { $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }; Write-Centered "OK" "Green" }
    "cmd_opt_bloat" = { if (Get-Command Get-AppxPackage -ErrorAction SilentlyContinue) { $bloatware = @("*bing*", "*xboxapp*", "*gethelp*", "*solitaire*"); foreach ($app in $bloatware) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue } }; Write-Centered "OK" "Green" }
    "cmd_opt_cpl" = { Start-Process control }
    "cmd_opt_dev" = { Start-Process devmgmt.msc }
    "cmd_opt_net" = { Start-Process ncpa.cpl }
    "cmd_opt_app" = { Start-Process appwiz.cpl }
    
    "cmd_opt_rename" = {
        Write-Centered "--- RENOMBRAR EQUIPO Y USUARIO ---" "Cyan"; Write-Host "`n"
        $newName = Read-Host " Ingrese nuevo nombre para el EQUIPO (Hostname) [Dejar vacio para omitir]"
        if ($newName) { Rename-Computer -NewName $newName -ErrorAction SilentlyContinue; Write-Centered "Nombre de equipo cambiado a $newName (Requiere reinicio)." "Yellow" }
        
        $user = Read-Host "`n Ingrese nuevo nombre de visualizacion para su USUARIO actual [Dejar vacio para omitir]"
        if ($user) { 
            $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]
            $wmiUser = Get-WmiObject Win32_UserAccount -Filter "Name='$currentUser'"
            $wmiUser.FullName = $user; $wmiUser.Put() | Out-Null
            Write-Centered "Nombre de visualización cambiado a $user." "Green"
        }
    }

    # ==========================================
    # IMPRESORAS
    # ==========================================
    "cmd_rep_spool" = { Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2; Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue; Start-Service -Name Spooler -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_print_folder" = { $path = "$PublicDesktop\Printers.{2227a280-3aea-1069-a2de-08002b30309d}"; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null; Write-Centered "Carpeta de Impresoras creada en el Escritorio." "Green" } else { Write-Centered "La carpeta ya existe." "Yellow" } }
    
    "cmd_print_del" = {
        $printers = Get-Printer | Select-Object Name, PortName
        if ($printers.Count -eq 0) { Write-Centered "No hay impresoras." "Yellow"; return }
        $i = 1; foreach ($p in $printers) { Write-Host "  $i. $($p.Name)" -ForegroundColor White; $i++ }
        $sel = Read-Host "`n Numero a eliminar (0 cancelar)"
        if ([int]$sel -gt 0 -and [int]$sel -le $printers.Count) { $target = $printers[[int]$sel - 1]; Remove-Printer -Name $target.Name -ErrorAction SilentlyContinue; Write-Centered "Impresora '$($target.Name)' eliminada." "Green" }
    }
    
    "cmd_print_driver" = {
        $drivers = Get-PrinterDriver | Select-Object Name
        if ($drivers.Count -eq 0) { Write-Centered "No hay drivers." "Yellow"; return }
        $i = 1; foreach ($d in $drivers) { Write-Host "  $i. $($d.Name)" -ForegroundColor White; $i++ }
        $sel = Read-Host "`n Numero a eliminar (0 cancelar)"
        if ([int]$sel -gt 0 -and [int]$sel -le $drivers.Count) { $target = $drivers[[int]$sel - 1]; Remove-PrinterDriver -Name $target.Name -ErrorAction SilentlyContinue; Write-Centered "Driver '$($target.Name)' eliminado." "Green" }
    }

    "cmd_print_fw" = {
        Write-Centered "Habilitando Ping (ICMPv4) y Puertos (137,138,139,445)..." "White"
        Enable-NetFirewallRule -Name "FPS-ICMP4-ERQ-In" -ErrorAction SilentlyContinue | Out-Null
        Enable-NetFirewallRule -DisplayGroup "Compartir archivos e impresoras" -ErrorAction SilentlyContinue | Out-Null
        Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Toolbox_PrintTCP" -Direction Inbound -Protocol TCP -LocalPort 139,445 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        New-NetFirewallRule -DisplayName "Toolbox_PrintUDP" -Direction Inbound -Protocol UDP -LocalPort 137,138 -Action Allow -ErrorAction SilentlyContinue | Out-Null
        Write-Centered "Reglas de Firewall configuradas con exito." "Green"
    }

    # ==========================================
    # IDENTIDAD Y USUARIOS
    # ==========================================
    "cmd_user_admin_on" = { net user administrator /active:yes; Write-Centered "Cuenta Administrador Local HABILITADA." "Green" }
    "cmd_user_admin_off" = { net user administrator /active:no; Write-Centered "Cuenta Administrador Local DESHABILITADA." "Red" }
    "cmd_user_pass" = {
        Write-Centered "--- USUARIOS DEL SISTEMA ---" "Cyan"; Write-Host "`n"
        Get-LocalUser | Select-Object Name, Enabled | Format-Table -AutoSize
        $u = Read-Host "`n Escriba el NOMBRE EXACTO del usuario a modificar (o deje vacio para cancelar)"
        if ($u) {
            $p = Read-Host " Ingrese la nueva contraseña"
            try { net user "$u" "$p" | Out-Null; Write-Centered "Contraseña cambiada exitosamente." "Green" } 
            catch { Write-Centered "Error al cambiar contraseña. Verifique el nombre." "Red" }
        }
    }

    # ==========================================
    # MODO AUTOMATICO
    # ==========================================
    "cmd_auto_run" = {
        Write-Centered ">> EJECUTANDO MANTENIMIENTO AUTOMATICO <<" "Green"; Write-Host "`n"
        Write-Centered "[ 1/5 ] Punto de Restauracion..." "Yellow"; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Centered "[ 2/5 ] Limpiando basura..." "Yellow"; &$Accion_Limpieza
        Write-Centered "[ 3/5 ] Reparando SO (SFC/DISM)..." "Yellow"; &$Accion_Reparacion
        Write-Centered "[ 4/5 ] Forzando Politicas (GPO)..." "Yellow"; gpupdate /force | Out-Null
        Write-Centered "[ 5/5 ] Sincronizando Hora..." "Yellow"; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-Null
        Play-FinishBeep; Write-Centered "PROCESO COMPLETADO EXITOSAMENTE" "Green"
    }
    "cmd_auto_run_exit" = { & $Actions["cmd_auto_run"]; [Console]::Clear(); exit }
    
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

    Show-Header

    if ($null -ne $menuData.titulo) { Write-Centered "=== $($menuData.titulo.$l) ===" "Cyan"; Write-Host "`n" }

    # Lógica de separación visual (Agrupa los números arriba, letras abajo)
    $mainOps = @()
    $extraOps = @()
    foreach ($op in $menuData.opciones) {
        if ($op.tecla -match '^[1-9]$') { $mainOps += $op }
        else { $extraOps += $op }
    }

    # Renderiza opciones principales
    foreach ($op in $mainOps) {
        $label = if ($l -eq 'es') { $op.label_es } else { $op.label_en }
        $color = if ($op.color) { $op.color } else { "White" }
        Write-Centered " $($op.tecla). $label " $color
    }

    # Renderiza separador visual y opciones extra
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
    
    # Input de 1 sola tecla integrado
    $key = Read-SingleKey
    Write-Host $key -ForegroundColor Cyan
    Start-Sleep -Milliseconds 150 # Pausa visual para sentir el click

    # Ruteo Logico
    $selectedOption = $null
    foreach ($op in $menuData.opciones) {
        if ($op.tecla.ToUpper() -eq $key) { $selectedOption = $op; break }
    }

    if ($selectedOption) {
        $target = $selectedOption.target

        if ($target -eq "sys_exit") { [Console]::Clear(); exit }
        elseif ($target -eq "sys_lang_toggle") { $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }; Write-Centered "Switching language..." "Cyan"; Start-Sleep -Milliseconds 400 }
        elseif ($target.StartsWith("cmd_") -or $target.StartsWith("action_")) {
            [Console]::Clear(); Show-Header
            if ($Actions.ContainsKey($target)) { & $Actions[$target] } 
            else { Write-Centered "[!] Comando no encontrado en el motor PS1: $target" "Red" }
            Pause-Menu
        }
        elseif ($null -ne $db.menus.$target) { $currentMenu = $target }
    }
}
