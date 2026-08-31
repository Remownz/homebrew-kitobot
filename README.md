# homebrew-kitobot

Homebrew tap for [KitoBot](https://github.com/Remownz/KitoBot).

## Install

```bash
brew tap Remownz/kitobot
brew trust remownz/kitobot   # newer Homebrew versions require trusting a fresh third-party tap once
brew install --cask kitobot
```

## Update

```bash
brew update
brew upgrade --cask kitobot
```

## Uninstall

```bash
brew uninstall --cask kitobot
# also remove app data (memory, bots, MCP config, ...):
brew uninstall --cask --zap kitobot
```

## Notes

- Apple Silicon (arm64) only — the release build has no Intel binary.
- Unsigned build (no Apple Developer Program membership) — the cask strips
  the `com.apple.quarantine` flag after install so Gatekeeper doesn't block
  the first launch.
- The cask's `version`/`sha256` need bumping by hand on every new
  [KitoBot release](https://github.com/Remownz/KitoBot-releases/releases) —
  no automation for that yet.
- KitoBot also has its own in-app updater (Tauri's, independent of this
  tap) that can self-update ahead of this tap's pinned version. A
  `preflight` block asks the app itself (`GET /api/version` on
  `127.0.0.1:8787`, falling back to the `version.json` it writes on every
  startup if the app isn't running) and aborts the install instead of
  downgrading a self-updated app back to whatever this tap still has
  pinned.
