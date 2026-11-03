#!/usr/bin/env bash
#
# The tests for run/loop.sh: the ordinary pass, and carrying on from wherever a
# killed run left a part. loop-sessions.sh and loop-checks.sh hold the rest.
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
if [ "$(field 01 status)" = "done" ] && [ "$(field 02 status)" = "done" ]; then
  ok "every part ends done"
else bad "every part ends done" "$(field 01 status) / $(field 02 status)"; fi
# The claim, the counter and the finish all end up in the commits: a run that
# leaves the part files modified leaves them for the next session to trip on.
if [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:changes/x/plan/02.md | sed -n 's/^status: *//p')" = "done" ]; then
  ok "a clean run leaves nothing uncommitted, and done is committed"
else bad "a clean run leaves nothing uncommitted, and done is committed" "$(git -C "$WORK" status --porcelain)"; fi
# Sessions run where the runner was started, which need not be where the path
# was written from: a session in a subdirectory looked for a relative part
# path at the repository root first.
if grep -qF "$(realpath "$WORK")/changes/x/plan/01.md" <(head -1 "$STUB_CALLS"); then
  ok "the build is given the part by its absolute path"
else bad "the build is given the part by its absolute path" "$(head -1 "$STUB_CALLS")"; fi
# Two builds and the final review. There is one session per part: the runner
# used to launch a second to review what the first built, and `/implement-code`
# spawns that reviewer itself.
if [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then ok "each part is built by exactly one session"
else bad "each part is built by exactly one session" "$(calls)"; fi

# The parts are built in the order of their numbers, and an `after:` left in
# a part from the old format changes nothing.
workspace
chunk 03
sed -i 's/^status: /after:     03\nstatus: /' "$WORK/changes/x/plan/01.md"; commit
plan build build build review
run > /dev/null
if grep -qF "plan/01.md." <(sed -n 1p "$STUB_CALLS") && grep -qF "plan/02.md." <(sed -n 2p "$STUB_CALLS") \
   && grep -qF "plan/03.md." <(sed -n 3p "$STUB_CALLS"); then
  ok "parts are built in the order of their numbers, whatever an after: says"
else bad "parts are built in the order of their numbers, whatever an after: says" "$(calls)"; fi

# --- a run killed in the middle
#
# A runner killed during a session left its claim at `doing`, uncommitted, with
# the session's work beside it: the next start refused the dirty tree, and a
# part committed at `doing` was never selected again. At startup a `doing`
# part can only be that, so the runner carries on with it - in the same
# session, on the same attempt.

workspace
plan killed build build review
run > /dev/null 2>&1
rc="$(run)"
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ "$rc" = 0 ] && [ "$(field 01 status)" = "done" ] && [ "$(field 01 attempts)" = 1 ]; then
  ok "a run killed in the middle is started again and finishes, on the same attempt"
else bad "a run killed in the middle is started again and finishes, on the same attempt" "rc=$rc $(field 01 status) $(field 01 attempts) $(out)"; fi
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ] \
   && grep -q 'interrupted' <(sed -n 2p "$STUB_CALLS"); then
  ok "the killed session is resumed, and told it was interrupted"
else bad "the killed session is resumed, and told it was interrupted" "$(cat "$STUB_SESSIONS") $(calls)"; fi
if git -C "$WORK" ls-files --error-unmatch code >/dev/null 2>&1; then
  ok "the killed session's work is carried on, not put aside"
else bad "the killed session's work is carried on, not put aside" "$(git -C "$WORK" stash list)"; fi

if grep -q 'carrying on with.*01.md' "$WORK/.out" && grep -q 'code' "$WORK/.out"; then
  ok "the restart says which claim it carries on with, and whose work it takes the tree for"
else bad "the restart says which claim it carries on with, and whose work it takes the tree for" "$(out)"; fi
# Resume, then the checks, then the next part: skipped for the half-built work,
# not for the run.
if awk '/--resume/ { r = NR } /--json-schema/ && r { v = NR } /02\.md/ && v { ok = 1 } END { exit !ok }' "$STUB_ARGS"; then
  ok "a restarted run still runs the checks before the next fresh claim"
else bad "a restarted run still runs the checks before the next fresh claim" "$(cut -c1-120 "$STUB_ARGS")"; fi

# The checks were green when the killed run started; run now, they would judge a
# half-built part.
workspace
STUB_VERIFY='! git status --porcelain | grep -q code'
plan killed build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 01 status)" = "done" ]; then
  ok "the checks are not run on the killed session's half-built work"
else bad "the checks are not run on the killed session's half-built work" "rc=$rc $(out)"; fi

# Killed before the session was launched, there is nothing to resume: what is
# there is put aside and the part built again.
workspace
plan killed build build review
run > /dev/null 2>&1
rm -f "$WORK"/.git/run-logs/*.claim
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 01 attempts)" = 2 ] && ! grep -q '^resume' "$STUB_SESSIONS" \
   && git -C "$WORK" stash list | grep -q '01.md'; then
  ok "a claim with no session to resume is put aside and built again"
else bad "a claim with no session to resume is put aside and built again" "rc=$rc $(field 01 attempts) $(cat "$STUB_SESSIONS") $(git -C "$WORK" stash list) $(out)"; fi

# A claim is on record under its own part directory: two changes both have a
# plan/01.md, and one's record must not resume the other's session.
workspace
cp -r "$WORK/changes/x" "$WORK/changes/y"; commit
plan killed killed build build review
run > /dev/null 2>&1
commit
( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" changes/y > "$WORK/.out" 2>&1 )
commit
git -C "$WORK" checkout -q HEAD~1 -- changes/y 2>/dev/null
sed -i 's/^status: .*/status:    ready/' "$WORK"/changes/y/plan/*.md; commit
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
rc="$(run)"
if [ "$rc" = 0 ] && grep -q "^resume $first\$" "$STUB_SESSIONS"; then
  ok "a killed claim resumes its own session, not another directory's of the same name"
else bad "a killed claim resumes its own session, not another directory's of the same name" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

# Killed after the session committed its build but before the runner checked
# it, the part is committed at `done`: a start again moves on without building
# it twice.
workspace
plan build-killed build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 02 status)" = "done" ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "a run killed after a build committed moves on without building it again"
else bad "a run killed after a build committed moves on without building it again" "rc=$rc $(calls) $(out)"; fi

# The runner's own halts leave the part file uncommitted. That is bookkeeping,
# not someone's work: a start again stops at the halt as the first run did,
# rather than refusing the tree.
workspace
plan claim-only claim-only
run > /dev/null
rc="$(run)"
if [ "$rc" != 0 ] && ! grep -q 'dirty tree' "$WORK/.out" && grep -q 'RUN STOPPED: 01.md halted (unbuilt)' "$WORK/.out" \
   && [ "$(wc -l < "$STUB_CALLS")" = 2 ]; then
  ok "a run started again after a halt stops at the halt, not at its own bookkeeping"
else bad "a run started again after a halt stops at the halt, not at its own bookkeeping" "rc=$rc $(out)"; fi

# Killed after the session wrote `done` and before it committed, the `done` is
# only a claim: a start again checks it against the commit like any other, and
# builds the part again.
workspace
plan claim-killed build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 01 attempts)" = 2 ] && [ "$(wc -l < "$STUB_CALLS")" = 4 ] \
   && [ "$(git -C "$WORK" show HEAD~1:changes/x/plan/01.md | sed -n 's/^status: *//p')" = "done" ]; then
  ok "a done left uncommitted by a killed run is checked, not believed"
else bad "a done left uncommitted by a killed run is checked, not believed" "rc=$rc $(field 01 attempts) $(calls) $(out)"; fi

# A part rests on what the parts before it built, so nothing after a halted
# part is built: a run started again over the halt launches nothing, and the
# halt stays as it was written.
workspace
plan claim-only claim-only
run > /dev/null
: > "$STUB_CALLS"
rc="$(run)"
if [ "$rc" = 1 ] && [ ! -s "$STUB_CALLS" ] && [ "$(field 01 status)" = halted ] && grep -q '^## Halt' <(chk 01) \
   && [ "$(field 02 status)" = ready ] && [ -z "$(git -C "$WORK" stash list)" ]; then
  ok "a part after a halted one is not built, and the halt stays"
else bad "a part after a halted one is not built, and the halt stays" "rc=$rc $(chk 01) / $(git -C "$WORK" stash list) $(calls) $(out)"; fi

# Killed after it handed a part back and before it released the record, the
# runner finds a ready part still on record: nothing to resume, only a fresh
# build to start.
workspace
plan killed build build review
run > /dev/null 2>&1
sed -i 's/^status: .*/status:    ready/' "$WORK/changes/x/plan/01.md"
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q '^resume' "$STUB_SESSIONS" && [ "$(field 01 attempts)" = 2 ]; then
  ok "a part handed back but still on record is built afresh, not resumed"
else bad "a part handed back but still on record is built afresh, not resumed" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

# A `done` only in the working tree is a claim nobody checked, whatever became
# of the record: killed between releasing it and writing the halt, the runner
# left exactly that, and a start again counted the part as built.
workspace
sed -i 's/^status: .*/status:    done/' "$WORK/changes/x/plan/01.md"
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q 'plan/01.md' <(head -1 "$STUB_CALLS"); then
  ok "an uncommitted done with nothing on record is built, not believed"
else bad "an uncommitted done with nothing on record is built, not believed" "rc=$rc $(calls) $(out)"; fi

finish
