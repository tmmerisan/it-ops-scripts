# IT Ops Scripts

A small collection of PowerShell scripts for diagnosing and fixing common
Windows device management problems: MDM enrollment, hybrid Azure AD join,
device cleanup, and endpoint security checks.

Built out of real troubleshooting sessions, generalized and stripped of
anything environment-specific (tenant IDs, device names, user info, org
names) so they're safe to run and reuse anywhere.

## ⚠️ Before you run anything

- **Read the script first.** Know what it does before you run it as Admin.
- Scripts are labeled **read-only / diagnostic** or **destructive** in
  their own docstring. Diagnostic scripts never delete or modify state.
  Destructive scripts always require explicit confirmation and are
  documented accordingly.
- These are general-purpose troubleshooting aids, not a replacement for
  your own change-management process. Test in a non-production device
  first if you're not sure.

## Structure

```
scripts/
  mdm-enrollment/     Intune / MDM enrollment diagnostics and cleanup
  hybrid-join/         Azure AD hybrid join troubleshooting (dsregcmd, PRT, SELF ACEs)
  device-cleanup/       Duplicate Entra/Intune object cleanup helpers
  security/             Endpoint security / compliance checks
```

Each folder has its own README describing what each script does, when to
use it, and what it does *not* do.

## Contributing

PRs welcome. If you contribute a script, please:
1. Keep it generic — no hardcoded org names, tenant IDs, or internal URLs.
2. Add a docstring header (`.SYNOPSIS`, `.DESCRIPTION`, `.NOTES`).
3. Clearly mark whether the script is read-only or destructive.
4. Update the relevant folder README.

## License

MIT — see [LICENSE](LICENSE).
