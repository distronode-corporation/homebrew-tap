cask "district-ai" do
  version "1.0,20024"
  sha256 "6fbad93c1b72d39f3467a039d5bfbe7afbe3fa527d73686cf00147fab87ea512"

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
