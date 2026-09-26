#!/usr/bin/env bash
#
# The tests for the runner: what it does with a ticket directory when nobody is
# watching.
#
#   tests/runner.sh
#
# Everything `run.sh` holds is something that has to be true when a session is
# dead or lying, which is why it is a script and not a skill. Each case below
# builds a throwaway repository in the layout the pipeline actually uses - an
# intent, the solution beside it, the tickets under it - puts a stub on PATH
# where `claude` would be, and runs the real thing against it.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$HERE/../run.sh"

# shellcheck source=lib.sh
. "$HERE/lib.sh"

WORKSPACES=()
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# One topic: a solution with two criteria and a ticket for each, the second
# after the first.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  mkdir -p "$WORK/intents/x/tickets"
  printf '# Intent: x\n\n## Done when\n\n- **C-1** the first thing.\n- **C-2** the second thing.\n' \
    > "$WORK/intents/x/01-INTENT.md"
  cat > "$WORK/intents/x/02-SOLUTION.md" <<'EOF'
# Solution: x

## Behaviour
- **AC-1** the first thing happens. *(C-1)*
- **AC-2** the second thing happens. *(C-2)*
EOF
  ticket 1-one AC-1 "the first thing happens." ""
  ticket 2-two AC-2 "the second thing happens." "1-one"
  git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm paper
  git -C "$WORK" checkout -q -b topic
  # The stub's own files sit in the workspace and are nobody's change: without
  # this every case would be refused as a dirty tree.
  printf '/.*\n' >> "$WORK/.git/info/exclude"
  STUB_CALLS="$WORK/.calls"; STUB_PLAN="$WORK/.plan"; STUB_SESSIONS="$WORK/.sessions"
  STUB_ARGS="$WORK/.args"
  : > "$STUB_CALLS"; : > "$STUB_PLAN"; : > "$STUB_SESSIONS"; : > "$STUB_ARGS"
  STUB_VERIFY=true
  export STUB_CALLS STUB_PLAN STUB_SESSIONS STUB_ARGS STUB_VERIFY
  mkdir -p "$WORK/.bin" && ln -sf "$HERE/stub-session" "$WORK/.bin/claude"
  # How long the runner asked to sleep, one line per sleep, and no wait at all.
  # The clock `date +%s` reads moves by what was slept instead, plus whatever
  # .suspend holds on the next sleep: a machine suspended in the middle of it.
  SLEPT="$WORK/.slept"; : > "$SLEPT"; CLOCK="$WORK/.clock"; date +%s > "$CLOCK"
  cat > "$WORK/.bin/sleep" <<STUB
#!/bin/sh
echo "\$1" >> "$SLEPT"
echo \$(( \$(cat "$CLOCK") + \$1 + \$(cat "$WORK/.suspend" 2>/dev/null || echo 0) )) > "$CLOCK"
rm -f "$WORK/.suspend"
STUB
  cat > "$WORK/.bin/date" <<STUB
#!/bin/sh
if [ "\$1" = +%s ]; then cat "$CLOCK"; else exec $(command -v date) "\$@"; fi
STUB
  chmod +x "$WORK/.bin/sleep" "$WORK/.bin/date"
}

ticket() {  # slug, id, text, after
  cat > "$WORK/intents/x/tickets/$1.md" <<EOF
---
solution:  02-SOLUTION.md
satisfies: $2
after:     $4
status:    ready
attempts:  0
---

## Build
x

## Done when

> **$2** $3

## Context
x

## Not here
x
EOF
}

plan()  { printf '%s\n' "$@" > "$STUB_PLAN"; }
commit() { git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm edit; }
run()   { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}" \
              bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$WORK/intents/x/tickets/$1.md" | head -1; }
tkt()   { cat "$WORK/intents/x/tickets/$1.md"; }
out()   { cat "$WORK/.out"; }
calls() { cat "$STUB_CALLS"; }

# --- refusals, before anything is launched

workspace; git -C "$WORK" checkout -q main
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -qi 'branch' "$WORK/.out"; then
  ok "it refuses to run on the main branch"
else bad "it refuses to run on the main branch" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "it launches nothing when it refuses"
else bad "it launches nothing when it refuses" "$(calls)"; fi

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" intents/x/nope >"$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ]; then ok "it refuses a ticket directory that is not there"
else bad "it refuses a ticket directory that is not there" "$(out)"; fi

# A repository with nothing committed yet is inside a work tree and has a branch
# name, so the two refusals above pass it. The HEAD check would in fact get it
# right - `rev-parse HEAD` prints the literal `HEAD` when it fails - but a
# correctness check resting on a command echoing its argument back is not one to
# leave standing, and the message says so.
workspace
rm -rf "$WORK/.git"
git -C "$WORK" init -q -b topic
git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'no commits' "$WORK/.out" && grep -q 'branch refusal' "$WORK/.out"; then
  ok "it refuses a repository with no commits, for the reason it gives"
else bad "it refuses a repository with no commits, for the reason it gives" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "a repository with no commits launches nothing"
else bad "a repository with no commits launches nothing" "$(calls)"; fi

# Whatever is lying around uncommitted is someone's, and a session cannot tell
# it from its own work: it lints it, reviews it, and has to carve it out of
# every diff. Untracked files count - an untracked mockup broke the lint of a
# whole run.
workspace
printf 'x\n' > "$WORK/stray"
plan build build walk
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'stray' "$WORK/.out"; then
  ok "it refuses a dirty tree, and names what is in it"
else bad "it refuses a dirty tree, and names what is in it" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "a dirty tree launches nothing"
else bad "a dirty tree launches nothing" "$(calls)"; fi

# --- the project's checks, before any build
#
# A build told the checks were green on HEAD cannot mistake a failure that was
# already there for its own, or halt over one. So they are run first, by the
# runner, and a run that starts red does not start.

workspace
STUB_VERIFY=false
plan build build walk
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'false' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "checks that fail before any build stop the run, naming the command"
else bad "checks that fail before any build stop the run, naming the command" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY=
plan build build walk
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'no verification command' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a session that names no verification command stops the run"
else bad "a session that names no verification command stops the run" "rc=$rc $(out) $(calls)"; fi

workspace
STUB_VERIFY='touch .verified'
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ] && [ -f "$WORK/.verified" ]; then
  ok "the command the session named is what the runner runs"
else bad "the command the session named is what the runner runs" "rc=$rc $(out)"; fi
if grep -q 'touch .verified' <(head -1 "$STUB_CALLS"); then
  ok "the build is told the command, and that it was green"
else bad "the build is told the command, and that it was green" "$(calls)"; fi

# Someone's notes in the ticket directory are not a ticket.
workspace
printf '# notes\n' > "$WORK/intents/x/tickets/README.md"; commit
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'ignoring' "$WORK/.out"; then
  ok "a file that is not a ticket is ignored, and said so"
else bad "a file that is not a ticket is ignored, and said so" "rc=$rc $(out)"; fi

# --- the drift pre-flight, in both directions
#
# A session never reads the solution and a committed ticket is revisited by
# nobody, so this is the only place the two can be found to disagree.

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/intents/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a ticket whose criterion left the solution stops the run"
else bad "a ticket whose criterion left the solution stops the run" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "drift stops it before any session"
else bad "drift stops it before any session" "$(calls)"; fi
# The stop is named where a person will look, not only on a terminal nobody is
# watching - which is the whole reason the runner is unattended.
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: the ticket's criterion moved"
else bad "drift is written into the ticket: the ticket's criterion moved" "$(tkt 1-one)"; fi

workspace
printf -- '- **AC-3** a third thing happens. *(C-3)*\n' >> "$WORK/intents/x/02-SOLUTION.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a criterion in no ticket stops the run"
else bad "a criterion in no ticket stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: a criterion no ticket quotes"
else bad "drift is written into the ticket: a criterion no ticket quotes" "$(tkt 1-one)"; fi
# Reported once, not once per ticket in the directory.
if [ "$(grep -c 'AC-3 is quoted by no ticket' "$WORK/.out")" = 1 ]; then
  ok "an uncovered criterion is reported once, not once per ticket"
else bad "an uncovered criterion is reported once, not once per ticket" "$(out)"; fi

# A criterion that no longer holds is deleted, and its number goes with it: the
# gap is what keeps the number from being handed out twice.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/intents/x/02-SOLUTION.md"
rm "$WORK/intents/x/tickets/1-one.md"
sed -i 's/^after: .*/after:/' "$WORK/intents/x/tickets/2-two.md"
git -C "$WORK" commit -qam delete
plan build walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a criterion deleted from the solution leaves a gap, and that is no drift"
else bad "a criterion deleted from the solution leaves a gap, and that is no drift" "rc=$rc $(out)"; fi

# Deleting a criterion a ticket still quotes is the upstream edit the check
# exists for, and it says so rather than reporting a mismatch against nothing.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam delete
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-1 is gone from' "$WORK/.out"; then
  ok "a ticket quoting a deleted criterion stops the run"
else bad "a ticket quoting a deleted criterion stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: its criterion was deleted"
else bad "drift is written into the ticket: its criterion was deleted" "$(tkt 1-one)"; fi

# The tag is what the ticket leaves off, whatever it says: a decision taken by
# the user rather than for a condition, a constraint named in words.
workspace
sed -i 's/\*(C-1)\*/*(Nutzer)*/' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam retag
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a tag of any word is left off the comparison"
else bad "a tag of any word is left off the comparison" "rc=$rc $(out)"; fi

workspace
sed -i 's/ \*(C-2)\*/ *(C-2; Constraint\n  „the groups the tool knows")*/' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam retag
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a tag with punctuation, broken over two lines, is left off the comparison"
else bad "a tag with punctuation, broken over two lines, is left off the comparison" "rc=$rc $(out)"; fi

workspace
rm "$WORK/intents/x/02-SOLUTION.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'not there' "$WORK/.out"; then
  ok "a ticket whose solution is gone stops the run"
else bad "a ticket whose solution is gone stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: the solution is gone"
else bad "drift is written into the ticket: the solution is gone" "$(tkt 1-one)"; fi

# A ticket with nothing left to build is deleted, and whatever came after it has
# to be told, or it waits for a ticket that will never be done.
workspace
rm "$WORK/intents/x/tickets/1-one.md"
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm delete
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'names 1-one, which is not a ticket' "$WORK/.out"; then
  ok "a ticket whose after: names a deleted ticket stops the run"
else bad "a ticket whose after: names a deleted ticket stops the run" "rc=$rc $(out)"; fi
if [ "$(field 2-two status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a dangling after: halts its ticket before any session"
else bad "a dangling after: halts its ticket before any session" "$(tkt 2-two) $(calls)"; fi

# A built ticket whose criterion changed is re-sliced in place: its words
# updated and its status put back, so the runner builds it again.
workspace
plan build build walk
run > /dev/null
sed -i 's/the first thing happens./the first thing happens, differently./' \
  "$WORK/intents/x/02-SOLUTION.md" "$WORK/intents/x/tickets/1-one.md"
sed -i 's/^status: .*/status:    ready/; s/^attempts: .*/attempts:  0/' "$WORK/intents/x/tickets/1-one.md"
git -C "$WORK" commit -qam reslice
: > "$STUB_CALLS"
plan build walk
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ] && grep -q '1-one' <(head -1 "$STUB_CALLS"); then
  ok "a done ticket put back to ready is built again, and only it"
else bad "a done ticket put back to ready is built again, and only it" "rc=$rc $(calls) $(out)"; fi
if [ "$(field 1-one status)" = done ] && [ "$(field 2-two status)" = done ]; then
  ok "the rebuilt ticket ends done beside the one left alone"
else bad "the rebuilt ticket ends done beside the one left alone" "$(field 1-one status) / $(field 2-two status)"; fi

# --- the ordinary pass

workspace
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ]; then ok "a clean run finishes"; else bad "a clean run finishes" "rc=$rc $(out)"; fi
if [ "$(field 1-one status)" = done ] && [ "$(field 2-two status)" = done ]; then
  ok "every ticket ends done"
else bad "every ticket ends done" "$(field 1-one status) / $(field 2-two status)"; fi
# The claim, the counter and the finish all end up in the commits: a run that
# leaves the ticket files modified leaves them for the next session to trip on.
if [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:intents/x/tickets/2-two.md | sed -n 's/^status: *//p')" = done ]; then
  ok "a clean run leaves nothing uncommitted, and done is committed"
else bad "a clean run leaves nothing uncommitted, and done is committed" "$(git -C "$WORK" status --porcelain)"; fi
# Sessions run where the runner was started, which need not be where the path
# was written from: a session in a subdirectory looked for a relative ticket
# path at the repository root first.
if grep -qF "$(realpath "$WORK")/intents/x/tickets/1-one.md" <(head -1 "$STUB_CALLS"); then
  ok "the build is given the ticket by its absolute path"
else bad "the build is given the ticket by its absolute path" "$(head -1 "$STUB_CALLS")"; fi
# A session that runs its checks in the background has to be able to wait on
# them, and `sleep` is refused.
if grep -q -- '--allowedTools .*Monitor' <(grep 'Use /implement' "$STUB_ARGS" | head -1); then
  ok "a build may use Monitor to wait on its background checks"
else bad "a build may use Monitor to wait on its background checks" "$(head -2 "$STUB_ARGS")"; fi
if grep -q '1-one' <(head -1 "$STUB_CALLS"); then ok "it builds in dependency order"
else bad "it builds in dependency order" "$(calls)"; fi
# Two builds and the walk. There is one session per ticket now: the runner used
# to launch a second to review what the first built, and `/implement` spawns
# that reviewer itself.
if [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then ok "each ticket is built by exactly one session"
else bad "each ticket is built by exactly one session" "$(calls)"; fi

# Dependency order, where the numbering says the opposite.
workspace
sed -i 's/^after: .*/after:     2-two/' "$WORK/intents/x/tickets/1-one.md"
sed -i 's/^after: .*/after:     /'      "$WORK/intents/x/tickets/2-two.md"; commit
plan build build walk
run > /dev/null
if grep -q '2-two' <(head -1 "$STUB_CALLS"); then ok "after: decides the order, not the filename"
else bad "after: decides the order, not the filename" "$(calls)"; fi

# --- the runner owns the claim
#
# A crashed session leaves its claim behind; only the runner can put it back,
# and the proof is that the ticket gets picked up again at all.

workspace
plan die build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ]; then ok "a ticket whose session died is picked up again"
else bad "a ticket whose session died is picked up again" "$(field 1-one status) $(out)"; fi
if [ "$(field 1-one attempts)" = 2 ]; then ok "a dead session still spends an attempt"
else bad "a dead session still spends an attempt" "attempts=$(field 1-one attempts)"; fi

# The attempt budget, spent.
workspace
plan die die
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ] && grep -q 'exhausted' <(tkt 1-one); then
  ok "the attempt budget, once spent, halts the ticket as exhausted"
else bad "the attempt budget, once spent, halts the ticket as exhausted" "rc=$rc $(tail -3 <(tkt 1-one))"; fi

# --- a session that stops before it finishes
#
# In `-p` a session that ends its turn to wait on a check it put in the
# background is not woken again: the process exits and the check is killed. One
# build did exactly that with its work done and reviewed, and the retry started
# from nothing on top of the diff it left. The same session is resumed instead,
# once, and a second early stop is put aside where the next attempt cannot
# mistake it for the state the checks were green on.

workspace
plan stop-early build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a session that stopped early is carried on without spending an attempt"
else bad "a session that stopped early is carried on without spending an attempt" "$(field 1-one status) $(field 1-one attempts) $(out)"; fi
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a session that stopped early is resumed, not started over"
else bad "a session that stopped early is resumed, not started over" "$(cat "$STUB_SESSIONS")"; fi
if grep -q 'background' <(sed -n 2p "$STUB_CALLS"); then ok "the resumed session is told its background work was killed"
else bad "the resumed session is told its background work was killed" "$(calls)"; fi

workspace
plan stop-early stop-early build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ] && [ "$(field 1-one attempts)" = 2 ] \
   && grep -q '^start ' <(sed -n 3p "$STUB_SESSIONS"); then
  ok "a session that stops early twice is started over, spending an attempt"
else bad "a session that stops early twice is started over, spending an attempt" "$(field 1-one attempts) $(cat "$STUB_SESSIONS") $(out)"; fi
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "what it left is stashed, not built on"
else bad "what it left is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# Started from a subdirectory, as the runner was in the run that found this: what
# is left at the repository root is put aside too.
workspace
plan stop-early stop-early build build walk
( cd "$WORK/intents" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS=2 \
    bash "$RUNNER" x/tickets > "$WORK/.out" 2>&1 )
if [ ! -e "$WORK/code" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "started from a subdirectory, what is left at the root is stashed too"
else bad "started from a subdirectory, what is left at the root is stashed too" "$(git -C "$WORK" status --porcelain) / $(git -C "$WORK" stash list) $(out)"; fi

# Only a session that ended cleanly is resumed: a crash was not waiting on
# anything, and what a finished build left lying around is not the next one's.
workspace
plan build-dirty die build build walk
run > /dev/null
if ! grep -q '^resume' "$STUB_SESSIONS" && git -C "$WORK" stash list | grep -q '1-one'; then
  ok "what a finished build leaves behind is put aside under its own name, not resumed on"
else bad "what a finished build leaves behind is put aside under its own name, not resumed on" "$(cat "$STUB_SESSIONS") / $(git -C "$WORK" stash list)"; fi

workspace
plan claim-dirty claim-only
run > /dev/null
if grep -q 'git stash' <(tkt 1-one); then ok "a halt after abandoned attempts points at the stash"
else bad "a halt after abandoned attempts points at the stash" "$(tail -3 <(tkt 1-one))"; fi

workspace
plan build build walk
run > /dev/null
if grep -q 'Monitor' <(head -1 "$STUB_CALLS"); then ok "the build is told nothing wakes it once its turn ends"
else bad "the build is told nothing wakes it once its turn ends" "$(head -1 "$STUB_CALLS")"; fi

# --- a build that committed nothing
#
# `review` is a session's account of itself, and a session that wrote no code can
# still write it. The commit is the part that cannot be claimed, so the runner
# believes the one and checks the other.

workspace
plan claim-only build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ]; then ok "a ticket whose session committed nothing is picked up again"
else bad "a ticket whose session committed nothing is picked up again" "$(field 1-one status)"; fi
if [ "$(field 1-one attempts)" = 2 ]; then ok "a session that committed nothing still spends an attempt"
else bad "a session that committed nothing still spends an attempt" "attempts=$(field 1-one attempts)"; fi

workspace
plan claim-dirty build build walk
run > /dev/null
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "what a build that committed nothing left behind is stashed, not built on"
else bad "what a build that committed nothing left behind is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# The finish goes into the build's own commit rather than one of its own, since
# only a session can write a message - and a ticket the session left out of that
# commit goes in with it.
workspace
plan code-only build walk
run > /dev/null
if [ "$(git -C "$WORK" rev-list --count HEAD)" = 3 ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD~1:intents/x/tickets/1-one.md | sed -n 's/^status: *//p')" = done ]; then
  ok "done is amended into the build's commit, ticket and all"
else bad "done is amended into the build's commit, ticket and all" "$(git -C "$WORK" log --stat) $(git -C "$WORK" status --porcelain)"; fi

workspace
plan claim-only claim-only
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ]; then
  ok "a build that never commits halts once the budget is spent"
else bad "a build that never commits halts once the budget is spent" "rc=$rc status=$(field 1-one status)"; fi
if grep -q 'unbuilt' <(tkt 1-one) && grep -q 'committed nothing' <(tkt 1-one); then
  ok "the halt is named for what happened, not for the budget"
else bad "the halt is named for what happened, not for the budget" "$(tail -3 <(tkt 1-one))"; fi

# --- a session's own halt stops the run

workspace
plan halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ]; then ok "a session halt stops the run"
else bad "a session halt stops the run" "rc=$rc status=$(field 1-one status)"; fi
if [ "$(field 2-two status)" = ready ]; then ok "a halt leaves the rest of the directory alone"
else bad "a halt leaves the rest of the directory alone" "$(field 2-two status)"; fi

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
plan limit build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ]; then ok "a usage limit is waited out and the ticket still finishes"
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
plan limit build build walk
( cd "$WORK" && PATH="$WORK/.bin:$PATH" STUB_RESET_IN=3600 LIMIT_MARGIN=120 WAIT_SECONDS=5 \
    bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 )
slept="$(awk '{ s += $1 } END { print s + 0 }' "$SLEPT")"
if [ "$slept" -ge 3715 ] && [ "$slept" -le 3720 ]; then
  ok "a limit is waited out until its reset, plus the margin"
else bad "a limit is waited out until its reset, plus the margin" "slept=$slept $(out)"; fi

# The reset is a time on the clock, and a machine suspended mid-wait has spent
# that time too: `sleep` counts only the time the machine was awake, and a run
# slept on well past a reset it had long reached.
workspace
plan limit build build walk
echo 3000 > "$WORK/.suspend"
( cd "$WORK" && PATH="$WORK/.bin:$PATH" STUB_RESET_IN=3600 LIMIT_MARGIN=120 WAIT_SECONDS=5 \
    bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 )
slept="$(awk '{ s += $1 } END { print s + 0 }' "$SLEPT")"
if [ "$(field 1-one status)" = done ] && [ "$slept" -le 780 ]; then
  ok "a wait counts the time the machine was suspended"
else bad "a wait counts the time the machine was suspended" "slept=$slept $(out)"; fi

# A subagent's limit is the subagent's: the session that then dies of something
# else has failed, and spends its attempt.
workspace
plan limit-sub build build walk
run > /dev/null
if [ ! -s "$SLEPT" ] && [ "$(field 1-one attempts)" = 2 ]; then
  ok "a subagent's limit does not make the session's failure a limit"
else bad "a subagent's limit does not make the session's failure a limit" "slept=$(cat "$SLEPT") $(tkt 1-one)"; fi

# A session that finished is not limited, whatever was rejected on the way.
workspace
plan limit-passed build walk
run > /dev/null
if [ "$(field 1-one status)" = done ] && [ ! -s "$SLEPT" ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "a session that finishes despite a rejected limit is not waited on"
else bad "a session that finishes despite a rejected limit is not waited on" "slept=$(cat "$SLEPT") $(calls)"; fi

# The rejected event is the signal, not any wording around it.
workspace
plan limit-quiet build build walk
run > /dev/null
if [ "$(field 1-one status)" = done ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a limit is recognised from the rejected event alone"
else bad "a limit is recognised from the rejected event alone" "$(tkt 1-one) $(out)"; fi

# A rate_limit error with no reset time still waits, for the fallback period.
workspace
plan limit-bare build build walk
( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=7 LIMIT_MARGIN=0 \
    bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 )
if [ "$(field 1-one status)" = done ] && [ "$(field 1-one attempts)" = 1 ] && [ "$(cat "$SLEPT")" = 7 ]; then
  ok "a limit that names no reset time is waited out too"
else bad "a limit that names no reset time is waited out too" "$(tkt 1-one) $(out)"; fi

workspace
plan build build limit walk
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 4 ] && grep -q '^resume ' <(tail -1 "$STUB_SESSIONS"); then
  ok "a limit during the walk is waited out and the walk carries on"
else bad "a limit during the walk is waited out and the walk carries on" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

workspace
plan build build limit limit limit
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=2 \
           bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && ! grep -q "^You've hit your session limit" "$WORK/.out"; then
  ok "a walk that gives up on a limit fails rather than reporting the limit as its result"
else bad "a walk that gives up on a limit fails rather than reporting the limit as its result" "rc=$rc $(out)"; fi

workspace
plan build-limit
( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=0 \
    bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 )
if grep -q '1-one.md is at review' "$WORK/.out" && ! grep -q 'goes back to ready' "$WORK/.out"; then
  ok "giving up names the status the session left, not one it did not"
else bad "giving up names the status the session left, not one it did not" "$(out)"; fi

# And it is bounded: a limit that never lifts has to end the run rather than
# wait forever - and without charging the ticket for it.
workspace
plan limit limit limit
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_WAITS=2 MAX_ATTEMPTS=1 \
           bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -q 'gave up waiting out the limit' "$WORK/.out"; then
  ok "a limit that never lifts gives up rather than waiting forever"
else bad "a limit that never lifts gives up rather than waiting forever" "rc=$rc $(out)"; fi
if [ "$(field 1-one status)" = ready ] && [ "$(field 1-one attempts)" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "giving up on a limit hands the ticket back rather than halting it"
else bad "giving up on a limit hands the ticket back rather than halting it" "$(tkt 1-one) $(calls)"; fi

# --- nothing selectable is not the same as everything finished

workspace
sed -i 's/^status: .*/status:    doing/' "$WORK/intents/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'never came back' "$WORK/.out"; then
  ok "a stale claim is reported rather than counted as done"
else bad "a stale claim is reported rather than counted as done" "rc=$rc $(out)"; fi

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/intents/x/tickets/2-two.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '9-ghost' "$WORK/.out"; then
  ok "a dependency nobody can satisfy is named"
else bad "a dependency nobody can satisfy is named" "rc=$rc $(out)"; fi

# --- the frontmatter, and only the frontmatter
#
# A ticket about the ticket format has body lines that look exactly like fields,
# and this repository's own tickets are full of them.

workspace
printf '\n## Record\n\n```\nstatus:    review\nattempts:  7\n```\n' >> "$WORK/intents/x/tickets/1-one.md"; commit
plan build build walk
run > /dev/null
if [ "$(grep -c '^status:    review' "$WORK/intents/x/tickets/1-one.md")" = 1 ]; then
  ok "only the frontmatter is rewritten"
else bad "only the frontmatter is rewritten" "$(tkt 1-one)"; fi

# --- the walk

workspace
plan build build walk
run > /dev/null
# `accept-intent` is disable-model-invocation, so the model cannot reach it from
# prose - the prompt has to *start* with the slash command for the harness to
# expand it. The stub cannot prove the expansion happens; it pins the shape.
if grep -q '^/accept-intent ' <(tail -1 "$STUB_CALLS"); then
  ok "the walk prompt starts with the slash command that reaches the skill"
else bad "the walk prompt starts with the slash command that reaches the skill" "$(tail -1 "$STUB_CALLS")"; fi
if grep -q '01-INTENT.md' <(tail -1 "$STUB_CALLS"); then ok "the walk is given the intent"
else bad "the walk is given the intent" "$(tail -1 "$STUB_CALLS")"; fi

# A change small enough that no intent document was written keeps its conditions
# in the solution's own `## Intent` section, and `/accept-intent` reads them
# there. So the walk follows the conditions rather than the filename: skipping it
# here dropped the only stage that asks whether the problem was solved.
workspace
rm "$WORK/intents/x/01-INTENT.md"; commit
plan build build walk
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "with no intent the walk still runs"
else bad "with no intent the walk still runs" "rc=$rc $(calls)"; fi
if grep -q '^/accept-intent .*02-SOLUTION.md' <(tail -1 "$STUB_CALLS"); then
  ok "with no intent the walk is given the solution that carries the conditions"
else bad "with no intent the walk is given the solution that carries the conditions" "$(tail -1 "$STUB_CALLS")"; fi

finish
