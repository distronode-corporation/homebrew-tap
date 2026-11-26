# Security Policy

## Reporting a vulnerability

Please report privately, not in a public issue.

- **Preferred:** GitHub's private vulnerability reporting. Open the repository's
  **Security** tab and choose **Report a vulnerability**, or go straight to
  <https://github.com/distronode-corporation/homebrew-tap/security/advisories/new>.
- **Fallback:** email **opensource@distronode.com** if you cannot use GitHub.

Include what you did, what happened, and what you expected. A proof of concept is
welcome but not required. Never include a real token, session or anyone's personal
data; if one is part of the problem, say where it appeared, not what it was.

Expect an acknowledgement within a few working days. The rest of the process
(assessment, a fix with a test that fails without it, a GitHub security advisory and a
CHANGELOG entry) is the organization's
[vulnerability response](https://github.com/distronode-corporation/.github/blob/main/GOVERNANCE.md#vulnerability-response),
which applies here. Reporters are credited in the advisory and in the CHANGELOG entry
for the fix, unless they ask to stay anonymous. There is no paid bug bounty.

## What this repository is responsible for

This repository holds Homebrew casks (`Casks/district-ai.rb`, `Casks/bridgewatch.rb`)
and a formula (`Formula/worldinmotion.rb`), which are recipes: each one names a download
URL, the SHA-256 that download must have, and how to install and remove the app or
tool (and, for the formula, how to test it). It also holds the workflows and scripts
that check and update those recipes. It holds no binaries.
[SECURITY-MODEL.md](../SECURITY-MODEL.md) describes how an install is protected and the
assurance case behind it.

In scope, for example:

- A cask that downloads from anywhere other than the app's own GitHub Releases.
- The formula downloading from anywhere other than the npm registry's tarball of the
  worldinmotion release it names.
- A recipe whose `sha256` does not match the file it downloads, or that skips the
  check (`sha256 :no_check`).
- A cask whose install, uninstall or `zap` steps touch anything outside the app's own
  files, or a formula that installs or removes anything outside Homebrew's prefix.
- A bump workflow that would propose a recipe without the checks it documents (the
  checksum, the asset digest, the provenance attestation).
- A workflow in `.github/workflows` that could be made to run untrusted code with
  this repository's token, or that leaks a credential.
- A release tag that `gitsign verify-tag` accepts but that this repository's
  `release.yml` did not sign.

Out of scope:

- Vulnerabilities in the District AI app itself. Report those privately in
  [district-macos](https://github.com/distronode-corporation/district-macos/security/advisories/new).
- Vulnerabilities in bridgewatch itself. Report those privately in
  [bridgewatch](https://github.com/distronode-corporation/bridgewatch/security/advisories/new).
- Vulnerabilities in worldinmotion (the `wim` command) itself. Report those privately in
  [worldinmotion](https://github.com/distronode-corporation/worldinmotion/security/advisories/new).
- Vulnerabilities in the District AI service. Report those privately to the contact
  published in <https://www.distronode.com/.well-known/security.txt>.
- Homebrew's own security model. Report those to
  [Homebrew](https://github.com/Homebrew/brew/security/policy).

## Supported versions

Only the recipes on `main` are supported, and each one names its project's latest
release. A fix lands on `main`, and so reaches everyone at their next `brew update`,
with its CHANGELOG entry, which makes `release.yml` tag it; older tags are not patched.
