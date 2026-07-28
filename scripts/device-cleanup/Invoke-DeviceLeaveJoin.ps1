<#
.SYNOPSIS
    Safely runs `dsregcmd /leave` as the local reset step of a device
    re-enrollment, with an explicit confirmation prompt.

.DESCRIPTION
    Part of a standard re-enrollment workflow:
      1. Delete the stale device object from Intune
      2. Delete the stale device object from Entra ID
      3. Run this script (dsregcmd /leave) on the physical device
      4. Reboot
      5. Rejoin domain / trigger delta sync if on-prem AD is in play
      6. Re-enroll via Company Portal

    This script only performs step 3. Steps 1-2 must be done first in the
    Intune/Entra admin portals — running this before cleaning up the cloud
    side just recreates the same conflict.

    On hybrid-joined devices, `dsregcmd /leave` can also remove the on-prem
    domain join as a side effect in some configurations — have domain admin
    credentials on hand in case a manual rejoin via sysdm.cpl is needed
    afterward.

.NOTES
    DESTRUCTIVE. Requires explicit confirmation. Run as Administrator.

.EXAMPLE
    .\Invoke-DeviceLeaveJoin.ps1
#>

Write-Warning "This will remove the device's Azure AD / Workplace join state."
Write-Warning "Make sure you have ALREADY deleted the stale objects from Intune and Entra ID first."
$confirm = Read-Host "Type YES to continue"

if ($confirm -ne 'YES') {
    Write-Host "Aborted. No changes made." -ForegroundColor Yellow
    return
}

dsregcmd /leave

Write-Host "`nDone. Next steps:" -ForegroundColor Green
Write-Host "  1. Reboot the device" -ForegroundColor Green
Write-Host "  2. If domain join was also dropped, rejoin manually via sysdm.cpl" -ForegroundColor Green
Write-Host "  3. Confirm with: dsregcmd /status" -ForegroundColor Green
Write-Host "  4. Re-enroll via Company Portal" -ForegroundColor Green
