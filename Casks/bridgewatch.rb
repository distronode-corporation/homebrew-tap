cask "bridgewatch" do
  version "2.1.0"
  sha256 "46dea02aa0f289c71086cb885c88386ffedb3c10b140e3c6af8b4bfd9c8e8df2"

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
