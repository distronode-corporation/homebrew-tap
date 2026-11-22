# Roadmap

This roadmap covers the next twelve months, to November 2027.

The tap carries the casks and formula listed in the [README](README.md) and follows
each project's releases. Most of its work is that automation, so the plan is short.

## Planned

- Keep `district-ai`, `bridgewatch` and `worldinmotion` current through their daily bump
  workflows, each checking the download against the release's checksums and provenance
  attestation before it proposes a change.
- Keep `audit.yml` passing on every push and pull request: `brew style`,
  `brew audit --strict --os all --arch all`, the Linux and macOS installs, zizmor and
  gitleaks.
- Add a cask or formula when another Distronode project publishes a release that
  Homebrew can install, with its own bump workflow that verifies the release the same
  way.

## Not planned

- `sha256 :no_check`, or a checksum copied from anywhere other than the downloaded file.
- Downloads from anywhere other than the project's own GitHub Releases (casks) or the
  npm registry's tarball of the release (the formula).
- Casks or formulae for software Distronode does not publish.
