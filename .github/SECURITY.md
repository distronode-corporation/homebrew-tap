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

Expect an acknowledgement within a few working days. There is no paid bug bounty;
what you get is credit in the changelog entry for the fix, if you want it.

## What this repository is responsible for

This repository holds Homebrew casks, which are recipes: each one names a download
URL, the SHA-256 that download must have, and how to install and remove the app. It
holds no binaries.

In scope, for example:

- A cask that downloads from anywhere other than the app's own GitHub Releases.
- A cask whose `sha256` does not match the release it names, or that skips the check
  (`sha256 :no_check`).
- A cask whose install, uninstall or `zap` steps touch anything outside the app's own
  files.
- A workflow in `.github/workflows` that could be made to run untrusted code with
  this repository's token, or that leaks a credential.

Out of scope:

- Vulnerabilities in the District AI app itself. Report those privately in
  [district-macos](https://github.com/distronode-corporation/district-macos/security/advisories/new).
- Vulnerabilities in the District AI service. Report those privately to the contact
  published in <https://www.distronode.com/.well-known/security.txt>.
- Homebrew's own security model. Report those to
  [Homebrew](https://github.com/Homebrew/brew/security/policy).

## Supported versions

Only the cask on `main` is supported. It always names the latest release of the app.
