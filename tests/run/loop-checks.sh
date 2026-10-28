#!/usr/bin/env bash
#
# The tests for run/loop.sh, on the checks the runner runs on every build's
# commit.
#
#   tests/run/loop-checks.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the checks on every build's commit
#
# A build's account of its checks is an account. The runner ran them once at the
# start and then believed every session, so a red commit went on to the next
# build - which was told the checks were green - and to the review. It runs them
# on every commit it accepts, and a red one goes back to the session that made
# it, which still has the build in its context.

workspace
STUB_VERIFY='echo x >> .runs'
plan build build review
run > /dev/null
if [ "$(wc -l < "$WORK/.runs")" = 4 ]; then ok "the checks run once at the start, once after every build and once after the final review"
else bad "the checks run once at the start, once after every build and once after the final review" "$(wc -l < "$WORK/.runs") $(out)"; fi

workspace
STUB_VERIFY='if [ -f .red ]; then echo REDMARK; exit 1; fi'
plan build-red fix-red build review
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a build whose checks are red is carried on without spending an attempt"
else bad "a build whose checks are red is carried on without spending an attempt" "rc=$rc $(field 1-one status) $(field 1-one attempts) $(out)"; fi
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a red build is resumed in its own session, not started over"
else bad "a red build is resumed in its own session, not started over" "$(cat "$STUB_SESSIONS")"; fi
if grep -q 'REDMARK' <(sed -n 2p "$STUB_CALLS") && grep -qF '.red' <(sed -n 2p "$STUB_CALLS"); then
  ok "the resumed session is told the command and what it printed"
else bad "the resumed session is told the command and what it printed" "$(sed -n 2p "$STUB_CALLS")"; fi
if [ ! -e "$WORK/.red" ] && [ "$(field 2-two status)" = "done" ]; then
  ok "the next build starts only once the checks are green"
else bad "the next build starts only once the checks are green" "$(out)"; fi

workspace
STUB_VERIFY='if [ -f .red ]; then echo REDMARK; exit 1; fi'
plan build-red build-red fix-red build review
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(field 1-one attempts)" = 2 ] && [ "$(sed -n 3p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a second red in the same claim spends an attempt, and resumes the same session"
else bad "a second red in the same claim spends an attempt, and resumes the same session" "rc=$rc $(field 1-one attempts) $(cat "$STUB_SESSIONS") $(out)"; fi

workspace
STUB_VERIFY='if [ -f .red ]; then echo REDMARK; exit 1; fi'
plan build-red build-red build-red
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ] && grep -q 'exhausted' <(tkt 1-one) \
   && grep -q 'checks' <(sed -n '/^## Halt/,$p' "$WORK/changes/x/tickets/1-one.md") && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "checks still red once the budget is spent halt the ticket as exhausted, saying so"
else bad "checks still red once the budget is spent halt the ticket as exhausted, saying so" "rc=$rc $(tkt 1-one) $(calls) $(out)"; fi

# The slow check is run on every build's commit as the fast one is, and the
# session it goes back to is told which of the two failed.
workspace
# shellcheck disable=SC2016 # the backticks are Markdown's, written literally
printf '# x\n\nFast check: `true`\nSlow check: `if [ -f .red ]; then echo SLOWMARK; exit 1; fi`\n' > "$WORK/CLAUDE.md"; commit
plan build-red fix-red build review
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
log="$(grep -o '[^ ]*slow-check-[^ ]*\.log' <(sed -n 2p "$STUB_CALLS") | head -1)"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ "$rc" = 0 ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ] && [ "$(field 1-one attempts)" = 1 ] \
   && grep -qF 'the slow check, `if [ -f .red ]; then echo SLOWMARK; exit 1; fi`, is red' <(sed -n 2p "$STUB_CALLS") && grep -q 'SLOWMARK' <(sed -n 2p "$STUB_CALLS") \
   && [ -n "$log" ] && grep -q SLOWMARK "$log"; then
  ok "a red slow check goes back to the build's session, told it is the slow check and where its output is"
else bad "a red slow check goes back to the build's session, told it is the slow check and where its output is" "rc=$rc log=$log $(cat "$STUB_SESSIONS") $(calls) $(out)"; fi
if ! grep -qF 'the fast check, `' <(sed -n 2p "$STUB_CALLS") && grep -q 'may run it too' <(sed -n 2p "$STUB_CALLS"); then
  ok "a session handed a red slow check alone is told that one, and that it may run it to confirm its fix"
else bad "a session handed a red slow check alone is told that one, and that it may run it to confirm its fix" "$(sed -n 2p "$STUB_CALLS")"; fi

# Killed after the build committed and before the checks ran, a start again
# checks the commit rather than believing it.
workspace
STUB_VERIFY='if [ -f .red ]; then echo REDMARK; exit 1; fi'
plan build-red-killed fix-red build review
run > /dev/null 2>&1
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ] && grep -q 'REDMARK' <(sed -n 2p "$STUB_CALLS"); then
  ok "a run killed before checking a build checks it when started again"
else bad "a run killed before checking a build checks it when started again" "rc=$rc $(cat "$STUB_SESSIONS") $(calls) $(out)"; fi

# The claim stands until the checks are green: a runner killed while the red
# build is being fixed carries on with that session.
workspace
STUB_VERIFY='if [ -f .red ]; then echo REDMARK; exit 1; fi'
plan build-red killed fix-red build review
run > /dev/null 2>&1
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(sed -n 3p "$STUB_SESSIONS")" = "resume $first" ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a run killed while a red build is fixed carries on with that session"
else bad "a run killed while a red build is fixed carries on with that session" "rc=$rc $(cat "$STUB_SESSIONS") $(field 1-one attempts) $(out)"; fi

finish
