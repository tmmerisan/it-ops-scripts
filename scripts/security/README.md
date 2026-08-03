# Security / Compliance Scripts

Endpoint security and compliance checks: Defender status, Conditional Access
sanity checks, BitLocker compliance, etc.

## Scripts

### `Get-BitLockerRecoveryKeys.ps1` — read-only, handles sensitive output
Lists BitLocker recovery passwords for the local machine's protected
volumes. Console output only by default; file export is opt-in via
`-ExportToFile` and writes to the current user's Desktop (not `C:\Temp`,
to avoid leaving keys in a shared location on multi-user machines).

**Handle the output as sensitive.** A recovery key grants access to
encrypted data. If you export to a file, delete it once you're done —
don't leave it sitting around, commit it, or send it unencrypted.

In most Entra-joined/hybrid setups, recovery keys are already escrowed to
Entra ID or AD — this script is for local/offline scenarios or to confirm
escrow worked, not as your primary source of truth for key recovery.
