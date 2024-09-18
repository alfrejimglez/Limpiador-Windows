function Get-DirectorySize {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        return (Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    } else {
        return 0
    }
}

function Format-Size {
    param (
        [int64]$Bytes
    )
    switch ($Bytes) {
        {$_ -gt 1GB} { "{0:N2} GB" -f ($Bytes / 1GB); break }
        {$_ -gt 1MB} { "{0:N2} MB" -f ($Bytes / 1MB); break }
        {$_ -gt 1KB} { "{0:N2} KB" -f ($Bytes / 1KB); break }
        default { "$Bytes Bytes" }
    }
}

$totalSizeBefore = 0
$totalSizeAfter = 0

# Limpia archivos temporales del sistema
Write-Host "Limpiando archivos temporales del sistema..."
$tempSizeBefore = Get-DirectorySize -Path "$env:temp\"
$totalSizeBefore += $tempSizeBefore
Write-Host "Tamaño antes: $(Format-Size $tempSizeBefore)"
Remove-Item -Path "$env:temp\*" -Recurse -Force -ErrorAction SilentlyContinue
$tempSizeAfter = Get-DirectorySize -Path "$env:temp\"
$totalSizeAfter += $tempSizeAfter
Write-Host "Tamaño después: $(Format-Size $tempSizeAfter)"

# Limpia archivos de la carpeta "Temp" de Windows
$winTempSizeBefore = Get-DirectorySize -Path "C:\Windows\Temp\"
$totalSizeBefore += $winTempSizeBefore
Write-Host "Tamaño de 'C:\Windows\Temp' antes: $(Format-Size $winTempSizeBefore)"
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
$winTempSizeAfter = Get-DirectorySize -Path "C:\Windows\Temp\"
$totalSizeAfter += $winTempSizeAfter
Write-Host "Tamaño de 'C:\Windows\Temp' después: $(Format-Size $winTempSizeAfter)"

# Limpia archivos de la carpeta "Prefetch"
Write-Host "Limpiando archivos de la carpeta 'Prefetch'..."
$prefetchSizeBefore = Get-DirectorySize -Path "C:\Windows\Prefetch\"
$totalSizeBefore += $prefetchSizeBefore
Write-Host "Tamaño antes: $(Format-Size $prefetchSizeBefore)"
Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
$prefetchSizeAfter = Get-DirectorySize -Path "C:\Windows\Prefetch\"
$totalSizeAfter += $prefetchSizeAfter
Write-Host "Tamaño después: $(Format-Size $prefetchSizeAfter)"

# Limpia la caché de navegadores (Google Chrome y Opera)
Write-Host "Limpiando caché de Google Chrome..."
$chromeCache = "$env:localappdata\Google\Chrome\User Data\Default\Cache"
$chromeCacheSizeBefore = Get-DirectorySize -Path $chromeCache
$totalSizeBefore += $chromeCacheSizeBefore
Write-Host "Tamaño de caché de Chrome antes: $(Format-Size $chromeCacheSizeBefore)"
if (Test-Path $chromeCache) {
    Remove-Item -Path "$chromeCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}
$chromeCacheSizeAfter = Get-DirectorySize -Path $chromeCache
$totalSizeAfter += $chromeCacheSizeAfter
Write-Host "Tamaño de caché de Chrome después: $(Format-Size $chromeCacheSizeAfter)"

Write-Host "Limpiando caché de Opera..."
$operaCache = "$env:localappdata\Opera Software\Opera Stable\Cache"
$operaCacheSizeBefore = Get-DirectorySize -Path $operaCache
$totalSizeBefore += $operaCacheSizeBefore
Write-Host "Tamaño de caché de Opera antes: $(Format-Size $operaCacheSizeBefore)"
if (Test-Path $operaCache) {
    Remove-Item -Path "$operaCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}
$operaCacheSizeAfter = Get-DirectorySize -Path $operaCache
$totalSizeAfter += $operaCacheSizeAfter
Write-Host "Tamaño de caché de Opera después: $(Format-Size $operaCacheSizeAfter)"

# Limpia la papelera de reciclaje
Write-Host "Vaciando la papelera de reciclaje..."
$recycleBinSizeBefore = Get-DirectorySize -Path "$env:Recycle.Bin"
$totalSizeBefore += $recycleBinSizeBefore
Write-Host "Tamaño de la papelera de reciclaje antes: $(Format-Size $recycleBinSizeBefore)"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
$recycleBinSizeAfter = Get-DirectorySize -Path "$env:Recycle.Bin"
$totalSizeAfter += $recycleBinSizeAfter
Write-Host "Tamaño de la papelera de reciclaje después: $(Format-Size $recycleBinSizeAfter)"

# Reporte final
$totalFreed = $totalSizeBefore - $totalSizeAfter
Write-Host "Tamaño total liberado: $(Format-Size $totalFreed)"
