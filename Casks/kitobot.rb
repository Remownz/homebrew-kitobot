require "json"
require "open3"

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

  # KitoBot has its own in-app updater (Tauri's, checking KitoBot-releases'
  # latest.json independently of this tap) that self-replaces the running
  # .app in place. If that already ran, this cask's own version/sha256 —
  # bumped by hand, see the tap's README — can be stale, and blindly
  # installing would downgrade a newer self-update. Ask the actually
  # running app first (GET /api/version), falling back to the version.json
  # it writes on every startup if nothing is listening (app not running).
  preflight do
    installed_version = nil

    begin
      stdout, _stderr, status = Open3.capture3(
        "/usr/bin/curl", "-s", "--max-time", "1", "http://127.0.0.1:8787/api/version"
      )
      installed_version = JSON.parse(stdout)["version"] if status.success? && !stdout.strip.empty?
    rescue
      installed_version = nil
    end

    # version.json outlives an uninstall (app data is kept on purpose — see
    # the tap README's zap trash list) — only trust it while the app it
    # describes is actually still sitting at the target install path.
    # Otherwise a plain fresh install after "delete the app, keep the data"
    # would see a stale file and wrongly think a newer copy is installed.
    if installed_version.nil? && File.exist?("/Applications/KitoBot.app")
      version_file = Pathname.new("~/Library/Application Support/com.kitobot.desktop/version.json").expand_path
      if version_file.exist?
        begin
          installed_version = JSON.parse(version_file.read)["version"]
        rescue
          installed_version = nil
        end
      end
    end

    if installed_version && Version.new(installed_version) >= version
      raise CaskError,
            "KitoBot #{installed_version} is already installed — that's newer than or equal to this cask's " \
            "#{version}, most likely from the in-app auto-updater running ahead of this tap. Skipping to avoid " \
            "downgrading; bump this cask's version/sha256 to #{installed_version} or later first."
    end
  end

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
