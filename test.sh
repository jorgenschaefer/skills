#!/usr/bin/env bash
#
# The tests.
#
#   ./test.sh
#
# Plain bash, because a repository of Markdown skills and one script should not
# have to install a test framework to check them. This file checks that every
# script passes shellcheck, and then runs the suites under tests/.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=tests/lib.sh
. "$HERE/tests/lib.sh"

# --- every script passes shellcheck --------------------------------------------
#
# The tests included: a suite is code that decides what passes. A lint that
# cannot run fails here rather than reading as a clean one.
if ! command -v shellcheck >/dev/null; then
  bad "every script passes shellcheck" "shellcheck is not on PATH"
elif lint="$(shellcheck -x -P SCRIPTDIR "$HERE"/sync.sh "$HERE"/test.sh "$HERE"/tests/*.sh 2>&1)"; then
  ok "every script passes shellcheck"
else
  bad "every script passes shellcheck" "$lint"
fi

# --- the suites ----------------------------------------------------------------

for suite in "$HERE/tests/no-dangling.sh" "$HERE/tests/sync.sh"; do
  printf '\n'
  "$suite" || failed=$((failed + 1))
done

printf '\n%d passed, %d failed, of the cases in this file\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
