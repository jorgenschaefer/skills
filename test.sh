#!/usr/bin/env bash
#
# The tests.
#
#   ./test.sh
#
# Plain bash, because a repository of Markdown skills and one script should not
# have to install a test framework to check them. This file holds what is true
# of the repository as a whole, and then runs the suites under tests/.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=tests/lib.sh
. "$HERE/tests/lib.sh"

# --- the skills' shared files -------------------------------------------------
#
# A skill installs on its own and cannot reach into a sibling's directory, so a
# reference file two skills both need is copied into each of them. Identical is
# the whole point, and an n-way edit is easy to make (n-1)-way by accident -
# today that is the three copies of CODING_STANDARDS.md.
#
# Quantified over whatever is shared rather than over that file by name: the
# holders move as skills come and go, and an assertion pinned to a list is one
# that gets edited to match whatever it found rather than read.
#
# Two names are held by several skills and are *not* copies. SKILL.md is each
# skill itself. VERIFY.md is the deliberate exception the README names: three
# skills hold one and the three are different documents on purpose, because an
# adversary written generically enough to serve all three stages says less at
# each of them.
shared=0
names=()
for f in "$HERE"/*/*.md; do
  name="$(basename "$f")"
  case "$name" in SKILL.md|VERIFY.md) continue ;; esac
  [[ " ${names[*]-} " == *" $name "* ]] || names+=("$name")
done

for name in ${names[@]+"${names[@]}"}; do
  copies=("$HERE"/*/"$name")
  [ "${#copies[@]}" -ge 2 ] || continue
  shared=$((shared + 1))
  if [ "$(md5sum "${copies[@]}" | awk '{print $1}' | sort -u | wc -l)" = 1 ]; then
    ok "every copy of $name is byte-identical (${#copies[@]} of them)"
  else
    bad "every copy of $name is byte-identical" "$(md5sum "${copies[@]}")"
  fi
done

# Zero groups found is zero failures, which reads as success - and the day this
# stops finding CODING_STANDARDS.md is the day it stops checking anything.
expect_counted "$shared" "files held by more than one skill"

# --- the scripts that ship pass shellcheck --------------------------------------
#
# Three reviews reported it as not installed and ran nothing. A lint that cannot
# run fails here rather than reading as a clean one.
if ! command -v shellcheck >/dev/null; then
  bad "run.sh and sync.sh pass shellcheck" "shellcheck is not on PATH"
elif lint="$(shellcheck "$HERE/run.sh" "$HERE/sync.sh" 2>&1)"; then
  ok "run.sh and sync.sh pass shellcheck"
else
  bad "run.sh and sync.sh pass shellcheck" "$lint"
fi

# --- the suites ----------------------------------------------------------------

printf '\n'
"$HERE/tests/runner.sh"     || failed=$((failed + 1))
printf '\n'
"$HERE/tests/no-dangling.sh" || failed=$((failed + 1))
printf '\n'
"$HERE/tests/sync.sh"        || failed=$((failed + 1))

printf '\n%d passed, %d failed, of the cases in this file\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
