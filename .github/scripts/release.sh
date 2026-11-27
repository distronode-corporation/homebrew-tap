#!/usr/bin/env bash
#
# The two decisions release.yml makes, kept here so they are tested:
#
#   .github/scripts/release.sh next-tag <YYYY-MM-DD> [existing tag ...]
#     Print the next CalVer tag for that UTC day: YYYY.MM.DD.N, where N is one more
#     than the highest N any existing tag of that day has (1 for the day's first).
#     Existing tags that are not of the form YYYY.MM.DD.N are ignored.
#
#   .github/scripts/release.sh notes <previous tag | ""> <commit>
#     Print the release notes for <commit>, run inside the repository: the lines
#     CHANGELOG.md gained between <previous tag> and <commit>. With no previous tag
#     (the first release), the newest dated section of CHANGELOG.md at <commit>.
set -euo pipefail

die() {
  echo "FATAL - $*" >&2
  exit 1
}

changelog=CHANGELOG.md
tag_re='^([0-9]{4})\.([0-9]{2})\.([0-9]{2})\.([1-9][0-9]*)$'

next_tag() {
  [ "$#" -ge 1 ] || die "usage: release.sh next-tag <YYYY-MM-DD> [existing tag ...]"
  local day="$1"
  shift
  [[ "$day" =~ ^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]] || die "date '$day' is not YYYY-MM-DD."
  local prefix="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
  local highest=0 tag n
  for tag in "$@"; do
    [[ "$tag" =~ $tag_re ]] || continue
    [ "${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}" = "$prefix" ] || continue
    n="${BASH_REMATCH[4]}"
    if ((n > highest)); then highest="$n"; fi
  done
  echo "$prefix.$((highest + 1))"
}

notes() {
  [ "$#" = "2" ] || die "usage: release.sh notes <previous tag | \"\"> <commit>"
  local previous="$1" commit="$2" lines
  [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || die "commit '$commit' is not a full commit SHA."
  git cat-file -e "$commit^{commit}" 2>/dev/null || die "commit $commit is not in this repository."
  if [ -z "$previous" ]; then
    # The first release: the newest dated section, from its heading to the next one.
    lines="$(git show "$commit:$changelog" | awk '/^## / { n++ } n == 1 { print }')"
    [ -n "$lines" ] || die "$changelog at $commit has no dated section."
    printf '%s\n' "$lines"
    return
  fi
  [[ "$previous" =~ $tag_re ]] || die "previous tag '$previous' is not YYYY.MM.DD.N."
  git rev-parse --verify --quiet "refs/tags/$previous" >/dev/null || die "tag $previous is not in this repository."
  # Added lines only: `+` lines of a zero-context diff, minus the `+++` file header.
  # One line: xtrace reports a pipeline split across lines on its last line only, so
  # bashcov would count the first as never run.
  lines="$(git diff --no-color --unified=0 "refs/tags/$previous" "$commit" -- "$changelog" | sed -n -e '/^+++ /d' -e 's/^+//p')"
  if [ -z "$lines" ]; then
    echo "No $changelog entries since $previous."
    return
  fi
  printf '%s\n' "$lines"
}

[ "$#" -ge 1 ] || die "usage: release.sh next-tag|notes ..."
command="$1"
shift
case "$command" in
  next-tag) next_tag "$@" ;;
  notes) notes "$@" ;;
  *) die "unknown command '$command'; use next-tag or notes." ;;
esac
