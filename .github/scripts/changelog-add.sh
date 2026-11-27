#!/usr/bin/env bash
#
# Add one entry to CHANGELOG.md, under a dated heading and a Keep a Changelog section.
#
#   .github/scripts/changelog-add.sh <file> <YYYY-MM-DD> <section> <entry>
#
# <section> is one of Added, Changed, Deprecated, Removed, Fixed, Security. <entry> is
# one line of Markdown, written as given after "- ".
#
# Called by the bump workflows (bump.yml, bump-bridgewatch.yml, bump-worldinmotion.yml)
# in the same commit as the recipe they write, so every bump carries its CHANGELOG line
# and release.yml's release notes (the lines CHANGELOG.md gained since the previous tag)
# include it. A person may run it too.
#
# Where the entry goes:
# - The newest dated heading (the first `## ` line) is <date>: under its `### <section>`,
#   first in that section, adding the section if the day has none yet.
# - The newest dated heading is older than <date>: a new `## <date>` heading above it.
# - The newest dated heading is NEWER than <date>, the file has no dated heading, or the
#   entry is already there word for word: refused, and the file is left as it was (an
#   existing identical entry is a success, so a re-run adds nothing).
set -euo pipefail

die() {
  echo "FATAL - $*" >&2
  exit 1
}

[ "$#" = "4" ] || die "usage: changelog-add.sh <file> <YYYY-MM-DD> <section> <entry>"
file="$1"
day="$2"
section="$3"
entry="$4"

[ -f "$file" ] || die "'$file' is not a file."
[[ "$day" =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]] || die "date '$day' is not YYYY-MM-DD."
case "$section" in
  # The pattern and its empty body on two lines: xtrace never reports a case pattern,
  # so bashcov counts a pattern line holding `;;` as code that never ran.
  Added | Changed | Deprecated | Removed | Fixed | Security)
    ;;
  *) die "section '$section' is not one of Added, Changed, Deprecated, Removed, Fixed, Security." ;;
esac
[ -n "$entry" ] || die "the entry is empty."
[[ "$entry" != *$'\n'* && "$entry" != *$'\r'* ]] || die "the entry is more than one line."

newest="$(grep -m 1 -E '^## ' "$file" || true)"
[ -n "$newest" ] || die "'$file' has no '## ' heading to add under."
[[ "$newest" =~ ^##\ ([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]] || die "the first '## ' heading in '$file' is '$newest', not a date."
latest="${BASH_REMATCH[1]}"
[[ ! "$latest" > "$day" ]] || die "'$file' already has $latest, newer than $day."

if grep -qxF -- "- $entry" "$file"; then
  echo "$file already has this entry; nothing added."
  exit 0
fi

# The values reach awk through the environment, never `-v`, which would interpret
# backslashes in the entry.
tmp="$(mktemp "$file.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
DAY="$day" SECTION="$section" ENTRY="$entry" awk '
  function section_block() {
    print "### " ENVIRON["SECTION"]
    print ""
    print "- " ENVIRON["ENTRY"]
  }
  # The first dated heading: either the day itself, or an older day that the new
  # heading goes above.
  !done && !inday && /^## / {
    if ($0 == "## " ENVIRON["DAY"]) {
      inday = 1
      print
      next
    }
    print "## " ENVIRON["DAY"]
    print ""
    section_block()
    print ""
    print
    done = 1
    next
  }
  # Inside the day: first in its own section, or a new section at the end of the day.
  inday && !done {
    if (pending) {
      if ($0 == "") {
        print
        print "- " ENVIRON["ENTRY"]
      } else {
        print "- " ENVIRON["ENTRY"]
        print
      }
      done = 1
      next
    }
    if ($0 == "### " ENVIRON["SECTION"]) {
      pending = 1
      print
      next
    }
    if (/^## /) {
      section_block()
      print ""
      print
      done = 1
      next
    }
  }
  { print }
  END {
    if (inday && !done) {
      if (pending) {
        print ""
        print "- " ENVIRON["ENTRY"]
      } else {
        print ""
        section_block()
      }
    }
  }
' "$file" >"$tmp"
# Written back over the file, not moved onto it, so the file keeps its own mode.
cat "$tmp" >"$file"
echo "$file: added under $day, $section: - $entry"
