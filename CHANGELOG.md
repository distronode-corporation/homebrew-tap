# Changelog

All notable changes to this tap are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). A
change reaches people who install from the tap when it merges to `main`, because
`brew update` fetches `main`. Entries are grouped under the UTC date they were written,
newest first, so the first `## ` heading is always a date.

Each version bump of a cask or the formula records its own line here, written by its
bump workflow in the same commit as the recipe (`.github/scripts/changelog-add.sh`).
Each merge to `main` that changes this file is tagged `YYYY.MM.DD.N` and signed by
[`release.yml`](.github/workflows/release.yml) (on the push, or at its daily run), and that tag's GitHub Release lists the
lines this file gained since the previous tag. How to verify a tag is in
[SECURITY-MODEL.md](SECURITY-MODEL.md#verifying-a-release).

## 2026-11-26

### Added

- `release.yml`: each merge to `main` that changes this file (on the push, or at the
  workflow's daily run) gets a CalVer tag
  (`YYYY.MM.DD.N`) signed keylessly with gitsign under the workflow's own identity, and
  a GitHub Release whose notes are the lines this file gained since the previous tag.
  The workflow verifies the signature with the documented command before it pushes
  the tag.
- `lint` job in `audit.yml`: ShellCheck (`--severity=style`) over every shell script
  and actionlint over every workflow.
- `script tests` job in `audit.yml`: `.github/scripts/test-scripts.sh` regenerates
  each recipe from its own version and checksum and compares it byte for byte, checks
  that every generator refuses bad input, and tests the CHANGELOG and release helpers;
  it runs under bashcov and fails below 80 percent line coverage of the scripts it
  measures.
- A planted control for the `--os all --arch all` audit in the `brew style and audit`
  job: a cask with known audit errors is added to the tap's checkout and the audit must
  fail on it.
- `ARCHITECTURE.md` (how the tap is put together and where each check sits).
- `SECURITY-MODEL.md` gains the assurance case (assets, threats, trust boundaries,
  design principles, weaknesses countered, residual risk) and how to verify a release.
- CONTRIBUTING: a development setup section, the coding standards and the rule that a
  change comes with a test.

### Changed

- The bump workflows write the bump's CHANGELOG line in the bump commit, with
  `.github/scripts/changelog-add.sh`.
- This file: entries are dated by the day they were written, the `[Unreleased]`
  section is gone, and every bump since 2026-10-13 is recorded.
- SECURITY.md covers the casks and the formula, worldinmotion included, and links the
  organization's vulnerability response process.
- README: bridgewatch's `.dmg` is notarised as well as the app inside it; a link to the
  governance document.
- The issue form config covers the formula and links worldinmotion's issues.

## 2026-11-23

### Changed

- `worldinmotion` 1.0.3: worldinmotion 1.0.3
  ([release notes](https://github.com/distronode-corporation/worldinmotion/releases/tag/v1.0.3)).

## 2026-11-22

### Added

- `ROADMAP.md` (the next twelve months, and what is not planned) and `SECURITY-MODEL.md`
  (how the pinned `sha256` and the bump workflows' checks protect an install).

## 2026-11-19

### Changed

- `bridgewatch` 2.2.0: bridgewatch 2.2.0
  ([release notes](https://github.com/distronode-corporation/bridgewatch/releases/tag/v2.2.0)).

## 2026-11-17

### Changed

- `worldinmotion` 1.0.2: worldinmotion 1.0.2
  ([release notes](https://github.com/distronode-corporation/worldinmotion/releases/tag/v1.0.2)).

## 2026-11-16

### Added

- `review-threads.yml`: the organization's review threads check, a `review-threads`
  commit status that is red while any review thread on a pull request is unresolved.

### Changed

- `worldinmotion` 1.0.1: worldinmotion 1.0.1
  ([release notes](https://github.com/distronode-corporation/worldinmotion/releases/tag/v1.0.1)).
- `worldinmotion` 1.0.0: worldinmotion 1.0.0
  ([release notes](https://github.com/distronode-corporation/worldinmotion/releases/tag/v1.0.0)).

## 2026-11-15

### Changed

- `bridgewatch` 2.1.0: bridgewatch 2.1.0
  ([release notes](https://github.com/distronode-corporation/bridgewatch/releases/tag/v2.1.0)).

## 2026-11-14

### Changed

- Pinned actions updated by Dependabot (the `actions-minor` group).

## 2026-11-09

### Added

- `worldinmotion` 0.2.0, the tap's first formula (`Formula/worldinmotion.rb`):
  worldinmotion's `wim` command, from the npm registry's tarball of the release, with
  Homebrew's `node`. Its test runs `wim --version`, writes the deployment kit the
  tarball carries, and runs `wim test` (a relay on loopback and two throwaway devices).
- `bump-worldinmotion.yml` and `worldinmotion-formula.sh`: proposes the formula for npm's
  latest `worldinmotion` once the tarball matches the registry's integrity and its npm
  provenance attestation verifies, and the `wim.mjs` inside it matches the GitHub
  Release's `SHA256SUMS` and asset digest and its attestation verifies; a version older
  than the formula's is refused. It dispatches `audit.yml` on the branch.
- `audit.yml` is formula-aware: `brew style` and `brew audit` cover `Formula/` (each
  formula also by name), a new `Linux install and test` job installs, tests and removes
  every formula, and the macOS job adds the online audit, `brew livecheck`, an install,
  `brew test` and an uninstall for every formula. The hygiene check holds `Formula/` to
  `.rb` files as it does `Casks/`.

### Changed

- `worldinmotion` 0.2.1: worldinmotion 0.2.1
  ([release notes](https://github.com/distronode-corporation/worldinmotion/releases/tag/v0.2.1)).
- README, CONTRIBUTING, SUPPORT and the issue and pull request templates describe the
  formula beside the casks.
- The public hygiene check is pinned to the organization's v1.3.0, then v1.4.0.

## 2026-11-08

### Changed

- `bridgewatch` 2.0.0: bridgewatch 2.0.0
  ([release notes](https://github.com/distronode-corporation/bridgewatch/releases/tag/v2.0.0)).

## 2026-11-06

### Added

- `bump-bridgewatch.yml` and `bridgewatch-cask.sh`: the pipeline for a second cask,
  `bridgewatch`. It proposes `Casks/bridgewatch.rb` for each new bridgewatch release once
  its universal `.dmg` matches the asset digest GitHub records and its provenance
  attestation verifies (bridgewatch publishes no `SHA256SUMS`), and dispatches
  `audit.yml` on the branch so the pull request's checks report.
- `bridgewatch` 1.2.0, the cask's first version
  ([release notes](https://github.com/distronode-corporation/bridgewatch/releases/tag/v1.2.0)).
- `public-hygiene.yml`: the organization's public hygiene check on this repository's
  issue, pull request, discussion and release text.

### Changed

- `bridgewatch` 1.3.0: bridgewatch 1.3.0
  ([release notes](https://github.com/distronode-corporation/bridgewatch/releases/tag/v1.3.0)).
- `district-ai` 3.3.0,20102: District AI for Mac 3.3.0
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.3.0)).
- README and CONTRIBUTING describe both casks: bridgewatch has no updater (so no
  `auto_updates`).

## 2026-11-01

### Changed

- The README opens with the Distronode logo, in a light and a dark version.

## 2026-10-31

### Changed

- Pinned actions updated by Dependabot (the `actions-minor` group).

## 2026-10-28

### Changed

- `district-ai` 3.1.0,20088: District AI for Mac 3.1.0
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.1.0)).

## 2026-10-27

### Changed

- Pinned actions updated by Dependabot (the `actions-minor` group).

## 2026-10-24

### Changed

- CODEOWNERS: @seandean is the code owner of every path, so every change is approved
  by a code owner.

## 2026-10-23

### Changed

- `district-ai` 3.0.3,20077: District AI for Mac 3.0.3
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.0.3)).

## 2026-10-21

### Changed

- Pinned actions updated by Dependabot (the `actions-minor` group).

## 2026-10-16

### Changed

- `district-ai` 3.0.2,20068: District AI for Mac 3.0.2
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.0.2)).
- `district-ai` 3.0.1,20063: District AI for Mac 3.0.1
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.0.1)).

## 2026-10-15

### Changed

- `district-ai` 3.0.0,20056: District AI for Mac 3.0.0
  ([release notes](https://github.com/distronode-corporation/district-macos/releases/tag/v3.0.0)).
- README: the cask exists, so the install commands work; the app is named District AI
  for Mac.

## 2026-10-13

### Changed

- `district-ai` 2.0.1,20042: District AI for Mac 2.0.1.

## 2026-10-08

### Changed

- `district-ai` 2.0,20040: District AI for Mac 2.0.

## 2026-10-05

### Added

- `codeql.yml`: CodeQL code scanning of the workflows (`actions`, security-extended) on
  pushes to main that change them, on pull requests and weekly. No `ruby` leg: a cask
  is declarative DSL, which `brew style` and `brew audit` already check.

## 2026-10-04

### Added

- The org's public-repo standard files: CONTRIBUTING.md, `.github/SUPPORT.md`, a
  cask bug report form and an issue config with blank issues off; the README gains the
  OpenSSF Scorecard badge and the standard "Contributing, security and conduct" and
  "License and trademarks" sections, and states the install commands as working only
  once the cask exists.
- `bump.yml`: proposes `Casks/district-ai.rb` for each new district-macos release once
  its `.dmg` matches `SHA256SUMS` and the asset digest and its attestation verifies,
  and dispatches `audit.yml` on the branch so the pull request's checks report.
- `audit.yml`: a macOS job that, for every cask, runs the online audit with
  `--signing`, `brew livecheck`, installs it, launches the app and removes it with
  `uninstall --zap`.
- `district-ai` 1.0,20024: the cask, for District AI for Mac 1.0, the app's first
  GitHub Release.

## 2026-10-03

### Added

- The tap: README, licence, security policy, code of conduct, and the audit workflow
  (`brew style` and `brew audit` on every cask, zizmor, gitleaks and a hygiene check).
  No casks yet; `district-ai` arrives with the first release of District AI for macOS.
