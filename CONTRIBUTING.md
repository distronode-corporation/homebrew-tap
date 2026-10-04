# Contributing to the Distronode Homebrew tap

Thanks for helping. The [README](README.md) covers what the tap is and how to install
from it. This file is the rules a change has to meet.

This repository holds casks, which are recipes: a download URL, the SHA-256 that
download must have, and how to install and remove the app. The app itself, its build
and its releases live in
[district-macos](https://github.com/distronode-corporation/district-macos). A bug in the
app goes there, not here.

## How a cask change is proposed

Every change is a pull request against `main`. Nothing is pushed to `main` directly.

1. Fork the repository, or branch if you have write access.
2. Make the change under `Casks/`. A cask is one `.rb` file; `Casks/` holds nothing else
   (CI's hygiene check rejects any other file there).
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

CI cannot install a macOS app, so a change to what a cask installs or removes also needs
a real run on a Mac:

```sh
brew install --cask distronode-corporation/tap/district-ai
# launch the app once, then
brew uninstall --cask --zap district-ai
```

Check that the app launched, and that `--zap` left nothing of the app's own behind.
Say which macOS version and which chip (Apple silicon or Intel) you ran it on.

## Versions and checksums

Casks are meant to be bumped by automation from district-macos releases. That workflow
is planned and not in this repository yet; until it is, a maintainer bumps the cask by
hand, and once it is, a bump by hand should be rare. Either way the `sha256` is computed
from the release's own `.dmg`, downloaded from its GitHub Release:

```sh
shasum -a 256 DistrictAI-<version>-<build>.dmg
```

Never copy a checksum from anywhere else, and never use `sha256 :no_check`. A cask
downloads only from the app's own GitHub Releases.

## Rules CI enforces

The [`audit`](.github/workflows/audit.yml) workflow runs on every push to `main`, every
pull request and once a week:

- **brew:** `brew style` and `brew audit --strict --os all --arch all` over every cask.
- **zizmor:** static analysis of the workflows. Actions are pinned to a full commit SHA.
- **gitleaks:** secrets anywhere in the history.
- **hygiene:** no en or em dashes in any tracked file (use commas, periods or
  parentheses), and `Casks/` holds only `.rb` files.

The workflow reads no secrets, so a pull request from a fork runs exactly the same
checks; GitHub asks a maintainer to approve the first run for a first-time contributor.

## Commits

Conventional Commits are not required. What is required is that the message says
**why**: the diff already says what.

Maintainers commit as `Distronode <opensource@distronode.com>`. Contributors commit
under their own name; there is no CLA and no sign-off requirement.

## Reporting bugs and asking questions

Use the bug report form for a problem installing, upgrading or removing the cask.
Questions and ideas go to
[Discussions](https://github.com/distronode-corporation/homebrew-tap/discussions), and a
problem with the app itself goes to
[district-macos's issues](https://github.com/distronode-corporation/district-macos/issues).
For anything security-relevant, do not open an issue; see
[SECURITY.md](.github/SECURITY.md).

## Licence of contributions

By contributing you agree that your contribution is licensed under the BSD 2-Clause
licence that covers this repository (see [LICENSE](LICENSE)).
