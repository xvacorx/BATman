<#
.SYNOPSIS
    VikTools CLI - Anti Sleep Utility
.DESCRIPTION
    Evita que el sistema y la pantalla entren en suspensión durante tareas prolongadas.
    Permite activar, desactivar y verificar el estado actual de la prevención de suspensión.
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
    Write-Host "         VIKTOOLS CLI - ANTI SLEEP            " -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " Evita que el sistema entre en suspension."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Get-AntiSleepStatus {
    $processes = Get-CimInstance -ClassName Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%SetThreadExecutionState%'" -ErrorAction SilentlyContinue
    if ($processes) {
        return $true
    }
    return $false
}

function Enable-AntiSleep {
    if (Get-AntiSleepStatus) {
        Write-Host "[!] El servicio Anti Sleep ya se encuentra ACTIVO." -ForegroundColor Yellow
        return
    }

    Write-Host "[i] Iniciando Anti Sleep en segundo plano..." -ForegroundColor Cyan

    # Comando de PowerShell que se ejecuta de fondo e invoca SetThreadExecutionState para bloquear la suspensión (pantalla y sistema)
    $psCommand = "`$code = '[DllImport(\`"kernel32.dll\`")] public static extern uint SetThreadExecutionState(uint esFlags);'; `$type = Add-Type -MemberDefinition `$code -Name 'Win32' -Namespace 'System' -PassThru; while (`$true) { `$type::SetThreadExecutionState(0x80000003); Start-Sleep -Seconds 60 }"
    
    # Lanzar el proceso de fondo de manera oculta
    Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command `"$psCommand`"" -WindowStyle Hidden

    Start-Sleep -Seconds 2
    if (Get-AntiSleepStatus) {
        Write-Host "[OK] Anti Sleep activado exitosamente." -ForegroundColor Green
    } else {
        Write-Host "[!] Error al iniciar el servicio Anti Sleep." -ForegroundColor Red
    }
}

function Disable-AntiSleep {
    if (-not (Get-AntiSleepStatus)) {
        Write-Host "[!] El servicio Anti Sleep no esta activo." -ForegroundColor Yellow
        return
    }

    Write-Host "[i] Deteniendo instancias de Anti Sleep..." -ForegroundColor Cyan
    $processes = Get-CimInstance -ClassName Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%SetThreadExecutionState%'" -ErrorAction SilentlyContinue
    
    if ($processes) {
        foreach ($proc in $processes) {
            Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Write-Host "[OK] Anti Sleep desactivado. Configuracion de energia restaurada." -ForegroundColor Green
    } else {
        Write-Host "[!] No se pudieron detener los procesos." -ForegroundColor Red
    }
}

# Bucle del Menú
do {
    Show-Header
    $isActive = Get-AntiSleepStatus
    if ($isActive) {
        Write-Host " ESTADO ACTUAL: " -NoNewline
        Write-Host "ACTIVO (Evitando suspension)" -ForegroundColor Green
    } else {
        Write-Host " ESTADO ACTUAL: " -NoNewline
        Write-Host "INACTIVO" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "  1. Activar Anti Sleep" -ForegroundColor Gray
    Write-Host "  2. Desactivar Anti Sleep" -ForegroundColor Gray
    Write-Host "  0. Salir" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Selecciona una opcion"
    
    switch ($choice) {
        "1" {
            Enable-AntiSleep
            Start-Sleep -Seconds 2
        }
        "2" {
            Disable-AntiSleep
            Start-Sleep -Seconds 2
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
