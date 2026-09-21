#!/usr/bin/env bash
#
# The tests for the contract the two sessions of a ticket loop work under -
# `/implement`, which builds it, and `/critique`, which reads what it built.
#
#   tests/build-contract.sh
#
# The skill is almost entirely constraints against what a helpful agent would
# otherwise do: work around a blocker, improve the solution it was handed,
# review its own diff, declare itself finished. Those are prose, and prose is
# what drifts, so these cases pin the ones with a mechanical shape: the statuses
# each session may write, the halts each may raise, and where its output goes.

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

says_to() {  # file, phrase -> the sentences instructing it, minus disclaiming ones
  # `the runner` alone is too broad a disclaimer: a sentence can name the runner
  # and still instruct. Only the phrases that actually deny apply - `cannot` was
  # in this list and denies nothing, so "if the build cannot be committed, raise
  # `unbuilt`" read as a disclaimer of the instruction it is.
  sentences < "$1" | grep -iE -- "$2" | grep -viE "never|not yours|the runner owns|do not"
}

# Marking your own ticket done is reviewing it by omission: the runner writes
# `done`, after a review the session did not run.
told="$(says_to "$SKILL" 'status: *done|mark[a-z]* the ticket done|ticket status to done')"
[ -z "$told" ] \
  && ok "the session is never told to write status: done" \
  || bad "the session is never told to write status: done" "$told"

told="$(says_to "$SKILL" 'status: *doing|claim the ticket')"
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

# The kinds a session raises. It has to know them by name to reach for the right
# one; the kinds it may not raise are the loop below.
for kind in blocked undecided mystery; do
  grep -q "\`$kind\`" "$SKILL" \
    && ok "the session knows the $kind halt" \
    || bad "the session knows the $kind halt" "not named in $SKILL"
done

# The runner's kinds have to be named as its, not merely left out: a session
# that has never heard of `unbuilt` reaches for the nearest kind it does know,
# and absence alone would let this case pass on a skill that says nothing. The
# third reason for the split is that the session that committed nothing is the
# one that reported a build, so it is in no position to report the opposite.
#
# Which side of the section a kind sits on is the whole criterion, so the lookup
# is scoped to the sides: a mention anywhere in the file passes just as happily
# when the kind has been moved into the list a session raises from.
#
# The list itself is the oracle both documents are held to, so it is written
# once: a fourth kind added to one loop and not the other leaves the other
# document unpinned, in green.
runner_kinds="exhausted drift unbuilt"
halts="$(sed -n '/^## Halt rather than improvise/,/^## /p' "$SKILL")"
mine="$(printf '%s\n' "$halts" | grep '^- ')"
theirs="$(printf '%s\n' "$halts" | sentences | grep -iE 'not yours')"
for kind in $runner_kinds; do
  told="$(says_to "$SKILL" "\`$kind\`")"
  if ! printf '%s\n' "$theirs" | grep -q -- "\`$kind\`"; then
    bad "the $kind halt is named as the runner's" "not named as the runner's in $SKILL"
  elif printf '%s\n' "$mine" | grep -q -- "\`$kind\`"; then
    bad "the $kind halt is named as the runner's" "also listed among the kinds a session raises"
  elif [ -n "$told" ]; then
    bad "the $kind halt is named as the runner's" "the session is told to raise it: $told"
  else
    ok "the $kind halt is named as the runner's"
  fi
done

# The other place the vocabulary is taught. A split that disagrees with the
# skill's is two answers to which kinds a session may raise, and the doc is
# where the next skill is written from.
IDEA="$ROOT/NEW_PIPELINE_IDEA.md"
runners="$(sed -n "/kinds are the \*\*runner's\*\*/,/^### /p" "$IDEA")"
for kind in $runner_kinds; do
  printf '%s' "$runners" | grep -q -- "^- \`$kind\`" \
    && ok "the idea's halt list has $kind as the runner's" \
    || bad "the idea's halt list has $kind as the runner's" "not in the runner's kinds in $IDEA"
done

# The doc counts the stops a person makes a few hundred lines above the Halts
# section, and names the halt kinds there as the conditional ones. The two lists
# have to agree: a kind added to one and not the other is the doc contradicting
# itself about when a run stops, and the count is the half a reader meets first.
#
# Both halves are found by their wording, and a doc may reword either. The
# kinds are asserted before the loop because a loop over an empty extraction
# writes no verdict at all: renaming the heading takes these cases with it and
# leaves a green suite six cases shorter.
idea_halts="$(sed -n '/^### Halts/,/^### /p' "$IDEA" | sed -n 's/^- `\([a-z]*\)`.*/\1/p')"
counted="$(sentences < "$IDEA" | grep -i 'conditional and named')"
[ -n "$idea_halts" ] \
  && ok "the idea's halt kinds are there to count against" \
  || bad "the idea's halt kinds are there to count against" "no kind bullets under ### Halts in $IDEA"
for kind in $idea_halts; do
  if [ -z "$counted" ]; then
    bad "the stop count names the $kind halt" "no sentence naming the conditional stops in $IDEA"
  elif printf '%s\n' "$counted" | grep -q -- "\`$kind\`"; then
    ok "the stop count names the $kind halt"
  else
    bad "the stop count names the $kind halt" "in the Halts section of $IDEA, not in the count"
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


# --- the review session

REVIEW="$ROOT/critique/SKILL.md"

if [ ! -f "$REVIEW" ]; then
  bad "the review skill is there" "no $REVIEW"
  finish
  exit
fi
ok "the review skill is there"

# A review that opens the solution is reviewing the approach, which was settled
# with someone before this ticket existed.
told="$(says_to "$REVIEW" 'read.*solution|open.*solution|consult.*solution|refer to.*solution')"
[ -z "$told" ] \
  && ok "the review is never told to read the solution" \
  || bad "the review is never told to read the solution" "$told"

# Statuses and counters are the runner's, from both ends of the loop.
told="$(says_to "$REVIEW" 'status: *(done|doing|ready)|ticket status to|increment .*(attempts|reviews)|set .*(attempts|reviews)')"
[ -z "$told" ] \
  && ok "the review never sets a status or a counter" \
  || bad "the review never sets a status or a counter" "$told"

# AC-15's deliverable, as an instruction rather than a string: the section name
# can appear in a sentence forbidding it.
told="$(says_to "$REVIEW" "write.*\`## Findings\`|into the ticket's \`## Findings\`")"
[ -n "$told" ] \
  && ok "the review is told to write the ticket's Findings" \
  || bad "the review is told to write the ticket's Findings" "no instruction in $REVIEW"

# It has to stay the review anyone can run on a branch: the pipeline mode is an
# addition, and a skill narrowed to tickets stops being reachable by hand.
case "$(sed -n '/^description:/p' "$REVIEW")" in
  *branch*|*PR*|*diff*) ok "the review still answers for a branch" ;;
  *) bad "the review still answers for a branch" "its description is scoped to the pipeline" ;;
esac

finish
