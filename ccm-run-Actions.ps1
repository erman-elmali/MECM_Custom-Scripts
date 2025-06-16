cls

# Friendly name ↔ Schedule GUID haritası
$SCCMActions = @{
    "Machine Policy Assignments Request"             = "{00000000-0000-0000-0000-000000000021}"
    "Machine Policy Evaluation"                      = "{00000000-0000-0000-0000-000000000022}"
    "Discovery Data Collection Record"               = "{00000000-0000-0000-0000-000000000003}"
    "Hardware Inventory"                             = "{00000000-0000-0000-0000-000000000001}"
    "Software Inventory"                             = "{00000000-0000-0000-0000-000000000002}"
    "File Collection"                                = "{00000000-0000-0000-0000-000000000010}"
    "IDMIF Collection"                               = "{00000000-0000-0000-0000-000000000011}"
    "Client Auth"                                    = "{00000000-0000-0000-0000-000000000012}"
    "Software Metering Usage Report"                 = "{00000000-0000-0000-0000-000000000031}"
    "User Policy Evaluate Assignment"                = "{00000000-0000-0000-0000-000000000027}"
    "Source Update Message"                          = "{00000000-0000-0000-0000-000000000032}"
    "Clear Proxy Settings Cache"                     = "{00000000-0000-0000-0000-000000000037}"
    "Policy Agent Cleanup (Machine)"                 = "{00000000-0000-0000-0000-000000000040}"
    "Policy Agent Cleanup (User)"                    = "{00000000-0000-0000-0000-000000000041}"
    "Validate Machine Policy/Assignment"             = "{00000000-0000-0000-0000-000000000042}"
    "Validate User Policy/Assignment"                = "{00000000-0000-0000-0000-000000000043}"
    "Peer DP Status Reporting"                       = "{00000000-0000-0000-0000-000000000061}"
    "Peer DP Pending Package Check"                  = "{00000000-0000-0000-0000-000000000062}"
    "SUM Updates Install Schedule"                   = "{00000000-0000-0000-0000-000000000063}"
    "Hardware Inventory Cycle"                       = "{00000000-0000-0000-0000-000000000101}"
    "Software Inventory Cycle"                       = "{00000000-0000-0000-0000-000000000102}"
    "Discovery Data Collection Cycle"                = "{00000000-0000-0000-0000-000000000103}"
    "File Collection Cycle"                          = "{00000000-0000-0000-0000-000000000104}"
    "IDMIF Collection Cycle"                         = "{00000000-0000-0000-0000-000000000105}"
    "Software Metering Usage Report Cycle"           = "{00000000-0000-0000-0000-000000000106}"
    "Windows Installer Source List Update Cycle"     = "{00000000-0000-0000-0000-000000000107}"
    "Software Updates Deployment Evaluation"         = "{00000000-0000-0000-0000-000000000108}"
    "Software Updates Scan Cycle"                    = "{00000000-0000-0000-0000-000000000113}"
}

$SuccessList = @()
$FailureList = @()

Write-Host "`n--- TriggerSchedule Script Starting ---`n" -ForegroundColor Cyan

foreach ($kv in $SCCMActions.GetEnumerator()) {
    $name = $kv.Key
    $guid = $kv.Value
    Write-Host "⏳ Triggering: $name ($guid)..."

    try {
        # trigger metodu çalıştırılıyor
        Invoke-WmiMethod -Namespace root\ccm -Class SMS_Client -Name TriggerSchedule -ArgumentList $guid -ErrorAction Stop | Out-Null
        Write-Host "✅ Success: $name" -ForegroundColor Green
        $SuccessList += $name
    } catch {
        Write-Warning "❌ Failed: $name - $($_.Exception.Message)"
        $FailureList += $name
    }
}

# Özet
Write-Host "`n=== ✅ Başarılı Olanlar ===" -ForegroundColor Green
$SuccessList | ForEach-Object { Write-Host " - $_" }

Write-Host "`n=== ❌ Başarısız Olanlar ===" -ForegroundColor Red
$FailureList | ForEach-Object { Write-Host " - $_" }

Write-Host "`n--- İşlem Tamamlandı ---`n" -ForegroundColor Cyan
