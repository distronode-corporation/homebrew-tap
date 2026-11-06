#!/usr/bin/env bash
#
# Print Casks/bridgewatch.rb for one release of bridgewatch.
#
#   .github/scripts/bridgewatch-cask.sh <version> <sha256> >Casks/bridgewatch.rb
#
# Called by .github/workflows/bump-bridgewatch.yml once it has checked the release's
# .dmg (the asset digest GitHub records, the provenance attestation). The one place
# the cask's text is written, so a bump changes only the version and the sha256.
#
# `depends_on :macos` (no version) says the cask is macOS-only, which `brew style`
# requires of a cask with an `app`. What the cask leaves out, on purpose:
# - A minimum macOS (`depends_on macos: ...`). The app's floor is 10.15, below the
#   oldest macOS Homebrew itself supports, and Homebrew 7 refuses to load a cask
#   naming `:catalina`.
# - `auto_updates`. The app has no updater: `brew upgrade` is how it gets updated.
#
# `zap` is what the app's own code writes outside its bundle, read from its source
# (the system WebView may add its own caches; none are listed until one is seen):
# - ~/Library/Application Support/bridgewatch: config.toml (the `dirs` crate's config
#   dir) and the notification ledgers and ETA samples (its data-local dir, since macOS
#   has no state dir).
# - ~/Library/Logs/bridgewatch: the daily log files.
# - ~/Library/LaunchAgents/bridgewatch.plist: written by the autostart plugin
#   (LaunchAgent mode, named after the product name) when "Launch at login" is on.
set -euo pipefail

die() {
  echo "FATAL - $*" >&2
  exit 1
}

[ "$#" = "2" ] || die "usage: bridgewatch-cask.sh <version> <sha256>"
[[ "$1" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] || die "version '$1' is not a version number."
[[ "$2" =~ ^[0-9a-f]{64}$ ]] || die "sha256 '$2' is not a SHA-256."

# ⛔ A QUOTED TEMPLATE, filled in by sed from the two validated values: an unquoted
# heredoc would run any backquoted text in the cask's comments as a command.
sed -e "s/@VERSION@/$1/" -e "s/@SHA256@/$2/" <<'CASK'
cask "bridgewatch" do
  version "@VERSION@"
  sha256 "@SHA256@"

  url "https://github.com/distronode-corporation/bridgewatch/releases/download/v#{version}/bridgewatch_#{version}_universal.dmg"
  name "bridgewatch"
  desc "Bridge-aware tray monitor for GitLab CI and GitHub Actions"
  homepage "https://www.distronode.com/open-source/bridgewatch"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "bridgewatch.app"

  uninstall quit: "com.distronode.bridgewatch"

  zap trash: [
    "~/Library/Application Support/bridgewatch",
    "~/Library/LaunchAgents/bridgewatch.plist",
    "~/Library/Logs/bridgewatch",
  ]
end
CASK
