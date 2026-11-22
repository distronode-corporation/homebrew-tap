# Security model

How this tap protects the people who install from it. To report a vulnerability, see
[SECURITY.md](.github/SECURITY.md).

## Pinned checksums

Every cask and formula pins its download by SHA-256 (`sha256` in `Casks/*.rb` and
`Formula/*.rb`). Homebrew checks the download against that value before it installs
anything, so a changed file at the same URL fails the install. `sha256 :no_check` is
never used.

## Where the checksums come from

The checksum is computed from the file the recipe downloads, never copied from
elsewhere. The bump workflows only propose a change after checking that file:

| Recipe | Download | Checked by | Checks |
| --- | --- | --- | --- |
| `district-ai` | `.dmg` from district-macos's GitHub Release | [`bump.yml`](.github/workflows/bump.yml) | SHA-256 equals the release's `SHA256SUMS` entry and GitHub's asset digest; build provenance attestation verifies |
| `bridgewatch` | `.dmg` from bridgewatch's GitHub Release | [`bump-bridgewatch.yml`](.github/workflows/bump-bridgewatch.yml) | SHA-256 equals GitHub's asset digest; build provenance attestation verifies (no `SHA256SUMS` is published) |
| `worldinmotion` | npm registry tarball | [`bump-worldinmotion.yml`](.github/workflows/bump-worldinmotion.yml) | tarball matches the registry's integrity and its npm provenance attestation verifies; the `wim.mjs` inside matches the GitHub Release's `SHA256SUMS`, asset digest and build provenance attestation |

Each attestation check uses `gh attestation verify` with
`--signer-workflow <project>/.github/workflows/release.yml`, `--source-ref refs/tags/<tag>`
and `--deny-self-hosted-runners`, so the file must have been built by that project's
release workflow, from the release tag, on a GitHub-hosted runner.

A bump lands as a pull request, and `audit.yml` (`brew style`, `brew audit`, a real
install) runs on it before it merges.

## After install

- **District AI** updates itself with Sparkle (`auto_updates true`), and every update is
  signed; see [distronode-corporation/updates](https://github.com/distronode-corporation/updates).
- **District AI** and the app inside the **bridgewatch** `.dmg` are notarised by Apple.

## Out of scope

The apps themselves, their builds and their releases live in their own repositories
(district-macos, bridgewatch, worldinmotion), and their security is described there.
