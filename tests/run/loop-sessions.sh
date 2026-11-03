#!/usr/bin/env bash
#
# The tests for run/loop.sh, on what a session leaves behind: a claim it did not
# put back, work it did not finish or did not commit, and a halt of its own.
#
#   tests/run/loop-sessions.sh

set -uo pipefail

# shellcheck source=harness.sh
. "$(dirname "$0")/harness.sh"

# --- the runner owns the claim
#
# A crashed session leaves its claim behind; only the runner can put it back,
# and the proof is that the part gets picked up again at all.

workspace
plan die build build review
run > /dev/null
if [ "$(field 01 status)" = "done" ]; then ok "a part whose session died is picked up again"
else bad "a part whose session died is picked up again" "$(field 01 status) $(out)"; fi
if [ "$(field 01 attempts)" = 2 ]; then ok "a dead session still spends an attempt"
else bad "a dead session still spends an attempt" "attempts=$(field 01 attempts)"; fi

# The attempt budget, spent.
workspace
plan die die
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 01 status)" = halted ] && grep -q 'exhausted' <(chk 01); then
  ok "the attempt budget, once spent, halts the part as exhausted"
else bad "the attempt budget, once spent, halts the part as exhausted" "rc=$rc $(tail -3 <(chk 01))"; fi

# --- a session that stops before it finishes
#
# A session can end its turn with the work unfinished. Under an earlier CLI one
# that ended it to wait on a check it put in the background was not woken again,
# and the check was killed. That build did so with its work done and reviewed,
# and the retry started from nothing on top of the diff it left. The same
# session is resumed instead, once, and a second early stop is put aside where
# the next attempt cannot mistake it for the state the checks were green on.

workspace
plan stop-early build build review
run > /dev/null
if [ "$(field 01 status)" = "done" ] && [ "$(field 01 attempts)" = 1 ]; then
  ok "a session that stopped early is carried on without spending an attempt"
else bad "a session that stopped early is carried on without spending an attempt" "$(field 01 status) $(field 01 attempts) $(out)"; fi
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a session that stopped early is resumed, not started over"
else bad "a session that stopped early is resumed, not started over" "$(cat "$STUB_SESSIONS")"; fi
if grep -q 'still in the tree' <(sed -n 2p "$STUB_CALLS"); then ok "the resumed session is told its work is still in the tree"
else bad "the resumed session is told its work is still in the tree" "$(calls)"; fi

# With nothing uncommitted, a stopped session was claimed again from scratch, and
# the new one halted over a build already in HEAD.
workspace
plan commit-stop build build review
run > /dev/null
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a session that committed and stopped is resumed, not started over"
else bad "a session that committed and stopped is resumed, not started over" "$(cat "$STUB_SESSIONS")"; fi
if [ "$(field 01 status)" = "done" ] && [ "$(field 01 attempts)" = 1 ]; then
  ok "a session that committed and stopped is carried on without spending an attempt"
else bad "a session that committed and stopped is carried on without spending an attempt" "$(field 01 status) $(field 01 attempts) $(out)"; fi

workspace
plan stop-early stop-early build build review
run > /dev/null
if [ "$(field 01 status)" = "done" ] && [ "$(field 01 attempts)" = 2 ] \
   && grep -q '^start ' <(sed -n 3p "$STUB_SESSIONS"); then
  ok "a session that stops early twice is started over, spending an attempt"
else bad "a session that stops early twice is started over, spending an attempt" "$(field 01 attempts) $(cat "$STUB_SESSIONS") $(out)"; fi
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '01.*attempt 1'; then
  ok "what it left is stashed, not built on"
else bad "what it left is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# Started from a subdirectory, as the runner was in the run that found this: what
# is left at the repository root is put aside too.
workspace
plan stop-early stop-early build build review
( cd "$WORK/changes" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS=2 \
    bash "$RUNNER" x > "$WORK/.out" 2>&1 )
if [ ! -e "$WORK/code" ] && git -C "$WORK" stash list | grep -q '01.*attempt 1'; then
  ok "started from a subdirectory, what is left at the root is stashed too"
else bad "started from a subdirectory, what is left at the root is stashed too" "$(git -C "$WORK" status --porcelain) / $(git -C "$WORK" stash list) $(out)"; fi

# Only a session that ended cleanly is resumed: a crash was not waiting on
# anything, and what a finished build left lying around is not the next one's.
workspace
plan build-dirty die build review
run > /dev/null
if ! grep -q '^resume' "$STUB_SESSIONS" && git -C "$WORK" stash list | grep -q '01.md'; then
  ok "what a finished build leaves behind is put aside under its own name, not resumed on"
else bad "what a finished build leaves behind is put aside under its own name, not resumed on" "$(cat "$STUB_SESSIONS") / $(git -C "$WORK" stash list)"; fi

workspace
plan claim-dirty claim-only
run > /dev/null
if grep -q 'git stash' <(chk 01); then ok "a halt after abandoned attempts points at the stash"
else bad "a halt after abandoned attempts points at the stash" "$(tail -3 <(chk 01))"; fi

# --- a build that committed nothing
#
# `done` is a session's account of itself, and a session that wrote no code can
# still write it. The commit is the part that cannot be claimed, so the runner
# believes the one and checks the other.

workspace
plan claim-only build build review
run > /dev/null
if [ "$(field 01 status)" = "done" ]; then ok "a part whose session committed nothing is picked up again"
else bad "a part whose session committed nothing is picked up again" "$(field 01 status)"; fi
if [ "$(field 01 attempts)" = 2 ]; then ok "a session that committed nothing still spends an attempt"
else bad "a session that committed nothing still spends an attempt" "attempts=$(field 01 attempts)"; fi

workspace
plan claim-dirty build build review
run > /dev/null
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '01.*attempt 1'; then
  ok "what a build that committed nothing left behind is stashed, not built on"
else bad "what a build that committed nothing left behind is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# The finish goes into the build's own commit rather than one of its own, since
# only a session can write a message - and a part the session left out of that
# commit goes in with it.
workspace
plan code-only build review
run > /dev/null
built="$(git -C "$WORK" log -1 --format=%H --grep='^build 01')"
if [ "$(git -C "$WORK" rev-list --count "$built")" = 3 ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show "$built:changes/x/plan/01.md" | sed -n 's/^status: *//p')" = "done" ]; then
  ok "done is amended into the build's commit, part and all"
else bad "done is amended into the build's commit, part and all" "$(git -C "$WORK" log --stat) $(git -C "$WORK" status --porcelain)"; fi

workspace
plan claim-only claim-only
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 01 status)" = halted ]; then
  ok "a build that never commits halts once the budget is spent"
else bad "a build that never commits halts once the budget is spent" "rc=$rc status=$(field 01 status)"; fi
if grep -q 'unbuilt' <(chk 01) && grep -q 'committed nothing' <(chk 01); then
  ok "the halt is named for what happened, not for the budget"
else bad "the halt is named for what happened, not for the budget" "$(tail -3 <(chk 01))"; fi

# --- a session's own halt stops the run

workspace
plan halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 01 status)" = halted ]; then ok "a session halt stops the run"
else bad "a session halt stops the run" "rc=$rc status=$(field 01 status)"; fi
if [ "$(field 02 status)" = ready ]; then ok "a halt leaves the rest of the directory alone"
else bad "a halt leaves the rest of the directory alone" "$(field 02 status)"; fi

# A halt is the one thing a run leaves for a person, and the runner commits its
# own. A session's own was left uncommitted, for the next start to read as
# someone else's change.
if [ "$(git -C "$WORK" show HEAD:changes/x/plan/01.md | sed -n 's/^status: *//p')" = halted ] \
   && [ -z "$(git -C "$WORK" status --porcelain -- changes/x/plan)" ] \
   && [ "$(git -C "$WORK" log -1 --format=%s)" = "Halt 01: blocked" ]; then
  ok "a session's halt is committed, named for its kind"
else bad "a session's halt is committed, named for its kind" "$(git -C "$WORK" log --oneline | head -3) $(git -C "$WORK" status --porcelain)"; fi

# The kind is read off what the session wrote, whichever of the three it is.
workspace
plan halt:mystery
run > /dev/null
if [ "$(git -C "$WORK" log -1 --format=%s)" = "Halt 01: mystery" ]; then
  ok "a session's halt commit names the kind it wrote"
else bad "a session's halt commit names the kind it wrote" "$(git -C "$WORK" log --oneline | head -3)"; fi

# /implement-plan halts as a departure where a hard decision or a hard test
# would have to change.
workspace
plan halt:departure
rc="$(run)"
if [ "$rc" = 1 ] && [ "$(field 01 status)" = halted ] && [ "$(field 02 status)" = ready ] \
   && [ "$(git -C "$WORK" log -1 --format=%s)" = "Halt 01: departure" ] \
   && grep -q 'RUN STOPPED: 01.md halted (departure)' "$WORK/.out"; then
  ok "a part its session halts as a departure stops the run, the kind read back"
else bad "a part its session halts as a departure stops the run, the kind read back" "rc=$rc $(git -C "$WORK" log --oneline | head -3) $(out)"; fi

# --- a build that changes a journey
#
# The journeys were changed and committed before the build. A build that
# changes one has changed what the developer agreed to.

workspace
plan build-journey build review
rc="$(run)"
if [ "$rc" = 1 ] && [ "$(field 01 status)" = halted ] && grep -q '^departure' <(sed -n '/^## Halt$/,$p' "$(chunk_path 01)" | sed -n 3p) \
   && grep -q 'journeys/one.md' <(chk 01) && [ "$(wc -l < "$STUB_CALLS")" = 1 ]; then
  ok "a build that changes a journey halts as a departure, naming it"
else bad "a build that changes a journey halts as a departure, naming it" "rc=$rc $(chk 01) $(out)"; fi
if grep -q 'RUN STOPPED: 01.md halted (departure)' "$WORK/.out" \
   && git -C "$WORK" log --format=%s | grep -q '^build 01.md' && [ -z "$(git -C "$WORK" status --porcelain)" ]; then
  ok "the build's commit stands for the developer, and the halt is committed"
else bad "the build's commit stands for the developer, and the halt is committed" "$(out) $(git -C "$WORK" status --porcelain)"; fi

finish
