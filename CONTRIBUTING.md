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

How the repository fits together is in [ARCHITECTURE.md](ARCHITECTURE.md). Who decides,
the roles and how a change is accepted are in the organization's
[GOVERNANCE.md](https://github.com/distronode-corporation/.github/blob/main/GOVERNANCE.md),
which applies here.

## Setup

You need [Homebrew](https://brew.sh) (macOS or Linux) and git. Homebrew works on its own
clone of the tap, so develop in that clone with your fork as a second remote:

```sh
brew tap distronode-corporation/tap
cd "$(brew --repository distronode-corporation/tap)"
git remote add fork https://github.com/<you>/homebrew-tap.git
git switch -c <branch>
```

Homebrew now reads your edits to `Casks/` and `Formula/` directly, so the local gate
below checks exactly what you changed. Set `HOMEBREW_NO_AUTO_UPDATE=1` while you work,
so an automatic `brew update` leaves the checkout alone. Push your branch with
`git push fork <branch>` and open the pull request from it. When you are done,
`git switch main` puts the tap back on `main`.

For the scripts and workflows you also need ShellCheck and actionlint
(`brew install shellcheck actionlint`), and to measure the script coverage, jq and
Ruby 3.2 or later with the `bashcov` gem (`gem install bashcov`); see the local gate.

## How a cask or formula change is proposed

Every change is a pull request against `main`. Nothing is pushed to `main` directly.

1. Fork the repository, or branch if you have write access.
2. Make the change under `Casks/` or `Formula/`. A cask or a formula is one `.rb` file;
   neither directory holds anything else (CI's hygiene check rejects any other file
   there).
3. Run the local gate below and say in the pull request what it printed.
4. Add a line to [CHANGELOG.md](CHANGELOG.md) under today's UTC date (newest first,
   with a Keep a Changelog section such as `### Added` or `### Fixed`). The helper the
   bump workflows use does it for you:
   `.github/scripts/changelog-add.sh CHANGELOG.md "$(date -u +%F)" Fixed "what changed"`.
5. Open the pull request and fill in the template.

A change comes with its test, in the same pull request:

- A new formula comes with a `test do` block that runs the installed tool, which CI
  runs on Linux and macOS.
- A new cask is covered by the macOS install, launch and `--zap` job, and gets its own
  generator in `.github/scripts`, its own bump workflow and a round-trip test in
  `test-scripts.sh`.
- A change to a script in `.github/scripts` comes with a test in `test-scripts.sh`; a
  bug fix adds a test that fails without the fix.
- A fix to a workflow comes with a check that fails without it (as the planted bad
  cask does for the `--os all --arch all` audit).

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

A change to `.github/scripts` or `.github/workflows` also needs the linters and the
script tests, which CI runs as the `lint` and `script tests` jobs:

```sh
shellcheck --severity=style .github/scripts/*.sh
actionlint
.github/scripts/test-scripts.sh
.github/scripts/coverage.sh   # needs bashcov and jq; fails below 80 percent
```

`test-scripts.sh` needs only bash, git and the usual text tools. It regenerates every
recipe from its own version and checksum and compares it byte for byte, so a recipe
edited without its generator (or the other way round) fails it.

## Coding standards

- **Casks and formulae:** Homebrew's
  [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook) and
  [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook), as enforced by `brew style`
  (RuboCop with Homebrew's cops) and `brew audit --strict`.
- **Shell scripts:** Bash with `set -euo pipefail`, clean under ShellCheck at
  `--severity=style`. A script that writes a recipe uses a quoted heredoc template and
  allowlists every value it substitutes.
- **Workflows:** clean under actionlint and zizmor; actions pinned to a full commit SHA
  with the version in a comment; least-privilege `permissions:` per job; untrusted
  values reach `run:` blocks through `env:`, never through `${{ }}` inside the script.
- **Everything:** [.editorconfig](.editorconfig), and no en or em dashes.

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

Each bump writes its own CHANGELOG.md line in the same commit as the recipe, with
`.github/scripts/changelog-add.sh`. GitHub Actions may not open pull requests in this
repository, so a bump run pushes its `bump/<name>-<version>` branch, dispatches
`audit.yml` on it and then fails with a link that opens the pull request; a maintainer
opens it, and a code owner approves it like any other change. Two bump pull requests
open at once both add to the top of CHANGELOG.md, so the second needs its branch
updated, and that conflict resolved, after the first merges.

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

- **brew style and audit:** `brew style` and `brew audit --strict --os all --arch all`
  over every cask and formula, and the same audit run against a planted bad cask, which
  it must fail.
- **Linux install and test:** every formula installed, tested and removed on Linux.
- **macOS install and zap:** on macOS, the online audit and `brew livecheck` for every
  cask and formula, then every cask installed, launched and zapped, and every formula
  installed, tested and removed.
- **zizmor:** static analysis of the workflows. Actions are pinned to a full commit SHA.
- **lint:** ShellCheck over `.github/scripts/*.sh` and actionlint over the workflows.
- **script tests:** `test-scripts.sh` under bashcov; fails on any failing test or below
  80 percent line coverage of the measured scripts.
- **gitleaks:** secrets anywhere in the history.
- **hygiene:** no en or em dashes in any tracked file (use commas, periods or
  parentheses), and `Casks/` and `Formula/` hold only `.rb` files.

The workflow reads no secrets, so a pull request from a fork runs exactly the same
checks; GitHub asks a maintainer to approve the first run for a first-time contributor.
Which checks must pass before a merge is set by the repository's ruleset.

## Releases

There is nothing to do by hand. A change reaches users when it merges to `main`. A
merge that changes CHANGELOG.md is tagged `YYYY.MM.DD.N` and signed by
[`release.yml`](.github/workflows/release.yml) when it lands. A merge that started no
workflow run (one pushed with a workflow's own token) is covered by the daily run,
which tags `main`'s head if CHANGELOG.md changed since the previous tag, so that merge
may share a tag with later ones. Each tag's GitHub Release lists the CHANGELOG lines
since the previous tag. A maintainer can also run it from the
Actions tab (`workflow_dispatch`, `main` only) to tag `main`'s head. How to verify a
tag is in [SECURITY-MODEL.md](SECURITY-MODEL.md#verifying-a-release).

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
