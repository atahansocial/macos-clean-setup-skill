---
name: macos-clean-setup
description: >-
  Interactive, SIP-safe macOS (Apple Silicon & Intel) system audit, cache cleanup,
  LaunchAgent/daemon de-bloating, telemetry/Siri/AI hardening, pmset power tuning,
  and lightweight open-source app setup. Use when the user asks to clean up,
  debloat, speed up, audit disk space, inspect Activity Monitor/startup bloat,
  or optimize a fresh macOS install.
---

# macos-clean-setup (`v1`)

Interactive, verification-first, **SIP-safe** macOS optimization and cleanup skill.

## Core Execution Rules

1. **Read-Only Baseline First:** Never modify anything during discovery. Always run [audit_system.sh](./scripts/audit_system.sh), [audit_disk.sh](./scripts/audit_disk.sh), and [audit_services.sh](./scripts/audit_services.sh) first to capture OS/hardware state, `memory_pressure`, swap, `pmset` flags, Firewall/Stealth status, disk/cache sizes, and LaunchAgents/Daemons.
2. **Structured, Scannable Report:** Organize Phase 1 findings under these exact 3 numbered sections without duplicating prose paragraphs:
   - **1. System, Performance & Power State** — compact summary table (`OS & Chip`, `CPU & RAM`, `Power & Sleep`, `Security & Firewall`, `UI & Ergonomics` with `[Healthy]` / `[Review]` / `[Action Needed]` tags).
   - **2. Storage & Caches** — clean `Storage Snapshot` table (`Folder / Cache`, `Size`, `Notes`).
   - **3. LaunchAgents, Daemons, Telemetry & Apps** — a **Merged Numbered Action Table** (`#`, `Item`, `Size / RAM`, `What It Does`, `If Disabled / Removed`, `Tag`: `[Safe]` / `[Conditional]` / `[Ecosystem]`), **Already Clean / Protected** as nested bullets, and `"Reply with the numbers to run (e.g., 1, 2)"`.
3. **Wait for Approval & Protect Ecosystem Features:** Never modify anything before the user picks numbered items. Preserve **Spotlight (`Cmd + Space`)**, **iCloud / AirDrop / Handoff**, and **Apple Music / TV / Podcasts** unless the user explicitly asks to disable them.
4. **Execute One by One with Verification:** Run one approved item at a time using [playbooks.md](./references/playbooks.md), verify the post-action state (exit code, disk delta, `launchctl print-disabled`, `defaults read`, `pmset -g`, or `socketfilterfw`), and report before continuing.
5. **Handle `sudo` Cleanly & Never Disable SIP:**
   - Never ask to disable System Integrity Protection (`csrutil`) and never touch `/System/Applications/`.
   - Run user-scoped commands (`defaults write`, `launchctl disable gui/$(id -u)/...`, `brew`) directly.
   - For root-scoped commands (`pmset`, `socketfilterfw`, `system/` daemons, `tmutil deletelocalsnapshots`), never attempt to bypass elevation—provide a self-contained script or exact `sudo` command for the user to run when non-interactive.
6. **Match User Language:** Translate summaries, trade-offs, and prompts naturally into the user's language while keeping exact macOS paths, `launchd` labels, `defaults` keys, and shell commands verbatim.

---

## Phase 1: Read-Only Discovery

Show the 5-step read-only analysis scope briefly and run all three audit scripts without modifying anything:

1. **OS, CPU, RAM & Swap:** macOS version/build, chip, SIP status, `memory_pressure`, and `vm.swapusage`.
2. **Storage, Caches & APFS Snapshots:** Root volume usage, `tmutil` local snapshots, `~/Library/Caches`, `DerivedData`, `CoreSimulator`, `Homebrew`, Chrome cache, and Trash.
3. **Power, Sleep & Security Flags:** `pmset` (`powernap`, `womp`, `proximitywake`, `SleepDisabled`), battery cycle count, Application Firewall + Stealth Mode, and AirDrop discoverability.
4. **LaunchAgents, Daemons & Updaters:** `~/Library/LaunchAgents`, `/Library/LaunchAgents`, `/Library/LaunchDaemons`, and `/Library/PrivilegedHelperTools` (flagging Google Keystone/`GoogleUpdater.wake`, Adobe, Logitech, and orphaned helpers).
5. **Telemetry, Siri/AI, UI & Installed Stack:** Live top RAM consumers, active Apple bloat processes (`Siri AI`, `siriactionsd`, `BiomeAgent`, `generativeexperiencesd`), UI ergonomics (`KeyRepeat`, `CreateDesktop`, `Dock`), and installed Homebrew packages.

```bash
./scripts/audit_system.sh
./scripts/audit_disk.sh
./scripts/audit_services.sh
```

---

## Phase 2: User Selection

Present the 3 numbered sections from Rule 2, clearly calling out trade-offs for `[Conditional]` and `[Ecosystem]` items (Siri, Apple Intelligence, Screen Time, HomeKit, `CreateDesktop`), and wait for the user's selection.

---

## Phase 3: One-by-One Execution & Verification

Execute only approved items from [playbooks.md](./references/playbooks.md) (or `./scripts/optimize.sh` and `./scripts/system-optimize.sh` if the user asks to apply the full preset directly):

1. **Safe Cache & Snapshot Cleanup:** Clear approved caches (`brew cleanup -s`, `DerivedData`, stale `tmutil` snapshots) and report reclaimed space.
2. **SIP-Safe Telemetry, Siri & Apple Intelligence Hardening:** Disable approved `LaunchAgents` across both `gui/$(id -u)` and `user/$(id -u)` domains (macOS 26/27 checks both), set `com.apple.Siri GMSignedUp -bool false`, and disable crash/ad telemetry. Note that already-running SIP-protected processes clear fully on the next reboot.
3. **Third-Party Bloat & Uninstalled App Hygiene:** Unload noisy updaters (Google Keystone / `GoogleUpdater.wake`), remove orphaned app data via `brew uninstall --cask --zap`, and clear stale TCC entries with `tccutil reset All <bundle_id>`.
4. **Power, Sleep & Firewall Hardening (`sudo`):** Apply `pmset -a powernap 0 womp 0 proximitywake 0` and enable macOS Firewall + Stealth Mode.
5. **UI, Finder, Dock & Keyboard Ergonomics:** Speed up window/Dock/Finder animations, enable Finder path/status bars and extensions, prevent `.DS_Store` on USB/SMB volumes, set balanced fast keyboard repeat (`KeyRepeat = 4`, `InitialKeyRepeat = 25`), and optionally hide desktop icons (`CreateDesktop = false`) + clean screenshots (`~/Pictures/Screenshots`).
6. **Lightweight Native Open-Source Stack (Optional):** Disable Homebrew analytics (`brew analytics off`) and install lightweight native FOSS alternatives (`rectangle`, `maccy`, `thaw` for macOS 26/27+, `pearcleaner`, `mole`, `iina`, `keka`, `mos` + `scripts/mos-auto.sh`, `ghostty`).

---

## Phase 4: Final Re-Scan & Baseline Delta

1. Re-run [audit_system.sh](./scripts/audit_system.sh), [audit_disk.sh](./scripts/audit_disk.sh), and [audit_services.sh](./scripts/audit_services.sh) after all approved tasks finish and summarize the delta in two compact tables:
   - **1. Disk & Power** (`Metric` | `Before` | `Now` | `Change`) — `Free Disk Space`, `Cleanable Caches`, `Power Nap / Wake`, `Firewall / Stealth`.
   - **2. System Load** (`Metric` | `Before` | `Now` | `Change`) — `Memory Free %`, `Swap Used`, `Disabled Agents (gui)`, `3rd-Party Updaters`, `Installed Tools`.
2. Conclude with a brief note that macOS point updates and new app installs can reset `GMSignedUp` or `KeyRepeat` or add new `LaunchAgents`, so re-running the read-only audit periodically keeps the setup clean.
