# SCCM Site kodu ve sunucu bilgisi
$SiteCode = "GBZ"  # Örn: PR1
$ProviderMachineName = "mecm-ss-01.tbtk.gov.tr"
 
# SCCM modülünü içeri al
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location "$SiteCode`:"
 
# Tüm boundary nesnelerini al
$boundaries = Get-CMBoundary
 
# IP Range ve Subnet tiplerini ayır
$ipBoundaries = $boundaries | Where-Object {
    $_.BoundaryType -eq 0 -or $_.BoundaryType -eq 3
} | Select-Object BoundaryID, DisplayName, BoundaryType, Value
 
# IP adreslerini normalize etmek için fonksiyon
function ConvertTo-IPRange {
    param ($boundary)
 
    if ($boundary.BoundaryType -eq 0) {
        # IP Subnet: Örn 192.168.1.0/24
        $parts = $boundary.Value.Split('/')
        $baseIP = [System.Net.IPAddress]::Parse($parts[0]).GetAddressBytes()
        $cidr = [int]$parts[1]
 
        $ipInt = [BitConverter]::ToUInt32([byte[]]($baseIP[3], $baseIP[2], $baseIP[1], $baseIP[0]), 0)
        $mask = [math]::Pow(2, 32) - [math]::Pow(2, 32 - $cidr)
        $startIP = $ipInt -band [uint32]$mask
        $endIP = $startIP + ([uint32][math]::Pow(2, 32 - $cidr)) - 1
 
        return @{ Start = $startIP; End = $endIP }
    }
    elseif ($boundary.BoundaryType -eq 3) {
        # IP Range: Örn 192.168.1.1-192.168.1.100
        $rangeParts = $boundary.Value -split "-"
        $startBytes = [System.Net.IPAddress]::Parse($rangeParts[0]).GetAddressBytes()
        $endBytes = [System.Net.IPAddress]::Parse($rangeParts[1]).GetAddressBytes()
 
        $startInt = [BitConverter]::ToUInt32([byte[]]($startBytes[3], $startBytes[2], $startBytes[1], $startBytes[0]), 0)
        $endInt = [BitConverter]::ToUInt32([byte[]]($endBytes[3], $endBytes[2], $endBytes[1], $endBytes[0]), 0)
 
        return @{ Start = $startInt; End = $endInt }
    }
    return $null
}
 
# Çakışmaları kontrol et
for ($i = 0; $i -lt $ipBoundaries.Count; $i++) {
    $range1 = ConvertTo-IPRange $ipBoundaries[$i]
    for ($j = $i + 1; $j -lt $ipBoundaries.Count; $j++) {
        $range2 = ConvertTo-IPRange $ipBoundaries[$j]
 
        if (($range1.Start -le $range2.End) -and ($range1.End -ge $range2.Start)) {
            Write-Host "Overlap detected between '$($ipBoundaries[$i].DisplayName)' and '$($ipBoundaries[$j].DisplayName)'" -ForegroundColor Yellow
            Write-Host "  → $($ipBoundaries[$i].Value) ↔ $($ipBoundaries[$j].Value)"
        }
    }
}
 
