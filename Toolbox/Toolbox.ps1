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

# --- 2. ELIMINAR MARCO AZUL Y AJUSTAR VENTANA ---
if ($Host.Name -eq "ConsoleHost") {
    $Raw = $Host.UI.RawUI
    $Raw.BackgroundColor = "Black"
    $Raw.ForegroundColor = "White"
    $Size = $Raw.WindowSize
    $Size.Width = 85
    $Size.Height = 35
    $Raw.BufferSize = $Size
    $Raw.WindowSize = $Size
}
[Console]::BackgroundColor = "Black"
[Console]::Clear() # Esto mata el marco azul definitivamente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- 3. FUNCION PARA CENTRAR TEXTO ---
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
        if($key){ Write-Centered "Licencia: $key" "Green" }
    }
    "3" = { Show-Header; Write-Centered "[*] Errores BSOD..." "Red"; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List }
    "4" = { Show-Header; Write-Centered "[*] Reset Red..." "Cyan"; netsh winsock reset; netsh int ip reset; ipconfig /flushdns }
    "5" = { Show-Header; Write-Centered "[*] Claves Wi-Fi..." "Cyan"; $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }; foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" } }
    "6" = { Show-Header; Write-Centered "[*] Limpiando..." "Cyan"; $p = @("C:\Windows\Temp\*", "$env:TEMP\*"); foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }; Write-Centered "Listo" "Green" }
    "7" = { Show-Header; Write-Centered "[*] Salud Disco..." "Cyan"; wmic diskdrive get model,status | Out-String | ForEach-Object { Write-Centered $_.Trim() "Yellow" } }
    "8" = { Show-Header; Write-Centered "[*] Instalando Apps..." "Cyan"; $apps = @("Google.Chrome", "AnyDesk.AnyDesk", "VideoLAN.VLC", "7zip.7zip"); foreach ($a in $apps) { Write-Centered "Instalando $a..." "Gray"; winget install --id $a -e --silent --accept-source-agreements } }
    "12"= { Show-Header; Write-Centered "[!] AUTO-MANTENIMIENTO..." "Red"; & $actions["6"]; & $actions["1"]; & $actions["4"]; Write-Centered "Finalizado" "Green" }
}

# --- 5. BUCLE PRINCIPAL ---
do {
    Show-Header
    Write-Centered " [SISTEMA]                                     " "Yellow"
    Write-Centered "  1. Reparar Archivos (SFC+DISM)   2. Hardware e Info"
    Write-Centered "  3. Ver Errores Criticos (BSOD)                     "
    Write-Host ""
    Write-Centered " [RED]                                         " "Yellow"
    Write-Centered "  4. Resetear Red Completo         5. Ver Claves Wi-Fi"
    Write-Host ""
    Write-Centered " [MANTENIMIENTO]                               " "Yellow"
    Write-Centered "  6. Limpiar Basura y Temporales   7. Salud de Disco (SMART)"
    Write-Host ""
    Write-Centered " [HERRAMIENTAS PRO]                            " "Yellow"
    Write-Centered "  8. Instalar Kit Soft Basico      12. MODO AUTOMATICO"
    Write-Host ""
    Write-Centered "-------------------------------------------------------" "Gray"
    Write-Centered " Q. Salir                                              "
    
    $choice = Read-Host "`n" + (" " * 30) + "Seleccione una opcion"
    if ($actions.ContainsKey($choice)) { & $actions[$choice]; Pause-Menu }
} while ($choice -ne "q")
