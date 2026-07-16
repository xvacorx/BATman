<#
.SYNOPSIS
    VikTools CLI - Copy to Startup Utility
.DESCRIPTION
    Crea un acceso directo en la carpeta de Inicio de Windows para ejecución automática al iniciar sesión.
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
    Write-Host "       VIKTOOLS CLI - COPY TO STARTUP         " -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " Registra aplicaciones para iniciar con Windows."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

Show-Header

# Comprobar si se pasó un archivo por parámetro (ej. arrastrado al script)
$targetFile = $args[0]

if ([string]::IsNullOrWhiteSpace($targetFile)) {
    Write-Host "Instrucciones: Puedes arrastrar y soltar un archivo aqui o escribir la ruta completa." -ForegroundColor Yellow
    Write-Host ""
    $targetFile = Read-Host "Ingresa la ruta del archivo"
}

# Quitar comillas si existen
$targetFile = $targetFile -replace '"', ''

if (-not (Test-Path -Path $targetFile -PathType Leaf)) {
    Write-Host ""
    Write-Host "[!] Error: El archivo '$targetFile' no existe o no es un archivo valido." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host ""
Write-Host "[i] Procesando archivo: '$targetFile'..." -ForegroundColor Cyan

try {
    $wshell = New-Object -ComObject WScript.Shell
    $startupFolder = [Environment]::GetFolderPath('Startup')
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($targetFile)
    $shortcutPath = Join-Path $startupFolder "$fileName.lnk"
    
    $shortcut = $wshell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetFile
    # Configurar el directorio de trabajo para que resuelva dependencias locales
    $shortcut.WorkingDirectory = [System.IO.Path]::GetDirectoryName($targetFile)
    $shortcut.Save()
    
    if (Test-Path $shortcutPath) {
        Write-Host ""
        Write-Host "[OK] Acceso directo registrado exitosamente en la carpeta de Inicio:" -ForegroundColor Green
        Write-Host "     $shortcutPath" -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "[!] Error: No se pudo verificar la creacion del acceso directo." -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "[!] Error al registrar el acceso directo: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
