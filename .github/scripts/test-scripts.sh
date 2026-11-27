#!/usr/bin/env bash

# SPDX-FileCopyrightText: Distronode Corporation
#
# SPDX-License-Identifier: BSD-2-Clause

#
# Tests for the scripts in .github/scripts:
#
#   .github/scripts/test-scripts.sh
#
# - Each generator, round trip: the version and sha256 are read back out of the
#   committed recipe, the generator is run with them, and its output must be the
#   committed file byte for byte. A recipe edited by hand, or a generator changed
#   without regenerating its recipe, fails here.
# - Each generator, refusals: a wrong number of arguments, a version, build or sha256
#   that is not one, and text that would break out of the sed substitution must exit
#   non-zero with a FATAL message and print nothing on stdout.
# - changelog-add.sh: every placement rule and every refusal, on scratch copies.
# - release.sh: the CalVer tag rule and the release notes, in a scratch repository.
#
# Run from the repository root. It needs bash, git, awk, sed and grep, and writes only
# under a temporary directory it removes. Exit status 0 means every test passed.
# coverage.sh runs this file under bashcov to measure the scripts it exercises.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
scripts="$root/.github/scripts"
work="$(mktemp -d "${TMPDIR:-/tmp}/tap-script-tests.XXXXXX")"
trap 'rm -rf "$work"' EXIT

passed=0
failed=0
ok() {
  passed=$((passed + 1))
  echo "ok - $1"
}
not_ok() {
  failed=$((failed + 1))
  echo "not ok - $1"
  if [ -n "${2:-}" ]; then
    printf '%s\n' "$2" | sed 's/^/    /'
  fi
}

# expect_refusal <name> <command ...>: the command exits non-zero, says FATAL on stderr
# and prints nothing on stdout.
expect_refusal() {
  local name="$1" status=0
  shift
  "$@" >"$work/out" 2>"$work/err" || status=$?
  if [ "$status" -ne 0 ] && grep -q '^FATAL - ' "$work/err" && [ ! -s "$work/out" ]; then
    ok "$name"
  else
    not_ok "$name" "status $status; stdout: $(cat "$work/out"); stderr: $(cat "$work/err")"
  fi
}

# expect_same <name> <expected file> <actual file>
expect_same() {
  if cmp -s "$2" "$3"; then
    ok "$1"
  else
    not_ok "$1" "$(diff -u "$2" "$3" || true)"
  fi
}

# recipe_value <file> <stanza>: the quoted value of a two-space-indented stanza.
recipe_value() {
  sed -n "s/^  $2 \"\(.*\)\"\$/\1/p" "$1"
}

good_sha="$(printf '%064d' 0 | tr 0 a)"

### Generators: round trip

cask="$root/Casks/district-ai.rb"
version="$(recipe_value "$cask" version)"
"$scripts/district-ai-cask.sh" "${version%,*}" "${version#*,}" "$(recipe_value "$cask" sha256)" >"$work/district-ai.rb"
expect_same "district-ai-cask.sh regenerates Casks/district-ai.rb" "$cask" "$work/district-ai.rb"

cask="$root/Casks/bridgewatch.rb"
"$scripts/bridgewatch-cask.sh" "$(recipe_value "$cask" version)" "$(recipe_value "$cask" sha256)" >"$work/bridgewatch.rb"
expect_same "bridgewatch-cask.sh regenerates Casks/bridgewatch.rb" "$cask" "$work/bridgewatch.rb"

formula="$root/Formula/worldinmotion.rb"
version="$(sed -n 's|^  url "https://registry.npmjs.org/worldinmotion/-/worldinmotion-\(.*\)\.tgz"$|\1|p' "$formula")"
"$scripts/worldinmotion-formula.sh" "$version" "$(recipe_value "$formula" sha256)" >"$work/worldinmotion.rb"
expect_same "worldinmotion-formula.sh regenerates Formula/worldinmotion.rb" "$formula" "$work/worldinmotion.rb"

### Generators: every placeholder is filled

"$scripts/district-ai-cask.sh" 9.8.7 12345 "$good_sha" >"$work/out"
if grep -q '@[A-Z0-9]*@' "$work/out"; then
  not_ok "district-ai-cask.sh fills every placeholder" "$(grep '@[A-Z0-9]*@' "$work/out")"
elif grep -qx '  version "9.8.7,12345"' "$work/out" && grep -qx "  sha256 \"$good_sha\"" "$work/out"; then
  ok "district-ai-cask.sh fills every placeholder"
else
  not_ok "district-ai-cask.sh fills every placeholder" "$(cat "$work/out")"
fi

"$scripts/bridgewatch-cask.sh" 9.8 "$good_sha" >"$work/out"
if ! grep -q '@[A-Z0-9]*@' "$work/out" && grep -qx '  version "9.8"' "$work/out"; then
  ok "bridgewatch-cask.sh fills every placeholder"
else
  not_ok "bridgewatch-cask.sh fills every placeholder" "$(cat "$work/out")"
fi

"$scripts/worldinmotion-formula.sh" 9.8.7 "$good_sha" >"$work/out"
if ! grep -q '@[A-Z0-9]*@' "$work/out" && grep -qF 'worldinmotion-9.8.7.tgz' "$work/out"; then
  ok "worldinmotion-formula.sh fills every placeholder"
else
  not_ok "worldinmotion-formula.sh fills every placeholder" "$(cat "$work/out")"
fi

### Generators: refusals

for bad in "" "1" "1.2.3.4" "v1.2.3" "1.2.3-beta" "1.2/e" "1.2;rm" $'1.2\n3' " 1.2"; do
  expect_refusal "district-ai-cask.sh refuses version '${bad//$'\n'/\\n}'" "$scripts/district-ai-cask.sh" "$bad" 1 "$good_sha"
  expect_refusal "bridgewatch-cask.sh refuses version '${bad//$'\n'/\\n}'" "$scripts/bridgewatch-cask.sh" "$bad" "$good_sha"
done
for bad in "" "1.2" "1.2.3.4" "v1.2.3" "1.2.3-beta" "1.2.3/e" $'1.2.3\n'; do
  expect_refusal "worldinmotion-formula.sh refuses version '${bad//$'\n'/\\n}'" "$scripts/worldinmotion-formula.sh" "$bad" "$good_sha"
done
for bad in "" "x" "1.0" "-1" "12a" "1/e"; do
  expect_refusal "district-ai-cask.sh refuses build '$bad'" "$scripts/district-ai-cask.sh" 1.0 "$bad" "$good_sha"
done
for bad in "" "${good_sha:1}" "${good_sha}a" "$(printf '%064d' 0 | tr 0 A)" "$(printf '%063d' 0 | tr 0 a)/" "sha256:$good_sha"; do
  expect_refusal "district-ai-cask.sh refuses sha256 '$bad'" "$scripts/district-ai-cask.sh" 1.0 1 "$bad"
  expect_refusal "bridgewatch-cask.sh refuses sha256 '$bad'" "$scripts/bridgewatch-cask.sh" 1.0 "$bad"
  expect_refusal "worldinmotion-formula.sh refuses sha256 '$bad'" "$scripts/worldinmotion-formula.sh" 1.0.0 "$bad"
done
expect_refusal "district-ai-cask.sh refuses two arguments" "$scripts/district-ai-cask.sh" 1.0 1
expect_refusal "district-ai-cask.sh refuses four arguments" "$scripts/district-ai-cask.sh" 1.0 1 "$good_sha" x
expect_refusal "bridgewatch-cask.sh refuses no arguments" "$scripts/bridgewatch-cask.sh"
expect_refusal "bridgewatch-cask.sh refuses three arguments" "$scripts/bridgewatch-cask.sh" 1.0 "$good_sha" x
expect_refusal "worldinmotion-formula.sh refuses one argument" "$scripts/worldinmotion-formula.sh" 1.0.0
expect_refusal "worldinmotion-formula.sh refuses three arguments" "$scripts/worldinmotion-formula.sh" 1.0.0 "$good_sha" x

### changelog-add.sh

add="$scripts/changelog-add.sh"

# fixture <name>: a small changelog with two dated days, the newest with one section.
fixture() {
  cat >"$work/$1" <<'EOF'
# Changelog

Preamble.

## 2026-01-02

### Changed

- older change

## 2026-01-01

### Added

- first
EOF
}

# expect_changelog <name> <file> <expected text>
expect_changelog() {
  printf '%s\n' "$3" >"$work/expected"
  expect_same "$1" "$work/expected" "$2"
}

fixture new-day.md
# shellcheck disable=SC2016 # the backquotes are Markdown, meant literally
"$add" "$work/new-day.md" 2026-01-03 Changed '`x` 1.0: x 1.0' >/dev/null
# shellcheck disable=SC2016 # the same literal Markdown
expect_changelog "changelog-add.sh puts a new day above the newest" "$work/new-day.md" '# Changelog

Preamble.

## 2026-01-03

### Changed

- `x` 1.0: x 1.0

## 2026-01-02

### Changed

- older change

## 2026-01-01

### Added

- first'

fixture same-section.md
"$add" "$work/same-section.md" 2026-01-02 Changed 'newer change' >/dev/null
expect_changelog "changelog-add.sh puts an entry first in the day's own section" "$work/same-section.md" '# Changelog

Preamble.

## 2026-01-02

### Changed

- newer change
- older change

## 2026-01-01

### Added

- first'

fixture new-section.md
"$add" "$work/new-section.md" 2026-01-02 Fixed 'a fix' >/dev/null
expect_changelog "changelog-add.sh adds a section the day lacks, at the end of the day" "$work/new-section.md" '# Changelog

Preamble.

## 2026-01-02

### Changed

- older change

### Fixed

- a fix

## 2026-01-01

### Added

- first'

printf '# Changelog\n\n## 2026-01-01\n\n### Added\n\n- first\n' >"$work/last-day.md"
"$add" "$work/last-day.md" 2026-01-01 Removed 'gone' >/dev/null
expect_changelog "changelog-add.sh adds a section to a day that ends the file" "$work/last-day.md" '# Changelog

## 2026-01-01

### Added

- first

### Removed

- gone'

printf '# Changelog\n\n## 2026-01-01\n\n### Added\n' >"$work/bare-section.md"
"$add" "$work/bare-section.md" 2026-01-01 Added 'only' >/dev/null
expect_changelog "changelog-add.sh fills an empty section that ends the file" "$work/bare-section.md" '# Changelog

## 2026-01-01

### Added

- only'

printf '# Changelog\n\n## 2026-01-01\n\n### Added\n- tight\n' >"$work/tight.md"
"$add" "$work/tight.md" 2026-01-01 Added 'first' >/dev/null
expect_changelog "changelog-add.sh handles a section with no blank line under its heading" "$work/tight.md" '# Changelog

## 2026-01-01

### Added
- first
- tight'

fixture literal.md
# shellcheck disable=SC2016 # text that must NOT expand, which is the test
"$add" "$work/literal.md" 2026-01-03 Security 'a \n b & c \\ d $(e) `f`' >/dev/null
# shellcheck disable=SC2016 # the same text, matched literally
if grep -qxF -- '- a \n b & c \\ d $(e) `f`' "$work/literal.md"; then
  ok "changelog-add.sh writes the entry literally (backslashes, &, \$(...), backquotes)"
else
  not_ok "changelog-add.sh writes the entry literally (backslashes, &, \$(...), backquotes)" "$(cat "$work/literal.md")"
fi

fixture again.md
cp "$work/again.md" "$work/again-before.md"
status=0
"$add" "$work/again.md" 2026-01-02 Changed 'older change' >"$work/out" 2>&1 || status=$?
if [ "$status" = 0 ] && cmp -s "$work/again.md" "$work/again-before.md" && grep -q 'nothing added' "$work/out"; then
  ok "changelog-add.sh adds nothing when the entry is already there"
else
  not_ok "changelog-add.sh adds nothing when the entry is already there" "status $status; $(cat "$work/out")"
fi

fixture mode.md
chmod 644 "$work/mode.md"
"$add" "$work/mode.md" 2026-01-03 Added 'mode' >/dev/null
if [ "$(stat -c %a "$work/mode.md" 2>/dev/null || stat -f %Lp "$work/mode.md")" = 644 ] && [ -z "$(find "$work" -name 'mode.md.*')" ]; then
  ok "changelog-add.sh keeps the file's mode and leaves no temporary file"
else
  not_ok "changelog-add.sh keeps the file's mode and leaves no temporary file" "$(ls -l "$work")"
fi

# The real CHANGELOG.md must stay a file the bump workflows can add to.
cp "$root/CHANGELOG.md" "$work/real.md"
newest="$(grep -m 1 '^## ' "$work/real.md" | cut -c4-)"
if "$add" "$work/real.md" "$newest" Changed 'test entry' >/dev/null && grep -qxF -- '- test entry' "$work/real.md"; then
  ok "changelog-add.sh can add to CHANGELOG.md (newest day $newest)"
else
  not_ok "changelog-add.sh can add to CHANGELOG.md (newest day $newest)"
fi

# Refusals leave the file as it was.
expect_refused_unchanged() {
  local name="$1" file="$2"
  shift 2
  cp "$file" "$work/before"
  expect_refusal "$name" "$@"
  if ! cmp -s "$work/before" "$file"; then
    not_ok "$name: the file is unchanged"
  fi
}
fixture refuse.md
expect_refused_unchanged "changelog-add.sh refuses a date older than the newest day" "$work/refuse.md" "$add" "$work/refuse.md" 2026-01-01 Added x
expect_refused_unchanged "changelog-add.sh refuses a date that is not YYYY-MM-DD" "$work/refuse.md" "$add" "$work/refuse.md" 2026-1-03 Added x
expect_refused_unchanged "changelog-add.sh refuses month 13" "$work/refuse.md" "$add" "$work/refuse.md" 2026-13-01 Added x
expect_refused_unchanged "changelog-add.sh refuses an unknown section" "$work/refuse.md" "$add" "$work/refuse.md" 2026-01-03 Misc x
expect_refused_unchanged "changelog-add.sh refuses an empty entry" "$work/refuse.md" "$add" "$work/refuse.md" 2026-01-03 Added ""
expect_refused_unchanged "changelog-add.sh refuses a two-line entry" "$work/refuse.md" "$add" "$work/refuse.md" 2026-01-03 Added $'a\nb'
expect_refused_unchanged "changelog-add.sh refuses a carriage return" "$work/refuse.md" "$add" "$work/refuse.md" 2026-01-03 Added $'a\rb'
expect_refusal "changelog-add.sh refuses a missing file" "$add" "$work/missing.md" 2026-01-03 Added x
expect_refusal "changelog-add.sh refuses three arguments" "$add" "$work/refuse.md" 2026-01-03 Added
printf '# Changelog\n\nNo days.\n' >"$work/no-day.md"
expect_refused_unchanged "changelog-add.sh refuses a file with no dated heading" "$work/no-day.md" "$add" "$work/no-day.md" 2026-01-03 Added x
printf '# Changelog\n\n## [Unreleased]\n\n## 2026-01-01\n' >"$work/unreleased.md"
expect_refused_unchanged "changelog-add.sh refuses a first heading that is not a date" "$work/unreleased.md" "$add" "$work/unreleased.md" 2026-01-03 Added x

### release.sh

release="$scripts/release.sh"

expect_output() {
  local name="$1" expected="$2" actual status=0
  shift 2
  actual="$("$@" 2>&1)" || status=$?
  if [ "$status" = 0 ] && [ "$actual" = "$expected" ]; then
    ok "$name"
  else
    not_ok "$name" "status $status; expected: $expected; got: $actual"
  fi
}

expect_output "release.sh next-tag starts a day at .1" 2026.11.26.1 "$release" next-tag 2026-11-26
expect_output "release.sh next-tag ignores other days and other tag shapes" 2026.11.26.1 \
  "$release" next-tag 2026-11-26 2026.11.25.4 v1.0.0 2026.11.26 2026.11.26.0 2026.11.26.x
expect_output "release.sh next-tag counts past the day's highest, not its count" 2026.11.26.11 \
  "$release" next-tag 2026-11-26 2026.11.26.2 2026.11.26.10 2026.11.26.9
expect_refusal "release.sh next-tag refuses a date that is not YYYY-MM-DD" "$release" next-tag 2026.11.26
expect_refusal "release.sh next-tag refuses no date" "$release" next-tag
expect_refusal "release.sh refuses no command" "$release"
expect_refusal "release.sh refuses an unknown command" "$release" publish

# A scratch repository with two releases' worth of CHANGELOG.md.
repo="$work/repo"
git init --quiet "$repo"
g() { git -C "$repo" -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false -c tag.gpgsign=false "$@"; }
printf '# Changelog\n\n## 2026-01-01\n\n### Added\n\n- first\n' >"$repo/CHANGELOG.md"
g add CHANGELOG.md
g commit --quiet -m one
g tag 2026.01.01.1
one="$(g rev-parse HEAD)"
"$add" "$repo/CHANGELOG.md" 2026-01-02 Changed 'second' >/dev/null
"$add" "$repo/CHANGELOG.md" 2026-01-02 Changed 'third' >/dev/null
printf 'other\n' >"$repo/other.txt"
g add CHANGELOG.md other.txt
g commit --quiet -m two
two="$(g rev-parse HEAD)"

# in_repo <arguments>: release.sh run from inside the scratch repository.
in_repo() { (cd "$repo" && "$release" "$@"); }

expect_output "release.sh notes: the first release is the newest dated section" '## 2026-01-01

### Added

- first' in_repo notes "" "$one"
expect_output "release.sh notes: the lines CHANGELOG.md gained since the previous tag" '## 2026-01-02

### Changed

- third
- second' in_repo notes 2026.01.01.1 "$two"
expect_output "release.sh notes: says so when CHANGELOG.md gained nothing" \
  'No CHANGELOG.md entries since 2026.01.01.1.' in_repo notes 2026.01.01.1 "$one"
expect_refusal "release.sh notes refuses a short commit SHA" in_repo notes "" "${two:0:12}"
expect_refusal "release.sh notes refuses a commit not in the repository" in_repo notes "" "$(printf '%040d' 0)"
expect_refusal "release.sh notes refuses a previous tag that is not CalVer" in_repo notes v1.0.0 "$two"
expect_refusal "release.sh notes refuses a previous tag that does not exist" in_repo notes 2025.01.01.1 "$two"
expect_refusal "release.sh notes refuses one argument" in_repo notes "$two"
printf '# Changelog\n\nNo days.\n' >"$repo/CHANGELOG.md"
g commit --quiet -am none
expect_refusal "release.sh notes refuses a first release with no dated section" in_repo notes "" "$(g rev-parse HEAD)"

echo
echo "$passed passed, $failed failed"
[ "$failed" = 0 ]
