# Distronode Homebrew tap

The [Homebrew](https://brew.sh) tap for Distronode's macOS apps. It will carry one cask,
`district-ai`: [District AI for macOS](https://github.com/distronode-corporation/district-macos),
the native desktop client for [District AI](https://www.distronode.com/district-ai).

> **The tap is empty for now.** The `district-ai` cask arrives with the first macOS
> release. Until then `brew install` below reports that no cask by that name exists.

## Install

```sh
brew install distronode-corporation/tap/district-ai
```

That taps this repository and installs the cask in one step. To tap it on its own first:

```sh
brew tap distronode-corporation/tap
brew install --cask district-ai
```

The cask installs the same file as the app's GitHub Releases: a universal (Apple silicon
and Intel) `.dmg`, signed with Distronode's Developer ID and notarised by Apple.
Homebrew checks the download against the SHA-256 recorded in the cask before it
installs anything.

## Updates

The app updates itself. It checks Distronode's update feed with
[Sparkle](https://sparkle-project.org), and every update is signed, so the app installs
only an update Distronode published.

The cask says so with `auto_updates true`, which means:

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
| `Casks/` | The casks. Empty until the first macOS release. |
| `.github/workflows/audit.yml` | `brew style` and `brew audit` on every cask, zizmor on the workflows, gitleaks over the whole history, and a hygiene check. |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard. It runs once the repository is public. |

The app's source, its build and its releases live in
[district-macos](https://github.com/distronode-corporation/district-macos). Distronode's
other open-source work is listed at <https://www.distronode.com/open-source>.

## Reporting a problem

- **A problem with the app itself:** report it in
  [district-macos](https://github.com/distronode-corporation/district-macos).
- **A problem installing through Homebrew** (the cask, the tap): open an issue here.
- **A security vulnerability:** report it privately, never in a public issue. See
  [SECURITY.md](.github/SECURITY.md).

## Licence

The contents of this repository are under the BSD 2-Clause licence (see
[LICENSE](LICENSE)), the licence Homebrew itself and its own taps use. The app the
cask installs has its own licence, in its repository.
