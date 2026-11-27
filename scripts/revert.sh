#!/usr/bin/env zsh

# ==============================================================================
# macOS Debloat & Optimization - REVERT SCRIPT
# ==============================================================================

UID_VAL=$(id -u)
echo "[REVERT] Re-enabling disabled agents and restoring macOS UI defaults..."

AGENTS=(
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
  "com.apple.GenerativeFunctions.agentstored"
  "com.apple.generativeexperiencesd"
  "com.apple.intelligencecontextd"
  "com.apple.intelligenceflowd"
  "com.apple.intelligenceplatformd"
  "com.apple.intelligencetasksd"
  "com.apple.visualintelligenced"
  "com.apple.callintelligenced"
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

for agent in "${AGENTS[@]}"; do
  launchctl enable gui/${UID_VAL}/${agent} 2>/dev/null
  launchctl enable user/${UID_VAL}/${agent} 2>/dev/null
done

# Restore Siri & UI/animation defaults
defaults delete com.apple.Siri GMSignedUp 2>/dev/null
defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null
defaults delete NSGlobalDomain NSWindowResizeTime 2>/dev/null
defaults delete -g QLPanelAnimationDuration 2>/dev/null
defaults delete com.apple.dock autohide-delay 2>/dev/null
defaults delete com.apple.dock autohide-time-modifier 2>/dev/null
defaults delete com.apple.dock launchanim 2>/dev/null
defaults delete com.apple.dock expose-animation-duration 2>/dev/null
defaults delete com.apple.dock showhidden 2>/dev/null
defaults delete com.apple.finder DisableAllAnimations 2>/dev/null
defaults delete com.apple.finder CreateDesktop 2>/dev/null
defaults delete com.apple.finder _FXShowPosixPathInTitle 2>/dev/null
defaults delete com.apple.screencapture disable-shadow 2>/dev/null
defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null
defaults delete NSGlobalDomain KeyRepeat 2>/dev/null
defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null

killall Finder 2>/dev/null
killall Dock 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "[DONE] Settings reverted to defaults. Restart your Mac for full effect."
