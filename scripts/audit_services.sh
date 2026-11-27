#!/usr/bin/env zsh

# ==============================================================================
# macos-clean-setup — Read-Only LaunchAgents, Daemons, Processes & Apps Audit
# ==============================================================================
# Safe & non-destructive: inventories background items and RAM/CPU consumers.
# ==============================================================================

UID_VAL=$(id -u)
echo "=================================================================="
echo "  MACOS LAUNCHAGENTS, DAEMONS, PROCESSES & APPS AUDIT (READ-ONLY)"
echo "=================================================================="

echo "\n--- 1. THIRD-PARTY STARTUP ITEMS & HELPERS ---"
for dir in \
  "$HOME/Library/LaunchAgents" \
  "/Library/LaunchAgents" \
  "/Library/LaunchDaemons" \
  "/Library/PrivilegedHelperTools"; do
  echo "[$dir]"
  if [[ -d "$dir" ]]; then
    ITEMS=$(ls -1 "$dir" 2>/dev/null)
    if [[ -n "$ITEMS" ]]; then
      echo "$ITEMS" | sed 's/^/  - /'
    else
      echo "  (empty)"
    fi
  else
    echo "  (not present)"
  fi
done

echo "\n--- 2. NOISY UPDATER / VENDOR AGENT CHECK (Google / Adobe / Logitech) ---"
NOISY=$(ps aux | grep -iE "keystone|GoogleUpdater|AdobeIPCBroker|CCXProcess|CoreSync|LogiMgr|logioptionsplus" | grep -v grep)
if [[ -n "$NOISY" ]]; then
  echo "$NOISY"
else
  echo "None running."
fi

echo "\n--- 3. TARGETED APPLE BLOAT / TELEMETRY / SIRI / AI STATUS ---"
echo "Currently running targeted Apple processes:"
LIVE_APPLE=$(ps aux | grep -iE "Siri AI|siriactionsd|BiomeAgent|generativeexperiencesd|intelligenceplatformd|analyticsagent|analyticsd|gamed|ScreenTimeAgent|homed|tipsd" | grep -v grep)
if [[ -n "$LIVE_APPLE" ]]; then
  echo "$LIVE_APPLE" | awk '{printf "  PID %-6s | RSS %6.1f MB | CPU %4.1f%% | %s\n", $2, $6/1024, $3, $11}'
else
  echo "  None of the targeted bloat processes are running."
fi

echo "\nDisabled count in launchd (gui/$UID_VAL):"
launchctl print-disabled gui/${UID_VAL} 2>/dev/null | grep -c '=> disabled' | xargs -I{} echo "  {} disabled entries in gui/$UID_VAL"

echo "\n--- 4. TOP 15 MEMORY CONSUMERS (AGGREGATED BY PROCESS) ---"
ps -axo rss,comm | awk '{sum[$2]+=$1} END {for (i in sum) printf "%8.1f MB | %s\n", sum[i]/1024, i}' | sort -rn | head -n 15

echo "\n--- 5. INSTALLED APPLICATIONS & HOMEBREW ---"
echo "Applications in /Applications:"
ls -1 /Applications 2>/dev/null | grep -v "^Utilities$" | sed 's/^/  - /'

if command -v brew >/dev/null 2>&1 || [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_BIN=$(command -v brew 2>/dev/null || echo "/opt/homebrew/bin/brew")
  echo "\nHomebrew Casks ($($BREW_BIN list --cask 2>/dev/null | wc -l | tr -d ' ')):"
  $BREW_BIN list --cask 2>/dev/null | tr '\n' ' ' && echo ""
  echo "Homebrew Formulae ($($BREW_BIN list --formula 2>/dev/null | wc -l | tr -d ' ')):"
  $BREW_BIN list --formula 2>/dev/null | tr '\n' ' ' && echo ""
fi
