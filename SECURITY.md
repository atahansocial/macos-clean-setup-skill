# Security & Safety Policy

## Reporting Unsafe Scripts or macOS Breakage

`macos-clean-setup` interacts with `launchd`, `defaults`, `pmset`, and `socketfilterfw`. Because unsafe system rules can break core macOS functionality (such as Spotlight, Keychain, iCloud, or sleep/wake), we treat safety regressions as high-priority issues.

If you discover:
- A `LaunchAgent` or `LaunchDaemon` rule that breaks core macOS behavior on a specific macOS release,
- An elevation/`sudo` command with unintended side effects, or
- Any potential security issue in the scripts or skill instructions,

please **do not** ignore it—open a GitHub issue with:
1. Your macOS version (`sw_vers`) and hardware (`sysctl -n machdep.cpu.brand_string`)
2. The exact command or line in `scripts/` or `references/playbooks.md`
3. Observed symptoms and how to reproduce or revert them.
