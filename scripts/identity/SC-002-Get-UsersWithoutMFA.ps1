<#
.SYNOPSIS
    Lists all enabled users with no MFA methods registered in Microsoft Entra ID.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves all enabled users.
    For each user, checks registered authentication methods.
    Users with only "password" as their method (no MFA) are exported to CSV.

.REQUIREMENTS
    Module: Microsoft.Graph
    Install: Install-Module Microsoft.Graph -Scope CurrentUser
    Permissions: UserAuthenticationMethod.Read.All, User.Read.All

.NOTES
    Author: Tony Merisan
    Blog:   https://tonymerisan.com
    Repo:   https://github.com/tmmerisan/it-ops-scripts
#>

Connect-MgGraph -Scopes "UserAuthenticationMethod.Read.All", "User.Read.All"

$OutputPath = "C:\Temp\UsersWithoutMFA_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

if (-not (Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
}

Write-Host "Retrieving enabled users..." -ForegroundColor Cyan

$users = Get-MgUser -Filter "accountEnabled eq true" -All -Property "Id,DisplayName,UserPrincipalName,AccountEnabled"

Write-Host "Found $($users.Count) enabled users. Checking MFA methods..." -ForegroundColor Cyan

$results = @()
$counter = 0

foreach ($user in $users) {
    $counter++
    Write-Progress -Activity "Checking MFA methods" -Status "$counter of $($users.Count): $($user.UserPrincipalName)" -PercentComplete (($counter / $users.Count) * 100)

    try {
        $methods = Get-MgUserAuthenticationMethod -UserId $user.Id

        $mfaMethods = $methods | Where-Object {
            $_.AdditionalProperties["@odata.type"] -ne "#microsoft.graph.passwordAuthenticationMethod"
        }

        if (-not $mfaMethods) {
            $results += [PSCustomObject]@{
                DisplayName       = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                AccountEnabled    = $user.AccountEnabled
                MFAMethodCount    = 0
                MFAMethods        = "None"
            }
        }
    }
    catch {
        Write-Warning "Could not retrieve methods for $($user.UserPrincipalName): $_"
    }
}

Write-Progress -Completed -Activity "Done"

if ($results) {
    $results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "`nUsers without MFA: $($results.Count)" -ForegroundColor Yellow
    Write-Host "Exported to: $OutputPath" -ForegroundColor Green
    $results | Format-Table -AutoSize
} else {
    Write-Host "`nAll enabled users have MFA methods registered." -ForegroundColor Green
}

Disconnect-MgGraph
