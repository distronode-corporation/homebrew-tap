cask "bridgewatch" do
  version "1.3.0"
  sha256 "962224c36045d3af9c3d7bf5987ce1035e51c7d586cdc25e593cfd10fda8fcbb"

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
