# Device Cleanup Scripts

Helpers for cleaning up duplicate Entra ID / Intune device objects, orphaned
Autopilot registrations, and safe re-enrollment workflows.

## Scripts

### `Get-DsregcmdSummary.ps1` — read-only
Parses `dsregcmd /status` into a clean object (AzureAdJoined, DomainJoined,
DeviceId, HostNameUpdated). The `DeviceId` is what you cross-reference
against Entra ID > Devices when a hostname has multiple duplicate objects,
so you know which one is the actual live machine before deleting anything.

### `Start-IntuneSync.ps1` — non-destructive
Triggers the `PushLaunch` scheduled task — same as clicking "Sync" in
Company Portal. Handy after making changes on the Entra/Intune side
(group membership, app/profile assignment) when you don't want to wait
for the background schedule.

### `Invoke-DeviceLeaveJoin.ps1` — **destructive, requires confirmation**
Runs `dsregcmd /leave` as the local reset step of a re-enrollment. This is
step 3 of the standard workflow:
1. Delete stale object from **Intune**
2. Delete stale object from **Entra ID**
3. Run this script locally on the device
4. Reboot
5. Rejoin domain if needed (on hybrid setups, `/leave` can also drop the
   on-prem domain join — have domain admin creds ready)
6. Re-enroll via Company Portal

Always do steps 1-2 in the portals **before** running this script — running
it first just recreates the same conflict.

## Common gotchas
- Autopilot-registered device objects **cannot** be deleted directly from
  the Entra admin center — remove from Intune > Autopilot devices first.
- "Connect" under Settings > Accounts > Access work or school always
  creates a **registered** (BYOD-style) object, never a proper hybrid join.
  Hybrid join happens via the Automatic-Device-Join scheduled task or
  `dsregcmd`.
- Deletion order to avoid orphaned records: **Intune first, then Entra ID**,
  never the reverse.
