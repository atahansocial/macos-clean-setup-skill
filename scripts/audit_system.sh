#!/usr/bin/env zsh

# ==============================================================================
# macos-clean-setup — Read-Only System, Power, Security & UI Audit
# ==============================================================================
# Safe & non-destructive: reads state only, modifies nothing.
# ==============================================================================

echo "=================================================================="
echo "  MACOS SYSTEM, PERFORMANCE, POWER & SECURITY AUDIT (READ-ONLY)"
echo "=================================================================="

echo "\n--- 1. OS & HARDWARE ---"
sw_vers
echo "Model       : $(sysctl -n hw.model 2>/dev/null)"
echo "Chip        : $(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
system_profiler SPHardwareDataType 2>/dev/null | grep -E "Model Name|Memory|Serial" | grep -v "Serial" | sed 's/^[[:space:]]*//'
echo "Uptime      : $(uptime | sed 's/.*up /up /' | sed 's/, [0-9]* users.*//')"
echo "SIP Status  : $(csrutil status 2>/dev/null || echo 'Unknown')"

echo "\n--- 2. CPU, MEMORY & SWAP ---"
echo "Load Avg    : $(sysctl -n vm.loadavg 2>/dev/null)"
memory_pressure 2>/dev/null | grep -E "System-wide memory free percentage|Pages active|Pages inactive|Pages free|Pages purgeable"
sysctl vm.swapusage 2>/dev/null

echo "\n--- 3. POWER, SLEEP & BATTERY ---"
pmset -g 2>/dev/null | grep -E "displaysleep|sleep|powernap|womp|proximitywake|SleepDisabled|hibernatemode"
pmset -g batt 2>/dev/null
BATT_INFO=$(ioreg -rn AppleSmartBattery 2>/dev/null | grep -E '"CycleCount"|"MaxCapacity"|"NominalChargeCapacity"|"DesignCapacity"' | head -n 6)
if [[ -n "$BATT_INFO" ]]; then
  echo "Battery Details:"
  echo "$BATT_INFO" | sed 's/^[[:space:]]*/  /'
fi

echo "\n--- 4. SECURITY & NETWORK PRIVACY ---"
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null
/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null
AIRDROP=$(defaults read com.apple.sharingd DiscoverableMode 2>/dev/null || echo "Default (Everyone/Contacts)")
echo "AirDrop Mode: $AIRDROP"

echo "\n--- 5. UI, ERGONOMICS & SIRI/AI FLAGS ---"
echo "KeyRepeat                 : $(defaults read NSGlobalDomain KeyRepeat 2>/dev/null || echo 'Default')"
echo "InitialKeyRepeat          : $(defaults read NSGlobalDomain InitialKeyRepeat 2>/dev/null || echo 'Default')"
echo "CreateDesktop             : $(defaults read com.apple.finder CreateDesktop 2>/dev/null || echo 'true (Default)')"
echo "Dock autohide-delay       : $(defaults read com.apple.dock autohide-delay 2>/dev/null || echo 'Default')"
echo "WindowAnimationsEnabled   : $(defaults read NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || echo 'true (Default)')"
echo "Siri GMSignedUp           : $(defaults read com.apple.Siri GMSignedUp 2>/dev/null || echo 'Unset')"
echo "Siri Assistant Enabled    : $(defaults read com.apple.assistant.support 'Assistant Enabled' 2>/dev/null || echo 'Default')"
if command -v brew >/dev/null 2>&1 || [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_BIN=$(command -v brew 2>/dev/null || echo "/opt/homebrew/bin/brew")
  echo "Homebrew Path             : $BREW_BIN"
  echo "Homebrew Analytics        : $($BREW_BIN analytics 2>/dev/null | head -n 1)"
else
  echo "Homebrew                  : Not installed"
fi
