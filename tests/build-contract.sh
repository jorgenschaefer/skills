#!/usr/bin/env bash
#
# The tests for the contract the two sessions of a ticket loop work under -
# `/implement`, which builds it, and `/critique`, which reads what it built.
#
#   tests/build-contract.sh
#
# The skill is almost entirely constraints against what a helpful agent would
# otherwise do: work around a blocker, improve the solution it was handed,
# review its own diff, declare itself d. Those are prose, and prose is
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

# The instructions a session may and may not be given. Each case looks for the
# imperative, not the token: a bare mention proves nothing, and the skill is
# allowed - encouraged - to say what it must not do.
#
# The disclaimers are matched on the sentence, not the line, because a line can
# carry an instruction and a disclaimer at once and the line-scoped version of
# this check let exactly that through.
sentences() { tr '\n' ' ' | sed 's/\([.!]\) /\1\n/g'; }

says_to() {  # phrase -> the sentences instructing it, minus the disclaiming ones
  sentences < "$SKILL" | grep -i -- "$1" | grep -vi "never\|not yours\|the runner\(  *owns\)\?\|cannot"
}

# Marking your own ticket done is reviewing it by omission: the runner writes
# `done`, after a review the session did not run.
told="$(says_to 'status: *done')$(says_to 'mark[a-z]* the ticket done')"
[ -z "$told" ] \
  && ok "the session is never told to write status: done" \
  || bad "the session is never told to write status: done" "$told"

told="$(says_to 'status: *doing')"
[ -z "$told" ] \
  && ok "the session is never told to claim a ticket" \
  || bad "the session is never told to claim a ticket" "$told"

for status in review halted; do
  # Present as an instruction, and not disclaimed anywhere else: a skill can
  # contradict itself in two sentences, and the later one is what a reader
  # remembers.
  told="$(sentences < "$SKILL" | grep -i "set .*status: *$status")"
  denied="$(sentences < "$SKILL" | grep -iE "(never|not) (write|set) .*status: *$status")"
  if [ -z "$told" ]; then
    bad "the session is told to set status: $status" "no instruction in $SKILL"
  elif [ -n "$denied" ]; then
    bad "the session is told to set status: $status" "and told not to: $denied"
  else
    ok "the session is told to set status: $status"
  fi
done

# The kinds a session can know about, and the two it cannot: a session out of
# attempts is not running to report it, and a session never reads the solution,
# so it cannot know the ticket has drifted from one.
for kind in blocked undecided mystery; do
  grep -q "\`$kind\`" "$SKILL" \
    && ok "the session knows the $kind halt" \
    || bad "the session knows the $kind halt" "not named in $SKILL"
done

for kind in exhausted drift; do
  told="$(says_to "\`$kind\`")"
  [ -z "$told" ] \
    && ok "the session is never told to raise the $kind halt" \
    || bad "the session is never told to raise the $kind halt" "$told"
done

# The Record is the only evidence a criterion was covered rather than claimed.
grep -q '## Record' "$SKILL" \
  && ok "the session writes the Record" \
  || bad "the session writes the Record" "not named in $SKILL"

# Reviewing is someone else's, in a context that did not write the code.
grep -q 'critique' "$SKILL" \
  && ok "the review is named as another session's" \
  || bad "the review is named as another session's" "$SKILL never names the reviewer"


# --- the review session

REVIEW="$ROOT/critique/SKILL.md"

# A review that opens the solution is reviewing the approach, which was settled
# with someone before this ticket existed.
told="$(sentences < "$REVIEW" | grep -i 'read.*SOLUTION_\|open.*solution' | grep -vi 'never\|not yours\|do not')"
[ -z "$told" ] \
  && ok "the review is never told to read the solution" \
  || bad "the review is never told to read the solution" "$told"

# Statuses and counters are the runner's, from both ends of the loop.
told="$(sentences < "$REVIEW" | grep -i 'set .*status:\|write .*status:' | grep -vi 'never\|not yours\|the runner')"
[ -z "$told" ] \
  && ok "the review never sets a status" \
  || bad "the review never sets a status" "$told"

grep -q '## Findings' "$REVIEW" \
  && ok "the review writes the ticket's Findings" \
  || bad "the review writes the ticket's Findings" "not named in $REVIEW"

# It has to stay the review anyone can run on a branch: the pipeline mode is an
# addition, and a skill narrowed to tickets stops being reachable by hand.
case "$(sed -n '/^description:/p' "$REVIEW")" in
  *branch*|*PR*|*diff*) ok "the review still answers for a branch" ;;
  *) bad "the review still answers for a branch" "its description is scoped to the pipeline" ;;
esac

finish
