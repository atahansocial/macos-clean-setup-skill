# macOS Clean Setup — Execution Playbooks

Verified, SIP-safe macOS execution playbooks referenced during **Phase 3 (One-by-One Execution & Verification)**. Only run the exact playbook items the user approved in Phase 2.

---

## 1. Safe Cache & Disk Cleanup

- **Homebrew cache & orphaned dependencies:**
  ```bash
  brew analytics off
  brew cleanup -s
  ```
- **User Caches (contents only — never delete the parent `Caches` directory itself):**
  ```bash
  rm -rf ~/Library/Caches/com.apple.Safari/* 2>/dev/null
  # Or inspect large sub-caches first before deleting:
  du -sh ~/Library/Caches/* | sort -hr | head -n 15
  ```
- **Xcode `DerivedData` (safe to remove; Xcode rebuilds on next compile):**
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
  ```
- **Time Machine Local APFS Snapshots (when `tmutil listlocalsnapshots /` shows stale snapshots):**
  ```bash
  # Replace <timestamp> with the exact snapshot date from `tmutil listlocalsnapshots /`
  sudo tmutil deletelocalsnapshots <timestamp>
  ```
- **Spotlight CPU Spike Prevention:**
  - Never disable Spotlight if the user relies on `Cmd + Space`. Instead, instruct the user to exclude `~/Library/Caches`, `node_modules`, and Unity `Library/` folders under **System Settings → Spotlight → Search Privacy**.

---

## 2. SIP-Safe Telemetry, Siri & Apple Intelligence Hardening

> Always confirm first whether the user actively uses **Siri**, **Apple Intelligence**, **Dictation**, **Screen Time**, **Game Center**, or **HomeKit** before disabling those groups.

- **Disable user-level telemetry, Siri, AI & bloat agents (both `gui/` and `user/` domains):**
  ```bash
  UID_VAL=$(id -u)
  AGENTS=(
    "com.apple.analyticsagent" "com.apple.ap.adprivacyd" "com.apple.ap.promotedcontentd"
    "com.apple.appleseed.seedusaged" "com.apple.DiagnosticsReporter" "com.apple.diagnostics_agent"
    "com.apple.feedbackd" "com.apple.geoanalyticsd" "com.apple.inputanalyticsd"
    "com.apple.triald" "com.apple.BiomeAgent" "com.apple.biomesyncd"
    "com.apple.Siri.agent" "com.apple.siri.context.service" "com.apple.siriactionsd"
    "com.apple.assistantd" "com.apple.assistant_service" "com.apple.siriknowledged"
    "com.apple.generativeexperiencesd" "com.apple.intelligenceplatformd"
    "com.apple.intelligencecontextd" "com.apple.intelligenceflowd" "com.apple.visualintelligenced"
    "com.apple.gamed" "com.apple.ScreenTimeAgent" "com.apple.UsageTrackingAgent"
    "com.apple.FamilyControlsAgent" "com.apple.tipsd" "com.apple.homed"
  )
  for agent in "${AGENTS[@]}"; do
    launchctl bootout gui/${UID_VAL} "/System/Library/LaunchAgents/${agent}.plist" 2>/dev/null
    launchctl disable gui/${UID_VAL}/${agent} 2>/dev/null
    launchctl disable user/${UID_VAL}/${agent} 2>/dev/null
  done
  ```
- **Disable Siri / Apple Intelligence / Ad Tracking preference flags:**
  ```bash
  defaults write com.apple.Siri GMSignedUp -bool false
  defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false
  defaults write com.apple.Siri StatusMenuVisible -bool false
  defaults write com.apple.Siri UserHasDeclinedEnable -bool true
  defaults write com.apple.assistant.support "Assistant Enabled" -bool false
  defaults write com.apple.assistant.support "Dictation Enabled" -bool false
  defaults write com.apple.assistant.support "Collect Analytics" -bool false
  defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false
  defaults write com.apple.CloudSubscriptionFeatures.optIn auto_opt_in -bool false
  defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
  defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
  defaults write com.apple.AdLib forceLimitAdTracking -bool true
  defaults write com.apple.CrashReporter DialogType none
  ```
- **System-wide root telemetry daemons (`sudo`):**
  ```bash
  for daemon in \
    com.apple.analyticsd com.apple.osanalytics.osanalyticshelper \
    com.apple.SubmitDiagInfo com.apple.CrashReporterSupportHelper \
    com.apple.ReportCrash.Root com.apple.diagnosticspushd \
    com.apple.triald.system com.apple.biomed com.apple.siriinferenced; do
    sudo launchctl bootout system/${daemon} 2>/dev/null
    sudo launchctl disable system/${daemon} 2>/dev/null
  done
  ```

---

## 3. Third-Party Background Bloat & Uninstalled App Hygiene

- **Google Chrome / Drive Keystone & GoogleUpdater wakeups (`sudo` for system daemons):**
  ```bash
  UID_VAL=$(id -u)
  defaults write com.google.Keystone.Agent checkInterval 0
  launchctl bootout gui/${UID_VAL} ~/Library/LaunchAgents/com.google.keystone.agent.plist 2>/dev/null
  launchctl bootout gui/${UID_VAL} ~/Library/LaunchAgents/com.google.keystone.xpcservice.plist 2>/dev/null
  launchctl bootout gui/${UID_VAL} ~/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist 2>/dev/null
  sudo launchctl bootout system /Library/LaunchDaemons/com.google.keystone.daemon.plist 2>/dev/null
  sudo launchctl bootout system /Library/LaunchDaemons/com.google.GoogleUpdater.wake.system.plist 2>/dev/null
  sudo launchctl disable system/com.google.keystone.daemon 2>/dev/null
  sudo launchctl disable system/com.google.GoogleUpdater.wake.system 2>/dev/null
  ```
- **Clean up leftover files & TCC permissions from uninstalled apps:**
  - Always prefer `brew uninstall --cask --zap <cask>` so preferences, caches, and login items are removed.
  - Reset orphaned Accessibility/Screen Recording TCC entries for removed apps:
    ```bash
    tccutil reset All <bundle_identifier>
    ```

---

## 4. Power, Sleep & Security Hardening (`sudo`)

- **Stop overnight battery drain on MacBooks (Power Nap, Wake-on-LAN, Proximity Wake):**
  ```bash
  sudo pmset -a powernap 0
  sudo pmset -a womp 0
  sudo pmset -a proximitywake 0
  ```
- **Enable Application Firewall & Stealth Mode:**
  ```bash
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
  ```
- **Restrict AirDrop discovery to contacts:**
  ```bash
  defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"
  ```

---

## 5. UI, Finder, Dock, Zero-Desktop & Keyboard Ergonomics

```bash
# Instant window, QuickLook & Dock animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write -g QLPanelAnimationDuration -float 0
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showhidden -bool true

# Finder power-user defaults
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Optional Zero-Desktop & clean screenshots
defaults write com.apple.finder CreateDesktop -bool false
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Balanced fast keyboard repeat (avoids overly aggressive Delete key)
defaults write NSGlobalDomain KeyRepeat -int 4
defaults write NSGlobalDomain InitialKeyRepeat -int 25
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

killall Finder Dock SystemUIServer 2>/dev/null
```

---

## 6. Lightweight Native Open-Source Utility Stack

Replace heavy Electron apps and paid bloatware with native Swift/open-source Homebrew tools:

```bash
brew analytics off
brew install --cask rectangle maccy thaw pearcleaner iina keka mos ghostty
brew install mole ripgrep fd jq ffmpeg yt-dlp imagemagick
brew cleanup -s
```

- **External Mouse Auto-Mos (`scripts/mos-auto.sh`):** Use a `StartInterval: 8` `LaunchAgent` calling `scripts/mos-auto.sh` so **Mos** automatically launches when an external USB/Bluetooth mouse is connected and quits when using the built-in Trackpad.
- **Note for macOS 26/27+:** Use **`thaw`** instead of `jordanbaird-ice` (`0.11.12`), as older Ice builds break under the unified menu bar window architecture.

---

## 7. Full Revert & Recovery Playbook

- Re-enable all user-level agents and restore UI/animation defaults:
  ```bash
  ./scripts/revert.sh
  ```
- Re-enable `pmset` defaults if desired:
  ```bash
  sudo pmset -a powernap 1 womp 1 proximitywake 1
  ```
- Restart macOS after reverting for all `launchd` agents to reload cleanly.
