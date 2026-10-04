#!/usr/bin/env bash
#
# The tests for run/prompts.sh: what a build and the final review are told.
#
#   tests/run/prompts.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- what earlier builds left standing
#
# A build that leaves something for a later ticket - a rename that belongs to
# the code the next one touches - says so in its Left standing, and nothing else ever
# carried it there: every session reads its own ticket and no other.

workspace
plan build build review
run > /dev/null
if ! grep -q 'already built' <(sed -n 1p "$STUB_CALLS") \
   && grep -qF "$WORK/changes/x/tickets/1-one.md" <(sed -n 2p "$STUB_CALLS") \
   && grep -q 'already built.*## Left standing' <(sed -n 2p "$STUB_CALLS"); then
  ok "a later build is pointed at what the tickets already built left standing"
else bad "a later build is pointed at what the tickets already built left standing" "$(calls)"; fi

# --- what a build is told

workspace
plan build build review
run > /dev/null
# A background task that finishes wakes the session. One run's sessions, told
# nothing would, waited on their subagents with Monitor timers that outlived them
# and woke each finished session up to three times more.
if ! grep -q 'Nothing wakes you' <(head -1 "$STUB_CALLS") && ! grep -q 'Nothing wakes you' <(tail -1 "$STUB_CALLS"); then
  ok "neither the build nor the review is told nothing wakes it"
else bad "neither the build nor the review is told nothing wakes it" "$(calls)"; fi
# What a build leaves standing is handed to the final review and read at
# acceptance, and both find it under one heading. A departure from a nudge is
# the one thing about a nudge anybody gets to see.
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -q '`## Left standing`' <(head -1 "$STUB_CALLS") && grep -q 'departed from a nudge' <(head -1 "$STUB_CALLS") \
   && grep -q '`## Nudges`' <(head -1 "$STUB_CALLS"); then
  ok "the build is told its nudges, and to record under Left standing where it departed from one"
else bad "the build is told its nudges, and to record under Left standing where it departed from one" "$(head -1 "$STUB_CALLS")"; fi
# A list of which test proves which criterion says of nearly every ticket what
# `done` already says, and buried the one line in it worth reading: a criterion
# checked by hand, with no test behind it.
if grep -q 'no automated test proves' <(head -1 "$STUB_CALLS") && ! grep -qi 'which test proves' <(head -1 "$STUB_CALLS"); then
  ok "the build lists under Left standing only the criteria no test proves"
else bad "the build lists under Left standing only the criteria no test proves" "$(head -1 "$STUB_CALLS")"; fi

# --- what the final review is told
#
# One review of the whole change, run with nobody watching: what it reviews,
# where its findings go, and what it must leave alone all reach it through its
# brief.

workspace
plan build build review
run > /dev/null
if grep -qF "$(git -C "$WORK" rev-parse main~1)" <(tail -1 "$STUB_CALLS"); then
  ok "the review is given the change from before its tickets were added"
else bad "the review is given the change from before its tickets were added" "$(tail -1 "$STUB_CALLS")"; fi
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF "$(realpath "$WORK")/changes/x/REVIEW.md" <(tail -1 "$STUB_CALLS") \
   && grep -q '`true`' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told where REVIEW.md goes, and the project's checks"
else bad "the review is told where REVIEW.md goes, and the project's checks" "$(tail -1 "$STUB_CALLS")"; fi
# A review fixes what it finds, and one fix went against a nudge the build had
# kept on purpose. A nudge is how the user agreed it gets built.
if grep -q 'departs from a nudge is not made' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told a fix that departs from a nudge is left standing, not made"
else bad "the review is told a fix that departs from a nudge is left standing, not made" "$(tail -1 "$STUB_CALLS")"; fi
# A second round costs a whole review, and five builds in one run paid it after a
# first round that found nothing that mattered.
if grep -q 'found only nits' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told not to review again after a round of only nits"
else bad "the review is told not to review again after a round of only nits" "$(tail -1 "$STUB_CALLS")"; fi
# Round two drove every screen again, and the one thing its driving found in a
# whole run was on a screen a round-one fix had changed.
if grep -q 'drives only the screens the fixes since the first round touched' <(tail -1 "$STUB_CALLS"); then
  ok "the review's second round drives only the screens its fixes touched"
else bad "the review's second round drives only the screens its fixes touched" "$(tail -1 "$STUB_CALLS")"; fi
# A build left a blocker it had not fixed in its Left standing, and the review,
# shown none of them, found the same bug again. Left standing is handed over
# whole, not pointed at: whole tickets are the plans critique must not see.
if grep -q 'left by 1-one' <(tail -1 "$STUB_CALLS") && grep -q 'left by 2-two' <(tail -1 "$STUB_CALLS"); then
  ok "the review is handed what every build left standing"
else bad "the review is handed what every build left standing" "$(tail -1 "$STUB_CALLS")"; fi
if grep -q 'blocker and should-fix' <(tail -1 "$STUB_CALLS") && grep -q '## For you' <(tail -1 "$STUB_CALLS"); then
  ok "the review settles the blockers and should-fix the builds left, or leaves them for the person"
else bad "the review settles the blockers and should-fix the builds left, or leaves them for the person" "$(tail -1 "$STUB_CALLS")"; fi
# The end of a run prints this section and nothing else of REVIEW.md, so it is
# the only place the most important of what is still open can go.
if grep -q 'most important first' <(tail -1 "$STUB_CALLS") && grep -q 'at most five' <(tail -1 "$STUB_CALLS"); then
  ok "the review opens REVIEW.md with the few most important things still open"
else bad "the review opens REVIEW.md with the few most important things still open" "$(tail -1 "$STUB_CALLS")"; fi
if grep -q 'severity' <(head -1 "$STUB_CALLS"); then
  ok "a build leaves its unfixed findings standing with their severity"
else bad "a build leaves its unfixed findings standing with their severity" "$(head -1 "$STUB_CALLS")"; fi

finish
