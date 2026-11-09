# Changelog

All notable changes to this tap are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The tap
itself has no version: an entry is dated, and a cask version bump is recorded under the
day it landed.

## [Unreleased]

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

- `bump-bridgewatch.yml` and `bridgewatch-cask.sh`: the pipeline for a second cask,
  `bridgewatch`. It proposes `Casks/bridgewatch.rb` for each new bridgewatch release once
  its universal `.dmg` matches the asset digest GitHub records and its provenance
  attestation verifies (bridgewatch publishes no `SHA256SUMS`), and dispatches
  `audit.yml` on the branch so the pull request's checks report. The cask itself lands
  with its first bump.

### Changed

- README, CONTRIBUTING, SUPPORT and the issue and pull request templates describe the
  formula beside the casks.
- README and CONTRIBUTING describe both casks: bridgewatch has no updater (so no
  `auto_updates`), and its 1.2.0 `.dmg` is signed but not notarised while the app inside
  it is notarised and stapled.

- The README opens with the Distronode logo, in a light and a dark version.
- README: the cask exists and is at 2.0.1,20042, so the install commands work; the app is
  named District AI for Mac.

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
