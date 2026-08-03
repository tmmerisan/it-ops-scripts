<#
.SYNOPSIS
    Retrieves BitLocker recovery keys for the local machine via the
    BitLocker PowerShell module.

.DESCRIPTION
    Lists BitLocker recovery passwords for all protected volumes on the
    device. By default, output goes to the console only.

.PARAMETER ExportToFile
    Optional switch. If set, also writes the output to a text file.
    Off by default on purpose — recovery keys are sensitive and a leftover
    plaintext file on disk is a real audit finding waiting to happen.

.PARAMETER OutputPath
    Where to write the file when -ExportToFile is used. Defaults to the
    current user's Desktop rather than C:\Temp (avoids leaving keys in a
    shared/world-writable location on multi-user machines).

.NOTES
    Read-only against BitLocker state (does not change protection status).
    Treat the output as sensitive: recovery keys grant access to encrypted
    data. If you export to a file, delete it as soon as you're done with it,
    and never commit it, email it unencrypted, or leave it in a shared folder.
    In an Entra-joined/hybrid environment, recovery keys are normally already
    escrowed to Entra ID / AD — this script is for cases where you need them
    locally (offline recovery, verifying escrow worked) rather than as your
    primary source of truth.

.EXAMPLE
    .\Get-BitLockerRecoveryKeys.ps1

.EXAMPLE
    .\Get-BitLockerRecoveryKeys.ps1 -ExportToFile
#>

param(
    [switch]$ExportToFile,
    [string]$OutputPath = "$env:USERPROFILE\Desktop\BitLockerKeys_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
)

if (-not (Get-Module -Name BitLocker -ListAvailable)) {
    Write-Error "BitLocker module not available on this system."
    return
}
Import-Module BitLocker -ErrorAction SilentlyContinue

if (-not (Get-Command -Name Get-BitLockerVolume -ErrorAction SilentlyContinue)) {
    Write-Error "Get-BitLockerVolume not available. Are you running this with sufficient privileges?"
    return
}

$volumes = Get-BitLockerVolume | Where-Object { $_.ProtectionStatus -eq 'On' }

if (-not $volumes) {
    Write-Warning "No volumes with BitLocker protection enabled were found."
    return
}

$results = foreach ($vol in $volumes) {
    $protectors = $vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
    foreach ($prot in $protectors) {
        [PSCustomObject]@{
            MountPoint       = $vol.MountPoint
            KeyProtectorId   = $prot.KeyProtectorId
            RecoveryPassword = $prot.RecoveryPassword
        }
    }
}

if (-not $results) {
    Write-Warning "BitLocker is on, but no RecoveryPassword protectors were found on these volumes."
    return
}

$results | Format-Table -AutoSize

if ($ExportToFile) {
    $results | Format-Table -AutoSize | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "`nExported to: $OutputPath" -ForegroundColor Yellow
    Write-Host "Remember: delete this file once you no longer need it." -ForegroundColor Yellow
}
