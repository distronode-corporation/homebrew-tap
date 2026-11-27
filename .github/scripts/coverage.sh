#!/usr/bin/env bash
#
# Run test-scripts.sh under bashcov and fail below the line coverage floor:
#
#   .github/scripts/coverage.sh
#
# Measured: every script the tap ships or its workflows call, which is every .sh file
# in .github/scripts except the two that make up the test harness (test-scripts.sh and
# this file). A script added there is measured from its first commit. The floor is
# for the measured scripts taken together, and each one is reported on its own line.
#
# Needs bashcov (a Ruby gem, on PATH) and jq. The `script tests` job in audit.yml
# installs bashcov at a pinned version, checked against a pinned SHA-256. bashcov
# writes its report to coverage/ (ignored by git); coverage/index.html is the
# line-by-line view.
set -euo pipefail

floor=80

die() {
  echo "FATAL - $*" >&2
  exit 1
}

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"
command -v bashcov >/dev/null || die "bashcov is not on PATH (gem install bashcov)."
command -v jq >/dev/null || die "jq is not on PATH."

measured=()
for f in .github/scripts/*.sh; do
  case "$f" in
    .github/scripts/test-scripts.sh | .github/scripts/coverage.sh) ;;
    *) measured+=("$root/$f") ;;
  esac
done
((${#measured[@]} > 0)) || die "no scripts to measure in .github/scripts."

# SimpleCov's defaults drop every path that starts with a dot, which is all of
# .github/. Its one config file outside the project is ~/.simplecov, loaded after the
# defaults, so bashcov runs with HOME pointed at a scratch directory holding one that
# keeps only the filter for files outside the repository. The tests' git commands then
# see no global git config, which they do not need, and GEM_HOME and GEM_PATH (set by
# whoever installed bashcov) still find the gems.
config="$(mktemp -d "${TMPDIR:-/tmp}/tap-coverage.XXXXXX")"
trap 'rm -rf "$config"' EXIT
cat >"$config/.simplecov" <<'RUBY'
SimpleCov.configure do
  filters.clear
  skip { |source| !source.filename.start_with?("#{SimpleCov.root}/") }
end
RUBY

rm -rf coverage
HOME="$config" bashcov --root "$root" -- .github/scripts/test-scripts.sh

resultset=coverage/.resultset.json
[ -s "$resultset" ] || die "bashcov wrote no $resultset."

# SimpleCov's result set: per file, one entry per line, null for a line bashcov does
# not count as code (a comment, a blank line), else the times it ran. A file the
# tests never ran at all is reported with every line at 0, or missing, which counts
# as 0 percent here.
total_relevant=0
total_covered=0
for f in "${measured[@]}"; do
  # Prints "<relevant> <covered> <missed>", where <missed> is the comma-separated line
  # numbers no test ran, or "-" when there are none.
  read -r relevant covered missed < <(jq -r --arg f "$f" '
    [.[] | .coverage[$f] | select(. != null) | (if type == "object" then .lines else . end)]
    | if length == 0 then "0 0 -"
      else
        (.[0] | length) as $n
        | [range(0; $n) as $i | [.[] | .[$i]] | map(select(. != null))
            | if length == 0 then empty else {line: ($i + 1), ran: (add > 0)} end]
        | (map(select(.ran | not) | .line | tostring) | join(",")) as $missed
        | "\(length) \(map(select(.ran)) | length) \(if $missed == "" then "-" else $missed end)"
      end' "$resultset")
  if ((relevant == 0)); then
    die "${f#"$root"/} has no measured lines; bashcov did not see it run."
  fi
  total_relevant=$((total_relevant + relevant))
  total_covered=$((total_covered + covered))
  printf '%6.1f%%  %3d of %3d lines  %s\n' "$(jq -n "$covered * 100 / $relevant")" "$covered" "$relevant" "${f#"$root"/}"
  if [ "$missed" != "-" ]; then
    echo "         not run: line $missed"
  fi
done

percent="$(jq -n "$total_covered * 100 / $total_relevant")"
printf '%6.1f%%  %3d of %3d lines  all measured scripts (floor %d%%)\n' "$percent" "$total_covered" "$total_relevant" "$floor"
if jq -e -n "$percent < $floor" >/dev/null; then
  die "line coverage is $percent%, below the $floor% floor."
fi
