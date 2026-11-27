#!/usr/bin/env zsh

# ==============================================================================
# macOS System-Wide (Root) Optimization, Power Management & Hardening
# ==============================================================================
# Requires administrator privileges (sudo).
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "Administrator (sudo) privileges required. Please enter your Mac password:"
   exec sudo /bin/zsh "$0" "$@"
fi

CURRENT_USER=$(stat -f "%Su" /dev/console)
USER_UID=$(id -u "$CURRENT_USER")

echo "[INFO] Starting macOS System-Wide Optimization (User: $CURRENT_USER)..."

# 1. DISABLE SYSTEM-WIDE TELEMETRY & CRASH DAEMONS
# ------------------------------------------------------------------------------
echo "\n[1/4] Disabling system-wide telemetry and crash reporting daemons..."
SYS_DAEMONS=(
  "com.apple.analyticsd"
  "com.apple.osanalytics.osanalyticshelper"
  "com.apple.SubmitDiagInfo"
  "com.apple.CrashReporterSupportHelper"
  "com.apple.ReportCrash.Root"
  "com.apple.diagnosticextensions.osx.getmobilityinfo.helper"
  "com.apple.diagnosticspushd"
  "com.apple.triald.system"
  "com.apple.biomed"
  "com.apple.siriinferenced"
)

for daemon in "${SYS_DAEMONS[@]}"; do
  launchctl bootout system/${daemon} 2>/dev/null
  launchctl disable system/${daemon} 2>/dev/null
  echo "  [OK] Disabled system daemon: ${daemon}"
done

defaults write /Library/Application\ Support/CrashReporter/DiagnosticSubmissionConfig.plist AutoSubmit -bool false 2>/dev/null

# 2. CLEAN UP GOOGLE KEYSTONE / GOOGLEUPDATER BACKGROUND AGENTS
# ------------------------------------------------------------------------------
echo "\n[2/4] Stopping Google Chrome/Drive background updater wakeups..."
sudo -u "$CURRENT_USER" defaults write com.google.Keystone.Agent checkInterval 0
launchctl bootout gui/${USER_UID} "/Users/${CURRENT_USER}/Library/LaunchAgents/com.google.keystone.agent.plist" 2>/dev/null
launchctl bootout gui/${USER_UID} "/Users/${CURRENT_USER}/Library/LaunchAgents/com.google.keystone.xpcservice.plist" 2>/dev/null
launchctl bootout gui/${USER_UID} "/Users/${CURRENT_USER}/Library/LaunchAgents/com.google.GoogleUpdater.wake.plist" 2>/dev/null

launchctl bootout system /Library/LaunchDaemons/com.google.keystone.daemon.plist 2>/dev/null
launchctl bootout system /Library/LaunchDaemons/com.google.GoogleUpdater.wake.system.plist 2>/dev/null
launchctl disable system/com.google.keystone.daemon 2>/dev/null
launchctl disable system/com.google.GoogleUpdater.wake.system 2>/dev/null
echo "  [OK] Google Keystone & GoogleUpdater background wake services disabled."

# 3. MACBOOK POWER & SLEEP OPTIMIZATION (pmset)
# ------------------------------------------------------------------------------
echo "\n[3/4] Applying macOS sleep and battery optimizations (pmset)..."
# Disable Power Nap (background syncing/checks while sleeping)
pmset -a powernap 0
# Disable Wake on Network / Magic Packet
pmset -a womp 0
# Disable Proximity Wake (waking on nearby iPhone/Watch while lid is closed)
pmset -a proximitywake 0
echo "  [OK] Power Nap, Wake-on-LAN, and Proximity Wake disabled."

# 4. BUILT-IN FIREWALL & STEALTH MODE
# ------------------------------------------------------------------------------
echo "\n[4/4] Enabling macOS Application Firewall and Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
echo "  [OK] Firewall and Stealth Mode enabled."

echo "\n[DONE] All system-wide optimizations complete!"
