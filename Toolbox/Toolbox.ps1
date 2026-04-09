# =========================================================
# TOOLBOX TECNICO PRO - By Viktor (V10.1 Language Toggle)
# TinyURL: tinyurl.com/VikToolBox
# =========================================================

# --- 0. DICCIONARIO Y DETECCION INICIAL ---
if ($null -eq $lang) { $global:lang = if ((Get-Culture).TwoLetterISOLanguageName -eq 'es') { 'es' } else { 'en' } }

$msg = @{
    'es' = @{
        'title'      = "TOOLBOX TECNICO PRO - By Viktor"
        'legend'     = "[Blanco: Seguro] | [Amarillo: Avanzado] | [Rojo: Borrado/Reset]"
        'reboot'     = "[!] ATENCION: EL SISTEMA REQUIERE UN REINICIO PENDIENTE [!]"
        'press_key'  = "Presione cualquier tecla para volver al menu..."
        'option'     = "Opcion: "
        'no_internet'= "[!] SIN CONEXION: Omitiendo reparacion DISM/SFC"
        'm_auto'     = "A. MODO AUTOMATICO"
        'm_lang'     = "L. CAMBIAR IDIOMA (ES/EN)"
        'm_exit'     = "0. Salir"
        'm1' = "1. Diagnostico e Info de Sistema"
        'm2' = "2. Reparacion y Solucion de Errores"
        'm3' = "3. Redes y Conectividad"
        'm4' = "4. Limpieza y Mantenimiento"
        'm5' = "5. Gestor de Software y Arranque"
        'm6' = "6. Optimizaciones y Atajos Clasicos"
        # ... (Resto de traducciones del V10.0 se mantienen igual)
    }
    'en' = @{
        'title'      = "TECH TOOLBOX PRO - By Viktor"
        'legend'     = "[White: Safe] | [Yellow: Advanced] | [Red: Delete/Reset]"
        'reboot'     = "[!] ATTENTION: SYSTEM REBOOT PENDING [!]"
        'press_key'  = "Press any key to return to menu..."
        'option'     = "Option: "
        'no_internet'= "[!] NO CONNECTION: Skipping DISM/SFC repair"
        'm_auto'     = "A. AUTOMATIC MODE"
        'm_lang'     = "L. CHANGE LANGUAGE (ES/EN)"
        'm_exit'     = "0. Exit"
        'm1' = "1. Diagnostics & System Info"
        'm2' = "2. Repair & Error Solutions"
        'm3' = "3. Network & Connectivity"
        'm4' = "4. Cleaning & Maintenance"
        'm5' = "5. Software & Startup Manager"
        'm6' = "6. Optimizations & Classic Shortcuts"
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

# --- 4. FUNCIONES GLOBALES ---
# (Se mantienen funciones: Write-ToolboxLog, Write-Centered, Play-FinishBeep, Get-WmiCim, Test-Internet, Check-RebootPending)

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
    if (Check-RebootPending) { Write-Centered $msg[$global:lang]['reboot'] "Red"; Write-Host "`n" }
    Write-Centered $msg[$global:lang]['legend'] "Gray"
    Write-Host "`n"
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
        Start-Sleep -Milliseconds 500
    }
    elseif ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "0")

[Console]::Clear(); exit
