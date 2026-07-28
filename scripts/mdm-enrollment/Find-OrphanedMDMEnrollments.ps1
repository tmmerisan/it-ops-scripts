<#
.SYNOPSIS
    Lists MDM enrollment records under HKLM:\SOFTWARE\Microsoft\Enrollments
    that carry a real ProviderID, filtering out unrelated registry noise
    (Workplace Join, cert subsystems, Defender components, etc).

.DESCRIPTION
    Windows devices that have gone through repeated failed enrollment /
    re-enrollment attempts (Intune, Autopilot, hybrid join) can accumulate
    dozens of leftover GUID keys under the Enrollments registry hive.
    Most of these are not real MDM enrollments and can be safely ignored.

    This script filters that noise down to only the entries that have a
    ProviderID set (e.g. "MS DM Server" for Intune, or a third-party MDM
    name), which are the actual candidates worth investigating before any
    cleanup or deletion.

.NOTES
    Read-only / diagnostic script. It does NOT delete or modify anything.
    Run as Administrator.

.EXAMPLE
    .\Find-OrphanedMDMEnrollments.ps1
#>

Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Enrollments" | ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    [PSCustomObject]@{
        GUID            = $_.PSChildName
        ProviderID      = $props.ProviderID
        UPN             = $props.UPN
        EnrollmentState = $props.EnrollmentState
    }
} | Where-Object { $_.ProviderID -ne $null } | Format-Table -AutoSize
