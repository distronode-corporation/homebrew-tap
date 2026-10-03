<!-- Thanks for the contribution. Delete any section that genuinely does not apply. -->

## What changed

<!-- One or two sentences. The diff says what; this says it in words. -->

## Why

<!-- The problem, not the patch. If it fixes an issue, link it (Fixes #123). -->

## How it was tested

<!-- Commands you actually ran, and what they said. "Should work" is not a test.
     CI's `audit` workflow runs the first two on every cask, plus zizmor, gitleaks
     and the hygiene check. -->

- [ ] `brew style distronode-corporation/tap`
- [ ] `brew audit --strict --tap distronode-corporation/tap`
- [ ] For a cask change: `brew install --cask distronode-corporation/tap/district-ai`
      on a Mac, the app launched, and `brew uninstall --cask --zap district-ai`
      left nothing behind
- [ ] For a version bump: the `sha256` was computed from the release's own `.dmg`
      (`shasum -a 256`), not copied from somewhere else
- [ ] An entry under `[Unreleased]` in CHANGELOG.md

## Anything a reviewer should know

<!-- A decision you were unsure about, something you deliberately left out, a follow-up
     you think is needed. Saying "I could not test X" here is useful, not a problem. -->
