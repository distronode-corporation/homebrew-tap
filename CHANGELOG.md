# Changelog

All notable changes to this tap are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The tap
itself has no version: an entry is dated, and a cask version bump is recorded under the
day it landed.

## [Unreleased]

### Added

- The tap: README, licence, security policy, code of conduct, and the audit workflow
  (`brew style` and `brew audit` on every cask, zizmor, gitleaks and a hygiene check).
  No casks yet; `district-ai` arrives with the first release of District AI for macOS.
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
