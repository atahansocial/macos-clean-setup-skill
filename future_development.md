# Future Development Roadmap (`v2+`)

Planned enhancements for `macos-clean-setup` beyond `v1`:

1. **System-Wide Encrypted DNS (DoH) Profile Generator:**
   - Generate and validate a zero-overhead `.mobileconfig` profile (`com.apple.dnsSettings.managed`) for Cloudflare, Quad9, AdGuard, or NextDNS without requiring any background VPN/filter app.
2. **Deep Developer Cache Cleaner:**
   - Interactive size-first cleanup for `~/Library/Developer/Xcode/DerivedData`, `CoreSimulator`, Unity `Library/` caches, `OrbStack` / `Docker` disk images, `pip` / `.venv`, `npm` / `pnpm`, and HuggingFace/Ollama model weights.
3. **Battery Longevity & Charge Limiter Integration:**
   - Automated detection of desk-bound AC usage (`CycleCount` + `AC Power` telemetry) with optional integration for 100% open-source charge limiters (`Battery Toolkit` or `battery` CLI) and `pmset` thermal tuning.
4. **Interactive `Brewfile` Export & Sync:**
   - Snapshot installed Homebrew casks/formulae and validated `defaults` into a portable, sanitized setup kit for instant migration to a new Mac.
5. **Post-macOS-Update Drift Detector:**
   - Compare current `audit_system.sh` / `audit_services.sh` snapshots against a saved baseline JSON after major macOS point updates (which occasionally re-enable `GMSignedUp`, reset `KeyRepeat`, or spawn new telemetry agents).
