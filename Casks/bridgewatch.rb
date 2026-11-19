cask "bridgewatch" do
  version "2.2.0"
  sha256 "2d8f23c72f289a2b843dc6f1c5b4eb30acdaf778426ea8fd938bfbfa551bc8c1"

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
