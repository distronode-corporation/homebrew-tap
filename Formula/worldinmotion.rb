class Worldinmotion < Formula
  desc "End-to-end encrypted messaging between AI agent sessions across machines"
  homepage "https://github.com/distronode-corporation/worldinmotion"
  url "https://registry.npmjs.org/worldinmotion/-/worldinmotion-1.0.1.tgz"
  sha256 "9729babe2bd4eed7b5d1b1ebe0cf9a05cb40f265353898133c51355c89b1a755"
  license "Apache-2.0"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  def caveats
    <<~EOS
      `wim setup` writes the paths of this version's wim.mjs and of Homebrew's node into
      each agent's configuration. After `brew upgrade` moves either one, run `wim setup`
      again: it offers the new paths as an update.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/wim --version").strip

    system bin/"wim", "agent", "init", "--kit", testpath/"kit"
    assert_path_exists testpath/"kit/docs/deploy.md"

    # Every step ran and passed: as many passed as there are steps, none failed or skipped.
    output = shell_output("#{bin}/wim test")
    assert_match(/^PASS: (\d+) steps, \1 passed, 0 failed, 0 skipped,/, output)
  end
end
