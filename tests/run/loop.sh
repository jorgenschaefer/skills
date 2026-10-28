#!/usr/bin/env bash
#
# The tests for run/loop.sh: the ordinary pass, and carrying on from wherever a
# killed run left a ticket. loop-sessions.sh and loop-checks.sh hold the rest.
#
#   tests/run/loop.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the ordinary pass

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ]; then ok "a clean run finishes"; else bad "a clean run finishes" "rc=$rc $(out)"; fi
if [ "$(field 1-one status)" = "done" ] && [ "$(field 2-two status)" = "done" ]; then
  ok "every ticket ends done"
else bad "every ticket ends done" "$(field 1-one status) / $(field 2-two status)"; fi
# The claim, the counter and the finish all end up in the commits: a run that
# leaves the ticket files modified leaves them for the next session to trip on.
if [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:changes/x/tickets/2-two.md | sed -n 's/^status: *//p')" = "done" ]; then
  ok "a clean run leaves nothing uncommitted, and done is committed"
else bad "a clean run leaves nothing uncommitted, and done is committed" "$(git -C "$WORK" status --porcelain)"; fi
# Sessions run where the runner was started, which need not be where the path
# was written from: a session in a subdirectory looked for a relative ticket
# path at the repository root first.
if grep -qF "$(realpath "$WORK")/changes/x/tickets/1-one.md" <(head -1 "$STUB_CALLS"); then
  ok "the build is given the ticket by its absolute path"
else bad "the build is given the ticket by its absolute path" "$(head -1 "$STUB_CALLS")"; fi
# Two builds and the final review. There is one session per ticket: the runner
# used to launch a second to review what the first built, and `/implement`
# spawns that reviewer itself.
if [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then ok "each ticket is built by exactly one session"
else bad "each ticket is built by exactly one session" "$(calls)"; fi

# Dependency order, where the numbering says the opposite.
workspace
sed -i 's/^after: .*/after:     2-two/' "$WORK/changes/x/tickets/1-one.md"
sed -i 's/^after: .*/after:     /'      "$WORK/changes/x/tickets/2-two.md"; commit
plan build build review
run > /dev/null
if grep -q '2-two' <(head -1 "$STUB_CALLS"); then ok "after: decides the order, not the filename"
else bad "after: decides the order, not the filename" "$(calls)"; fi

# --- a run killed in the middle
#
# A runner killed during a session left its claim at `doing`, uncommitted, with
# the session's work beside it: the next start refused the dirty tree, and a
# ticket committed at `doing` was never selected again. At startup a `doing`
# ticket can only be that, so the runner carries on with it - in the same
# session, on the same attempt.

workspace
plan killed build build review
run > /dev/null 2>&1
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a run killed in the middle is started again and finishes, on the same attempt"
else bad "a run killed in the middle is started again and finishes, on the same attempt" "rc=$rc $(field 1-one status) $(field 1-one attempts) $(out)"; fi
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ] \
   && grep -q 'interrupted' <(sed -n 2p "$STUB_CALLS"); then
  ok "the killed session is resumed, and told it was interrupted"
else bad "the killed session is resumed, and told it was interrupted" "$(cat "$STUB_SESSIONS") $(calls)"; fi
if git -C "$WORK" ls-files --error-unmatch code >/dev/null 2>&1; then
  ok "the killed session's work is carried on, not put aside"
else bad "the killed session's work is carried on, not put aside" "$(git -C "$WORK" stash list)"; fi

if grep -q 'carrying on with.*1-one' "$WORK/.out" && grep -q 'code' "$WORK/.out"; then
  ok "the restart says which claim it carries on with, and whose work it takes the tree for"
else bad "the restart says which claim it carries on with, and whose work it takes the tree for" "$(out)"; fi
# Resume, then the checks, then the next ticket: skipped for the half-built work,
# not for the run.
if awk '/--resume/ { r = NR } /--json-schema/ && r { v = NR } /2-two\.md/ && v { ok = 1 } END { exit !ok }' "$STUB_ARGS"; then
  ok "a restarted run still runs the checks before the next fresh claim"
else bad "a restarted run still runs the checks before the next fresh claim" "$(cut -c1-120 "$STUB_ARGS")"; fi

# The checks were green when the killed run started; run now, they would judge a
# half-built ticket.
workspace
STUB_VERIFY='! git status --porcelain | grep -q code'
plan killed build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 1-one status)" = "done" ]; then
  ok "the checks are not run on the killed session's half-built work"
else bad "the checks are not run on the killed session's half-built work" "rc=$rc $(out)"; fi

# Killed before the session was launched, there is nothing to resume: what is
# there is put aside and the ticket built again.
workspace
plan killed build build review
run > /dev/null 2>&1
rm -f "$WORK"/.git/run-logs/*.claim
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 1-one attempts)" = 2 ] && ! grep -q '^resume' "$STUB_SESSIONS" \
   && git -C "$WORK" stash list | grep -q '1-one'; then
  ok "a claim with no session to resume is put aside and built again"
else bad "a claim with no session to resume is put aside and built again" "rc=$rc $(field 1-one attempts) $(cat "$STUB_SESSIONS") $(git -C "$WORK" stash list) $(out)"; fi

# A claim is on record under its own ticket directory: two changes both have a
# 1-one.md, and one's record must not resume the other's session.
workspace
cp -r "$WORK/changes/x" "$WORK/changes/y"; commit
plan killed killed build build review
run > /dev/null 2>&1
commit
( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" changes/y/tickets > "$WORK/.out" 2>&1 )
commit
git -C "$WORK" checkout -q HEAD~1 -- changes/y 2>/dev/null
sed -i 's/^status: .*/status:    ready/' "$WORK"/changes/y/tickets/*.md; commit
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
rc="$(run)"
if [ "$rc" = 0 ] && grep -q "^resume $first\$" "$STUB_SESSIONS"; then
  ok "a killed claim resumes its own session, not another directory's of the same name"
else bad "a killed claim resumes its own session, not another directory's of the same name" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

# Killed after the session committed its build but before the runner checked
# it, the ticket is committed at `done`: a start again moves on without building
# it twice.
workspace
plan build-killed build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 2-two status)" = "done" ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "a run killed after a build committed moves on without building it again"
else bad "a run killed after a build committed moves on without building it again" "rc=$rc $(calls) $(out)"; fi

# The runner's own halts leave the ticket file uncommitted. That is bookkeeping,
# not someone's work: a start again stops at the halt as the first run did,
# rather than refusing the tree.
workspace
plan claim-only claim-only
run > /dev/null
rc="$(run)"
if [ "$rc" != 0 ] && ! grep -q 'dirty tree' "$WORK/.out" && grep -q 'RUN STOPPED: 1-one.md halted (unbuilt)' "$WORK/.out" \
   && [ "$(wc -l < "$STUB_CALLS")" = 2 ]; then
  ok "a run started again after a halt stops at the halt, not at its own bookkeeping"
else bad "a run started again after a halt stops at the halt, not at its own bookkeeping" "rc=$rc $(out)"; fi

# Killed after the session wrote `done` and before it committed, the `done` is
# only a claim: a start again checks it against the commit like any other, and
# builds the ticket again.
workspace
plan claim-killed build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 1-one attempts)" = 2 ] && [ "$(wc -l < "$STUB_CALLS")" = 4 ] \
   && [ "$(git -C "$WORK" show HEAD~1:changes/x/tickets/1-one.md | sed -n 's/^status: *//p')" = "done" ]; then
  ok "a done left uncommitted by a killed run is checked, not believed"
else bad "a done left uncommitted by a killed run is checked, not believed" "rc=$rc $(field 1-one attempts) $(calls) $(out)"; fi

# A halt the runner wrote stays where it is while the run goes on with the
# tickets that do not depend on it - not stashed with some other build's
# leftovers, which handed the ticket a fresh budget.
workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan claim-only claim-only code-only
run > /dev/null
run > /dev/null
if [ "$(field 1-one status)" = halted ] && [ "$(field 1-one attempts)" = 2 ] && grep -q '^## Halt' <(tkt 1-one) \
   && [ "$(field 2-two status)" = "done" ] && [ -z "$(git -C "$WORK" stash list)" ]; then
  ok "a halt left uncommitted survives the builds after it"
else bad "a halt left uncommitted survives the builds after it" "$(tkt 1-one) / $(git -C "$WORK" stash list) $(out)"; fi

# Killed after it handed a ticket back and before it released the record, the
# runner finds a ready ticket still on record: nothing to resume, only a fresh
# build to start.
workspace
plan killed build build review
run > /dev/null 2>&1
sed -i 's/^status: .*/status:    ready/' "$WORK/changes/x/tickets/1-one.md"
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q '^resume' "$STUB_SESSIONS" && [ "$(field 1-one attempts)" = 2 ]; then
  ok "a ticket handed back but still on record is built afresh, not resumed"
else bad "a ticket handed back but still on record is built afresh, not resumed" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

# A `done` only in the working tree is a claim nobody checked, whatever became
# of the record: killed between releasing it and writing the halt, the runner
# left exactly that, and a start again counted the ticket as built.
workspace
sed -i 's/^status: .*/status:    done/' "$WORK/changes/x/tickets/1-one.md"
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q '1-one' <(head -1 "$STUB_CALLS"); then
  ok "an uncommitted done with nothing on record is built, not believed"
else bad "an uncommitted done with nothing on record is built, not believed" "rc=$rc $(calls) $(out)"; fi

finish
