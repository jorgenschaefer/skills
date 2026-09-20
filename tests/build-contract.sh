#!/usr/bin/env bash
#
# The tests for what `/implement` is not allowed to do.
#
#   tests/build-contract.sh
#
# The skill is almost entirely constraints against what a helpful agent would
# otherwise do: work around a blocker, improve the solution it was handed,
# review its own diff, declare itself finished. Those are prose, and prose is
# what drifts, so these cases pin the two that have a mechanical shape - the
# statuses a session may write, and the halts it may raise.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$HERE/.."
SKILL="$ROOT/implement/SKILL.md"

# shellcheck source=format-lib.sh
. "$HERE/format-lib.sh"

if [ ! -f "$SKILL" ]; then
  bad "the build skill is there" "no $SKILL"
  finish
  exit
fi

# A session that marks its own ticket done has reviewed itself by omission: the
# runner sets `done` after a review it did not run. The skill is allowed to say
# so - what it may not do is tell the agent to write it.
told="$(grep -n 'status: *done' "$SKILL" | grep -vi 'never\|not yours\|runner owns')"
[ -z "$told" ] \
  && ok "the session is never told to write status: done" \
  || bad "the session is never told to write status: done" "$told"

for status in review halted; do
  grep -q "status: *$status" "$SKILL" \
    && ok "the session is told to write status: $status" \
    || bad "the session is told to write status: $status" "not in $SKILL"
done

# The kinds a session can know about. `exhausted` and `drift` are the runner's:
# a session out of attempts is not running, and a session never reads the
# solution, so listing them here would be telling it to report what it cannot see.
for kind in blocked undecided mystery; do
  grep -q "\`$kind\`" "$SKILL" \
    && ok "the session knows the $kind halt" \
    || bad "the session knows the $kind halt" "not named in $SKILL"
done

for kind in exhausted drift; do
  if grep -q "writes\? \`$kind\`\|raise \`$kind\`" "$SKILL"; then
    bad "the session does not raise the $kind halt" "$SKILL tells it to"
  else
    ok "the session does not raise the $kind halt"
  fi
done

# The Record is the only evidence a criterion was covered rather than claimed.
grep -q '## Record' "$SKILL" \
  && ok "the session writes the Record" \
  || bad "the session writes the Record" "not named in $SKILL"

# Reviewing is someone else's, in a context that did not write the code.
grep -q 'critique' "$SKILL" \
  && ok "the review is named as another session's" \
  || bad "the review is named as another session's" "$SKILL never names the reviewer"

finish
