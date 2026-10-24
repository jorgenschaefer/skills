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

# --- what the final review is told
#
# One review of the whole change, run with nobody watching: what it reviews,
# where its findings go and what the builds left standing all reach it through
# its brief.

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
# A build left a blocker it had not fixed in its Left standing, and the review,
# shown none of them, found the same bug again. Left standing is handed over
# whole, not pointed at: whole tickets are the plans critique must not see.
if grep -q 'left by 1-one' <(tail -1 "$STUB_CALLS") && grep -q 'left by 2-two' <(tail -1 "$STUB_CALLS"); then
  ok "the review is handed what every build left standing"
else bad "the review is handed what every build left standing" "$(tail -1 "$STUB_CALLS")"; fi

finish
