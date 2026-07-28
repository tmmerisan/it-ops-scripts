<#
.SYNOPSIS
    Forces an immediate Intune MDM policy/sync cycle instead of waiting for
    the default background schedule.

.DESCRIPTION
    Triggers the same scheduled task Company Portal's "Sync" button kicks
    off. Useful after making Entra/Intune-side changes (group membership,
    Autopilot profile assignment, app assignment) when you don't want to
    wait for the client to pick it up on its own schedule.

.NOTES
    Non-destructive. Only requests a sync — does not change device state.
    Requires the Intune Management Extension / MDM client to already be
    enrolled on the device.

.EXAMPLE
    .\Start-IntuneSync.ps1
#>

$task = Get-ScheduledTask | Where-Object { $_.TaskName -eq 'PushLaunch' }

if (-not $task) {
    Write-Warning "PushLaunch scheduled task not found. Device may not be MDM-enrolled."
    return
}

Start-ScheduledTask -InputObject $task
Write-Host "Intune sync triggered. Check Company Portal or Event Viewer" -ForegroundColor Green
Write-Host "(Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin) for progress." -ForegroundColor Green
