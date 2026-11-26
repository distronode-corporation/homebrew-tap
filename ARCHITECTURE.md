# Architecture

How the tap is put together: what Homebrew reads from it, where each recipe comes
from, and where every check sits. What each check protects against is in
[SECURITY-MODEL.md](SECURITY-MODEL.md); the rules a change must meet are in
[CONTRIBUTING.md](CONTRIBUTING.md).

## What a tap is to Homebrew

A tap is a git repository of recipes that Homebrew clones and reads. `brew tap
distronode-corporation/tap` (or the first `brew install distronode-corporation/tap/...`)
clones `https://github.com/distronode-corporation/homebrew-tap` into Homebrew's own
directory, and `brew update` fetches its `main` from then on. Homebrew reads two
directories:

- `Casks/`: one Ruby file per cask (a macOS app shipped as a `.dmg`):
  `district-ai.rb` and `bridgewatch.rb`.
- `Formula/`: one Ruby file per formula (a command-line tool): `worldinmotion.rb`.

Each file is Homebrew's cask or formula DSL: a version, a download URL, the SHA-256 of
that download, and how to install, remove and (for the formula) test it. Homebrew does
all the downloading, checking and installing; nothing in this repository runs on a
user's machine except those recipes, inside Homebrew. The tap builds nothing and
ships no binaries.

## Where each recipe comes from

No recipe is edited by hand in the normal course. Each is printed by one generator
script in `.github/scripts`, from validated inputs, and proposed by one bump workflow:

| Recipe | Generator | Bump workflow | Source of releases |
| --- | --- | --- | --- |
| `Casks/district-ai.rb` | `district-ai-cask.sh <version> <build> <sha256>` | `bump.yml` | district-macos GitHub Releases |
| `Casks/bridgewatch.rb` | `bridgewatch-cask.sh <version> <sha256>` | `bump-bridgewatch.yml` | bridgewatch GitHub Releases |
| `Formula/worldinmotion.rb` | `worldinmotion-formula.sh <version> <sha256>` | `bump-worldinmotion.yml` | npm's `latest` worldinmotion, matched to its GitHub Release |

The generator holds the recipe's whole text as a quoted template and fills in only
the version, build and checksum, each first checked against a fixed pattern. So a bump
can change those values and nothing else, and `test-scripts.sh` proves that each
committed recipe is exactly what its generator prints for its own values.

## The flow of a change

```text
upstream release (GitHub Release or npm)
  |
  |  bump workflow, daily: download, verify checksum + digest + provenance attestation
  v
bump/<name>-<version> branch: the regenerated recipe + its CHANGELOG.md line
  |
  |  audit.yml dispatched on the branch; a maintainer opens the pull request
  v
pull request to main
  |
  |  audit.yml, codeql.yml, review-threads.yml and public-hygiene.yml report;
  |  a code owner approves; the default branch ruleset decides when it can merge
  v
main
  |----> release.yml (when CHANGELOG.md changed): signed tag YYYY.MM.DD.N + GitHub Release
  |
  |  brew update (HTTPS)
  v
the user's Homebrew: download, check the sha256, install
```

A change by a person (a new recipe, a workflow fix, documentation) enters at "pull
request to main" and goes through the same checks.

## Where each check sits

| Check | Workflow and job | Runs on | What it looks at |
| --- | --- | --- | --- |
| Checksum, digest, provenance | the bump workflows | schedule, dispatch | the upstream file, before any recipe is written |
| Generator input patterns | the generators | every bump | version, build, checksum |
| `brew style`, `brew audit --strict --os all --arch all`, a planted bad cask | `audit.yml`, `brew style and audit` | push to main, pull request, weekly, dispatch | every recipe, and that the audit really audits a macOS-only cask on Linux |
| Install, `brew test`, uninstall | `audit.yml`, `Linux install and test` | as above | every formula on Linux |
| Online audit, livecheck, install, codesign and Gatekeeper, launch, `uninstall --zap`; formula install and test | `audit.yml`, `macOS install and zap` | as above | every cask and formula on macOS |
| ShellCheck, actionlint | `audit.yml`, `lint` | as above | `.github/scripts/*.sh`, every workflow and its `run:` blocks |
| Script tests, 80 percent line coverage | `audit.yml`, `script tests` | as above | the generators, `changelog-add.sh`, `release.sh` |
| zizmor | `audit.yml`, `zizmor` | as above | the workflows |
| gitleaks | `audit.yml`, `gitleaks` | as above | the whole git history |
| No en or em dashes; `Casks/` and `Formula/` hold only recipes | `audit.yml`, `hygiene` | as above | every tracked file |
| CodeQL (`actions`, security-extended) | `codeql.yml` | pull request, push to main that changes a workflow, weekly | the workflows |
| Review threads resolved | `review-threads.yml` (`review-threads` status) | pull request events, every 15 minutes | every review thread |
| Public text | `public-hygiene.yml` | issue, pull request, discussion and release events | titles, descriptions, comments, commit messages |
| OpenSSF Scorecard | `scorecard.yml` | weekly, push to main | repository posture |
| Tag signature | `release.yml`, `signed tag` | each new tag | `gitsign verify-tag` with the documented identity |

Which of these must pass before a pull request can merge is set by the repository's
default branch ruleset, not by the workflows.

## The supporting scripts

| Script | Used by | Does |
| --- | --- | --- |
| `.github/scripts/changelog-add.sh` | the bump workflows | adds one line to CHANGELOG.md under today's date and a Keep a Changelog section |
| `.github/scripts/release.sh` | `release.yml` | the next `YYYY.MM.DD.N` tag, and the release notes (the CHANGELOG lines since the previous tag) |
| `.github/scripts/test-scripts.sh` | `audit.yml`, `script tests` | the tests for every script above and the three generators |
| `.github/scripts/coverage.sh` | `audit.yml`, `script tests` | runs the tests under bashcov and enforces the 80 percent floor |
