# Distronode Homebrew tap

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/distronode-corporation/homebrew-tap/badge)](https://scorecard.dev/viewer/?uri=github.com/distronode-corporation/homebrew-tap)

The [Homebrew](https://brew.sh) tap for Distronode's macOS apps. It will carry one cask,
`district-ai`: [District AI for macOS](https://github.com/distronode-corporation/district-macos),
the native desktop client for [District AI](https://www.distronode.com/district-ai).

> **The tap is empty for now.** The `district-ai` cask arrives with the first
> GitHub Release of District AI for macOS. Until then the commands below do not work:
> `brew install` reports that no cask by that name exists.

## Install (once the cask exists)

When the first release is out and `Casks/district-ai.rb` is in this repository:

```sh
brew install distronode-corporation/tap/district-ai
```

That taps this repository and installs the cask in one step. Homebrew loads casks from
a tap it does not ship only once you trust them, and naming the cask in full, as above,
is what trusts it. If you tap first, keep the full name when you install:

```sh
brew tap distronode-corporation/tap
brew install --cask distronode-corporation/tap/district-ai
```

The cask installs the same file as the app's GitHub Releases: a universal (Apple silicon
and Intel) `.dmg`, signed with Distronode's Developer ID and notarised by Apple.
Homebrew checks the download against the SHA-256 recorded in the cask before it
installs anything.

## Updates

The app updates itself. It checks Distronode's update feed with
[Sparkle](https://sparkle-project.org), and every update is signed, so the app installs
only an update Distronode published.

The cask will say so with `auto_updates true`, which means:

- `brew upgrade` leaves District AI alone, because the app is already keeping itself
  current. `brew upgrade --greedy` (or `--greedy-auto-updates`) reinstalls it from the
  cask anyway.
- The version in the cask follows the releases, but an installed app is never held
  back to it: an app that has updated itself is newer than the cask, which is expected.

To remove it, `brew uninstall --cask district-ai`. Add `--zap` to remove the app's
preferences and caches too.

## Without an account with us

Today District AI for macOS needs a District AI account to sign in. We want the
District AI apps to work without an account with us too. We have not worked out what
that looks like or whether it can work, and the answer depends on what people would
use them with, so we are asking before we build anything:
[tell us what you would connect them to](https://github.com/distronode-corporation/.github/discussions/1).

## What is in this repository

| Path | What it is |
| --- | --- |
| `Casks/` | The casks. Empty until the first GitHub Release of District AI for macOS. |
| `.github/workflows/audit.yml` | `brew style` and `brew audit` on every cask, zizmor on the workflows, gitleaks over the whole history, and a hygiene check. |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard, the result behind the badge above. |

The app's source, its build and its releases live in
[district-macos](https://github.com/distronode-corporation/district-macos). Distronode's
other open-source work is listed at <https://www.distronode.com/open-source>.

## Contributing, security and conduct

- [CONTRIBUTING.md](CONTRIBUTING.md): how a cask change is proposed, the local gate
  (`brew style`, `brew audit --strict --os all --arch all`, a real install and
  `uninstall --zap` on a Mac) and the rules CI enforces.
- [SECURITY.md](.github/SECURITY.md): report vulnerabilities privately, through
  [GitHub's private vulnerability reporting](https://github.com/distronode-corporation/homebrew-tap/security/advisories/new),
  never in a public issue.
- [CODE_OF_CONDUCT.md](.github/CODE_OF_CONDUCT.md).
- [SUPPORT](.github/SUPPORT.md): a problem with the app itself goes to
  [district-macos](https://github.com/distronode-corporation/district-macos/issues), a
  problem installing it through Homebrew to this repository's
  [Issues](https://github.com/distronode-corporation/homebrew-tap/issues), and questions
  to [Discussions](https://github.com/distronode-corporation/homebrew-tap/discussions).
- [CHANGELOG.md](CHANGELOG.md).

Questions about a District AI account, number or bill go to
[District AI support](https://www.distronode.com/support).

## License and trademarks

The contents of this repository are under the BSD 2-Clause licence (see
[LICENSE](LICENSE)), the licence Homebrew itself and its own taps use. The app the
cask installs has its own licence, in its repository.

District AI, Distronode and the District AI and Distronode logos and app icons are
trademarks of Distronode Corporation. They are not licensed under the BSD 2-Clause
licence. This tap is not affiliated with or endorsed by the Homebrew project.
