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
# A build that leaves something for a later part - a rename that belongs to
# the code the next one touches - says so in its Left standing, and nothing else ever
# carried it there: every session reads its own part and no other.

workspace
plan build build review
run > /dev/null
if ! grep -q 'already built' <(sed -n 1p "$STUB_CALLS") \
   && grep -qF "$WORK/changes/x/plan/01.md" <(sed -n 2p "$STUB_CALLS") \
   && grep -q 'already built.*## Left standing' <(sed -n 2p "$STUB_CALLS"); then
  ok "a later build is pointed at what the parts already built left standing"
else bad "a later build is pointed at what the parts already built left standing" "$(calls)"; fi

# --- what a build is told about the checks
#
# The runner runs the fast and the slow check on every build's commit, so a
# build runs only the fast one, and has to be told so: told nothing, /implement-code
# runs the slow check before its commit too.

workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nFast check: `true # fast`\nSlow check: `true # slow`\n' > "$WORK/CLAUDE.md"; commit
plan build build review
run > /dev/null
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF 'fast check is `true # fast`' <(head -1 "$STUB_CALLS") && grep -qF 'slow check is `true # slow`' <(head -1 "$STUB_CALLS") \
   && grep -q 'runner runs both checks on your commit itself, so run only the fast check' <(head -1 "$STUB_CALLS") \
   && grep -q 'When the work is done and the fast check passes' <(head -1 "$STUB_CALLS"); then
  ok "a build is told both checks, and to run only the fast one because the runner runs both"
else bad "a build is told both checks, and to run only the fast one because the runner runs both" "$(head -1 "$STUB_CALLS")"; fi
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF 'fast check is `true # fast`' <(tail -1 "$STUB_CALLS") && grep -qF 'slow check is `true # slow`' <(tail -1 "$STUB_CALLS") \
   && grep -q 'run only the fast check yourself' <(tail -1 "$STUB_CALLS") && grep -q 'run the fast check and commit' <(tail -1 "$STUB_CALLS") \
   && grep -q "the runner's last run of both checks.*your own run of the fast check - saying which it is" <(tail -1 "$STUB_CALLS"); then
  ok "the final review is told both checks, to run only the fast one, and to tell the reviewer whose result it hands over"
else bad "the final review is told both checks, to run only the fast one, and to tell the reviewer whose result it hands over" "$(tail -1 "$STUB_CALLS")"; fi

workspace
plan build build review
run > /dev/null
if grep -q 'it has no slow check' <(head -1 "$STUB_CALLS"); then
  ok "a build in a project with no slow check is told it has none"
else bad "a build in a project with no slow check is told it has none" "$(head -1 "$STUB_CALLS")"; fi

# --- the skills a session is told to use
#
# A session loads the skill its brief names, so a brief naming one that is gone
# builds with none. The build halts in the kinds the runner reads back, and
# `undecided` is not among them: the plan left no question for the build.

workspace; unsplit
plan split-two build build review
run > /dev/null
if grep -q '^/split-plan on ' <(sed -n 1p "$STUB_CALLS"); then
  ok "the split's brief starts with /split-plan, which loads it"
else bad "the split's brief starts with /split-plan, which loads it" "$(sed -n 1p "$STUB_CALLS")"; fi
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -q '^Use /implement-plan on ' <(sed -n 2p "$STUB_CALLS") && ! grep -q 'undecided' <(sed -n 2p "$STUB_CALLS") \
   && grep -q '`departure`.*`blocked`.*`mystery`' <(sed -n 2p "$STUB_CALLS"); then
  ok "a build's brief names /implement-plan and the halt kinds of a session, and no undecided"
else bad "a build's brief names /implement-plan and the halt kinds of a session, and no undecided" "$(sed -n 2p "$STUB_CALLS")"; fi
# The end review is a code review against the plan; the walk is acceptance's.
if grep -q 'review-code' <(tail -1 "$STUB_CALLS") && grep -qF "$(realpath "$WORK")/changes/x/plan.md as the spec" <(tail -1 "$STUB_CALLS") \
   && ! grep -q 'walk' <(tail -1 "$STUB_CALLS") && ! grep -q 'review-change\|implement-change' <(tail -1 "$STUB_CALLS"); then
  ok "the end review's brief has review-code review the diff against plan.md, and walks nothing"
else bad "the end review's brief has review-code review the diff against plan.md, and walks nothing" "$(tail -1 "$STUB_CALLS")"; fi

# --- what the final review is told
#
# One review of the whole change, run with nobody watching: what it reviews,
# where its findings go and what the builds left standing all reach it through
# its brief.

workspace
plan build build review
run > /dev/null
if grep -qF "$(git -C "$WORK" rev-parse main~1)" <(tail -1 "$STUB_CALLS"); then
  ok "the review is given the change from before its parts were added"
else bad "the review is given the change from before its parts were added" "$(tail -1 "$STUB_CALLS")"; fi
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF "write what you left standing into $(realpath "$WORK")/changes/x/plan.md, under a \`### End review\` heading" <(tail -1 "$STUB_CALLS") \
   && grep -q "Set plan.md's \`status: done\`" <(tail -1 "$STUB_CALLS") && grep -q 'Two rounds at most' <(tail -1 "$STUB_CALLS") \
   && grep -q '`true`' <(tail -1 "$STUB_CALLS") && ! grep -q 'REVIEW.md' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told to leave what it left under End review in plan.md, set it done, two rounds at most, and the project's checks"
else bad "the review is told to leave what it left under End review in plan.md, set it done, two rounds at most, and the project's checks" "$(tail -1 "$STUB_CALLS")"; fi
# A build left a blocker it had not fixed in its Left standing, and the review,
# shown none of them, found the same bug again. Left standing is handed over
# whole, not pointed at: whole parts are the plans the reviewer must not see.
if grep -q 'left by 01' <(tail -1 "$STUB_CALLS") && grep -q 'left by 02' <(tail -1 "$STUB_CALLS"); then
  ok "the review is handed what every build left standing"
else bad "the review is handed what every build left standing" "$(tail -1 "$STUB_CALLS")"; fi

finish
