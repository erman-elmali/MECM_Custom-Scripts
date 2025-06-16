Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx |
Select-Object CacheId, ContentID, ContentSize, ContentComplete, Location


# Get all cache entries
$cacheEntries = Get-WmiObject -Namespace "root\ccm\SoftMgmtAgent" -Class CacheInfoEx

# Loop through and delete each one
foreach ($entry in $cacheEntries) {
    try {
        Write-Host "Deleting ContentID: $($entry.ContentID)" -ForegroundColor Yellow
        $entry.Delete()
    } catch {
        Write-Host "Failed to delete $($entry.ContentID): $_" -ForegroundColor Red
    }
}
