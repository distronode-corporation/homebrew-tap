# Roadmap

This roadmap covers the next twelve months, to November 2027.

The tap carries the casks and formula listed in the [README](README.md) and follows
each project's releases. Most of its work is that automation, so the plan is short.

## Planned

- Keep `district-ai`, `bridgewatch` and `worldinmotion` current through their daily bump
  workflows, each verifying the download before it proposes a change. For `district-ai` and
  `bridgewatch` that is the release's checksums and provenance attestation. For
  `worldinmotion` the npm tarball is checked against the registry's integrity and its npm
  provenance, and only the `wim.mjs` inside it is compared with the GitHub Release's
  SHA256SUMS and the release asset's attestation.
- Keep `audit.yml` passing on every push and pull request: `brew style`,
  `brew audit --strict --os all --arch all`, the Linux and macOS installs, zizmor,
  ShellCheck and actionlint, the script tests at or above their 80 percent coverage
  floor, and gitleaks.
- Keep signing a release tag for each change recorded in the CHANGELOG, verifiable with
  the command in SECURITY-MODEL.md.
- Add a cask or formula when another Distronode project publishes a release that
  Homebrew can install, with its own bump workflow that verifies the release the same
  way.

## Not planned

- `sha256 :no_check`, or a checksum copied from anywhere other than the downloaded file.
- Downloads from anywhere other than the project's own GitHub Releases (casks) or the
  npm registry's tarball of the release (the formula).
- Casks or formulae for software Distronode does not publish.
