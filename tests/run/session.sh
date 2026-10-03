#!/usr/bin/env bash
#
# The tests for run/session.sh: a session carried through usage limits, and
# what its event stream says it cost.
#
#   tests/run/session.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the usage budget is waited out rather than spent
#
# A usage limit is not a failure of the work: the session was stopped, often
# halfway through it. Waiting it out and carrying on in that same session is the
# whole reason this outlives its sessions.
#
# The stub writes what the CLI writes when it is limited. The runner once
# matched a message only the stub had ever printed, passed every case here, and
# spent a real ticket's attempts in four seconds.

workspace
plan limit build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ]; then ok "a usage limit is waited out and the ticket still finishes"
else bad "a usage limit is waited out and the ticket still finishes" "$(field 1-one status) $(out)"; fi
if [ "$(field 1-one attempts)" = 1 ]; then ok "waiting out a limit does not spend an attempt"
else bad "waiting out a limit does not spend an attempt" "attempts=$(field 1-one attempts)"; fi
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "after a limit the same session carries on"
else bad "after a limit the same session carries on" "$(cat "$STUB_SESSIONS")"; fi
if grep -q 'waiting until' "$WORK/.out" && grep -q '! usage limit, resets' "$WORK/.out"; then
  ok "the limit and the wait are announced"
else bad "the limit and the wait are announced" "$(out)"; fi
if grep -q 'usage limit' <(sed -n 2p "$STUB_CALLS"); then ok "the resumed session is told why it stopped"
else bad "the resumed session is told why it stopped" "$(calls)"; fi

# The wait runs to the reset the limit names, plus the margin.
workspace
plan limit build build review
( cd "$WORK" && PATH="$WORK/.bin:$PATH" STUB_RESET_IN=3600 LIMIT_MARGIN=120 WAIT_SECONDS=5 \
    bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 )
slept="$(awk '{ s += $1 } END { print s + 0 }' "$SLEPT")"
if [ "$slept" -ge 3715 ] && [ "$slept" -le 3720 ]; then
  ok "a limit is waited out until its reset, plus the margin"
else bad "a limit is waited out until its reset, plus the margin" "slept=$slept $(out)"; fi

# The reset is a time on the clock, and a machine suspended mid-wait has spent
# that time too: `sleep` counts only the time the machine was awake, and a run
# slept on well past a reset it had long reached.
workspace
plan limit build build review
echo 3000 > "$WORK/.suspend"
( cd "$WORK" && PATH="$WORK/.bin:$PATH" STUB_RESET_IN=3600 LIMIT_MARGIN=120 WAIT_SECONDS=5 \
    bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 )
slept="$(awk '{ s += $1 } END { print s + 0 }' "$SLEPT")"
if [ "$(field 1-one status)" = "done" ] && [ "$slept" -le 780 ]; then
  ok "a wait counts the time the machine was suspended"
else bad "a wait counts the time the machine was suspended" "slept=$slept $(out)"; fi

# A subagent's limit is the subagent's: the session that then dies of something
# else has failed, and spends its attempt.
workspace
plan limit-sub build build review
run > /dev/null
if [ ! -s "$SLEPT" ] && [ "$(field 1-one attempts)" = 2 ]; then
  ok "a subagent's limit does not make the session's failure a limit"
else bad "a subagent's limit does not make the session's failure a limit" "slept=$(cat "$SLEPT") $(tkt 1-one)"; fi

# A session that finished is not limited, whatever was rejected on the way.
workspace
plan limit-passed build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ] && [ ! -s "$SLEPT" ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "a session that finishes despite a rejected limit is not waited on"
else bad "a session that finishes despite a rejected limit is not waited on" "slept=$(cat "$SLEPT") $(calls)"; fi

# The rejected event is the signal, not any wording around it.
workspace
plan limit-quiet build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a limit is recognised from the rejected event alone"
else bad "a limit is recognised from the rejected event alone" "$(tkt 1-one) $(out)"; fi

# A rate_limit error with no reset time still waits, for the fallback period.
workspace
plan limit-bare build build review
( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=7 LIMIT_MARGIN=0 \
    bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 )
if [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 1 ] && [ "$(cat "$SLEPT")" = 7 ]; then
  ok "a limit that names no reset time is waited out too"
else bad "a limit that names no reset time is waited out too" "$(tkt 1-one) $(out)"; fi

workspace
plan build build limit review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 4 ] && grep -q '^resume ' <(tail -1 "$STUB_SESSIONS"); then
  ok "a limit during the final review is waited out and the review carries on"
else bad "a limit during the final review is waited out and the review carries on" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

workspace
plan build build limit limit limit
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=2 \
           bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -q 'gave up waiting out the limit' "$WORK/.out"; then
  ok "a final review that gives up on a limit fails the run"
else bad "a final review that gives up on a limit fails the run" "rc=$rc $(out)"; fi

workspace
plan build-limit
( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=0 \
    bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 )
if grep -q '1-one.md is at done' "$WORK/.out" && ! grep -q 'goes back to ready' "$WORK/.out"; then
  ok "giving up names the status the session left, not one it did not"
else bad "giving up names the status the session left, not one it did not" "$(out)"; fi

# And it is bounded: a limit that never lifts has to end the run rather than
# wait forever - and without charging the ticket for it.
workspace
plan limit limit limit
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=2 MAX_ATTEMPTS=1 \
           bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -q 'gave up waiting out the limit' "$WORK/.out"; then
  ok "a limit that never lifts gives up rather than waiting forever"
else bad "a limit that never lifts gives up rather than waiting forever" "rc=$rc $(out)"; fi
if [ "$(field 1-one status)" = ready ] && [ "$(field 1-one attempts)" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "giving up on a limit hands the ticket back rather than halting it"
else bad "giving up on a limit hands the ticket back rather than halting it" "$(tkt 1-one) $(calls)"; fi

# --- the token log
#
# Which tickets are expensive, counted in context read - a big session re-reads
# a big context on every turn - with the subagents apart, since a review is
# one. The stub's every call reads 111 in its own context, written twice the way
# the CLI repeats a message per content block, and 1000 in a subagent's.

workspace
plan build build review
run > /dev/null
if grep -qE '1-one +main +111 +subagents +1000 +total +1111' "$WORK/.out" \
   && grep -qE '2-two +main +111 +subagents +1000' "$WORK/.out"; then
  ok "the end of a run gives each ticket's context read, main session and subagents"
else bad "the end of a run gives each ticket's context read, main session and subagents" "$(out)"; fi
if grep -qE 'review +main +111 +subagents +1000' "$WORK/.out"; then
  ok "the final review is counted beside the tickets"
else bad "the final review is counted beside the tickets" "$(out)"; fi

# Every session a ticket took counts: a failed attempt read its context too.
workspace
plan claim-only build build review
run > /dev/null
if grep -qE '1-one +main +222 +subagents +2000' "$WORK/.out"; then
  ok "a ticket's count sums every session it took"
else bad "a ticket's count sums every session it took" "$(out)"; fi

# A run is started again after a halt or a kill, and what the first start spent
# is still spent.
workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build halt:blocked build review
run > /dev/null
sed -i '/^## Halt$/,$d; s/^status: .*/status:    ready/' "$WORK/changes/x/tickets/2-two.md"; commit
run > /dev/null
if grep -qE '1-one +main +111 ' "$WORK/.out" && grep -qE '2-two +main +222 ' "$WORK/.out"; then
  ok "the count survives a run started again"
else bad "the count survives a run started again" "$(out)"; fi

finish
