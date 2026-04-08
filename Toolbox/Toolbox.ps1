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

# --- 2. CONFIGURACION DE VENTANA PANORAMICA (WIDESCREEN) ---
if ($Host.Name -eq "ConsoleHost") {
    $Raw = $Host.UI.RawUI
    $Raw.BackgroundColor = "Black"
    $Raw.ForegroundColor = "White"
    $Size = $Raw.WindowSize
    $Size.Width = 110
    $Size.Height = 38
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
    Write-Centered ("=" * 80) "Gray"
    Write-Centered "              TOOLBOX TECNICO PRO - By Viktor              " "White" "Blue"
    Write-Centered ("=" * 80) "Gray"
    
    $legendText = "[Blanco: Seguro/Info] | [Amarillo: Avanzado] | [Rojo: Reset/Borrado]"
    $width = [Console]::WindowWidth
    $padding = [math]::Max(0, [int](($width - $legendText.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host "[" -ForegroundColor Gray -NoNewline
    Write-Host "Blanco: Seguro/Info" -ForegroundColor White -NoNewline
    Write-Host "] | [" -ForegroundColor Gray -NoNewline
    Write-Host "Amarillo: Avanzado" -ForegroundColor Yellow -NoNewline
    Write-Host "] | [" -ForegroundColor Gray -NoNewline
    Write-Host "Rojo: Reset/Borrado" -ForegroundColor Red -NoNewline
    Write-Host "]" -ForegroundColor Gray
    Write-Host "`n"
}

function Pause-Menu {
    Write-Host "`n"
    Write-Centered "Presione cualquier tecla para volver al menu..." "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Get-KeyPress {
    Write-Host "`n"
    Write-Host (" " * 46) + "Opcion: " -ForegroundColor Gray -NoNewline
    $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character.ToString().ToUpper()
    Write-Host $key -ForegroundColor Cyan
    return $key
}

# --- 4. ACCIONES MAESTRAS ---
$Accion_Limpieza = {
    $p = @("C:\Windows\Temp\*", "$env:TEMP\*", "C:\Windows\Prefetch\*")
    foreach ($i in $p) { Remove-Item $i -Recurse -Force -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

$Accion_Reparacion = { 
    Write-Host "`n"
    Write-Centered "--- REPARANDO IMAGEN DEL SISTEMA (DISM) ---" "Yellow"
    dism /online /cleanup-image /restorehealth
    Write-Host "`n"
    Write-Centered "--- COMPROBANDO INTEGRIDAD DE ARCHIVOS (SFC) ---" "Yellow"
    sfc /scannow
}

$Accion_Red = { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null }

# --- 5. MENUS CATEGORIZADOS ---
$menus = @{
    "A" = { 
        $subAuto = $true
        while($subAuto){
            Show-Header; Write-Centered "[!] MANTENIMIENTO AUTOMATICO..." "Green"
            Write-Host "`n"
            Write-Centered "Esta herramienta desatendida realizara lo siguiente:" "Cyan"
            Write-Host "`n"
            Write-Centered "1. ELIMINACION: Archivos Temporales, Cache, Prefetch y Papelera." "White"
            Write-Centered "2. REPARACION: Escaneo SFC y DISM (Toma tiempo/Requiere Internet)." "White"
            Write-Centered "3. REDES: Reset de IP, DNS y Winsock (Causara un micro-corte)." "White"
            Write-Host "`n"
            Write-Centered " 1. Ejecutar y Volver al Menu " "Yellow"
            Write-Centered " 2. Ejecutar y CERRAR Toolbox " "Red"
            Write-Host "`n"
            Write-Centered " 0. Volver " "Gray"
            
            $conf = Get-KeyPress
            if ($conf -eq '1' -or $conf -eq '2') {
                Show-Header
                Write-Centered ">> EJECUTANDO MANTENIMIENTO AUTOMATICO <<" "Green"
                Write-Host "`n"
                
                Write-Centered "[ Paso 1 de 3 ] Limpiando basura del sistema y papelera..." "Yellow"
                &$Accion_Limpieza
                Write-Centered "OK" "Green"
                Write-Host "`n"

                Write-Centered "[ Paso 2 de 3 ] Reparando archivos del SO (Aguarde por favor)..." "Yellow"
                &$Accion_Reparacion
                Write-Host "`n"

                Write-Centered "[ Paso 3 de 3 ] Reseteando stack de red..." "Yellow"
                &$Accion_Red
                Write-Centered "OK" "Green"
                Write-Host "`n"
                
                $reportPath = "$env:USERPROFILE\Desktop\Reporte_Mantenimiento.txt"
                "=== REPORTE DE MANTENIMIENTO ===" | Out-File -FilePath $reportPath
                "Toolbox by Viktor" | Out-File -FilePath $reportPath -Append
                "Fecha: $(Get-Date -Format 'dd/MM/yyyy a las HH:mm:ss')" | Out-File -FilePath $reportPath -Append
                "--------------------------------" | Out-File -FilePath $reportPath -Append
                "- Limpieza Total y Papelera: OK" | Out-File -FilePath $reportPath -Append
                "- Reparacion de integridad (SFC/DISM): OK" | Out-File -FilePath $reportPath -Append
                "- Restablecimiento de red: OK" | Out-File -FilePath $reportPath -Append
                "--------------------------------" | Out-File -FilePath $reportPath -Append
                "El equipo ha sido optimizado exitosamente. Se recomienda reiniciar." | Out-File -FilePath $reportPath -Append
                
                Write-Centered ("-" * 80) "Gray"
                Write-Centered "[OK] MANTENIMIENTO COMPLETADO CON EXITO" "Green"
                Write-Centered "Reporte guardado en el Escritorio." "Cyan"
                
                if ($conf -eq '2') { exit }
                Pause-Menu; $subAuto = $false
            } elseif ($conf -eq '0') {
                $subAuto = $false
            }
        }
    }
    
    "C" = { 
        Show-Header; Write-Centered "=== CREDITOS ===" "Cyan"; Write-Host "`n"
        Write-Centered "Toolbox Tecnico Pro ha sido desarrollado por Viktor." "White"
        Write-Host "`n"; Write-Centered "Repositorio Oficial:" "Gray"; Write-Centered "https://github.com/xvacorx" "Cyan"
        Write-Host "`n"; Write-Centered "Abriendo navegador..." "Yellow"
        Start-Process "https://github.com/xvacorx"
        Pause-Menu
    }
    
    "1" = { # DIAGNOSTICO
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== DIAGNOSTICO E INFO DE SISTEMA ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resumen de Sistema (Hardware, Serial, Uptime, BitLocker)" "White"
            Write-Centered "2. Estado de Licencia (Activacion real)" "White"
            Write-Centered "3. Ver Ultimos Pantallazos Azules (BSOD)" "White"
            Write-Centered "4. Ver Salud de Discos (S.M.A.R.T.)" "White"
            Write-Centered "5. Generar Reporte de Bateria (HTML) [Abre Navegador]" "Yellow"
            Write-Centered "6. Exportar Inventario de PC (TXT) [Guarda en Escritorio]" "Yellow"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header; Write-Centered "--- RADIOGRAFIA DEL SISTEMA ---" "Cyan"; Write-Host "`n"
                    # Hardware
                    $serial = (Get-WmiObject Win32_Bios).SerialNumber
                    $cpu = (Get-WmiObject Win32_Processor).Name
                    $ram = [Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)
                    
                    # Uptime
                    $os = Get-WmiObject Win32_OperatingSystem
                    $uptime = $os.ConvertToDateTime($os.LastBootUpTime)
                    $timespan = New-TimeSpan -Start $uptime -End (Get-Date)
                    $uptimeStr = "$($timespan.Days) Dias, $($timespan.Hours) Horas, $($timespan.Minutes) Minutos"

                    # BitLocker
                    $bl = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume -Filter "DriveLetter='C:'" -ErrorAction SilentlyContinue
                    if ($bl) { if ($bl.ProtectionStatus -eq 1) { $blStatus = "Cifrado (ACTIVADO)" } else { $blStatus = "Desencriptado (DESACTIVADO)" } } else { $blStatus = "No Detectado" }

                    Write-Centered "Procesador (CPU): $cpu" "White"
                    Write-Centered "Memoria RAM: $ram GB" "White"
                    Write-Centered "Serial (BIOS): $serial" "White"
                    Write-Host "`n"
                    Write-Centered "Tiempo Encendido (Uptime): $uptimeStr" "Cyan"
                    if($blStatus -match "ACTIVADO"){Write-Centered "Estado BitLocker (C:): $blStatus" "Red"}else{Write-Centered "Estado BitLocker (C:): $blStatus" "Green"}
                    
                    $key = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
                    if($key){ Write-Centered "Licencia OEM BIOS: $key" "Green" }
                    Pause-Menu 
                }
                '2' { Show-Header; Write-Centered "--- ESTADO DE LICENCIA ---" "Cyan"; Write-Host "`n"; cscript //nologo c:\windows\system32\slmgr.vbs /xpr | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '3' { Show-Header; Write-Centered "--- ULTIMOS 5 ERRORES CRITICOS ---" "Red"; Write-Host "`n"; Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2} -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Message | Format-List; Pause-Menu }
                '4' { Show-Header; Write-Centered "--- SALUD DEL DISCO ---" "Cyan"; Write-Host "`n"; Get-WmiObject Win32_DiskDrive | Select-Object Model, Status | Out-String -Stream | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Write-Centered $_.Trim() "White" }; Pause-Menu }
                '5' { Show-Header; Write-Centered "Generando reporte de bateria..." "Cyan"; powercfg /batteryreport /output "$env:USERPROFILE\Desktop\BatteryReport.html" | Out-Null; Invoke-Item "$env:USERPROFILE\Desktop\BatteryReport.html"; Write-Centered "Reporte guardado en Escritorio y abierto." "Green"; Pause-Menu }
                '6' {
                    Show-Header; Write-Centered "Generando TXT con inventario..." "Cyan"
                    $inv = "$env:USERPROFILE\Desktop\Inventario_$env:COMPUTERNAME.txt"
                    "=== INVENTARIO DE EQUIPO ===" | Out-File $inv
                    "Nombre de PC: $env:COMPUTERNAME" | Out-File $inv -Append
                    "Usuario Actual: $env:USERNAME" | Out-File $inv -Append
                    "Sistema: $((Get-WmiObject Win32_OperatingSystem).Caption)" | Out-File $inv -Append
                    "CPU: $((Get-WmiObject Win32_Processor).Name)" | Out-File $inv -Append
                    "RAM: $([Math]::Round((Get-WmiObject Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB)) GB" | Out-File $inv -Append
                    "Serial BIOS: $((Get-WmiObject Win32_Bios).SerialNumber)" | Out-File $inv -Append
                    Write-Centered "Inventario guardado en el Escritorio." "Green"; Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "2" = { # REPARACION
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REPARACION Y SOLUCION DE ERRORES ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Reparar Imagen de Windows (SFC + DISM) [Toma 10-20 Min]" "Yellow"
            Write-Centered "2. Programar Reparacion de Disco (CHKDSK)" "Yellow"
            Write-Centered "3. Escaneo Rapido Antivirus (Windows Defender)" "Yellow"
            Write-Centered "4. Destrabar Cola de Impresion (Borra Spooler)" "Yellow"
            Write-Centered "5. Reconstruir Cache de Iconos (Reinicia el Explorador)" "Yellow"
            Write-Centered "6. Alternar Administrador Oculto" "Yellow"
            Write-Centered "7. Forzar Sincronizacion de Hora" "Yellow"
            Write-Centered "8. Hard Reset Windows Update (Borra SoftwareDistribution)" "Red"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Reparacion; Write-Host "`n"; Write-Centered "Listo." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "A. Escaneo Rapido (/f) | B. Escaneo Profundo (/f /r)" "Yellow"
                    $chk = Get-KeyPress
                    if ($chk -eq 'A') { cmd.exe /c "echo S | chkdsk C: /f" | Out-Null; Write-Centered "Programado para el reinicio." "Green" }
                    if ($chk -eq 'B') { cmd.exe /c "echo S | chkdsk C: /f /r" | Out-Null; Write-Centered "Programado para el reinicio." "Green" }
                    Pause-Menu
                }
                '3' { 
                    Show-Header; Write-Centered "--- ESCANEO DE WINDOWS DEFENDER ---" "Yellow"; Write-Host "`n"
                    Start-MpScan -ScanType QuickScan
                    Write-Host "`n"; Write-Centered "Escaneo completado." "Green"; Pause-Menu 
                }
                '4' { 
                    Show-Header; Write-Centered "Vaciando cola de impresion..." "Cyan"
                    Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
                    Start-Service -Name Spooler -ErrorAction SilentlyContinue
                    Write-Centered "Cola de impresion vaciada." "Green"; Pause-Menu
                }
                '5' {
                    Show-Header; Write-Centered "Reiniciando Explorador y borrando cache..." "Cyan"
                    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\IconCache.db" -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:localappdata\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
                    Start-Process explorer; Write-Centered "Escritorio recargado." "Green"; Pause-Menu
                }
                '6' {
                    Show-Header; Write-Centered "A. Activar Administrador | B. Desactivar" "Yellow"
                    $adm = Get-KeyPress
                    if ($adm -eq 'A') { net user administrador /active:yes | Out-Null; net user administrator /active:yes | Out-Null; Write-Centered "Cuenta Habilitada." "Green" }
                    if ($adm -eq 'B') { net user administrador /active:no | Out-Null; net user administrator /active:no | Out-Null; Write-Centered "Cuenta Deshabilitada." "Green" }
                    Pause-Menu
                }
                '7' {
                    Show-Header; Write-Centered "Sincronizando reloj con servidores de Windows..." "Cyan"; Write-Host "`n"
                    Restart-Service w32time -ErrorAction SilentlyContinue
                    w32tm /resync | Out-String | ForEach-Object { Write-Centered $_.Trim() "White" }
                    Pause-Menu
                }
                '8' { 
                    Show-Header; Write-Centered "Reseteando Windows Update..." "Red"
                    Stop-Service wuauserv, cryptSvc, bits -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:windir\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
                    Start-Service wuauserv, cryptSvc, bits -ErrorAction SilentlyContinue
                    Write-Centered "Servicios de Update reseteados y cache purgado." "Green"; Pause-Menu 
                }
                '0' { $sub = $false }
            }
        }
    }

    "3" = { # REDES
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== REDES Y CONECTIVIDAD ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Resetear Stack de Red Completo (Causa Micro-Corte)" "Yellow"
            Write-Centered "2. Extraer Claves Wi-Fi Guardadas" "White"
            Write-Centered "3. Test de Conectividad e Info IP" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Red; Write-Centered "Red reseteada. Reinicie el equipo." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "--- CLAVES WI-FI ---" "Cyan"; Write-Host "`n"
                    $profiles = netsh wlan show profiles | Select-String "\:(.+)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
                    foreach ($profile in $profiles) { $pass = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content" | ForEach-Object { $_.ToString().Split(':')[1].Trim() }; Write-Centered "$profile : $pass" "Green" }
                    Pause-Menu 
                }
                '3' { 
                    Show-Header; Write-Centered "--- TEST DE CONECTIVIDAD ---" "Cyan"; Write-Host "`n"
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
            Write-Centered "1. Borrar Archivos Temporales, Cache, Prefetch y Papelera" "Yellow"
            Write-Centered "2. Purgar Visor de Eventos (Borra TODOS los Logs)" "Red"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { Show-Header; &$Accion_Limpieza; Write-Centered "Basura y Papelera eliminadas." "Green"; Pause-Menu }
                '2' { 
                    Show-Header; Write-Centered "Borrando historial de eventos del sistema..." "Red"
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
            Write-Centered "2. Actualizador Global de Software (Winget)" "Yellow"
            Write-Centered "3. Ver Programas que Inician con Windows" "White"
            Write-Centered "4. Alternar Modo Seguro (Safe Mode)" "Yellow"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    $subSoft = $true
                    while($subSoft) {
                        Show-Header; Write-Centered "-- GESTOR DE SOFTWARE --" "Cyan"; Write-Host "`n"
                        Write-Centered "[ PAQUETE BASICO ]" "Cyan"
                        Write-Centered " 1. Chrome | 2. AnyDesk | 3. 7-Zip | 4. TODOS (1-3)" "Yellow"
                        Write-Host "`n"
                        Write-Centered "[ HERRAMIENTAS OPCIONALES ]" "Cyan"
                        Write-Centered " 5. VLC Media | 6. Notepad++ | 7. Reader | 8. Zoom" "Yellow"
                        Write-Host "`n"
                        Write-Centered " 0. Volver" "Gray"
                        
                        $inst = Get-KeyPress
                        switch($inst) {
                            '1' { Show-Header; Write-Centered "Instalando Chrome..." "Yellow"; Write-Host "`n"; winget install Google.Chrome -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '2' { Show-Header; Write-Centered "Instalando AnyDesk..." "Yellow"; Write-Host "`n"; winget install AnyDesk.AnyDesk -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '3' { Show-Header; Write-Centered "Instalando 7-Zip..." "Yellow"; Write-Host "`n"; winget install 7zip.7zip -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '4' { Show-Header; Write-Centered "Instalando Paquete Basico..." "Yellow"; Write-Host "`n"; foreach($a in @("Google.Chrome","AnyDesk.AnyDesk","7zip.7zip")){winget install $a -e --accept-source-agreements --accept-package-agreements}; Pause-Menu }
                            '5' { Show-Header; Write-Centered "Instalando VLC..." "Yellow"; Write-Host "`n"; winget install VideoLAN.VLC -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '6' { Show-Header; Write-Centered "Instalando Notepad++..." "Yellow"; Write-Host "`n"; winget install Notepad++.Notepad++ -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '7' { Show-Header; Write-Centered "Instalando Adobe Reader..." "Yellow"; Write-Host "`n"; winget install Adobe.Acrobat.Reader.64-bit -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '8' { Show-Header; Write-Centered "Instalando Zoom..." "Yellow"; Write-Host "`n"; winget install Zoom.Zoom -e --accept-source-agreements --accept-package-agreements; Pause-Menu }
                            '0' { $subSoft = $false }
                        }
                    }
                }
                '2' { 
                    Show-Header; Write-Centered "--- ACTUALIZADOR GLOBAL WINGET ---" "Yellow"; Write-Host "`n"
                    winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
                    Write-Host "`n"; Write-Centered "Actualizacion global finalizada." "Green"
                    Pause-Menu
                }
                '3' { Show-Header; Write-Centered "--- APLICACIONES DE INICIO ---" "Cyan"; Write-Host "`n"; Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider | Format-Table; Pause-Menu }
                '4' { 
                    Show-Header; Write-Centered "A. Activar Modo Seguro | B. Desactivar (Normal)" "Yellow"
                    $sm = Get-KeyPress
                    if ($sm -eq 'A') { bcdedit /set "{current}" safeboot minimal | Out-Null; Write-Centered "Modo Seguro ACTIVADO. Reinicie." "Green" }
                    if ($sm -eq 'B') { bcdedit /deletevalue "{current}" safeboot | Out-Null; Write-Centered "Modo Seguro DESACTIVADO. Reinicie." "Green" }
                    Pause-Menu
                }
                '0' { $sub = $false }
            }
        }
    }

    "6" = { # OPTIMIZACIONES Y ATAJOS CLASICOS
        $sub = $true
        while($sub) {
            Show-Header; Write-Centered "=== OPTIMIZACIONES Y ATAJOS CLASICOS ===" "Cyan"; Write-Host "`n"
            Write-Centered "1. Deshabilitar Inicio Rapido (Fast Startup)" "Yellow"
            Write-Centered "2. Habilitar Inicio Rapido (Fast Startup)" "Yellow"
            Write-Centered "3. Generar acceso 'God Mode' en Escritorio" "Yellow"
            Write-Host "`n"
            Write-Centered "--- PANELES DE CONTROL ANTIGUOS ---" "Cyan"
            Write-Centered "4. Panel de Control Principal" "White"
            Write-Centered "5. Administrador de Dispositivos" "White"
            Write-Centered "6. Conexiones de Red (Adaptadores)" "White"
            Write-Centered "7. Programas y Caracteristicas (Desinstalar)" "White"
            Write-Host "`n"; Write-Centered "0. Volver al Menu Principal" "Gray"
            
            $op = Get-KeyPress
            switch($op) {
                '1' { 
                    Show-Header
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Centered "Inicio Rapido DESHABILITADO. Apagados limpios activados." "Green"; Pause-Menu 
                }
                '2' { 
                    Show-Header
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force -ErrorAction SilentlyContinue
                    Write-Centered "Inicio Rapido HABILITADO." "Green"; Pause-Menu 
                }
                '3' { 
                    Show-Header
                    $path = "$env:USERPROFILE\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
                    if (-not (Test-Path $path)) { 
                        New-Item -ItemType Directory -Path $path | Out-Null
                        Write-Centered "Carpeta 'God Mode' creada en el Escritorio." "Green" 
                    } else { 
                        Write-Centered "La carpeta 'God Mode' ya existe en el Escritorio." "White" 
                    }
                    Pause-Menu 
                }
                '4' { Start-Process control; Write-Centered "Abriendo Panel de Control..." "Green"; Pause-Menu }
                '5' { Start-Process devmgmt.msc; Write-Centered "Abriendo Adm. de Dispositivos..." "Green"; Pause-Menu }
                '6' { Start-Process ncpa.cpl; Write-Centered "Abriendo Conexiones de Red..." "Green"; Pause-Menu }
                '7' { Start-Process appwiz.cpl; Write-Centered "Abriendo Programas..." "Green"; Pause-Menu }
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
    Write-Centered " 6. Optimizaciones y Atajos Clasicos   " "White"
    Write-Host "`n"
    Write-Centered " A. MODO AUTOMATICO                    " "Green"
    Write-Centered " C. Creditos (GitHub)                  " "Cyan"
    Write-Host "`n"
    Write-Centered ("-" * 80) "Gray"
    Write-Centered " 0. Salir                              " "Gray"
    
    $choice = Get-KeyPress
    if ($menus.ContainsKey($choice)) { & $menus[$choice] }
} while ($choice -ne "0")
