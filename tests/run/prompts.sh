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
if grep -q '`## Left standing`' <(head -1 "$STUB_CALLS") && grep -q 'departed from a technical decision or a nudge' <(head -1 "$STUB_CALLS") \
   && grep -q '`## Nudges`' <(head -1 "$STUB_CALLS"); then
  ok "the build is told its nudges, and to record under Left standing where it departed from one"
else bad "the build is told its nudges, and to record under Left standing where it departed from one" "$(head -1 "$STUB_CALLS")"; fi

# The technical decisions were approved, so the build is told to build to them,
# and that going beyond one is a departure the person approves at acceptance.
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -q '`## Technical decisions` were agreed' <(head -1 "$STUB_CALLS") \
   && grep -q 'record the departure' <(head -1 "$STUB_CALLS"); then
  ok "the build is told its technical decisions, and to record under Left standing where it departed from one"
else bad "the build is told its technical decisions, and to record under Left standing where it departed from one" "$(head -1 "$STUB_CALLS")"; fi
# A list of which test proves which criterion says of nearly every ticket what
# `done` already says, and buried the one line in it worth reading: a criterion
# checked by hand, with no test behind it.
if grep -q 'no automated test proves' <(head -1 "$STUB_CALLS") && ! grep -qi 'which test proves' <(head -1 "$STUB_CALLS"); then
  ok "the build lists under Left standing only the criteria no test proves"
else bad "the build lists under Left standing only the criteria no test proves" "$(head -1 "$STUB_CALLS")"; fi
# Reviews stop after two rounds, and what a build fixes after the last one no
# reviewer sees. Three of 27 second rounds found a blocker; on weight-tracker
# what the limit left was all real and fixed by hand at acceptance.
if grep -q 'fixes you made after the last review' <(head -1 "$STUB_CALLS"); then
  ok "the build lists under Left standing the fixes no reviewer saw"
else bad "the build lists under Left standing the fixes no reviewer saw" "$(head -1 "$STUB_CALLS")"; fi

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
# A nudge is an idea, not an order, and a technical decision can be widened
# where the code calls for it: neither stops a fix, but the person sees
# where a fix went against one.
if grep -q 'A nudge or a technical decision does not stop a fix' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told a nudge or a technical decision does not stop a fix, and to name the departure"
else bad "the review is told a nudge or a technical decision does not stop a fix, and to name the departure" "$(tail -1 "$STUB_CALLS")"; fi
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
# A nit's fix added a redirect nobody drove, and acceptance found it showing an
# outdated result.
if grep -q 'review again only if one of those fixes changes what a screen shows or where an action leads' <(tail -1 "$STUB_CALLS"); then
  ok "the review drives a nit's fix that changes a screen"
else bad "the review drives a nit's fix that changes a screen" "$(tail -1 "$STUB_CALLS")"; fi
if grep -q 'A fix that needs a decision the criteria do not settle is not made' <(tail -1 "$STUB_CALLS"); then
  ok "the review leaves a fix of its own findings that needs a decision to the person"
else bad "the review leaves a fix of its own findings that needs a decision to the person" "$(tail -1 "$STUB_CALLS")"; fi
# A build left a blocker it had not fixed in its Left standing, and the review,
# shown none of them, found the same bug again. Left standing is handed over
# whole, not pointed at: whole tickets are the plans critique must not see.
if grep -q 'left by 1-one' <(tail -1 "$STUB_CALLS") && grep -q 'left by 2-two' <(tail -1 "$STUB_CALLS"); then
  ok "the review is handed what every build left standing"
else bad "the review is handed what every build left standing" "$(tail -1 "$STUB_CALLS")"; fi
if grep -q 'blocker and should-fix' <(tail -1 "$STUB_CALLS") && grep -q '## For you' <(tail -1 "$STUB_CALLS"); then
  ok "the review settles the blockers and should-fix the builds left, or leaves them for the person"
else bad "the review settles the blockers and should-fix the builds left, or leaves them for the person" "$(tail -1 "$STUB_CALLS")"; fi
# A fix a build made after its last review was seen by nobody; the final review
# is the first that can check it. Its own fixes after its last round go to
# acceptance the same way.
if grep -q 'made after its last review' <(tail -1 "$STUB_CALLS") \
   && grep -q 'fixes you made after the last review' <(tail -1 "$STUB_CALLS"); then
  ok "the review checks the fixes no build's reviewer saw, and lists its own"
else bad "the review checks the fixes no build's reviewer saw, and lists its own" "$(tail -1 "$STUB_CALLS")"; fi
# Acceptance puts what is open to the person in the order REVIEW.md gives it.
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -q 'decision first' <(tail -1 "$STUB_CALLS") && grep -q 'most important first' <(tail -1 "$STUB_CALLS") \
   && [ "$(grep -o 'under `## For you`' <(tail -1 "$STUB_CALLS") | wc -l)" -ge 2 ]; then
  ok "the review opens REVIEW.md with what needs a decision, then the rest most important first"
else bad "the review opens REVIEW.md with what needs a decision, then the rest most important first" "$(tail -1 "$STUB_CALLS")"; fi
# Nobody reads a session's closing message; a build has to know who reads its
# Left standing instead.
if grep -q 'handed to the final review' <(head -1 "$STUB_CALLS") && grep -q 'read at acceptance' <(head -1 "$STUB_CALLS"); then
  ok "a build is told who reads its Left standing"
else bad "a build is told who reads its Left standing" "$(head -1 "$STUB_CALLS")"; fi
if grep -q 'severity' <(head -1 "$STUB_CALLS"); then
  ok "a build leaves its unfixed findings standing with their severity"
else bad "a build leaves its unfixed findings standing with their severity" "$(head -1 "$STUB_CALLS")"; fi

finish
