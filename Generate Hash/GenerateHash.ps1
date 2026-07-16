<#
.SYNOPSIS
    VikTools CLI - Generate Hash Utility
.DESCRIPTION
    Calcula checksums de archivos (MD5, SHA-1, SHA-256) y permite la extracción del Hardware Hash
    de Windows Autopilot / Intune en formato CSV.
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
    Write-Host "        VIKTOOLS CLI - GENERATE HASH          " -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " Calcula firmas de archivos e informacion WMI."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-FileHashes {
    Write-Host ""
    $filePath = Read-Host "Arrastra el archivo aqui o ingresa su ruta"
    $filePath = $filePath -replace '"', ''

    if (-not (Test-Path -Path $filePath -PathType Leaf)) {
        Write-Host "[!] Archivo no encontrado." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return
    }

    Write-Host ""
    Write-Host "[i] Calculando hashes..." -ForegroundColor Cyan
    
    try {
        $md5 = (Get-FileHash -Path $filePath -Algorithm MD5).Hash
        $sha1 = (Get-FileHash -Path $filePath -Algorithm SHA1).Hash
        $sha256 = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash

        Write-Host "MD5:    " -NoNewline -ForegroundColor Yellow; Write-Host $md5
        Write-Host "SHA1:   " -NoNewline -ForegroundColor Yellow; Write-Host $sha1
        Write-Host "SHA256: " -NoNewline -ForegroundColor Yellow; Write-Host $sha256
    } catch {
        Write-Host "[!] Error al calcular los hashes: $_" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

function Export-HardwareHash {
    if (-not (Test-IsAdmin)) {
        Write-Host ""
        Write-Host "[i] Elevando privilegios para leer datos de Hardware Hash de Windows Autopilot..." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        # Re-lanzar el script como administrador enfocado en esta funcion
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        return
    }

    Write-Host ""
    Write-Host "[i] Extrayendo Hardware Hash (WMI Nativo)..." -ForegroundColor Cyan

    try {
        $devDetail = Get-CimInstance -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'" -ErrorAction Stop
        $serial = (Get-CimInstance -Class Win32_BIOS).SerialNumber
        $product = (Get-CimInstance -Class Win32_OperatingSystem).SerialNumber
        
        $desktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'HardwareHash.csv')
        
        # Generar CSV estructurado
        "Device Serial Number,Windows Product ID,Hardware Hash" | Out-File -FilePath $desktopPath -Encoding utf8
        "$serial,$product,$($devDetail.DeviceHardwareData)" | Out-File -FilePath $desktopPath -Encoding utf8 -Append
        
        Write-Host ""
        Write-Host "[OK] CSV generado exitosamente en el Escritorio:" -ForegroundColor Green
        Write-Host "     $desktopPath" -ForegroundColor Cyan
    } catch {
        Write-Host ""
        Write-Host "[!] Error al extraer el Hardware Hash: $_" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    [void][System.Console]::ReadKey($true)
}

# Bucle del Menú
do {
    Show-Header
    Write-Host "  1. Calcular hashes de un archivo (MD5, SHA1, SHA256)" -ForegroundColor Gray
    Write-Host "  2. Extraer Hardware Hash (Autopilot/Intune CSV)" -ForegroundColor Gray
    Write-Host "  0. Salir" -ForegroundColor Gray
    Write-Host ""
    
    $choice = Read-Host "Selecciona una opcion"
    
    switch ($choice) {
        "1" {
            Get-FileHashes
        }
        "2" {
            Export-HardwareHash
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
