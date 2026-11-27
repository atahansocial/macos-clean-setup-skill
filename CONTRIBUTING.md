# Contributing to `macos-clean-setup`

Thank you for helping make `macos-clean-setup` safer, cleaner, and more useful for Apple Silicon and Intel Mac users!

## Core Rules for Contributions

1. **SIP-Safe Always:** Never propose rules or scripts that require disabling System Integrity Protection (`csrutil disable`) or modifying `/System/` read-only volumes.
2. **Read-Only First:** Any new discovery or diagnostic checks belong in `scripts/audit_*.sh` and must never modify system state.
3. **Always Provide Revert Steps:** Every new `launchctl disable`, `defaults write`, or `pmset` rule added to `scripts/optimize.sh`, `scripts/system-optimize.sh`, or `references/playbooks.md` must have a matching revert path in `scripts/revert.sh` or `references/playbooks.md`.
4. **100% Open-Source Recommendations:** Only recommend open-source tools (MIT, GPL, Apache, BSD, etc.) in the default stack.
5. **Zero Personal Data:** Never commit hardcoded usernames, machine serials, API keys, DNS IDs, or personal paths (always use `$HOME`, `$(id -u)`, etc.).

## How to Submit Changes

1. Fork the repository and create a feature branch from `main`.
2. Test syntax and permissions locally on macOS:
   ```bash
   chmod +x scripts/*.sh
   zsh -n scripts/*.sh
   ./scripts/audit_system.sh
   ./scripts/audit_disk.sh
   ./scripts/audit_services.sh
   ```
3. Open a Pull Request describing what macOS version/chip you tested on and any trade-offs.
