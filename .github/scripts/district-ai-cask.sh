#!/usr/bin/env bash
#
# Print Casks/district-ai.rb for one release of District AI for macOS.
#
#   .github/scripts/district-ai-cask.sh <version> <build> <sha256> >Casks/district-ai.rb
#
# Called by .github/workflows/bump.yml once it has checked the release's .dmg (its
# checksum, the asset digest, the provenance attestation). The one place the cask's
# text is written, so a bump changes only the version and the sha256.
#
# ⛔ `zap` IS LIMITED TO WHAT ONLY THE DIRECT DOWNLOAD WRITES. The Mac App Store build is
# the same app with the same bundle id (com.distronode.district), sandboxed like this
# one, so both keep their data in ~/Library/Containers/com.distronode.district (the
# defaults, caches and saved state inside it) and share one keychain access group.
# Zapping any of that would wipe the App Store copy's sign-in and settings too. What
# only this build writes is Sparkle's: its installer runs outside the sandbox and
# stages updates in ~/Library/Caches/com.distronode.district/org.sparkle-project.Sparkle
# (Sparkle's SPULocalCacheDirectory, resolved from an unsandboxed process); the
# sandboxed app itself never writes outside its container.
set -euo pipefail

die() {
  echo "FATAL - $*" >&2
  exit 1
}

[ "$#" = "3" ] || die "usage: district-ai-cask.sh <version> <build> <sha256>"
[[ "$1" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] || die "version '$1' is not a version number."
[[ "$2" =~ ^[0-9]+$ ]] || die "build '$2' is not a build number."
[[ "$3" =~ ^[0-9a-f]{64}$ ]] || die "sha256 '$3' is not a SHA-256."

# ⛔ A QUOTED TEMPLATE, filled in by sed from the three validated values: an unquoted
# heredoc would run any backquoted text in the cask's comments as a command.
sed -e "s/@VERSION@/$1/" -e "s/@BUILD@/$2/" -e "s/@SHA256@/$3/" <<'CASK'
cask "district-ai" do
  version "@VERSION@,@BUILD@"
  sha256 "@SHA256@"

  url "https://github.com/distronode-corporation/district-macos/releases/download/v#{version.csv.first}/DistrictAI-#{version.csv.first}-#{version.csv.second}.dmg"
  name "District AI"
  desc "Inbox, calls, meeting rooms and scheduling for Distronode workspaces"
  homepage "https://www.distronode.com/open-source/district-macos"

  livecheck do
    url "https://updates.distronode.com/district/macos/appcast.xml"
    strategy :sparkle
  end

  auto_updates true
  # Sonoma or later: a bare symbol is a minimum (brew style refuses the ">= :sonoma" form).
  depends_on macos: :sonoma

  app "District AI.app"

  uninstall quit: "com.distronode.district"

  # Only what the direct download writes: the App Store build of the same app shares
  # its container (~/Library/Containers/com.distronode.district) and keychain group.
  zap trash: "~/Library/Caches/com.distronode.district/org.sparkle-project.Sparkle",
      rmdir: "~/Library/Caches/com.distronode.district"
end
CASK
