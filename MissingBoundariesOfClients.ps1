
# SCCM Site Ayarları
$SiteCode = "GBZ"  # Örnek: PR1
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location "$SiteCode`:"
 
# 1. SCCM'den tanımlı IP Subnet Boundary'leri al
$boundarySubnets = Get-CMBoundary | Where-Object { $_.BoundaryType -eq 0 } | Select-Object -ExpandProperty Value
 
# 2. Cihaz listesini al ve IP adreslerini getir
$devices = Get-CMDevice | Where-Object { $_.IPAddresses -ne $null }
 
function Get-SubnetFromIP {
    param ([string]$ip)
    if ($ip -match "(\d+)\.(\d+)\.(\d+)\.(\d+)") {
        return "$($matches[1]).$($matches[2]).$($matches[3]).0/24"
    }
    return $null
}
 
# 3. Tüm sistemlerin subnet'lerini topla
$usedSubnets = @{}
foreach ($dev in $devices) {
    foreach ($ip in $dev.IPAddresses) {
        $subnet = Get-SubnetFromIP $ip
        if ($subnet -and !$usedSubnets.ContainsKey($subnet)) {
            $usedSubnets[$subnet] = 1
        }
    }
}
 
# 4. Boundary olmayan subnet'leri bul
$missingSubnets = @()
foreach ($subnet in $usedSubnets.Keys) {
    if ($boundarySubnets -notcontains $subnet) {
        $missingSubnets += $subnet
    }
}
 
# 5. Raporlama
if ($missingSubnets.Count -gt 0) {
    Write-Host "The following subnets are in use but NOT defined as SCCM boundaries:" -ForegroundColor Red
    $missingSubnets | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "All used subnets are defined in SCCM boundaries." -ForegroundColor Green
}
 
