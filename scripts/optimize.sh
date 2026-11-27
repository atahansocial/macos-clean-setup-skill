#!/usr/bin/env zsh

# ==============================================================================
# macOS Debloat & Optimization Script (Spotlight & Apple Media Preserved)
# ==============================================================================
# Runs without disabling SIP (System Integrity Protection).
# Does NOT touch Spotlight (Cmd+Space) or Apple Music / Podcasts / TV services.
# ==============================================================================

UID_VAL=$(id -u)
echo "[INFO] Starting macOS Optimization & Debloat (UID: $UID_VAL)..."

# 1. DISABLE NON-ESSENTIAL USER-LEVEL BACKGROUND AGENTS (LaunchAgents)
# ------------------------------------------------------------------------------
AGENTS=(
  # Telemetry, Analytics, Advertising & Feedback
  "com.apple.analyticsagent"
  "com.apple.ap.adprivacyd"
  "com.apple.ap.promotedcontentd"
  "com.apple.appleseed.seedusaged"
  "com.apple.appleseed.seedusaged.postinstall"
  "com.apple.DiagnosticsReporter"
  "com.apple.diagnosticextensionsd"
  "com.apple.diagnostics_agent"
  "com.apple.diagnosticspushd"
  "com.apple.feedbackd"
  "com.apple.geoanalyticsd"
  "com.apple.inputanalyticsd"
  "com.apple.triald"
  "com.apple.BiomeAgent"
  "com.apple.biomesyncd"

  # Siri & Voice Assistant
  "com.apple.Siri.agent"
  "com.apple.SiriTTSTrainingAgent"
  "com.apple.siri.context.service"
  "com.apple.assistant_cdmd"
  "com.apple.assistant_service"
  "com.apple.assistantd"
  "com.apple.siriactionsd"
  "com.apple.siriappintentsd"
  "com.apple.siriinferenced"
  "com.apple.siriknowledged"
  "com.apple.sirittsd"

  # Apple Intelligence (AI) & Background Models
  "com.apple.GenerativeFunctions.agentstored"
  "com.apple.generativeexperiencesd"
  "com.apple.intelligencecontextd"
  "com.apple.intelligenceflowd"
  "com.apple.intelligenceplatformd"
  "com.apple.intelligencetasksd"
  "com.apple.visualintelligenced"
  "com.apple.callintelligenced"

  # Game Center, Screen Time, Tips, HomeKit, Parental Controls
  "com.apple.gamed"
  "com.apple.ScreenTimeAgent"
  "com.apple.ScreenTimeSettingsAgent"
  "com.apple.UsageTrackingAgent"
  "com.apple.FamilyControlsAgent"
  "com.apple.familycircled"
  "com.apple.familycontrols.useragent"
  "com.apple.familynotificationd"
  "com.apple.macos.studentd"
  "com.apple.tipsd"
  "com.apple.homed"
)

echo "\n[1/4] Disabling unnecessary background services (gui & user domains)..."
DISABLED_COUNT=0
for agent in "${AGENTS[@]}"; do
  PLIST="/System/Library/LaunchAgents/${agent}.plist"
  if [[ -f "$PLIST" ]]; then
    launchctl bootout gui/${UID_VAL} "$PLIST" 2>/dev/null
    launchctl disable gui/${UID_VAL}/${agent} 2>/dev/null
    launchctl disable user/${UID_VAL}/${agent} 2>/dev/null
    ((DISABLED_COUNT++))
  fi
done
echo "  [OK] Disabled $DISABLED_COUNT background agents."

# 2. DISABLE TELEMETRY, ADS, SIRI & APPLE INTELLIGENCE PREFERENCES
# ------------------------------------------------------------------------------
echo "\n[2/4] Disabling telemetry, Siri, Apple Intelligence & ad tracking..."

defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.assistant.support "Dictation Enabled" -bool false
defaults write com.apple.assistant.support "Collect Analytics" -bool false
defaults write com.apple.assistant.backedup "Use device speaker for TTS" -int 3
defaults write com.apple.Siri "StatusMenuVisible" -bool false
defaults write com.apple.Siri "UserHasDeclinedEnable" -bool true
defaults write com.apple.Siri "GMSignedUp" -bool false
defaults write com.apple.Siri "VoiceTriggerUserEnabled" -bool false
defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false
defaults write com.apple.CloudSubscriptionFeatures.optIn auto_opt_in -bool false

# Ad Tracking, Crash Reporters, AirDrop & Lookup Suggestions
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.CrashReporter DialogType none
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"

# 3. PERFORMANCE, ANIMATIONS, FINDER, DOCK, DESKTOP & KEYBOARD
# ------------------------------------------------------------------------------
echo "\n[3/4] Optimizing animations, Finder, Dock, Desktop & Keyboard..."

# Speed up window and QuickLook animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write -g QLPanelAnimationDuration -float 0

# Dock settings
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showhidden -bool true

# Finder & Zero-Desktop settings
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Save screenshots to ~/Pictures/Screenshots without drop shadow
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# Prevent .DS_Store creation on network and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Balanced fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 4
defaults write NSGlobalDomain InitialKeyRepeat -int 25
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Expanded save/print panels & save locally by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# 4. THAW DEFAULTS
# ------------------------------------------------------------------------------
echo "\n[4/4] Configuring Thaw defaults..."

# Thaw (Ice Bar for notched MacBooks + click/scroll trigger)
defaults write com.stonerl.Thaw ShowIceIcon -bool true
defaults write com.stonerl.Thaw UseIceBar -bool true
defaults write com.stonerl.Thaw ShowOnClick -bool true
defaults write com.stonerl.Thaw ShowOnHover -bool false
defaults write com.stonerl.Thaw ShowOnScroll -bool true
defaults write com.stonerl.Thaw AutoRehide -bool true
defaults write com.stonerl.Thaw RehideInterval -float 5
defaults write com.stonerl.Thaw HideApplicationMenus -bool true
defaults write com.stonerl.Thaw EnableAlwaysHiddenSection -bool false
defaults write com.stonerl.Thaw AllowsBetaUpdates -bool false
defaults write com.stonerl.Thaw UpdateChannel -string "stable"
defaults write com.stonerl.Thaw NewItemsSection -string "hidden"

killall Finder 2>/dev/null
killall Dock 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "\n[DONE] All user-level optimizations applied!"
