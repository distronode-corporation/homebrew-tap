#!/usr/bin/env bash
#
# Print Formula/worldinmotion.rb for one release of worldinmotion.
#
#   .github/scripts/worldinmotion-formula.sh <version> <sha256> >Formula/worldinmotion.rb
#
# Called by .github/workflows/bump-worldinmotion.yml once it has checked the release (the
# npm tarball against the registry's integrity and its provenance, the wim.mjs inside it
# against the GitHub Release's SHA256SUMS, asset digest and attestation). The one place
# the formula's text is written, so a bump changes only the version and the sha256.
#
# Why the npm tarball and not the GitHub Release's wim.mjs:
# - The tarball is wim.mjs plus agent-kit/, the deployment kit `wim agent init --kit`
#   writes out, and the licence files. A wim installed from the bare wim.mjs has no kit.
# - Its wim.mjs is byte for byte the release's (the bump checks it), so both channels run
#   the same client.
# - Every worldinmotion release before 1.0 is a GitHub pre-release, and `brew audit
#   --online` refuses a formula whose URL is a GitHub pre-release download.
# - It is how Homebrew installs a node package: `npm install` of the downloaded tarball
#   with `std_npm_args` (no scripts run; the package has no dependencies).
#
# The test needs no network beyond loopback and reads nothing of the person's: `wim
# --version`, the deployment kit, and `wim test`, which starts a relay on loopback and
# runs two throwaway devices through the client's main paths, then removes them.
set -euo pipefail

die() {
  echo "FATAL - $*" >&2
  exit 1
}

[ "$#" = "2" ] || die "usage: worldinmotion-formula.sh <version> <sha256>"
[[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "version '$1' is not a version number."
[[ "$2" =~ ^[0-9a-f]{64}$ ]] || die "sha256 '$2' is not a SHA-256."

# ⛔ A QUOTED TEMPLATE, filled in by sed from the two validated values: an unquoted
# heredoc would expand the formula's own `#{...}` and backquoted text.
sed -e "s/@VERSION@/$1/g" -e "s/@SHA256@/$2/" <<'FORMULA'
class Worldinmotion < Formula
  desc "End-to-end encrypted messaging between AI agent sessions across machines"
  homepage "https://github.com/distronode-corporation/worldinmotion"
  url "https://registry.npmjs.org/worldinmotion/-/worldinmotion-@VERSION@.tgz"
  sha256 "@SHA256@"
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
FORMULA
