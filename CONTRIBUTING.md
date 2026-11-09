# Contributing to the Distronode Homebrew tap

Thanks for helping. The [README](README.md) covers what the tap is and how to install
from it. This file is the rules a change has to meet.

This repository holds casks and formulae, which are recipes: a download URL, the
SHA-256 that download must have, and how to install and remove the app or tool (and, for
a formula, how to test it). Each one's source, its build and its releases live in its own
repository: [district-macos](https://github.com/distronode-corporation/district-macos)
for `district-ai`, [bridgewatch](https://github.com/distronode-corporation/bridgewatch)
for `bridgewatch` and
[worldinmotion](https://github.com/distronode-corporation/worldinmotion) for the
`worldinmotion` formula. A bug in an app or tool goes there, not here.

## How a cask or formula change is proposed

Every change is a pull request against `main`. Nothing is pushed to `main` directly.

1. Fork the repository, or branch if you have write access.
2. Make the change under `Casks/` or `Formula/`. A cask or a formula is one `.rb` file;
   neither directory holds anything else (CI's hygiene check rejects any other file
   there).
3. Run the local gate below and say in the pull request what it printed.
4. Add a line under `[Unreleased]` in [CHANGELOG.md](CHANGELOG.md).
5. Open the pull request and fill in the template.

## The local gate

With the tap linked to your checkout (or tapped from your fork), run:

```sh
brew style distronode-corporation/tap
brew audit --strict --os all --arch all --tap distronode-corporation/tap
```

`--os all --arch all` is load-bearing: without it, an audit on a machine that does not
match a cask's `depends_on` can skip that cask and still exit 0. CI runs both commands
on every pull request, on Linux.

A change to a formula also needs a real install and its test, which CI runs on Linux and
on macOS and which you can run on either:

```sh
brew install --formula distronode-corporation/tap/<formula>
brew test distronode-corporation/tap/<formula>
brew uninstall --formula <formula>
```

CI cannot install a macOS app, so a change to what a cask installs or removes also needs
a real run on a Mac:

```sh
brew install --cask distronode-corporation/tap/<cask>
# launch the app once, then
brew uninstall --cask --zap <cask>
```

Check that the app launched, and that `--zap` removed what the cask lists:

- `district-ai`: Sparkle's update cache
  (`~/Library/Caches/com.distronode.district/org.sparkle-project.Sparkle`). It leaves the
  app's sandbox container on purpose: the Mac App Store build of the same app shares it.
- `bridgewatch`: `~/Library/Application Support/bridgewatch`,
  `~/Library/Logs/bridgewatch` and, if "Launch at login" was on,
  `~/Library/LaunchAgents/bridgewatch.plist`.

Say which macOS version and which chip (Apple silicon or Intel) you ran it on.

## Versions and checksums

Casks and the formula are bumped by automation from their projects' releases, one
workflow each:

- `district-ai`: [`bump.yml`](.github/workflows/bump.yml) runs daily, checks the latest
  district-macos release's `.dmg` against `SHA256SUMS`, the asset digest and its
  provenance attestation, and proposes the cask with
  [`district-ai-cask.sh`](.github/scripts/district-ai-cask.sh).
- `bridgewatch`: [`bump-bridgewatch.yml`](.github/workflows/bump-bridgewatch.yml) runs
  daily, checks the latest bridgewatch release's `.dmg` against the asset digest and its
  provenance attestation (bridgewatch publishes no `SHA256SUMS`), and proposes the cask
  with [`bridgewatch-cask.sh`](.github/scripts/bridgewatch-cask.sh).
- `worldinmotion`: [`bump-worldinmotion.yml`](.github/workflows/bump-worldinmotion.yml)
  runs daily, follows npm's latest `worldinmotion`, checks the tarball against the
  registry's integrity and its npm provenance attestation and the `wim.mjs` inside it
  against the GitHub Release's `SHA256SUMS`, asset digest and attestation, and proposes
  the formula with [`worldinmotion-formula.sh`](.github/scripts/worldinmotion-formula.sh).

A bump by hand should be rare. Either way the `sha256` is computed from the file the
recipe downloads: a cask's `.dmg` from its GitHub Release, the formula's tarball from the
npm registry:

```sh
shasum -a 256 DistrictAI-<version>-<build>.dmg
shasum -a 256 bridgewatch_<version>_universal.dmg
curl -fsSL https://registry.npmjs.org/worldinmotion/-/worldinmotion-<version>.tgz | shasum -a 256
```

Never copy a checksum from anywhere else, and never use `sha256 :no_check`. A cask
downloads only from the app's own GitHub Releases, and the formula only from the npm
registry's tarball of the release.

## Rules CI enforces

The [`audit`](.github/workflows/audit.yml) workflow runs on every push to `main`, every
pull request and once a week:

- **brew:** `brew style` and `brew audit --strict --os all --arch all` over every cask
  and formula.
- **Linux install and test:** every formula installed, tested and removed on Linux.
- **macOS install and zap:** on macOS, the online audit and `brew livecheck` for every
  cask and formula, then every cask installed, launched and zapped, and every formula
  installed, tested and removed.
- **zizmor:** static analysis of the workflows. Actions are pinned to a full commit SHA.
- **gitleaks:** secrets anywhere in the history.
- **hygiene:** no en or em dashes in any tracked file (use commas, periods or
  parentheses), and `Casks/` and `Formula/` hold only `.rb` files.

The workflow reads no secrets, so a pull request from a fork runs exactly the same
checks; GitHub asks a maintainer to approve the first run for a first-time contributor.

## Commits

Conventional Commits are not required. What is required is that the message says
**why**: the diff already says what.

Maintainers commit as `Distronode <opensource@distronode.com>`. Contributors commit
under their own name; there is no CLA and no sign-off requirement.

## Reporting bugs and asking questions

Use the bug report form for a problem installing, upgrading or removing a cask or the
formula.
Questions and ideas go to
[Discussions](https://github.com/distronode-corporation/homebrew-tap/discussions), and a
problem with an app or tool itself goes to its own issues
([district-macos](https://github.com/distronode-corporation/district-macos/issues),
[bridgewatch](https://github.com/distronode-corporation/bridgewatch/issues) or
[worldinmotion](https://github.com/distronode-corporation/worldinmotion/issues)).
For anything security-relevant, do not open an issue; see
[SECURITY.md](.github/SECURITY.md).

## Licence of contributions

By contributing you agree that your contribution is licensed under the BSD 2-Clause
licence that covers this repository (see [LICENSE](LICENSE)).
