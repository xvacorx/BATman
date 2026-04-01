# =========================================================
# TOOLBOX TECNICO PRO - By Viktor
# Repositorio: https://github.com/xvacorx/BATman
# TinyURL: https://tinyurl.com/VikToolBox
# =========================================================

# --- 1. AUTO-ELEVACION A ADMINISTRADOR ---
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] Sin permisos de administrador. Solicitando acceso..." -ForegroundColor Yellow
    # Usamos tu nuevo TinyURL para la re-ejecucion
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"iex (irm tinyurl.com/VikToolBox)`""
    exit
}

# --- 2. CONFIGURACION VISUAL Y DE VENTANA ---
if ($host.Name -eq "ConsoleHost") {
    $Size = $host.UI.RawUI.WindowSize
    $Size.Width = 85
    $Size.Height = 32
    $host.UI.RawUI.WindowSize = $Size
    $host.UI.RawUI.BufferSize = $Size
}

# Forzar colores de fondo y texto
$host.ui.RawUI.BackgroundColor = "Black"
$host.ui.RawUI.ForegroundColor = "White"
Clear-Host 

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Toolbox Tecnico Pro - By Viktor [ADMIN]"

function Show-Header {
    Clear-Host
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

# --- 3. DEFINICION DE ACCIONES ---
$actions = @{
    "1" = { 
        Show-Header
        Write-Host "[*] Reparacion Profunda (DISM + SFC)..." -ForegroundColor Cyan
        dism /online /cleanup-image /restorehealth
        sfc /scannow
    }
    "2" = {
        Show-Header
        Write-Host "[*] Info de Hardware y Clave Windows..." -ForegroundColor Cyan
        $serial = (Get-WmiObject Win32_Bios).SerialNumber
        $cpu = (Get-WmiObject Win32_Processor).Name
        $ram = [Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
        $os = (Get-WmiObject Win32_OperatingSystem).Caption
        Write-Host "-------------------------------------------"
        Write-Host "OS:     $os" -ForegroundColor Yellow
        Write-Host "CPU:    $cpu" -ForegroundColor Yellow
        Write-Host "RAM:    $ram GB" -ForegroundColor Yellow
        Write-Host "Serial: $serial" -ForegroundColor Yellow
        $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
        Write-Host "Clave BIOS (OEM): " -NoNewline; if($key){Write-Host $key -ForegroundColor Green}else{Write-Host "No encontrada" -ForegroundColor Red}
        Write-Host "-------------------------------------------"
    }
    "3" = {
        Show-Header
        Write-Host "[*] Analizando ultimos 5 errores criticos (BSOD)..." -ForegroundColor Red
        Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List
    }
    "4" = {
        Show-Header
        Write-Host "[*] Reseteando Stack de Red (Winsock/IP/DNS)..." -ForegroundColor Cyan
        netsh winsock reset; netsh int ip reset; ipconfig /release; ipconfig /renew; ipconfig /flushdns
        Write-Host "Red reseteada con exito." -ForegroundColor Green
    }
    "5" = {
        Show-Header
        Write-Host "[*] Recuperando Claves Wi-Fi Guardadas..." -ForegroundColor Cyan
        $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
        foreach ($profile in $profiles) {
            $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }
            Write-Host "Red: $profile -> " -NoNewline -ForegroundColor Green; Write-Host $pass -ForegroundColor Yellow
        }
    }
    "6" = {
        Show-Header
        Write-Host "[*] Limpiando Temporales, Cache y Prefetch..." -ForegroundColor Cyan
        $paths = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
        foreach ($p in $paths) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
        Write-Host "Limpieza completada." -ForegroundColor Green
    }
    "7" = {
        Show-Header
        Write-Host "[*] Estado Salud del Disco (SMART)..." -ForegroundColor Cyan
        wmic diskdrive get model,status
    }
    "8" = {
        Show-Header
        Write-Host "[*] Instalando Kit Basico (Chrome, AnyDesk, VLC, 7zip)..." -ForegroundColor Cyan
        $apps = @("Google.Chrome", "AnyDesk.AnyDesk", "VideoLAN.VLC", "7zip.7zip")
        foreach ($app in $apps) { Write-Host "Instalando $app..."; winget install --id $app -e --silent --accept-source-agreements --accept-package-agreements }
    }
    "9" = {
        Show-Header
        Write-Host "[*] Listando Programas que inician con Windows..." -ForegroundColor Cyan
        Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table
    }
    "10" = {
        Show-Header
        Write-Host "[*] Reparando Microsoft Store (WSReset)..." -ForegroundColor Cyan
        wsreset.exe
        Write-Host "Espere a que la Tienda se abra automaticamente." -ForegroundColor Yellow
    }
    "11" = {
        Show-Header
        Write-Host "[*] Forzando Actualizacion de Directivas (GPUpdate)..." -ForegroundColor Cyan
        gpupdate /force
    }
    "12" = {
        Show-Header
        Write-Host "[!] INICIANDO MANTENIMIENTO AUTOMATICO..." -ForegroundColor Red
        & $actions["6"]; & $actions["1"]; & $actions["4"]
        Write-Host "`n[OK] Tareas automaticas finalizadas." -ForegroundColor Green
    }
}

# --- 4. BUCLE PRINCIPAL DEL MENU ---
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
