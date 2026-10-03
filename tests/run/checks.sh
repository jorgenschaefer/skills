#!/usr/bin/env bash
#
# The tests for run/checks.sh: the project's checks, found by a session and run
# by the runner before any build.
#
#   tests/run/checks.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the project's checks, before any build
#
# A build told the checks were green on HEAD cannot mistake a failure that was
# already there for its own, or halt over one. So they are run first, by the
# runner, and a run that starts red does not start.

workspace
STUB_VERIFY=false
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'false' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "checks that fail before any build stop the run, naming the command"
else bad "checks that fail before any build stop the run, naming the command" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY=
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'no verification command' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a session that names no verification command stops the run"
else bad "a session that names no verification command stops the run" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY='touch .verified'
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.verified" ]; then
  ok "the command the session named is what the runner runs"
else bad "the command the session named is what the runner runs" "rc=$rc $(out)"; fi
if grep -q 'touch .verified' <(head -1 "$STUB_CALLS"); then
  ok "the build is told the command, and that it was green"
else bad "the build is told the command, and that it was green" "$(calls)"; fi
# A criterion is proven once, by the ticket that closes it, and where its user
# acts; a ticket that only advances one proves its own narrower part.
if grep -q 'closes:.*where its user acts.*## Toward' <(head -1 "$STUB_CALLS"); then
  ok "the build is told how a closed criterion and an advanced one are proven"
else bad "the build is told how a closed criterion and an advanced one are proven" "$(calls)"; fi

# A VERIFY in the caller's environment is not a check that passed.
workspace
STUB_VERIFY=false
plan build build review
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" VERIFY=true bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a VERIFY already in the environment does not skip the checks"
else bad "a VERIFY already in the environment does not skip the checks" "rc=$rc $(out)"; fi

finish
