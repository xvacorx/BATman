<#
.SYNOPSIS
    VikTools CLI - Ping Check Utility
.DESCRIPTION
    Audita una lista de direcciones IP o Hostnames, verificando si estan activos.
    Resuelve el Hostname mediante DNS y la direccion MAC mediante la tabla ARP local.
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
    Write-Host "         VIKTOOLS CLI - PING CHECK            " -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host " Audita y mapea IPs activas en la red local."
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

$inputFile = "ips.txt"
$resultFile = "result.txt"

Show-Header

# Si no existe el archivo de entrada, permitir al usuario crearlo interactivamente
if (-not (Test-Path -Path $inputFile)) {
    Write-Host "[!] No se encontro el archivo '$inputFile' en el directorio actual." -ForegroundColor Yellow
    Write-Host "  1. Crear archivo '$inputFile' e ingresar IPs interactivamente" -ForegroundColor Gray
    Write-Host "  0. Salir" -ForegroundColor Gray
    Write-Host ""
    
    $opt = Read-Host "Selecciona una opcion"
    if ($opt -eq "1") {
        Write-Host ""
        Write-Host "Ingresa las IPs o Hostnames uno a uno. Deja la linea vacia y presiona Enter para finalizar:" -ForegroundColor Cyan
        $ipsList = @()
        do {
            $ipInput = Read-Host "IP / Hostname"
            if (-not [string]::IsNullOrWhiteSpace($ipInput)) {
                $ipsList += $ipInput.Trim()
            }
        } while (-not [string]::IsNullOrWhiteSpace($ipInput))

        if ($ipsList.Count -eq 0) {
            Write-Host "[!] No se ingresaron IPs. Cancelando..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            exit 1
        }
        $ipsList | Out-File -FilePath $inputFile -Encoding utf8
        Write-Host "[OK] Archivo '$inputFile' guardado con $($ipsList.Count) elementos." -ForegroundColor Green
        Start-Sleep -Seconds 1
        Show-Header
    } else {
        exit 0
    }
}

$ips = Get-Content -Path $inputFile | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

if ($ips.Count -eq 0) {
    Write-Host "[!] El archivo '$inputFile' esta vacio." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host "[i] Iniciando auditoria para $($ips.Count) hosts..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
"--------------------------------------------------------" | Out-File -FilePath $resultFile -Encoding utf8
"Ping Check Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $resultFile -Encoding utf8 -Append
"--------------------------------------------------------" | Out-File -FilePath $resultFile -Encoding utf8 -Append

$activeCount = 0
$failedCount = 0

foreach ($target in $ips) {
    $target = $target.Trim()
    Write-Host "Analizando $target... " -NoNewline -ForegroundColor Gray
    
    # Realizar ping rapido (1 paquete, 800ms de timeout)
    $pingTest = Test-Connection -ComputerName $target -Count 1 -TimeOutMilliSeconds 800 -ErrorAction SilentlyContinue
    
    if ($pingTest) {
        $resolvedIp = $pingTest.IPV4Address.IPAddressToString
        
        # Intentar resolver hostname
        $resolvedHost = ""
        try {
            $resolvedHost = [System.Net.Dns]::GetHostEntry($resolvedIp).HostName
        } catch {
            $resolvedHost = "N/A"
        }
        
        # Obtener direccion MAC mediante tabla ARP
        $macAddress = "N/A"
        $arpOutput = arp -a $resolvedIp 2>$null | Select-String -Pattern $resolvedIp
        if ($arpOutput) {
            $match = [regex]::Match($arpOutput, "([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}")
            if ($match.Success) {
                $macAddress = $match.Value
            }
        }
        
        Write-Host "ONLINE" -ForegroundColor Green
        Write-Host "  -> IP: $resolvedIp | MAC: $macAddress | Host: $resolvedHost" -ForegroundColor DarkGray
        
        "$target [ONLINE] - IP: $resolvedIp - MAC: $macAddress - Host: $resolvedHost" | Out-File -FilePath $resultFile -Encoding utf8 -Append
        $activeCount++
    } else {
        Write-Host "DESCONECTADO" -ForegroundColor Red
        "$target [DESCONECTADO]" | Out-File -FilePath $resultFile -Encoding utf8 -Append
        $failedCount++
    }
}

Write-Host "--------------------------------------------------------" -ForegroundColor Gray
Write-Host "[OK] Analisis completo." -ForegroundColor Green
Write-Host "     Activos: $activeCount | Desconectados: $failedCount" -ForegroundColor Cyan
Write-Host "     Reporte guardado en '$resultFile'" -ForegroundColor Yellow

"--------------------------------------------------------" | Out-File -FilePath $resultFile -Encoding utf8 -Append
"Resumen: Activos: $activeCount | Desconectados: $failedCount" | Out-File -FilePath $resultFile -Encoding utf8 -Append
"--------------------------------------------------------" | Out-File -FilePath $resultFile -Encoding utf8 -Append

Write-Host ""
Write-Host "Presiona cualquier tecla para salir..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
