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
    Write-Centered "Presione Enter para continuar..." "Gray"
    Read-Host
}

# --- 4. ACCIONES MAESTRAS (SILENCIOSAS PARA AUTO-MODO) ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
}
$Accion_Reparacion = { dism /online /cleanup-image /restorehealth | Out-Null; sfc /scannow | Out-Null }
$Accion_Red = { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null }

# --- 5. MENUS CATEGORIZADOS ---
$menus = @{
    "0" = { 
        Show-Header; Write-Centered "[!] MANTENIMIENTO AUTOMATICO..." "Red"
        Write-Host "`n"
        Write-Centered "¿Que tareas realiza esta opcion?" "Cyan"
        Write-Centered "- Limpia archivos temporales, prefetch y cache." "White"
        Write-Centered "- Resetea la configuracion de red (IP, DNS, Winsock)." "White"
        Write-Centered "- Ejecuta SFC y DISM para reparar la imagen del sistema." "White"
        Write-Host "`n"
        $conf = Read-Host (" " * 18) + "Presione ENTER para continuar o 'Q' para cancelar"
        if ($conf -ne 'q' -and $conf -ne 'Q') {
            Write-Host "`n"
            Write-Centered "1/3 Limpiando basura del sistema..." "Yellow"; &$Accion_Limpieza
            Write-Centered "2/3 Reseteando stack de red..." "Yellow"; &$Accion_Red
            Write-Centered "3/3 Reparando archivos (Esto tomara tiempo)..." "Yellow"; &$Accion_Reparacion
            Write-Host "`n"; Write-Centered "[OK] MANTENIMIENTO COMPLETADO" "Green"
        } else {
            Write-Host "`n"; Write-Centered "Operacion cancelada por el usuario." "Gray"
        }
        Pause-Menu
    }
    
    "1" = { # DIAGNOSTICO
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== DIAGNOSTICO E INFO DE SISTEMA ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resumen de Hardware y Serial" "White"
            Write-Centered "2. Estado de Licencia (Activacion real)" "White"
            Write-Centered "3. Ver Ultimos Pantallazos Azules (BSOD)" "White"
            Write-Centered "4. Ver Salud de Discos (S.M.A.R.T.)" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            $op = Read-Host "`n" + (" " * 35) + "Opcion"; Write-Host ""
            switch($op) {
                '1' { 
                    $serial = (Get-WmiObject Win32_Bios).SerialNumber
                    $cpu = (Get-WmiObject Win32_Processor).Name
                    $ram = [Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
                    Write-Centered "CPU: $cpu" "Yellow"; Write-Centered "RAM: $ram GB" "Yellow"; Write-Centered "Serial: $serial" "Yellow"
                    $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
                    if($key){ Write-Centered "Licencia BIOS: $key" "Green" }
                    Pause-Menu 
                }
                '2' { cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "Yellow" }; Pause-Menu }
                '3' { Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List; Pause-Menu }
                '4' { wmic diskdrive get model,status | Out-String | ForEach-Object { Write-Centered $_.Trim() "Yellow" }; Pause-Menu }
                '0' { $sub = $false }
            }
        }
    }

    "2" = { # REPARACION
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REPARACION Y SOLUCION DE ERRORES ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Reparar Imagen de Windows (SFC + DISM)" "White"
            Write-Centered "2. Programar Reparacion de Disco (CHKDSK)" "White"
            Write-Centered "3. Hard Reset Windows Update" "Red"
            Write-Centered "4. Destrabar Cola de Impresion" "White"
            Write-Centered "5. Reconstruir Cache de Iconos (Pantalla blanca)" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            $op = Read-Host "`n" + (" " * 35) + "Opcion"; Write-Host ""
            switch($op) {
                '1' { Write-Centered "Reparando..." "Cyan"; &$Accion_Reparacion; Write-Centered "Listo." "Green"; Pause-Menu }
                '2' { 
                    Write-Centered "A. Escaneo Rapido (/f) | B. Escaneo Profundo (/f /r)" "Yellow"
                    $chk = Read-Host (" " * 35) + "Opcion"
                    if ($chk -match 'A') { cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "Programado para el reinicio." "Green" }
                    if ($chk -match 'B') { cmd.exe /c "echo S | chkdsk C: /f /r" | Out-Null; Write-Centered "Programado para el reinicio." "Green" }
                    Pause-Menu
                }
                '3' { 
                    Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                    Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue
                    Write-Centered "Servicios de Update reseteados." "Green"; Pause-Menu 
                }
                '4' { 
                    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
                    Start-Service -Name Spooler -ErrorAction SilentlyContinue
                    Write-Centered "Cola de impresion vaciada." "Green"; Pause-Menu
                }
                '5' {
                    Write-Centered "Reiniciando Explorador y borrando cache..." "Yellow"
                    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
                    Start-Process explorer; Write-Centered "Escritorio recargado." "Green"; Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "3" = { # REDES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REDES Y CONECTIVIDAD ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resetear Stack de Red Completo" "White"
            Write-Centered "2. Extraer Claves Wi-Fi Guardadas" "White"
            Write-Centered "3. Test de Conectividad e Info IP" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            $op = Read-Host "`n" + (" " * 35) + "Opcion"; Write-Host ""
            switch($op) {
                '1' { &$Accion_Red; Write-Centered "Red reseteada. Reinicie el equipo." "Green"; Pause-Menu }
                '2' { 
                    $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                    foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" }
                    Pause-Menu 
                }
                '3' { 
                    Write-Centered "Testeando ping a Google (8.8.8.8)..." "Yellow"
                    Test-Connection -ComputerName 8.8.8.8 -Count 4 -ErrorAction SilentlyContinue | Format-Table Address, ResponseTime
                    Write-Centered "Adaptadores Activos:" "Yellow"
                    Get-NetAdapter | Where-Object Status -eq 'Up' | Format-Table Name, MacAddress, LinkSpeed
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "4" = { # LIMPIEZA
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== MANTENIMIENTO Y LIMPIEZA ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Borrar Archivos Temporales y Cache" "White"
            Write-Centered "2. Purgar Visor de Eventos (Borrar Logs)" "Red"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            $op = Read-Host "`n" + (" " * 35) + "Opcion"; Write-Host ""
            switch($op) {
                '1' { &$Accion_Limpieza; Write-Centered "Basura eliminada." "Green"; Pause-Menu }
                '2' { 
                    Write-Centered "Borrando historial de eventos del sistema..." "Yellow"
                    wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
                    Write-Centered "Logs de Windows completamente limpios." "Green"; Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "5" = { # SOFTWARE Y ARRANQUE
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== SOFTWARE Y ARRANQUE ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Gestor de Instalaciones (Apps y Utilidades)" "White"
            Write-Centered "2. Ver Programas que Inician con Windows" "White"
            Write-Centered "3. Alternar Modo Seguro (Safe Mode)" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            $op = Read-Host "`n" + (" " * 35) + "Opcion"; Write-Host ""
            switch($op) {
                '1' { 
                    $subSoft = $true
                    while($subSoft) {
                        Show-Header; Write-Centered "-- GESTOR DE SOFTWARE --" "Cyan"; Write-Host "`n"
                        Write-Centered "[ PAQUETE BASICO ]" "Yellow"
                        Write-Centered " 1. Chrome   2. AnyDesk   3. 7-Zip   4. Instalar TODOS (1-3)" "White"
                        Write-Host "`n"
                        Write-Centered "[ HERRAMIENTAS OPCIONALES ]" "Yellow"
                        Write-Centered " 5. VLC Media   6. Notepad++   7. Adobe Reader   8. Zoom" "White"
                        Write-Host "`n"
                        Write-Centered " 0. Volver" "Gray"
                        $inst = Read-Host "`n" + (" " * 35) + "Opcion"
                        switch($inst) {
                            '1' { Write-Centered "Instalando Chrome..." "Cyan"; winget install Google.Chrome -e --silent --accept-source-agreements; Pause-Menu }
                            '2' { Write-Centered "Instalando AnyDesk..." "Cyan"; winget install AnyDesk.AnyDesk -e --silent --accept-source-agreements; Pause-Menu }
                            '3' { Write-Centered "Instalando 7-Zip..." "Cyan"; winget install 7zip.7zip -e --silent --accept-source-agreements; Pause-Menu }
                            '4' { Write-Centered "Instalando Paquete Basico..." "Cyan"; foreach($a in @("Google.Chrome","AnyDesk.AnyDesk","7zip.7zip")){winget install $a -e --silent --accept-source-agreements}; Pause-Menu }
                            '5' { Write-Centered "Instalando VLC..." "Cyan"; winget install VideoLAN.VLC -e --silent --accept-source-agreements; Pause-Menu }
                            '6' { Write-Centered "Instalando Notepad++..." "Cyan"; winget install Notepad++.Notepad++ -e --silent --accept-source-agreements; Pause-Menu }
                            '7' { Write-Centered "Instalando Adobe Reader..." "Cyan"; winget install Adobe.Acrobat.Reader.64-bit -e --silent --accept-source-agreements; Pause-Menu }
                            '8' { Write-Centered "Instalando Zoom..." "Cyan"; winget install Zoom.Zoom -e --silent --accept-source-agreements; Pause-Menu }
                            '0' { $subSoft = $false }
                        }
                    }
                }
                '2' { Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table; Pause-Menu }
                '3' { 
                    Write-Centered "A. Activar Modo Seguro | B. Desactivar (Normal)" "Yellow"
                    $sm = Read-Host (" " * 35) + "Opcion"
                    if ($sm -match 'A') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered "Modo Seguro ACTIVADO. Reinicie." "Green" }
                    if ($sm -match 'B') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered "Modo Seguro DESACTIVADO. Reinicie." "Green" }
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }
}

# --- 6. BUCLE DEL MENU PRINCIPAL ---
do {
    Show-Header
    Write-Centered " 1. Diagnostico e Info de Sistema      " "White"
    Write-Centered " 2. Reparacion y Solucion de Errores   " "White"
    Write-Centered " 3. Redes y Conectividad               " "White"
    Write-Centered " 4. Limpieza y Mantenimiento           " "White"
    Write-Centered " 5. Gestor de Software y Arranque      " "White"
    Write-Host ""
    Write-Centered " 0. MODO AUTOMATICO (1 Clic)           " "Green"
    Write-Host ""
    Write-Centered "-------------------------------------------------------" "Gray"
    Write-Centered " Q. Salir                              " "White"
    
    $choice = Read-Host "`n" + (" " * 32) + "Seleccione una categoria"
    if ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "q")
