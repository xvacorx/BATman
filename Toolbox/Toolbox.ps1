# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V10.1 Language Toggle)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. DICCIONARIO Y DETECCION DE IDIOMA ---
if ($null -eq $global:lang) { 
    $global:lang = if ((Get-Culture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' } 
}

$msg = @{
    'es' = @{
        'title'      = "TOOLBOX TECNICO PRO - By Viktor"
        'legend'     = "[Blanco: Seguro] | [Amarillo: Avanzado] | [Rojo: Borrado/Reset]"
        'reboot'     = "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]"
        'press_key'  = "Presione cualquier tecla para volver al menu..."
        'option'     = "Opcion: "
        'no_internet'= "[!] SIN CONEXION: Omitiendo reparacion DISM/SFC"
        'internet_ok'= "[OK] Internet Detectado."
        'm_auto'     = "A. MODO AUTOMATICO"
        'm_lang'     = "L. CAMBIAR IDIOMA (ES/EN)"
        'm_exit'     = "0. Salir"
        'm1' = "1. Diagnostico e Info de Sistema"
        'm2' = "2. Reparacion y Solucion de Errores"
        'm3' = "3. Redes y Conectividad"
        'm4' = "4. Limpieza y Mantenimiento"
        'm5' = "5. Gestor de Software y Arranque"
        'm6' = "6. Optimizaciones y Atajos Clasicos"
        'storage'    = "Almacenamiento (C:): "
        'uptime'     = "Tiempo Encendido (Uptime): "
        'days'       = "Dias"; 'hours' = "Horas"; 'mins' = "Minutos"
    }
    'en' = @{
        'title'      = "TECH TOOLBOX PRO - By Viktor"
        'legend'     = "[White: Safe] | [Yellow: Advanced] | [Red: Delete/Reset]"
        'reboot'     = "[!] ATTENTION: SYSTEM REBOOT PENDING [!]"
        'press_key'  = "Press any key to return to menu..."
        'option'     = "Option: "
        'no_internet'= "[!] NO CONNECTION: Skipping DISM/SFC repair"
        'internet_ok'= "[OK] Internet Detected."
        'm_auto'     = "A. AUTOMATIC MODE"
        'm_lang'     = "L. CHANGE LANGUAGE (ES/EN)"
        'm_exit'     = "0. Exit"
        'm1' = "1. Diagnostics & System Info"
        'm2' = "2. Repair & Error Solutions"
        'm3' = "3. Network & Connectivity"
        'm4' = "4. Cleaning & Maintenance"
        'm5' = "5. Software & Startup Manager"
        'm6' = "6. Optimizations & Classic Shortcuts"
        'storage'    = "Storage (C:): "
        'uptime'     = "System Uptime: "
        'days'       = "Days"; 'hours' = "Hours"; 'mins' = "Minutes"
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

# --- 4. FUNCIONES GLOBALES (EL CORAZON DEL SCRIPT) ---
function Write-Centered {
    param([string]$text, [string]$color = "White", [string]$bg = "Black")
    $width = [Console]::WindowWidth; if ($width -le 0) { $width = 110 }
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
    Write-Centered ("=" * 80) "Gray"
    Write-Centered "              $($msg[$global:lang]['title'])              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    
    $r1 = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $r2 = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    if ($r1 -or $r2) { Write-Centered $msg[$global:lang]['reboot'] "Red"; Write-Host "`n" }

    Write-Centered $msg[$global:lang]['legend'] "Gray"
    Write-Host "`n"
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

function Pause-Menu {
    Write-Host "`n"; Write-Centered $msg[$global:lang]['press_key'] "Gray"
    try { $Host.UI.RawUI.FlushInputBuffer() } catch { }
    try { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") } catch { Start-Sleep -Seconds 2 }
}

function Get-WmiCim([string]$Class, [string]$Namespace = "Root\CIMv2", [string]$Filter = "") {
    try { if ($Filter) { return Get-CimInstance -ClassName $Class -Namespace $Namespace -Filter $Filter -ErrorAction Stop } else { return Get-CimInstance -ClassName $Class -Namespace $Namespace -ErrorAction Stop } }
    catch { if ($Filter) { return Get-WmiObject -Class $Class -Namespace $Namespace -Filter $Filter -ErrorAction SilentlyContinue } else { return Get-WmiObject -Class $Class -Namespace $Namespace -ErrorAction SilentlyContinue } }
}

# --- 5. BUCLE PRINCIPAL ---
do {
    Show-Header
    Write-Centered " 1. $($msg[$global:lang]['m1']) " "White"
    Write-Centered " 2. $($msg[$global:lang]['m2']) " "White"
    Write-Centered " 3. $($msg[$global:lang]['m3']) " "White"
    Write-Centered " 4. $($msg[$global:lang]['m4']) " "White"
    Write-Centered " 5. $($msg[$global:lang]['m5']) " "White"
    Write-Centered " 6. $($msg[$global:lang]['m6']) " "White"
    Write-Host "`n"
    Write-Centered " $($msg[$global:lang]['m_auto']) " "Green"
    Write-Centered " $($msg[$global:lang]['m_lang']) " "Yellow"
    Write-Host "`n"; Write-Centered ("-" * 80) "Gray"
    Write-Centered " $($msg[$global:lang]['m_exit']) " "Gray"
    
    $choice = Get-KeyPress
    
    if ($choice -eq 'L') {
        $global:lang = if ($global:lang -eq 'es') { 'en' } else { 'es' }
        Write-Centered "Cambiando idioma / Switching language..." "Cyan"
        Start-Sleep -Milliseconds 600
    }
    elseif ($choice -eq '0') { break }
    # Aquí irían las llamadas a los otros menús (se omiten por brevedad del ejemplo reparado)
} while ($true)

[Console]::Clear(); exit
