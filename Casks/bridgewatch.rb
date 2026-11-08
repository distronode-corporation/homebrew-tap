cask "bridgewatch" do
  version "2.0.0"
  sha256 "1f8847cd574bba86a5ae5accfda7f6c8d92b30d5018619f8d4065e2d8e83c9b1"

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
