> [!WARNING]
> **This is a "vibecoded" project.** Most of the code and scripts were written with AI assistance and have not been audited by a professional software engineering team. It is provided **as-is**, with no warranty of any kind. Always inspect the scripts before executing them—especially commands requiring `sudo`—and verify changes against your own macOS setup and backups.

<div align="center">

# macos-clean-setup

[![CI](https://github.com/atahansocial/macos-clean-setup-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/atahansocial/macos-clean-setup-skill/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%20(Apple%20Silicon%20%26%20Intel)-1e293b.svg)](#)
[![Safety](https://img.shields.io/badge/Safety-SIP--Safe%20%C2%B7%20Reversible-0f766e.svg)](#safety-and-scope)

**SIP-safe, verification-first macOS (Apple Silicon & Intel) system audit, telemetry/LaunchAgent de-bloating, power tuning, and open-source setup Agent Skill (`v1`).**

[Features](#features) · [Safety & Scope](#safety-and-scope) · [Architecture](#architecture) · [Installation](#installation) · [Usage](#usage)

</div>

---

## Features

- **Read-Only Discovery First (Zero Blind Edits)**
  - Runs three non-destructive audit scripts (`audit_system.sh`, `audit_disk.sh`, `audit_services.sh`) to capture OS/SIP state, `memory_pressure`, `vm.swapusage`, `pmset` power flags, Firewall/Stealth status, disk/cache sizes (excluding `~/Library/CloudStorage`), and all 4 persistence layers before proposing any change.
  - Groups findings into a numbered impact table (`[Safe]`, `[Conditional]`, `[Ecosystem]`) so you approve exact items one by one rather than running a blind all-in-one script.
- **SIP-Safe `launchd` & Telemetry Hardening (`gui/` + `user/`)**
  - Never disables System Integrity Protection (`csrutil`) and never touches `/System/` read-only volumes.
  - Disables approved Apple analytics, ad tracking (`AdLib`), crash reporters, Game Center, Screen Time, Tips, HomeKit, Siri, and Apple Intelligence (`GMSignedUp = false`) agents across both `gui/$(id -u)` and `user/$(id -u)` domains—while preserving **Spotlight (`Cmd + Space`)** and **Apple Music/TV/Podcasts** unless explicitly requested.
- **Third-Party Updater & Orphan Hygiene**
  - Inventories `~/Library/LaunchAgents`, `/Library/LaunchAgents`, `/Library/LaunchDaemons`, and `/Library/PrivilegedHelperTools` to surface noisy updaters (**Google Keystone / `GoogleUpdater.wake`**, Adobe, Logitech).
  - Supports `--zap` cleanup and `tccutil reset All <bundle_id>` for orphaned permissions left behind by uninstalled apps.
- **Power, Sleep & Network Security Tuning (`pmset` + `socketfilterfw`)**
  - Eliminates overnight battery drain on MacBooks by disabling `powernap`, `womp` (Wake on LAN), and `proximitywake`.
  - Enables the built-in macOS Application Firewall with Stealth Mode and locks AirDrop discovery to `Contacts Only`.
- **UI, Finder & Keyboard Ergonomics**
  - Speeds up window, QuickLook, Dock (`autohide-delay = 0`, `show-recents = false`, `showhidden = true`), and Finder animations; enables file extensions, path/status bars, folders-first sorting, and blocks `.DS_Store` writes on USB/SMB volumes.
  - Sets balanced fast keyboard repeat (`KeyRepeat = 4`, `InitialKeyRepeat = 25`), optional Zero-Desktop (`CreateDesktop = false`), and shadow-free screenshots in `~/Pictures/Screenshots`.
- **100% Open-Source Native Utility Stack**
  - Pairs with native Swift/open-source Homebrew tools (with `brew analytics off`): `rectangle`, `maccy`, `thaw` *(macOS 26/27+ menu bar manager)*, `pearcleaner`, `mole`, `iina`, `keka`, `mos` + `scripts/mos-auto.sh` *(auto-runs Mos only when an external USB/Bluetooth mouse is connected)*, `ghostty`, `ripgrep`, `fd`, `jq`, `ffmpeg`, `yt-dlp`, `imagemagick`.
- **Full Revert & Post-Action Verification**
  - Re-runs the read-only audit scripts after execution to verify reclaimed space, `launchctl print-disabled` state, `pmset` flags, and firewall state. Includes `scripts/revert.sh` to restore user-level agents and UI defaults.

---

## Safety and Scope

This skill is built around **zero System Integrity Protection changes**, **read-only baseline auditing**, and **explicit user approval** per action. See [SECURITY.md](SECURITY.md) for reporting unsafe rules.

| Operation / Scope | Mechanism | Requires `sudo` | Reversible |
|---|---|---|---|
| System, RAM, `pmset` & security audit | `scripts/audit_system.sh` (read-only) | No | N/A |
| Disk, cache & APFS snapshot audit | `scripts/audit_disk.sh` (read-only, skips `CloudStorage`) | No | N/A |
| 4-layer LaunchAgents/Daemons & RAM audit | `scripts/audit_services.sh` (read-only) | No | N/A |
| Disable user-level `LaunchAgents` & `defaults` | `launchctl disable gui/` + `user/`, `defaults write` | No | Yes (`scripts/revert.sh`) |
| Disable root telemetry & Google Keystone daemons | `launchctl disable system/` | Yes | Yes (`launchctl enable`) |
| Sleep protection & Firewall / Stealth Mode | `pmset -a`, `socketfilterfw` | Yes | Yes (`pmset` / `socketfilterfw`) |
| External mouse auto-launcher for Mos | `scripts/mos-auto.sh` (`ioreg` HID check) | No | Yes (unload `LaunchAgent`) |

---

## Architecture

```text
scripts/audit_system.sh + audit_disk.sh + audit_services.sh (Read-Only Baseline)
   │
   ▼  3-section report + numbered impact table ([Safe] / [Conditional] / [Ecosystem])
User Selection (1, 2, ...)
   │
   ├──► references/playbooks.md (One-by-one execution + state verification)
   ├──► scripts/optimize.sh / system-optimize.sh (Optional standalone presets)
   └──► scripts/revert.sh (Restore user-level agents & macOS defaults)
```

---

## Repository Structure

```text
macos-clean-setup-skill/
├── SKILL.md                   # AI agent instructions & 4-phase interactive workflow
├── README.md                  # Documentation, safety scope & usage guide
├── future_development.md      # v2+ roadmap
├── CONTRIBUTING.md            # Contribution rules & testing checklist
├── CODE_OF_CONDUCT.md         # Contributor Covenant v2.1
├── SECURITY.md                # Safety & regression reporting policy
├── LICENSE                    # MIT License
├── references/
│   └── playbooks.md           # Verified SIP-safe execution playbooks
└── scripts/
    ├── audit_system.sh        # Read-only OS, RAM, pmset, security & defaults audit
    ├── audit_disk.sh          # Read-only APFS snapshot, cache & home size audit
    ├── audit_services.sh      # Read-only 4-layer LaunchAgent/Daemon & process audit
    ├── optimize.sh            # Standalone user-level preset script
    ├── system-optimize.sh     # Standalone root telemetry, pmset & firewall script (sudo)
    ├── revert.sh              # Revert user-level agents & UI defaults
    └── mos-auto.sh            # Auto-start/stop Mos based on external mouse detection
```

---

## Installation

### Antigravity / Gemini CLI
```bash
# Global
git clone https://github.com/atahansocial/macos-clean-setup-skill.git ~/.gemini/config/skills/macos-clean-setup

# Workspace
git clone https://github.com/atahansocial/macos-clean-setup-skill.git <repo>/.agents/skills/macos-clean-setup
```

### Claude Code / OpenCode / Cursor
```bash
git clone https://github.com/atahansocial/macos-clean-setup-skill.git ~/.claude/skills/macos-clean-setup
```

---

## Usage

### 1. Interactive Agent Workflow (Recommended)
Ask your agent after installing the skill:
- *"Use macos-clean-setup to audit what's running in the background and clean up my Mac."*
- *"Run macos-clean-setup to check my RAM, LaunchAgents, caches, and power settings."*
- *"Re-run macos-clean-setup after the macOS update to check if anything reverted."*

The agent responds in whatever language you prompt in while keeping exact macOS paths, `launchd` labels, and `defaults` keys intact.

### 2. Standalone Read-Only Audits
```bash
chmod +x scripts/*.sh
./scripts/audit_system.sh
./scripts/audit_disk.sh
./scripts/audit_services.sh
```

### 3. Standalone Preset & Revert Scripts
```bash
./scripts/optimize.sh          # User-level debloat, privacy & UI defaults
./scripts/system-optimize.sh   # System-wide daemons, Google Keystone, pmset & Stealth Firewall (sudo)
./scripts/revert.sh            # Revert user-level changes back to macOS defaults
```

---

## Roadmap

See [future_development.md](future_development.md) for planned `v2+` modules (system-wide DoH `.mobileconfig` generator, deep dev cache cleaner, open-source battery charge limiter integration, `Brewfile` export/sync, and post-update drift detection).

## License

MIT © [atahansocial](https://github.com/atahansocial)
