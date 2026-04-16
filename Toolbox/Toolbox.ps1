# =========================================================
# TOOLBOX TECNICO PRO - ENGINE V11 MASTER v2.2.0
# =========================================================

# --- 1. PROTOCOLOS Y ELEVACION ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# --- 2. CONFIGURACION VISUAL ---
if ($Host.Name -eq "ConsoleHost") {
    $Raw = $Host.UI.RawUI; $Raw.BackgroundColor = "Black"; $Raw.ForegroundColor = "White"
    $Size = $Raw.WindowSize; $Size.Width = 110; $Size.Height = 35; $Raw.WindowSize = $Size
}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 3. FUNCIONES DE APOYO ---
function Write-Centered ($text, $color="White") {
    $width = [console]::WindowWidth; if($width -le 0){$width=110}
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding + $text) -ForegroundColor $color
}

function Pause-Menu {
    Write-Host "`n"
    Write-Centered $db.diccionario.press_key.$global:lang "Gray"
    [void]$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-Header {
    $l = $global:lang
    Write-Host "`n"
    Write-Centered "  _______ ____   ____  _      ____   ______  __ " "Cyan"
    Write-Centered " |__   __/ __ \ / __ \| |    |  _ \ / __ \ \/ / " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    | |_) | |  | \  /  " "Cyan"
    Write-Centered "    | | | |  | | |  | | |    |  _ <| |  | /  \  " "Cyan"
    Write-Centered "    |_|  \____/ \____/|______|____/ \____/_/\_\ " "Cyan"
    Write-Host "`n"; Write-Centered ("=" * 80) "Gray"
    Write-Centered $db.diccionario.title.$l "Cyan"
    Write-Centered ("=" * 80) "Gray"; Write-Centered $db.diccionario.legend.$l "Gray"; Write-Host "`n"
}

# --- 4. CARGA DE DATOS ---
$jsonUrl = "https://raw.githubusercontent.com/xvacorx/BATman/refs/heads/ToolboxUpdate/Toolbox/menu.json"
try {
    $db = Invoke-RestMethod -Uri $jsonUrl
} catch {
    Write-Host "CRITICAL: No se pudo conectar con GitHub. Buscando local..." -ForegroundColor Yellow
    $db = Get-Content "menu.json" | ConvertFrom-Json
}
$global:lang = if ($null -eq $global:lang) { (Get-Culture).TwoLetterISOLanguageName } else { $global:lang }
if ($global:lang -ne 'es' -and $global:lang -ne 'en') { $global:lang = 'es' }

# --- 5. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}
$Accion_Reparacion = {
    dism /online /cleanup-image /restorehealth; sfc /scannow
}

# --- 6. REGISTRO DE COMANDOS ($Actions) ---
$Actions = @{
    # DIAGNOSTICO
    "cmd_diag_sysinfo" = { Write-Centered "PC: $(hostname)" "Yellow"; Write-Centered "OS: $((Get-WmiObject Win32_OperatingSystem).Caption)" }
    "cmd_diag_disk" = { Get-PhysicalDisk | Select-Object MediaType, Model, HealthStatus | Format-Table }
    "cmd_diag_batt" = { powercfg /batteryreport /output "$env:USERPROFILE\Desktop\Battery.html" }

    # REPARACION
    "cmd_rep_sfc" = { &$Accion_Reparacion }
    "cmd_rep_chkdsk" = { cmd.exe /c "echo S | chkdsk C: /f" }
    "cmd_rep_time" = { Restart-Service w32time; w32tm /resync }

    # REDES Y RDP
    "cmd_net_reset" = { netsh winsock reset; ipconfig /flushdns }
    "cmd_net_ip" = { ipconfig | findstr "IPv4" }
    "cmd_net_gpupdate" = { gpupdate /force }
    "cmd_net_rdp_on" = {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
        Enable-NetFirewallRule -DisplayGroup "@FirewallAPI.dll,-28752" -ErrorAction SilentlyContinue
        $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress | Select-Object -First 1
        $ip | Set-Clipboard; Write-Centered "RDP Habilitado e IP ($ip) en portapapeles." "Green"
    }
    "cmd_net_rdp_off" = { Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1 }

    # LIMPIEZA
    "cmd_clean_temp" = { &$Accion_Limpieza }
    "cmd_clean_winsxs" = { dism /online /cleanup-image /StartComponentCleanup }

    # SOFTWARE CATALOGO [X]
    "cmd_soft_catalog" = {
        $apps = @(
            @{ID="1"; Name="Chrome"; Winget="Google.Chrome"},
            @{ID="2"; Name="AnyDesk"; Winget="AnyDesk.AnyDesk"},
            @{ID="3"; Name="7-Zip"; Winget="7zip.7zip"},
            @{ID="4"; Name="VLC"; Winget="VideoLAN.VLC"},
            @{ID="5"; Name="Firefox"; Winget="Mozilla.Firefox"}
        )
        $selected = New-Object System.Collections.Generic.List[string]
        while ($true) {
            [Console]::Clear(); Write-Centered "--- CATALOGO INTERACTIVO ---" "Cyan"
            foreach ($app in $apps) {
                $mark = if ($selected.Contains($app.ID)) { "[X]" } else { "[ ]" }
                Write-Host (" " * 35 + "$mark $($app.ID). $($app.Name)") -ForegroundColor (if($selected.Contains($app.ID)){"Green"}else{"White"})
            }
            Write-Host "`n"; Write-Centered "E. Esenciales | I. Instalar | 0. Volver" "Yellow"
            $ans = (Read-Host " Opcion").ToUpper()
            if ($ans -eq '0') { break }
            if ($ans -eq 'E') { $selected.Clear(); $selected.AddRange(@("1","2","3")) }
            if ($ans -eq 'I') {
                foreach($id in $selected){ $a=$apps|?{$_.ID -eq $id}; Write-Host "Instalando $($a.Name)..."; winget install $a.Winget --accept-source-agreements }
                break
            }
            if ($selected.Contains($ans)) { $selected.Remove($ans) } elseif ($apps.ID -contains $ans) { $selected.Add($ans) }
        }
    }

    # IDENTIDAD (NUEVO)
    "cmd_user_admin_on" = { net user administrator /active:yes; Write-Centered "Admin Local Habilitado." "Green" }
    "cmd_user_admin_off" = { net user administrator /active:no; Write-Centered "Admin Local Deshabilitado." "Red" }
    "cmd_user_pass" = {
        Get-LocalUser | Select-Object Name, Enabled
        $u = Read-Host "`n Usuario a modificar"; $p = Read-Host " Nueva Contraseña"
        net user $u $p; Write-Centered "OK." "Green"
    }

    # IMPRESORAS Y OPT
    "cmd_rep_spool" = { Stop-Service spooler -Force; Remove-Item "C:\Windows\System32\spool\PRINTERS\*" -Force; Start-Service spooler }
    "cmd_print_folder" = { New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\Printers.{2227a280-3aea-1069-a2de-08002b30309d}" -ErrorAction SilentlyContinue }
    "cmd_opt_rename" = { $n = Read-Host "Nuevo nombre PC"; if($n){ Rename-Computer -NewName $n -ErrorAction SilentlyContinue } }

    # AUTOMATICO
    "cmd_auto_run" = {
        Write-Centered "MANTENIMIENTO AUTOMATICO..." "Yellow"
        &$Accion_Limpieza; &$Accion_Reparacion; gpupdate /force; Restart-Service w32time; w32tm /resync
        Write-Centered "PROCESO FINALIZADO" "Green"
    }
}

# --- 7. BUCLE PRINCIPAL ---
$currentMenu = "principal"
while ($true) {
    [Console]::Clear(); Show-Header
    $m = $db.menus.$currentMenu
    foreach ($op in $m.opciones) {
        $color = "White"
        if($op.tecla -eq "A"){$color="Green"} elseif($op.tecla -eq "L"){$color="Yellow"}
        Write-Host (" " * 30 + "$($op.tecla). $($op."label_$global:lang")") -ForegroundColor $color
    }
    Write-Host "`n"; Write-Host (" " * 45 + "+ $($db.diccionario.option.$global:lang) ") -NoNewline
    $key = (Read-Host).ToUpper()
    if ($key -eq "0" -and $currentMenu -eq "principal") { exit }
    $sel = $m.opciones | ? { $_.tecla -eq $key }
    if ($sel) {
        $t = $sel.target
        if ($t.StartsWith("cmd_")) { [Console]::Clear(); & $Actions[$t]; Pause-Menu }
        elseif ($db.menus.$t) { $currentMenu = $t }
        elseif ($t -eq "sys_lang_toggle") { $global:lang = if($global:lang -eq "es"){"en"}else{"es"} }
    }
}