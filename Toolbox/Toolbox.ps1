# =========================================================
# TOOLBOX TECNICO PRO - By Viktor
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 1. AUTO-ELEVACION ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`""
    exit
}

# --- 2. CONFIGURACION DE VENTANA ---
if ($Host.Name -eq "ConsoleHost") {
    $Raw = $Host.UI.RawUI
    $Raw.BackgroundColor = "Black"
    $Raw.ForegroundColor = "White"
    $Size = $Raw.WindowSize
    $Size.Width = 90
    $Size.Height = 36
    $Raw.BufferSize = $Size
    $Raw.WindowSize = $Size
}
[Console]::BackgroundColor = "Black"
[Console]::Clear() 
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 3. FUNCIONES DE INTERFAZ ---
function Write-Centered {
    param([string]$text, [string]$color = "White", [string]$bg = "Black")
    $width = [Console]::WindowWidth
    $padding = [math]::Max(0, [int](($width - $text.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $text -ForegroundColor $color -BackgroundColor $bg
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
    Write-Centered "  =======================================================  " "Gray"
    Write-Centered "              TOOLBOX TECNICO PRO - By Viktor              " "White" "Blue"
    Write-Centered "  =======================================================  " "Gray"
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`n"
    Write-Centered "Presione Enter para volver al menu..." "Gray"
    Read-Host
}

# --- 4. ACCIONES ---
$actions = @{
    "1" = { Show-Header; Write-Centered "[*] Reparando Sistema..." "Cyan"; dism /online /cleanup-image /restorehealth; sfc /scannow }
    "2" = { 
        Show-Header; Write-Centered "[*] Info Hardware..." "Cyan"
        $serial = (Get-WmiObject Win32_Bios).SerialNumber
        $cpu = (Get-WmiObject Win32_Processor).Name
        $ram = [Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
        Write-Centered "CPU: $cpu" "Yellow"; Write-Centered "RAM: $ram GB" "Yellow"; Write-Centered "Serial: $serial" "Yellow"
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        if($key){ Write-Centered "Licencia OEM: $key" "Green" }
    }
    "3" = { Show-Header; Write-Centered "[*] Errores BSOD..." "Red"; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List }
    "4" = { 
        Show-Header; Write-Centered "[*] Estado de Licencia Real..." "Cyan"
        cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "Yellow" }
    }
    "5" = { Show-Header; Write-Centered "[*] Reset Red..." "Cyan"; netsh winsock reset; netsh int ip reset; ipconfig /flushdns; Write-Centered "Listo." "Green" }
    "6" = { Show-Header; Write-Centered "[*] Claves Wi-Fi..." "Cyan"; $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" } }
    "7" = { Show-Header; Write-Centered "[*] Limpiando..." "Cyan"; $p = @("C:\Windows\Temp\*", "$env:TEMP\*"); foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }; Write-Centered "Listo." "Green" }
    "8" = { Show-Header; Write-Centered "[*] Salud Disco..." "Cyan"; wmic diskdrive get model,status | Out-String | ForEach-Object { Write-Centered $_.Trim() "Yellow" } }
    "9" = { 
        Show-Header; Write-Centered "[*] Hard Reset Windows Update..." "Red"
        Stop-Service wuauserv -Force -ErrorAction SilentlyContinue; Stop-Service cryptSvc -Force -ErrorAction SilentlyContinue; Stop-Service bits -Force -ErrorAction SilentlyContinue
        Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service wuauserv -ErrorAction SilentlyContinue; Start-Service cryptSvc -ErrorAction SilentlyContinue; Start-Service bits -ErrorAction SilentlyContinue
        Write-Centered "Servicios reiniciados y cache purgado." "Green"
    }
    "10"= { 
        Show-Header; Write-Centered "[*] Destrabando Impresora..." "Cyan"
        Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
        Start-Service -Name Spooler -ErrorAction SilentlyContinue
        Write-Centered "Cola de impresion vaciada." "Green"
    }
    "11"= { Show-Header; Write-Centered "[*] Instalando Apps Basicas..." "Cyan"; $apps = @("Google.Chrome", "AnyDesk.AnyDesk", "VideoLAN.VLC", "7zip.7zip"); foreach ($a in $apps) { Write-Centered "Instalando $a..." "Gray"; winget install --id $a -e --silent --accept-source-agreements } }
    "12"= { 
        Show-Header; Write-Centered "[*] Switch Modo Seguro..." "Yellow"
        Write-Host "`n"
        Write-Centered "1. Activar Modo Seguro | 2. Desactivar (Modo Normal)" "White"
        $sm = Read-Host "`n" + (" " * 35) + "Opcion"
        if ($sm -eq '1') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered "Modo Seguro ACTIVADO. Reinicie el equipo." "Green" }
        if ($sm -eq '2') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered "Modo Seguro DESACTIVADO. Reinicie el equipo." "Green" }
    }
    "13"= { Show-Header; Write-Centered "[!] AUTO-MANTENIMIENTO..." "Red"; Write-Host "`n"; & $actions["7"]; & $actions["1"]; & $actions["5"]; Write-Host "`n"; Write-Centered "Mantenimiento Finalizado" "Green" }
}

# --- 5. BUCLE PRINCIPAL ---
do {
    Show-Header
    Write-Centered " [SISTEMA]                                     " "Yellow"
    Write-Centered "  1. Reparar Archivos (SFC+DISM)   2. Hardware e Info"
    Write-Centered "  3. Ver Errores Criticos (BSOD)   4. Estado de Licencia"
    Write-Host ""
    Write-Centered " [RED]                                         " "Yellow"
    Write-Centered "  5. Resetear Red Completo         6. Ver Claves Wi-Fi"
    Write-Host ""
    Write-Centered " [MANTENIMIENTO]                               " "Yellow"
    Write-Centered "  7. Limpiar Basura/Temporales     8. Salud de Disco (SMART)"
    Write-Centered "  9. Hard Reset Windows Update    10. Destrabar Impresora"
    Write-Host ""
    Write-Centered " [HERRAMIENTAS PRO]                            " "Yellow"
    Write-Centered " 11. Instalar Kit Soft Basico     12. Alternar Modo Seguro"
    Write-Host ""
    Write-Centered " 13. MODO AUTOMATICO (Limpieza + Reparacion + Red)     " "Green"
    Write-Host ""
    Write-Centered "-------------------------------------------------------" "Gray"
    Write-Centered " Q. Salir                                              "
    
    $choice = Read-Host "`n" + (" " * 32) + "Seleccione una opcion"
    if ($actions.ContainsKey($choice)) { & $actions[$choice]; Pause-Menu }
} while ($choice -ne "q")
