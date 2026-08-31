cask "kitobot" do
  version "0.1.3"
  sha256 "097f6228098347c077d9665145c6c9dfec3581e86675c1991af9bcdbacd91740"

  url "https://github.com/Remownz/KitoBot-releases/releases/download/v#{version}/KitoBot_#{version}_aarch64.dmg"
  name "KitoBot"
  desc "Local multi-bot chat app for running several AI personas side by side"
  homepage "https://github.com/Remownz/KitoBot"

  # The release workflow only builds aarch64 (server/package.json's
  # build:sidecar only targets node22-macos-arm64) — no Intel build exists.
  # No enforced macOS floor here — tauri.conf.json doesn't set one, so
  # don't fabricate a version guess Homebrew would then enforce.
  depends_on arch: :arm64
  depends_on :macos

  app "KitoBot.app"

  # Unsigned/un-notarized build (no Apple Developer Program membership) —
  # Homebrew's own curl-based download doesn't set com.apple.quarantine the
  # way a browser download does, but strip it anyway as a safety net so
  # Gatekeeper never blocks the first launch, regardless of how the .app
  # ended up on disk.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/KitoBot.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/com.kitobot.desktop",
    "~/Library/Preferences/com.kitobot.desktop.plist",
    "~/Library/Saved Application State/com.kitobot.desktop.savedState",
    "~/Library/WebKit/com.kitobot.desktop",
  ]
end
