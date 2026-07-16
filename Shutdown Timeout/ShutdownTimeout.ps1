<#
.SYNOPSIS
    VikTools CLI - Shutdown Timeout Utility
.DESCRIPTION
    Monitorea la inactividad de Windows mediante GetLastInputInfo.
    Lanza una advertencia visual y programa el apagado del equipo al alcanzar el límite configurado.
.NOTES
    Autor: Viktor! / Viklab
    Versión: 2.0
#>

# Configuración de salida
$OutputEncoding = [System.Text.Encoding]::UTF8
[console]::InputEncoding = [System.Text.Encoding]::UTF8
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "       VIKTOOLS CLI - SHUTDOWN TIMEOUT        " -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " Apagado programado inteligente por inactividad."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Código de C# para importar GetLastInputInfo de user32.dll
$signature = @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public static uint GetIdleTime() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);
        if (!GetLastInputInfo(ref lii)) {
            return 0;
        }
        return (uint)Environment.TickCount - lii.dwTime;
    }
}
"@

# Cargar el tipo de C# si no está ya cargado
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition $signature
}

function Start-Monitoring {
    param(
        [int]$warningMinutes = 40,
        [int]$shutdownMinutes = 45,
        [int]$checkIntervalSeconds = 30
    )

    $warningSeconds = $warningMinutes * 60
    $shutdownSeconds = $shutdownMinutes * 60
    $warningSent = $false

    Show-Header
    Write-Host "[i] Iniciando monitor de inactividad..." -ForegroundColor Cyan
    Write-Host "    - Apagar equipo tras: $shutdownMinutes minutos sin actividad." -ForegroundColor Yellow
    Write-Host "    - Mostrar advertencia tras: $warningMinutes minutos sin actividad." -ForegroundColor Yellow
    Write-Host "    - Monitoreando de fondo cada $checkIntervalSeconds segundos..." -ForegroundColor Gray
    Write-Host ""
    Write-Host "[i] Presiona Ctrl+C para detener el monitoreo." -ForegroundColor DarkGray
    Write-Host ""

    while ($true) {
        $idleMs = [Win32]::GetIdleTime()
        $idleSec = [int]($idleMs / 1000)

        # Mostrar progreso discreto en la misma linea de consola
        $currentIdleMin = [Math]::Round($idleSec / 60, 1)
        Write-Host -NoNewline "`r[i] Inactividad actual: $currentIdleMin min (Límite: $shutdownMinutes min)   "

        if ($idleSec -ge $shutdownSeconds) {
            Write-Host "`n[!] Se alcanzo el limite de inactividad. Procediendo con el apagado..." -ForegroundColor Red
            shutdown /s /f /t 10 /c "Apagado por inactividad de VikTools CLI"
            break
        }
        elseif ($idleSec -ge $warningSeconds) {
            if (-not $warningSent) {
                Write-Host "`n[i] Lanzando mensaje de advertencia..." -ForegroundColor Yellow
                # Ejecutar diálogo de alerta
                $msgText = "ATENCION: No se ha detectado actividad en los ultimos $warningMinutes minutos. La computadora se apagara automaticamente en 5 minutos."
                # Lanzar de fondo de forma asíncrona para no bloquear el bucle
                Start-Process msg.exe -ArgumentList "* `"$msgText`"" -WindowStyle Hidden
                $warningSent = $true
            }
        }
        else {
            # Resetear flag de aviso si el usuario regresó
            if ($warningSent) {
                Write-Host "`n[OK] Actividad detectada. Reiniciando contadores." -ForegroundColor Green
                $warningSent = $false
            }
        }

        Start-Sleep -Seconds $checkIntervalSeconds
    }
}

# Flujo de Menú
do {
    Show-Header
    Write-Host "  1. Iniciar con valores por defecto (Advertencia: 40 min | Apagado: 45 min)" -ForegroundColor Gray
    Write-Host "  2. Iniciar con valores personalizados" -ForegroundColor Gray
    Write-Host "  0. Salir" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Selecciona una opcion"
    
    switch ($choice) {
        "1" {
            Start-Monitoring
            break
        }
        "2" {
            Write-Host ""
            [int]$warning = Read-Host "Minutos de inactividad antes de ADVERTIR"
            [int]$shutdown = Read-Host "Minutos de inactividad antes de APAGAR"
            if ($warning -gt 0 -and $shutdown -gt $warning) {
                Start-Monitoring -warningMinutes $warning -shutdownMinutes $shutdown
            } else {
                Write-Host "[!] Los minutos ingresados no son coherentes." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
            break
        }
        "0" {
            break
        }
        default {
            Write-Host "[!] Opcion no valida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne "0")
