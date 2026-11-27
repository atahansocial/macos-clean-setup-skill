#!/usr/bin/env zsh

# ==============================================================================
# macos-clean-setup — Read-Only Disk, Cache & Snapshot Audit
# ==============================================================================
# Safe & non-destructive: measures sizes only, skips CloudStorage mounts.
# ==============================================================================

echo "=================================================================="
echo "  MACOS STORAGE, CACHES & APFS SNAPSHOT AUDIT (READ-ONLY)"
echo "=================================================================="

echo "\n--- 1. ROOT VOLUME USAGE ---"
df -h /

echo "\n--- 2. APFS LOCAL SNAPSHOTS (TIME MACHINE) ---"
SNAPSHOTS=$(tmutil listlocalsnapshots / 2>/dev/null)
if [[ -n "$SNAPSHOTS" ]]; then
  echo "$SNAPSHOTS"
else
  echo "No local APFS snapshots found."
fi

echo "\n--- 3. CLEANABLE CACHE & DEV DIRECTORIES ---"
CACHE_DIRS=(
  "$HOME/Library/Caches"
  "$HOME/Library/Logs"
  "$HOME/Library/Caches/Homebrew"
  "$HOME/Library/Developer/Xcode/DerivedData"
  "$HOME/Library/Developer/CoreSimulator"
  "$HOME/Library/Caches/Google/Chrome"
  "$HOME/.Trash"
  "$HOME/.npm"
  "$HOME/.cache"
)

for d in "${CACHE_DIRS[@]}"; do
  if [[ -d "$d" ]]; then
    SZ=$(du -sh "$d" 2>/dev/null | awk '{print $1}')
    printf "  %-8s | %s\n" "${SZ:-0B}" "${d/#$HOME/~}"
  fi
done

echo "\n--- 4. TOP 10 LARGEST HOME DIRECTORIES (EXCL. CLOUD STORAGE) ---"
for entry in "$HOME"/*(N) "$HOME"/.Trash(N); do
  [[ "$entry" == "$HOME/Library" ]] && continue
  [[ -d "$entry" ]] || continue
  du -sh "$entry" 2>/dev/null
done | sort -hr | head -n 10
echo "  (Note: ~/Library top-level subdirectories below, excluding CloudStorage)"
for entry in "$HOME/Library"/*(N); do
  [[ "$entry" == "$HOME/Library/CloudStorage" ]] && continue
  [[ -d "$entry" ]] || continue
  du -sh "$entry" 2>/dev/null
done | sort -hr | head -n 8
