# MDM Enrollment Scripts

Scripts for diagnosing Windows MDM enrollment state, mainly useful when a
device shows conflicting or duplicate enrollment errors (e.g. "this device
is managed by another organization") after a reprovisioning, re-enrollment,
or hybrid join attempt.

## Scripts

### `Find-OrphanedMDMEnrollments.ps1`
Read-only diagnostic. Lists registry entries under
`HKLM:\SOFTWARE\Microsoft\Enrollments` that have a `ProviderID` set,
filtering out unrelated noise (Workplace Join, certs, Defender, etc).
Run this **before** deciding what to clean up manually — never delete
enrollment keys blindly, a wrong deletion can leave a device unmanaged
or break MDM services.

**Usage:**
```powershell
# Run PowerShell as Administrator
.\Find-OrphanedMDMEnrollments.ps1
```

**Output:** a table with GUID, ProviderID, UPN, and EnrollmentState for
each real candidate enrollment.

## Related reading
- [Microsoft: MDM enrollment troubleshooting](https://learn.microsoft.com/en-us/mem/intune/enrollment/troubleshoot-device-enrollment-in-intune)
