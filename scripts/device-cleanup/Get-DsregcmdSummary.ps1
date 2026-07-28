<#
.SYNOPSIS
    Parses `dsregcmd /status` into a clean PowerShell object and flags the
    fields that matter most when diagnosing hybrid join / Entra join issues.

.DESCRIPTION
    `dsregcmd /status` dumps a wall of text that's easy to misread under
    pressure. This wraps it into a structured object so you can quickly see
    AzureAdJoined, DomainJoined, device name, and Device ID — the Device ID
    is what you cross-reference against the Entra ID portal to identify
    which object (of possibly several duplicates) corresponds to the live
    machine you're standing in front of.

.NOTES
    Read-only. Does not modify anything.
    TenantId / TenantName are intentionally excluded from output — strip
    them yourself if you add fields, they shouldn't end up in shared logs.

.EXAMPLE
    .\Get-DsregcmdSummary.ps1
#>

$raw = dsregcmd /status

function Get-Value($pattern) {
    ($raw | Select-String $pattern) -replace '.*:\s*', '' | Select-Object -First 1
}

$summary = [PSCustomObject]@{
    DeviceName      = $env:COMPUTERNAME
    AzureAdJoined   = Get-Value 'AzureAdJoined\s*:'
    DomainJoined    = Get-Value 'DomainJoined\s*:'
    DeviceId        = Get-Value 'DeviceId\s*:'
    HostNameUpdated = Get-Value 'HostNameUpdated\s*:'
    KeyProviderId   = Get-Value 'KeyProviderID\s*:'
}

$summary | Format-List

Write-Host "`nUse 'DeviceId' above to cross-reference against Entra ID > Devices" -ForegroundColor Cyan
Write-Host "when multiple objects with the same hostname exist." -ForegroundColor Cyan
