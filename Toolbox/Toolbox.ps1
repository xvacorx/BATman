# =========================================================
# TOOLBOX TECNICO PRO - ENGINE V11 MASTER (v3.0.0)
# =========================================================

# --- 1. PROTOCOLOS Y ELEVACION ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($null -eq $IsWindows) { $IsWindows = $true; $IsLinux = $false; $IsMacOS = $false }

if ($IsWindows) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ($PSCommandPath) { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" }
        else { Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`"" }
        exit
    }
    try { [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic"); [Microsoft.VisualBasic.Interaction]::AppActivate($PID) } catch { }
} else {
    $uid = $(id -u)
    if ($uid -ne "0") {
        Write-Host "Elevando privilegios (sudo)..." -ForegroundColor Yellow
        if ($PSCommandPath) { sudo pwsh -NoProfile -File "$PSCommandPath" }
        else { sudo pwsh -NoProfile -Command "iex (irm tinyurl.com/VikToolBox)" }
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
        $null = Read-Host # Fallback seguro por si la consola falla
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
function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") { try { if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop } else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop } } catch { if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue } else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue } } }
function Test-Internet { if (Test-Connection 8.8.8.8 -Count 1 -Quiet -ErrorAction SilentlyContinue) { return $true }; return $false }

# --- 4. CARGA DE BASE DE DATOS (JSON) ---
$jsonUrl = "https://raw.githubusercontent.com/xvacorx/BATman/refs/heads/update-toolbox-v3-17865159802571578976/Toolbox/menu.json"
# --- $jsonUrl = "https://raw.githubusercontent.com/xvacorx/BATman/refs/heads/main/Toolbox/menu.json"


$jsonPath = Join-Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition -ErrorAction SilentlyContinue) "menu.json" -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($jsonPath) -or -not (Test-Path $jsonPath)) { $jsonPath = ".\menu.json" }

if (Test-Path $jsonPath) {
    try { $db = Get-Content -Raw -Path $jsonPath -Encoding UTF8 | ConvertFrom-Json }
    catch { Write-Host "[!] FATAL ERROR: El archivo menu.json local tiene errores." -ForegroundColor Red; Pause; exit }
} else {
    Write-Host "Cargando motor V11 desde la nube..." -ForegroundColor Cyan
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
    } else {
        Remove-Item "/tmp/*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:HOME/.cache/*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$Accion_Reparacion = {
    if (Test-Internet) {
        Write-Centered "SFC & DISM..." "Yellow"
        if ($IsWindows) {
            dism /online /cleanup-image /restorehealth
            sfc /scannow
        }
    }
}

# --- 6. REGISTRO DE COMANDOS ($Actions) ---
$Actions = @{
    # DIAGNOSTICO
    "cmd_diag_sysinfo" = {
        Write-Centered "--- INFO ---" "Cyan"; Write-Host "`n"
        if ($IsWindows) {
            $sysInfo = Get-WmiCim "Win32_ComputerSystem"; $cpu = (Get-WmiCim "Win32_Processor").Name
            $os = Get-WmiCim "Win32_OperatingSystem"; try { $bt = $os.LastBootUpTime; if ($bt.GetType().Name -eq "String") { $bt = $os.ConvertToDateTime($bt) }; $ts = New-TimeSpan -Start $bt -End (Get-Date); $uptime = "$($ts.Days) D, $($ts.Hours) H" } catch { $uptime = "?" }
            $diskC = Get-WmiCim "Win32_LogicalDisk" -Filter "DeviceID='C:'"; if ($diskC) { $free = [math]::Round($diskC.FreeSpace / 1GB, 1); $total = [math]::Round($diskC.Size / 1GB, 1) }
            Write-Centered "PC: $($sysInfo.Manufacturer) $($sysInfo.Model)" "Yellow"
            Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk C: $free GB / $total GB" "White"; Write-Centered "Uptime: $uptime" "Green"
        } elseif ($IsLinux) {
            $pc = hostname; $cpu = (lscpu | grep "Model name:" | sed 's/Model name: *//').Trim()
            $disk = df -h / | tail -n 1 | awk '{print $4 " / " $2}'
            $uptime = uptime -p
            Write-Centered "PC: $pc" "Yellow"; Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk /: $disk" "White"; Write-Centered "Uptime: $uptime" "Green"
        } elseif ($IsMacOS) {
            $pc = scutil --get ComputerName; $cpu = sysctl -n machdep.cpu.brand_string
            $disk = df -h / | tail -n 1 | awk '{print $4 " / " $2}'
            $uptime = uptime | awk -F'( |,|:)+' '{print $6 " H, " $7 " M"}'
            Write-Centered "PC: $pc" "Yellow"; Write-Centered "CPU: $cpu" "White"; Write-Centered "Disk /: $disk" "White"; Write-Centered "Uptime: $uptime" "Green"
        }
    }
    "cmd_diag_lic" = { cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" } }
    "cmd_diag_bsod" = { Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List }
    "cmd_diag_disk" = { if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table -AutoSize | Out-String -Stream | ForEach-Object { Write-Centered $_.Trim() "White" } } }
    "cmd_diag_batt" = { powercfg /batteryreport /output "$PublicDesktop\BatteryReport.html" | Out-Null; if (Test-Path "$PublicDesktop\BatteryReport.html") { Invoke-Item "$PublicDesktop\BatteryReport.html"; Write-Centered "OK" "Green" } }
    "cmd_diag_inv" = { "Inventario" | Out-File "$PublicDesktop\Inventario_$env:COMPUTERNAME.txt" -Encoding UTF8; Write-Centered "OK" "Green" }
    "cmd_diag_logs" = { if (Test-Path $logPath) { Get-Content $logPath -Tail 15 | ForEach-Object { Write-Centered $_ "White" } } }

    # REPARACION
    "cmd_rep_sfc" = { &$Accion_Reparacion; Play-FinishBeep }
    "cmd_rep_chkdsk" = { cmd.exe /c "echo S | chkdsk C: /f"; Write-Centered "OK" "Green" }
    "cmd_rep_restore" = { Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Manual" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_rep_icons" = { Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue; Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue; Start-Process explorer; Write-Centered "OK" "Green" }
    "cmd_rep_time" = { Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" } }
    "cmd_rep_wu" = { Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue; Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue; Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }

    # REDES Y RDP
    "cmd_net_reset" = {
        Write-Centered "--- RESET DE RED PROFUNDO ---" "Cyan"
        Write-Centered "ADVERTENCIA: Esto cortara cualquier conexion remota (AnyDesk/RDP) y requiere REINICIO." "Red"
        Write-Host (" " * 30) "+ Desea continuar? (S/N): " -ForegroundColor Gray -NoNewline

        $ans = Read-SingleKey
        Write-Host $ans -ForegroundColor Cyan

        if ($ans -eq 'S') {
            Write-Centered "Liberando IP y limpiando DNS..." "Yellow"
            ipconfig /release | Out-Null
            ipconfig /flushdns | Out-Null

            Write-Centered "Reseteando Winsock y TCP/IP..." "Yellow"
            netsh winsock reset | Out-Null
            netsh int ip reset c:\resetlog.txt | Out-Null

            Write-Centered "Renovando IP local..." "Yellow"
            ipconfig /renew | Out-Null

            Write-Centered "OK! EL STACK ESTA LIMPIO. DEBES REINICIAR LA PC." "Green"
        } else {
            Write-Centered "Operacion cancelada por el usuario." "White"
        }
    }
    "cmd_net_wifi" = { $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content|Contenido de la clave" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" } }
    "cmd_net_ip" = {
        if ($IsWindows) { ipconfig | findstr "IPv4" | ForEach-Object { Write-Centered $_.Trim() "White" } }
        else { ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | ForEach-Object { Write-Centered $_ "White" } }
    }
    "cmd_net_gpupdate" = { Write-Centered "GPO Update..." "Yellow"; gpupdate /force | Out-Null }
    "cmd_net_rdp_on" = { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0; Enable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null; $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress | Select-Object -First 1; if ($ip) { $ip | Set-Clipboard; Write-Centered "RDP ON ($ip)." "Green" } }
    "cmd_net_rdp_off" = { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1; Disable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue | Out-Null; Write-Centered "RDP OFF." "Red" }

    # LIMPIEZA
    "cmd_clean_temp" = { &$Accion_Limpieza; Write-Centered "OK" "Green" }
    "cmd_clean_logs" = { wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }; Write-Centered "OK" "Green" }
    "cmd_clean_winsxs" = { dism /online /cleanup-image /StartComponentCleanup; Write-Centered "OK" "Green" }

    # SOFTWARE CATALOGO
    "cmd_soft_scan" = { if (Get-Command Start-MpScan -ErrorAction SilentlyContinue) { Start-MpScan -ScanType QuickScan; Write-Centered "OK" "Green" } }
    "cmd_soft_startup" = { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table }
    "cmd_soft_safe" = { Write-Host "`n"; Write-Centered "1. Safe Mode ON | 2. Safe Mode OFF | 0. Cancelar" "Yellow"; $sm = Read-SingleKey; if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null }; if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null }; Write-Centered "OK" "Green" }
    "cmd_soft_catalog" = {
        $apps = @(
            @{ID="1"; Name="Chrome"; Winget="Google.Chrome"}, @{ID="2"; Name="Firefox"; Winget="Mozilla.Firefox"},
            @{ID="3"; Name="AnyDesk"; Winget="AnyDesk.AnyDesk"}, @{ID="4"; Name="7-Zip"; Winget="7zip.7zip"},
            @{ID="5"; Name="VLC"; Winget="VideoLAN.VLC"}, @{ID="6"; Name="Adobe Reader"; Winget="Adobe.Acrobat.Reader.64-bit"},
            @{ID="7"; Name="Notepad++"; Winget="Notepad++.Notepad++"}, @{ID="8"; Name="Zoom"; Winget="Zoom.Zoom"},
            @{ID="9"; Name="Rufus"; Winget="Rufus.Rufus"}, @{ID="A"; Name="Spotify"; Winget="Spotify.Spotify"},
            @{ID="B"; Name="OBS Studio"; Winget="OBSProject.OBSStudio"}, @{ID="C"; Name="WinRAR"; Winget="RARLab.WinRAR"}
        )
        $selected = New-Object System.Collections.Generic.List[string]
        while ($true) {
            [Console]::Clear(); Write-Centered "--- CATALOGO INTERACTIVO ---" "Cyan"; Write-Host "`n"

            # Split array for two columns
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
            Write-Centered "I. Instalar | 0. Volver" "Yellow"
            Write-Host (" " * 30) "+ Opcion: " -NoNewline
            $input = Read-SingleKey
            Write-Host $input -ForegroundColor Cyan

            if ($input -eq '0') { break }
            if ($input -eq 'E') { $selected.Clear(); $selected.AddRange(@("1","3","4","5","7")) }
            if ($input -eq 'I' -and $selected.Count -gt 0) {
                foreach ($id in $selected) {
                    $app = $apps | ?{$_.ID -eq $id}
                    Write-Centered "Instalando $($app.Name)..." "Cyan"
                    winget install $app.Winget --disable-interactivity --accept-source-agreements --accept-package-agreements
                }
                break
            }
            if ($selected.Contains($input)) { $selected.Remove($input) | Out-Null }
            elseif ($apps.ID -contains $input) { $selected.Add($input) }
        }
    }

    # OPTIMIZACIONES
    "cmd_opt_fastoff" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force; Write-Centered "OK" "Green" }
    "cmd_opt_faston" = { Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force; Write-Centered "OK" "Green" }
    "cmd_opt_godmode" = { $path = "$PublicDesktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"; if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }; Write-Centered "OK" "Green" }
    "cmd_opt_bloat" = { Write-Centered "Aniquilando Bloatware..." "Yellow"; $bloat = @("*bing*", "*xboxapp*", "*gethelp*", "*solitaire*", "*people*", "*skype*"); foreach ($app in $bloat) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }; Write-Centered "OK" "Green" }
    "cmd_opt_visuals" = {
        Write-Centered "Ajustando rendimiento visual..." "Yellow"
        # 1 = Appearance, 2 = Best Appearance, 3 = Best Performance, 0 = Custom
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
        # Disable mostly everything except Font Smoothing and Thumbnails
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0 -Force -ErrorAction SilentlyContinue # Ensure thumbnails are ON
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -Force -ErrorAction SilentlyContinue # Font smoothing ON
        Write-Centered "OK (Requiere reiniciar o cerrar sesion)" "Green"
    }
    "cmd_opt_cpl" = { Start-Process control }; "cmd_opt_dev" = { Start-Process devmgmt.msc }; "cmd_opt_net" = { Start-Process ncpa.cpl }; "cmd_opt_app" = { Start-Process appwiz.cpl }
    "cmd_opt_rename" = {
        $n = Read-Host " Nuevo Hostname"
        if($n){
            if ($IsWindows) { Rename-Computer -NewName $n -ErrorAction SilentlyContinue }
            elseif ($IsLinux) { hostnamectl set-hostname $n }
            elseif ($IsMacOS) { scutil --set ComputerName $n; scutil --set LocalHostName $n; scutil --set HostName $n }
            Write-Centered "PC -> $n (Reiniciar)." "Yellow"
        }
    }

    # IMPRESORAS
    "cmd_rep_spool" = { Stop-Service Spooler -Force -ErrorAction SilentlyContinue; Remove-Item "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue; Start-Service Spooler -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" }
    "cmd_print_folder" = { $p = "$PublicDesktop\Printers.{2227a280-3aea-1069-a2de-08002b30309d}"; if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }; Write-Centered "OK" "Green" }
    "cmd_print_del" = { $printers = Get-Printer; $i=1; foreach($p in $printers){ Write-Host "  $i. $($p.Name)" -ForegroundColor White; $i++ }; $s = Read-Host "`n Borrar nro (0 cancelar)"; if([int]$s -gt 0 -and [int]$s -le $printers.Count){ Remove-Printer -Name $printers[[int]$s-1].Name -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" } }
    "cmd_print_driver" = { $drivers = Get-PrinterDriver; $i=1; foreach($d in $drivers){ Write-Host "  $i. $($d.Name)" -ForegroundColor White; $i++ }; $s = Read-Host "`n Borrar nro (0 cancelar)"; if([int]$s -gt 0 -and [int]$s -le $drivers.Count){ Remove-PrinterDriver -Name $drivers[[int]$s-1].Name -ErrorAction SilentlyContinue; Write-Centered "OK" "Green" } }
    "cmd_print_fw" = { Enable-NetFirewallRule -Name "FPS-ICMP4-ERQ-In" -ErrorAction SilentlyContinue; New-NetFirewallRule -DisplayName "Toolbox_PrintTCP" -Direction Inbound -Protocol TCP -LocalPort 139,445 -Action Allow -ErrorAction SilentlyContinue | Out-Null; Write-Centered "OK" "Green" }

    # IDENTIDAD
    "cmd_user_admin_on" = { net user administrator /active:yes; Write-Centered "ADMIN ON." "Green" }
    "cmd_user_admin_off" = { net user administrator /active:no; Write-Centered "ADMIN OFF." "White" }
    "cmd_user_pass" = { Get-LocalUser | Select-Object Name; $u = Read-Host "Usuario"; if($u){ $p = Read-Host "Clave"; net user "$u" "$p" | Out-Null; Write-Centered "OK" "Green" } }

    # MODO AUTOMATICO (8 PASOS - v2.3.1)
    "cmd_auto_run" = {
        Write-Centered ">> MANTENIMIENTO AUTOMATICO EN PROGRESO <<" "Green"; Write-Host "`n"
        Write-Centered "[ 1/8 ] Punto de Restauracion..." "Yellow"; Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue; Checkpoint-Computer -Description "Toolbox_Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Centered "[ 2/8 ] Limpieza de Basura..." "Yellow"; &$Accion_Limpieza
        Write-Centered "[ 3/8 ] Reparacion de SO (SFC/DISM)..." "Yellow"; &$Accion_Reparacion
        Write-Centered "[ 4/8 ] Escaneo de Disco en Vivo (CHKDSK)..." "Yellow"; chkdsk C: /scan
        Write-Centered "[ 5/8 ] Limpieza Profunda WinSxS..." "Yellow"; dism /online /cleanup-image /StartComponentCleanup
        Write-Centered "[ 6/8 ] Purgando Visor de Eventos..." "Yellow"; wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
        Write-Centered "[ 7/8 ] Forzando Politicas (GPO)..." "Yellow"; gpupdate /force | Out-Null
        Write-Centered "[ 8/8 ] Sincronizando Hora..." "Yellow"; Restart-Service w32time -ErrorAction SilentlyContinue; w32tm /resync | Out-Null
        Play-FinishBeep; Write-Centered "MANTENIMIENTO FINALIZADO" "Green"
    }
    "cmd_auto_run_exit" = { & $Actions["cmd_auto_run"]; [Console]::Clear(); exit }

    "action_credits" = {
        Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"; Write-Centered "Toolbox Tecnico Pro - By Viktor" "White"
        Write-Centered "Vik Tools" "Magenta"; Write-Host "`n"; Write-Centered "GitHub: github.com/xvacorx" "Cyan"; Start-Process "https://github.com/xvacorx"
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

    # Renderiza la Información extra (Ej: para el Modo Automático)
    if ($null -ne $menuData.info) {
        foreach ($line in $menuData.info) {
            $textInfo = if ($l -eq 'es') { $line.es } else { $line.en }
            Write-Centered $textInfo "Yellow"
        }
        Write-Host "`n"
    }

    # Filtrar por sistema operativo
    $currentOS = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "MacOS" } else { "Unknown" }
    $validOps = @()
    foreach ($op in $menuData.opciones) {
        if ($null -eq $op.os -or $op.os -contains $currentOS) {
            $validOps += $op
        }
    }

    # Lógica de separación visual (Agrupa los números arriba, letras abajo)
    $mainOps = @()
    $extraOps = @()
    foreach ($op in $validOps) {
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
            if ($Actions.ContainsKey($target)) { & $Actions[$target] }
            else { Write-Centered "[!] Comando no encontrado en el motor PS1: $target" "Red" }
            Pause-Menu
        }
        elseif ($null -ne $db.menus.$target) { $currentMenu = $target }
    }
}
