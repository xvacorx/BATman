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

# --- 2. EL SECRETO DEL COLOR Y TAMANO (MODO MASSGRAVE) ---
# Forzar el modo de procesamiento ANSI para colores reales
if ($Host.Name -eq "ConsoleHost") {
    $Size = $Host.UI.RawUI.WindowSize
    $Size.Width = 85
    $Size.Height = 30
    $Host.UI.RawUI.WindowSize = $Size
    $Host.UI.RawUI.BufferSize = $Size
}

# Forzar fondo negro y limpiar la pantalla a bajo nivel
[Console]::BackgroundColor = "Black"
[Console]::ForegroundColor = "White"
[Console]::Clear()

# Codigo ANSI para Reset y Limpieza
$esc = [char]27
$reset = "$esc[0m"
$blackBG = "$esc[40m"
$whiteFG = "$esc[37m"
Write-Host -NoNewline "$blackBG$whiteFG"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    [Console]::Clear()
    Write-Host "`n"
    Write-Host "  _______ ____   ____  _      ____   ______  __ " -ForegroundColor Cyan
    Write-Host " |__   __/ __ \ / __ \| |    |  _ \ / __ \ \/ / " -ForegroundColor Cyan
    Write-Host "    | | | |  | | |  | | |    | |_) | |  | \  /  " -ForegroundColor Cyan
    Write-Host "    | | | |  | | |  | | |    |  _ <| |  | /  \  " -ForegroundColor Cyan
    Write-Host "    |_|  \____/ \____/|______|____/ \____/_/\_\ " -ForegroundColor Cyan
    Write-Host "  =======================================================" -ForegroundColor Gray
    Write-Host "              TOOLBOX TECNICO PRO - By Viktor            " -ForegroundColor White -BackgroundColor Blue
    Write-Host "  =======================================================" -ForegroundColor Gray
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`nPresione Enter para volver al menu..." -ForegroundColor Gray
    Read-Host
}

$actions = @{
    "1" = { Show-Header; Write-Host "[*] Reparando Sistema..." -Cyan; dism /online /cleanup-image /restorehealth; sfc /scannow }
    "2" = { 
        Show-Header; Write-Host "[*] Info Hardware..." -Cyan
        $serial = (Get-WmiObject Win32_Bios).SerialNumber
        $cpu = (Get-WmiObject Win32_Processor).Name
        $ram = [Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
        Write-Host "CPU: $cpu`nRAM: $ram GB`nSerial: $serial" -Yellow
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        Write-Host "Key: $key" -Green
    }
    "3" = { Show-Header; Write-Host "[*] Errores BSOD..." -Red; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List }
    "4" = { Show-Header; Write-Host "[*] Reset Red..." -Cyan; netsh winsock reset; netsh int ip reset; ipconfig /flushdns }
    "5" = { Show-Header; Write-Host "[*] Claves Wi-Fi..." -Cyan; $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Host "$profile : $pass" -Green } }
    "6" = { Show-Header; Write-Host "[*] Limpiando..." -Cyan; $p = @("C:\Windows\Temp\*", "$env:TEMP\*"); foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }; Write-Host "Listo" -Green }
    "7" = { Show-Header; Write-Host "[*] Salud Disco..." -Cyan; wmic diskdrive get model,status }
    "8" = { Show-Header; Write-Host "[*] Instalando Apps..." -Cyan; $apps = @("Google.Chrome", "AnyDesk.AnyDesk", "VideoLAN.VLC", "7zip.7zip"); foreach ($a in $apps) { winget install --id $a -e --silent --accept-source-agreements } }
    "9" = { Show-Header; Write-Host "[*] Apps Inicio..." -Cyan; Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table }
    "10"= { Show-Header; Write-Host "[*] WSReset..." -Cyan; wsreset.exe }
    "11"= { Show-Header; Write-Host "[*] GPUpdate..." -Cyan; gpupdate /force }
    "12"= { Show-Header; Write-Host "[!] AUTO-MANTENIMIENTO..." -Red; & $actions["6"]; & $actions["1"]; & $actions["4"]; Write-Host "Finalizado" -Green }
}

do {
    Show-Header
    Write-Host " [SISTEMA]" -ForegroundColor Yellow
    Write-Host "  1. Reparar Archivos (SFC+DISM)   2. Hardware e Info"
    Write-Host "  3. Ver Errores Criticos (BSOD)"
    Write-Host "`n [RED]" -ForegroundColor Yellow
    Write-Host "  4. Resetear Red Completo         5. Ver Claves Wi-Fi"
    Write-Host "`n [MANTENIMIENTO]" -ForegroundColor Yellow
    Write-Host "  6. Limpiar Basura y Temporales   7. Salud de Disco (SMART)"
    Write-Host "`n [HERRAMIENTAS PRO]" -ForegroundColor Yellow
    Write-Host "  8. Instalar Kit Soft Basico      9. Ver Apps de Inicio"
    Write-Host " 10. Reparar Microsoft Store      11. Forzar GPUpdate"
    Write-Host "`n 12. MODO AUTOMATICO (Limpieza + Reparacion + Red)" -ForegroundColor Green
    Write-Host "---------------------------------------------------------" -ForegroundColor Gray
    Write-Host " Q. Salir"
    
    $choice = Read-Host "`nElija una opcion"
    if ($actions.ContainsKey($choice)) { & $actions[$choice]; Pause-Menu }
} while ($choice -ne "q")
