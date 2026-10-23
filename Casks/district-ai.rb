cask "district-ai" do
  version "3.0.3,20077"
  sha256 "2f8097a6e0a308d234eb969f7de9ec564cea2e1f863b115e336ab06c1658bf78"

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
