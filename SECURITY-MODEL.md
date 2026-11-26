# Security model

How this tap protects the people who install from it, how to verify what it
publishes, and the assurance case: what is protected, from what, and why the design
holds. To report a vulnerability, see [SECURITY.md](.github/SECURITY.md). How the
pieces fit together is in [ARCHITECTURE.md](ARCHITECTURE.md).

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

## How dependencies are kept current

- **The recipes:** the three bump workflows run daily and propose each project's new
  release once it passes the checks above. A bump pushes a `bump/<name>-<version>`
  branch and dispatches `audit.yml` on it. GitHub Actions cannot approve pull requests
  in this repository, and may not open them, so a maintainer opens the pull request
  from the link the run prints; a code owner approves it like any other change.
- **The actions the workflows use:** pinned to full commit SHAs (the repository
  requires it), and [Dependabot](.github/dependabot.yml) proposes updates weekly, held
  back until a release is a week old. Dependabot security updates are on.
- **The tools CI installs** (ShellCheck, actionlint, gitleaks, gitsign, bashcov) are
  pinned to a version in the workflow, checked against a pinned SHA-256 or the Go
  checksum database, and updated by hand.
- `brew livecheck` runs weekly on every recipe in `audit.yml`, so a recipe that falls
  behind its project shows up even if a bump workflow stops.

## After install

- **District AI** updates itself with Sparkle (`auto_updates true`), and every update is
  signed; see [distronode-corporation/updates](https://github.com/distronode-corporation/updates).
- **District AI**'s `.dmg` is notarised by Apple. **bridgewatch**'s `.dmg` and the app
  inside it are both notarised, with the tickets stapled.
- **worldinmotion** is upgraded by `brew upgrade`; see the README for `wim setup` after
  an upgrade.

## Verifying a release

Homebrew reads no tags: `brew update` fetches `main` over HTTPS and every install is
checked against its recipe's `sha256`. The signed tags are for anyone who wants to
check that a state of the tap is one this repository's `release.yml` published. What
keeps a tag pointing where it was created is the repository's tag ruleset, which
refuses moving or deleting a tag; repository admins can bypass it, and the signature
alone would not reveal a tag ref moved onto a different, validly signed tag object, so
check the tag's own name too (below). The tags do not stand apart from GitHub
account security: a change that reaches `main` through a compromised maintainer or
owner account, and records a CHANGELOG line, is tagged and signed like any other, and
the command below accepts it, because it checks the workflow's identity, not who
approved the change. The review that gates `main` is what protects against that (see
the assurance case below).

[`release.yml`](.github/workflows/release.yml) tags merges to `main` that change
CHANGELOG.md as `YYYY.MM.DD.N` (the UTC date, then a counter from 1) and signs the tag
keylessly with [gitsign](https://github.com/sigstore/gitsign). Sigstore's Fulcio issues
a short-lived certificate for the workflow's own GitHub OIDC identity, and the signature
is recorded in Sigstore's public Rekor transparency log, so there is no long-lived
private key at all, on GitHub or anywhere else. The identity in the certificate is the
workflow file on `main`:

- certificate identity:
  `https://github.com/distronode-corporation/homebrew-tap/.github/workflows/release.yml@refs/heads/main`
- certificate OIDC issuer: `https://token.actions.githubusercontent.com`

To verify a tag, install gitsign (`brew install gitsign`), then in a clone of this
repository:

```sh
git fetch --tags origin
gitsign verify-tag <tag> \
  --certificate-identity https://github.com/distronode-corporation/homebrew-tap/.github/workflows/release.yml@refs/heads/main \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

A good tag prints `Validated Git signature: true`, `Validated Rekor entry: true` and
`Validated Certificate claims: true`, and the command exits 0. The tag's name is part
of what was signed, so also check that `git cat-file tag <tag> | sed -n 's/^tag //p'`
prints exactly `<tag>`: a ref moved onto another signed release tag fails that check.
A merge is tagged when it lands, with two exceptions where it shares a later tag
instead: one that started no workflow run (pushed with a workflow's own token), which
the daily run covers by tagging `main`'s head, and one whose run was still waiting
when a newer merge's run queued behind the same release (GitHub cancels the older
waiting run). Either way its CHANGELOG lines are in that later tag's release notes. `release.yml` runs this
same command on every tag before it pushes it. GitHub's web page shows these tags as
unverified, because GitHub does not trust Sigstore's certificate authority; the command
above is the check.

To compare the tap you have installed with a tag, run the same commands in Homebrew's
own clone of the tap (`cd "$(brew --repository distronode-corporation/tap)"`), then
check that `git rev-parse HEAD` equals `git rev-parse <tag>^{commit}`, that
`git diff --quiet <tag>` exits 0 (no tracked file differs from the tag, committed or
not), and that `git status --porcelain --untracked-files=all --ignored` prints nothing
(no extra files, including ones a local ignore rule hides). A file you created
yourself, such as `.DS_Store` or a `coverage/` directory from the script tests, shows
up there too: delete it, or confirm it is not under `Casks/` or `Formula/`, the only
directories Homebrew reads recipes from. Each tag's GitHub Release lists the CHANGELOG
lines it added.

## Assurance case

The claim: someone who runs `brew install distronode-corporation/tap/<name>` gets the
file that project's own release workflow built, or the install fails. The argument is
in five parts.

### What is protected

- The recipes on `main`: each one's download URL, its `sha256`, and its install,
  uninstall, `zap` and test steps. These are the only part of the repository Homebrew
  executes on a user's machine.
- The path by which a recipe changes: the bump workflows, their branches, `audit.yml`
  and the pull request review.
- The repository's workflow token, which can write branches and tags when a workflow
  is granted that.
- The release tags, as the signed record of what `main` held.

### Threats considered

1. A compromised upstream release: a replaced or added asset on a project's GitHub
   Release, or a tampered npm tarball.
2. A man in the middle between a user and GitHub or the npm registry.
3. A malicious pull request, including one from a fork, that changes a recipe or a
   workflow.
4. Injection into a workflow: untrusted text (a release name, a tag, an asset name)
   reaching a shell command or a recipe template.
5. A compromised or careless maintainer account, or a bot account, merging a change on
   its own.
6. A leaked credential in the repository or its history.
7. A forged release tag.

Out of scope: a compromised Homebrew client or a compromised GitHub itself; the apps'
own vulnerabilities (reported to their repositories, see SECURITY.md).

### Trust boundaries

| Boundary | What crosses it | What is checked there |
| --- | --- | --- |
| Upstream release to bump workflow | A `.dmg` or npm tarball, its `SHA256SUMS`, digest and attestation | Every check in the table above, fail closed; the version, build and tag must match fixed patterns before any is used |
| Bump workflow to the recipe file | A version, a build number and a SHA-256 | The generator's own allowlist (`^[0-9]+(\.[0-9]+){1,2}$`, `^[0-9a-f]{64}$` and similar), and a quoted template, so nothing else can reach the file |
| A fork's pull request to CI | Untrusted recipe and workflow changes | `audit.yml` runs on `pull_request` with a read-only token and no secrets; no workflow uses `pull_request_target` |
| A pull request to `main` | Any change | The default branch ruleset: a code owner's approval after the last push, the required checks, every review thread resolved, no force push |
| `main` to a user's machine | The recipes, by `brew update` over HTTPS | Homebrew checks each download against the recipe's `sha256` before installing |
| `main` to a release tag | A commit | A gitsign signature under `release.yml`'s OIDC identity, verified before the push, recorded in Rekor; the tag ruleset forbids moving or deleting it |

### Secure design principles applied

- **Least privilege.** Every workflow starts from `permissions: {}` or `contents:
  read`, and each job is granted only what it uses: `audit.yml` only reads; a bump job
  may push its branch, dispatch `audit.yml` and open a pull request; `release.yml`'s
  `id-token: write` is on its signing job only. No workflow reads a secret other than
  its own job token, except the public hygiene check's one key, mapped by name. Every
  checkout sets `persist-credentials: false`, and a push hands the token to git for
  that one command only.
- **Fail closed.** A bump stops at the first mismatch (checksum, digest, attestation,
  version pattern, tag name) and proposes nothing. The changelog helper and the
  generators refuse input they do not recognise and leave the file as it was.
  `release.yml` does not push a tag that fails verification.
- **Complete mediation.** Homebrew checks the `sha256` on every install, not once.
- **Economy of mechanism.** Each recipe's text lives in exactly one generator script,
  so a bump can change only the version and the checksum; the test suite proves the
  committed recipe is what its generator writes.
- **Separation of duty.** No workflow can approve a pull request (the repository's
  Actions setting), a code owner's approval is required and must come after the last
  push, and the account that pushed a change cannot be the one that approves it.
- **Defence in depth.** Upstream provenance, the asset digest and `SHA256SUMS` are
  checked independently; static analysis (CodeQL, zizmor, actionlint, ShellCheck) and
  dynamic checks (real installs, `brew test`, launch and `--zap`) both gate a change.

### Common weaknesses countered

| Weakness | Where it could appear | Countered by |
| --- | --- | --- |
| CWE-494, download of code without an integrity check | Any recipe | A pinned `sha256` on every recipe, `:no_check` never used, `brew audit --strict` |
| CWE-345, insufficient verification of data authenticity | A bump taking an upstream file on trust | Attestation verification bound to the upstream release workflow, tag and a GitHub-hosted runner, plus the digest and `SHA256SUMS` |
| CWE-319, cleartext transmission | Recipe URLs | Every URL is HTTPS; `brew audit --strict` and the online audit check them |
| CWE-78 and CWE-94, command or code injection | The generators' templates, workflow `run:` blocks | Quoted heredoc templates filled only by `sed` from allowlisted values; untrusted values reach `run:` blocks through `env:`, never `${{ }}` inside the script; zizmor and CodeQL's `actions` queries check for template injection |
| CWE-250 and CWE-272, excessive privilege | Workflow tokens | Per-job permissions; no `pull_request_target`; zizmor's permission audits |
| CWE-798 and CWE-522, embedded or leaked credentials | The repository and its history | gitleaks over the whole history on every push and pull request, GitHub secret scanning with push protection |
| CWE-829, inclusion of functionality from an untrusted source | Third-party actions and CI tools | Actions pinned by full SHA (repository-enforced), an allowlist of actions, tools pinned by version and checksum |
| CWE-347, improper verification of a signature | A forged release tag | `gitsign verify-tag` with the exact identity and issuer above, run before every push |

### What remains

- Homebrew does not verify the tap's commits or tags: `brew update` trusts GitHub's
  HTTPS and the repository's access controls. The signed tags let a user check after
  the fact; they do not stop a bad `main` from being fetched.
- A recipe is only as trustworthy as its project's release workflow, which this
  repository verifies but does not control.
- One maintainer approves every change today, so a compromise of that account together
  with an owner account could land a change; the organization's continuity and access
  rules are in its [GOVERNANCE.md](https://github.com/distronode-corporation/.github/blob/main/GOVERNANCE.md#continuity).

## Out of scope

The apps themselves, their builds and their releases live in their own repositories
(district-macos, bridgewatch, worldinmotion), and their security is described there.
