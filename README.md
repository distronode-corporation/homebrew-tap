<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/distronode-logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/distronode-logo-light.png">
  <img alt="Distronode" src=".github/assets/distronode-logo-light.png" width="220">
</picture>

# Distronode Homebrew tap

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/distronode-corporation/homebrew-tap/badge)](https://scorecard.dev/viewer/?uri=github.com/distronode-corporation/homebrew-tap)

The [Homebrew](https://brew.sh) tap for Distronode's macOS apps. It carries two casks,
each following its app's GitHub Releases:

| Cask | App |
| --- | --- |
| `district-ai` | [District AI for Mac](https://github.com/distronode-corporation/district-macos), the native desktop client for [District AI](https://www.distronode.com/district-ai). |
| `bridgewatch` | [bridgewatch](https://github.com/distronode-corporation/bridgewatch), a tray monitor for GitLab CI and GitHub Actions that follows a push into its child pipelines and workflow runs. |

## Install

```sh
brew install distronode-corporation/tap/district-ai
brew install distronode-corporation/tap/bridgewatch
```

That taps this repository and installs the cask in one step. Homebrew loads casks from
a tap it does not ship only once you trust them, and naming the cask in full, as above,
is what trusts it. If you tap first, keep the full name when you install:

```sh
brew tap distronode-corporation/tap
brew install --cask distronode-corporation/tap/bridgewatch
```

Each cask installs the same file as its app's GitHub Releases: a universal (Apple
silicon and Intel) `.dmg`, signed with Distronode's Developer ID. Homebrew checks the
download against the SHA-256 recorded in the cask before it installs anything.

- **District AI:** the `.dmg` is notarised by Apple.
- **bridgewatch:** the app inside the `.dmg` is notarised by Apple and the ticket is
  stapled to it, so Gatekeeper accepts the installed app; the 1.2.0 `.dmg` itself is
  signed but not notarised. Homebrew mounts the `.dmg` and copies the app out, so this
  makes no difference to a `brew install`.

## Updates

### District AI

The app updates itself. It checks Distronode's update feed with
[Sparkle](https://sparkle-project.org), and every update is signed, so the app installs
only an update Distronode published.

The cask says so with `auto_updates true`, which means:

- `brew upgrade` leaves District AI alone, because the app is already keeping itself
  current. `brew upgrade --greedy` (or `--greedy-auto-updates`) reinstalls it from the
  cask anyway.
- The version in the cask follows the releases, but an installed app is never held
  back to it: an app that has updated itself is newer than the cask, which is expected.

To remove it, `brew uninstall --cask district-ai`. Add `--zap` to remove what only this
download leaves behind, Sparkle's update cache. The app's own settings and data live in
its sandbox container, `~/Library/Containers/com.distronode.district`, which the Mac App
Store build of the same app shares, so `--zap` leaves them in place; delete that folder
yourself once neither build is installed.

### bridgewatch

bridgewatch has no updater of its own, so `brew upgrade` is how it is kept current: the
cask follows bridgewatch's releases, and `brew upgrade` installs the newer one.

To remove it, `brew uninstall --cask bridgewatch`. Add `--zap` to also remove its
settings and state (`~/Library/Application Support/bridgewatch`), its logs
(`~/Library/Logs/bridgewatch`) and, if "Launch at login" was on, its login item
(`~/Library/LaunchAgents/bridgewatch.plist`). The tokens it reads live in your login
keychain, which `--zap` does not touch.

## District AI without an account with us

Today District AI for Mac needs a District AI account to sign in. We want the
District AI apps to work without an account with us too. We have not worked out what
that looks like or whether it can work, and the answer depends on what people would
use them with, so we are asking before we build anything:
[tell us what you would connect them to](https://github.com/distronode-corporation/.github/discussions/1).

## What is in this repository

| Path | What it is |
| --- | --- |
| `Casks/` | The casks: `district-ai.rb`, District AI for Mac, and `bridgewatch.rb`, bridgewatch. |
| `.github/workflows/audit.yml` | `brew style` and `brew audit` on every cask, zizmor on the workflows, gitleaks over the whole history, a hygiene check, and on macOS the online audit with the download, `brew livecheck`, an install, a launch and `uninstall --zap`. |
| `.github/workflows/bump.yml` | Daily: proposes the cask for the latest district-macos release, after checking the `.dmg` against `SHA256SUMS`, the release's asset digest and its provenance attestation. |
| `.github/scripts/district-ai-cask.sh` | Writes `Casks/district-ai.rb`; the one place the cask's text lives. |
| `.github/workflows/bump-bridgewatch.yml` | Daily: proposes the cask for the latest bridgewatch release, after checking the `.dmg` against the release's asset digest and its provenance attestation (bridgewatch publishes no `SHA256SUMS`). |
| `.github/scripts/bridgewatch-cask.sh` | Writes `Casks/bridgewatch.rb`; the one place the cask's text lives. |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard, the result behind the badge above. |

Each app's source, its build and its releases live in its own repository,
[district-macos](https://github.com/distronode-corporation/district-macos) and
[bridgewatch](https://github.com/distronode-corporation/bridgewatch). Distronode's
other open-source work is listed at <https://www.distronode.com/open-source>.

## Contributing, security and conduct

- [CONTRIBUTING.md](CONTRIBUTING.md): how a cask change is proposed, the local gate
  (`brew style`, `brew audit --strict --os all --arch all`, a real install and
  `uninstall --zap` on a Mac) and the rules CI enforces.
- [SECURITY.md](.github/SECURITY.md): report vulnerabilities privately, through
  [GitHub's private vulnerability reporting](https://github.com/distronode-corporation/homebrew-tap/security/advisories/new),
  never in a public issue.
- [CODE_OF_CONDUCT.md](.github/CODE_OF_CONDUCT.md).
- [SUPPORT](.github/SUPPORT.md): a problem with an app itself goes to its repository
  ([district-macos](https://github.com/distronode-corporation/district-macos/issues) or
  [bridgewatch](https://github.com/distronode-corporation/bridgewatch/issues)), a
  problem installing it through Homebrew to this repository's
  [Issues](https://github.com/distronode-corporation/homebrew-tap/issues), and questions
  to [Discussions](https://github.com/distronode-corporation/homebrew-tap/discussions).
- [CHANGELOG.md](CHANGELOG.md).

Questions about a District AI account, number or bill go to
[District AI support](https://www.distronode.com/support).

## License and trademarks

The contents of this repository are under the BSD 2-Clause licence (see
[LICENSE](LICENSE)), the licence Homebrew itself and its own taps use. The apps the
casks install have their own licences, in their repositories.

District AI, Distronode and the District AI and Distronode logos and app icons are
trademarks of Distronode Corporation. They are not licensed under the BSD 2-Clause
licence. This tap is not affiliated with or endorsed by the Homebrew project.
