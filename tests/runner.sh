#!/usr/bin/env bash
#
# The tests for the runner: what it does with a ticket directory when nobody is
# watching.
#
#   tests/runner.sh
#
# Everything `run.sh` holds is something that has to be true when a session is
# dead or lying, which is why it is a script and not a skill. Each case below
# builds a throwaway repository in the layout the pipeline actually uses - a
# change's CRITERIA.md with the tickets under it - puts a stub on PATH where
# `claude` would be, and runs the real thing against it.

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

# One change: two criteria and a ticket for each, the second after the first,
# and a nudge the first one quotes. On a branch whose history starts before the
# change's paper, as a real one does.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  git -C "$WORK" commit -q --allow-empty -m start
  mkdir -p "$WORK/changes/x/tickets"
  cat > "$WORK/changes/x/CRITERIA.md" <<'EOF'
# Criteria: x

## Problem
x

## Acceptance criteria
- **AC-1** the first thing happens.
- **AC-2** the second thing happens.

## Nudges
- reuse the list that is already there.

## Ruled out
- x
EOF
  ticket 1-one AC-1 "the first thing happens." "" "reuse the list that is already there."
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

ticket() {  # slug, id, text, after, nudge
  cat > "$WORK/changes/x/tickets/$1.md" <<EOF
---
criteria:  CRITERIA.md
closes:    $2
advances:
after:     $4
status:    ready
attempts:  0
---

## Build
x

## Done when

> **$2** $3

## Nudges
${5:+
> $5
}
## Context
x

## Not here
x
EOF
}

# A ticket that builds part of a criterion another ticket closes.
advancer() {  # slug, id, text, after
  cat > "$WORK/changes/x/tickets/$1.md" <<EOF
---
criteria:  CRITERIA.md
closes:
advances:  $2
after:     $4
status:    ready
attempts:  0
---

## Build
x

## Done when
part of it happens.

## Toward

> **$2** $3

## Nudges

## Context
x

## Not here
x
EOF
}

plan()  { printf '%s\n' "$@" > "$STUB_PLAN"; }
commit() { git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm edit; }
run()   { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}" \
              bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$WORK/changes/x/tickets/$1.md" | head -1; }
tkt()   { cat "$WORK/changes/x/tickets/$1.md"; }
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
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" changes/x/nope >"$WORK/.out" 2>&1 ); echo $?)"
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
plan build build review
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

# Someone's notes in the ticket directory are not a ticket.
workspace
printf '# notes\n' > "$WORK/changes/x/tickets/README.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'ignoring' "$WORK/.out"; then
  ok "a file that is not a ticket is ignored, and said so"
else bad "a file that is not a ticket is ignored, and said so" "rc=$rc $(out)"; fi

# A ticket that only splits a large file before the others add to it closes and
# advances nothing, and is still a ticket: built first, and no drift.
workspace
cat > "$WORK/changes/x/tickets/3-split.md" <<'EOF2'
---
criteria:  CRITERIA.md
closes:
advances:
after:
status:    ready
attempts:  0
---

## Build
Split the large file the other tickets add to.

## Done when
It is split, the behaviour is unchanged, and the checks pass.
EOF2
sed -i 's/^after: *$/after:     3-split/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q '3-split.md' <(head -1 "$STUB_CALLS") && [ "$(field 3-split status)" = "done" ]; then
  ok "a ticket that closes no criterion, only splitting a file, is built first and is no drift"
else bad "a ticket that closes no criterion, only splitting a file, is built first and is no drift" "rc=$rc $(out) $(calls)"; fi

# --- the drift pre-flight, in both directions
#
# A session never reads CRITERIA.md and a committed ticket is revisited by
# nobody, so this is the only place the two can be found to disagree.

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a ticket whose criterion left CRITERIA.md stops the run"
else bad "a ticket whose criterion left CRITERIA.md stops the run" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "drift stops it before any session"
else bad "drift stops it before any session" "$(calls)"; fi
# The stop is named where a person will look, not only on a terminal nobody is
# watching - which is the whole reason the runner is unattended.
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: the ticket's criterion moved"
else bad "drift is written into the ticket: the ticket's criterion moved" "$(tkt 1-one)"; fi

workspace
sed -i '/^- \*\*AC-2\*\*/a - **AC-3** a third thing happens.' "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out"; then
  ok "a criterion in no ticket stops the run"
else bad "a criterion in no ticket stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: a criterion no ticket quotes"
else bad "drift is written into the ticket: a criterion no ticket quotes" "$(tkt 1-one)"; fi
# Reported once, not once per ticket in the directory.
if [ "$(grep -c 'AC-3 is closed by no ticket' "$WORK/.out")" = 1 ]; then
  ok "an uncovered criterion is reported once, not once per ticket"
else bad "an uncovered criterion is reported once, not once per ticket" "$(out)"; fi

# A criterion that no longer holds is deleted, and its number goes with it: the
# gap is what keeps the number from being handed out twice.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
rm "$WORK/changes/x/tickets/1-one.md"
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"
git -C "$WORK" commit -qam delete
plan build
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a criterion deleted from CRITERIA.md leaves a gap, and that is no drift"
else bad "a criterion deleted from CRITERIA.md leaves a gap, and that is no drift" "rc=$rc $(out)"; fi

# Deleting a criterion a ticket still quotes is the upstream edit the check
# exists for, and it says so rather than reporting a mismatch against nothing.
workspace
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
git -C "$WORK" commit -qam delete
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-1 is gone from' "$WORK/.out"; then
  ok "a ticket quoting a deleted criterion stops the run"
else bad "a ticket quoting a deleted criterion stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: its criterion was deleted"
else bad "drift is written into the ticket: its criterion was deleted" "$(tkt 1-one)"; fi

# A nudge is quoted word for word too. Nothing checks the build against it, so
# the quote is the only thing that carries it to the builder - and a quote that
# no longer matches carries something nobody agreed to.
workspace
sed -i 's/reuse the list that is already there./reuse the list./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: a nudge it quotes is not in' "$WORK/.out" \
   && [ "$(field 1-one status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket whose nudge is not in CRITERIA.md word for word stops the run"
else bad "a ticket whose nudge is not in CRITERIA.md word for word stops the run" "rc=$rc $(out)"; fi

workspace
sed -i 's/^- reuse the list that is already there./- reuse the list that is\n  already there./' "$WORK/changes/x/CRITERIA.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a nudge broken over two lines still matches its quote"
else bad "a nudge broken over two lines still matches its quote" "rc=$rc $(out)"; fi

# A nudge nobody quotes is not drift: it is guidance, and only the tickets it
# bears on carry it.
workspace
sed -i '/^- reuse the list/a - do not touch the other view.' "$WORK/changes/x/CRITERIA.md"; commit
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a nudge no ticket quotes is no drift"
else bad "a nudge no ticket quotes is no drift" "rc=$rc $(out)"; fi

# --- which ticket closes which criterion
#
# A criterion can take several tickets to build. Exactly one closes it - the
# one after which it is true, and which writes its test - and it comes after
# every ticket that advances it, or the test it writes is red for want of work
# still waiting to run.

workspace
sed -i 's/^closes: .*/closes:/; s/^advances:.*/advances:  AC-2/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-2 is closed by no ticket' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a criterion only advanced, and closed by no ticket, stops the run"
else bad "a criterion only advanced, and closed by no ticket, stops the run" "rc=$rc $(out)"; fi

workspace
ticket 3-three AC-2 "the second thing happens." "1-one"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-2 is closed by more than one ticket: 2-two 3-three' "$WORK/.out" \
   && [ ! -s "$STUB_CALLS" ]; then
  ok "a criterion closed by two tickets stops the run, naming both"
else bad "a criterion closed by two tickets stops the run, naming both" "rc=$rc $(out)"; fi

workspace
advancer 3-three AC-2 "the second thing happens." ""; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '2-two.md: closes AC-2 and does not come after 3-three, which advances it' "$WORK/.out" \
   && [ "$(field 2-two status)" = halted ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket closing a criterion before one that advances it stops the run"
else bad "a ticket closing a criterion before one that advances it stops the run" "rc=$rc $(out)"; fi

# After it by way of another ticket is after it.
workspace
advancer 3-three AC-2 "the second thing happens." ""
sed -i 's/^after: .*/after:     3-three/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build build build review
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a closing ticket after an advancing one by way of a third runs"
else bad "a closing ticket after an advancing one by way of a third runs" "rc=$rc $(out)"; fi

# The frontmatter is what coverage is counted from and the quote is what the
# builder reads, so the two have to name the same criteria.
workspace
sed -i 's/^advances:.*/advances:  AC-2/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: claims AC-2 and does not quote it' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket claiming a criterion it does not quote stops the run"
else bad "a ticket claiming a criterion it does not quote stops the run" "rc=$rc $(out)"; fi

workspace
sed -i 's/^## Nudges$/> **AC-2** the second thing happens.\n\n## Nudges/' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: quotes AC-2 and neither closes nor advances it' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "a ticket quoting a criterion it does not claim stops the run"
else bad "a ticket quoting a criterion it does not claim stops the run" "rc=$rc $(out)"; fi

workspace
rm "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'not there' "$WORK/.out"; then
  ok "a ticket whose CRITERIA.md is gone stops the run"
else bad "a ticket whose CRITERIA.md is gone stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: CRITERIA.md is gone"
else bad "drift is written into the ticket: CRITERIA.md is gone" "$(tkt 1-one)"; fi

# A ticket with nothing left to build is deleted, and whatever came after it has
# to be told, or it waits for a ticket that will never be done.
workspace
rm "$WORK/changes/x/tickets/1-one.md"
sed -i '/^- \*\*AC-1\*\*/d' "$WORK/changes/x/CRITERIA.md"
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
# updated and its status put back, so the runner builds it again. The re-slice
# deletes the final review, which reviewed what is about to change.
workspace
plan build build review
run > /dev/null
sed -i 's/the first thing happens./the first thing happens, differently./' \
  "$WORK/changes/x/CRITERIA.md" "$WORK/changes/x/tickets/1-one.md"
sed -i 's/^status: .*/status:    ready/; s/^attempts: .*/attempts:  0/' "$WORK/changes/x/tickets/1-one.md"
git -C "$WORK" rm -q changes/x/REVIEW.md
git -C "$WORK" commit -qam reslice
: > "$STUB_CALLS"
plan build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ] && grep -q '1-one' <(head -1 "$STUB_CALLS"); then
  ok "a done ticket put back to ready is built again, and only it"
else bad "a done ticket put back to ready is built again, and only it" "rc=$rc $(calls) $(out)"; fi
if [ "$(field 1-one status)" = "done" ] && [ "$(field 2-two status)" = "done" ]; then
  ok "the rebuilt ticket ends done beside the one left alone"
else bad "the rebuilt ticket ends done beside the one left alone" "$(field 1-one status) / $(field 2-two status)"; fi

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
# A session that runs its checks in the background has to be able to wait on
# them, and `sleep` is refused.
if grep -q -- '--allowedTools .*Monitor' <(grep 'Use /implement' "$STUB_ARGS" | head -1); then
  ok "a build may use Monitor to wait on its background checks"
else bad "a build may use Monitor to wait on its background checks" "$(head -2 "$STUB_ARGS")"; fi
# Every call pays for every tool defined, so a session is given the tools a
# build uses and no others. Playwright stays, for testing in the browser; the
# claude.ai connectors go.
build_args="$(grep 'Use /implement' "$STUB_ARGS" | head -1)"
if grep -q -- '--tools Bash .*Agent' <<< "$build_args" && grep -q -- '--tools .*Skill' <<< "$build_args" \
   && grep -q -- '--tools .*ToolSearch' <<< "$build_args" && grep -q -- '--allowedTools .*mcp__playwright' <<< "$build_args" \
   && ! grep -q -- '--tools .*CronCreate' <<< "$build_args"; then
  ok "a build is given only the tools it uses, Playwright among them"
else bad "a build is given only the tools it uses, Playwright among them" "$build_args"; fi
if grep -q '^ENABLE_CLAUDEAI_MCP_SERVERS=false ' <<< "$build_args" \
   && grep -q '^ENABLE_CLAUDEAI_MCP_SERVERS=false .*--tools Bash' <(grep -- '--json-schema' "$STUB_ARGS" | head -1); then
  ok "the build and the call for the checks run without the claude.ai connectors, on the same tools"
else bad "the build and the call for the checks run without the claude.ai connectors, on the same tools" "$(head -2 "$STUB_ARGS")"; fi
if grep -q '1-one' <(head -1 "$STUB_CALLS"); then ok "it builds in dependency order"
else bad "it builds in dependency order" "$(calls)"; fi
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

# A VERIFY in the caller's environment is not a check that passed.
workspace
STUB_VERIFY=false
plan build build review
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" VERIFY=true bash "$RUNNER" changes/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && [ ! -s "$STUB_CALLS" ]; then
  ok "a VERIFY already in the environment does not skip the checks"
else bad "a VERIFY already in the environment does not skip the checks" "rc=$rc $(out)"; fi

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
if [ "$rc" != 0 ] && ! grep -q 'dirty tree' "$WORK/.out" && grep -q '1-one.md: halted' "$WORK/.out" \
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

# The ticket files are the runner's bookkeeping and nothing else in their
# directory is: someone's notes there are still someone's.
workspace
plan claim-only claim-only
run > /dev/null
printf 'notes\n' > "$WORK/changes/x/tickets/notes.md"
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'dirty tree' "$WORK/.out" && grep -q 'notes.md' "$WORK/.out"; then
  ok "an uncommitted file beside the tickets is refused, bookkeeping or not"
else bad "an uncommitted file beside the tickets is refused, bookkeeping or not" "rc=$rc $(out)"; fi

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

# --- one runner at a time
#
# A second runner started on a tree another is working took over its claim and
# resumed the session it was running. It stops instead, touching nothing - and a
# session that outlived a killed runner counts, since it is still building.

workspace
lock="$WORK/.git/run.lock"
( flock "$lock" sh -c ": > '$WORK/.locked'; exec /bin/sleep 5" ) &
until [ -e "$WORK/.locked" ]; do /bin/sleep 0.1; done
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'still' "$WORK/.out" && [ ! -s "$STUB_CALLS" ] \
   && [ -z "$(git -C "$WORK" status --porcelain)" ]; then
  ok "a run started while another holds the repository stops, touching nothing"
else bad "a run started while another holds the repository stops, touching nothing" "rc=$rc $(out)"; fi

workspace
plan orphaned build build review
run > /dev/null 2>&1
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'still' "$WORK/.out" && [ "$(field 1-one status)" = doing ] \
   && [ "$(wc -l < "$STUB_CALLS")" = 1 ]; then
  ok "a run started while a killed run's session still runs stops, touching nothing"
else bad "a run started while a killed run's session still runs stops, touching nothing" "rc=$rc $(out)"; fi
flock -w 10 "$WORK/.git/run.lock" true
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(field 1-one status)" = "done" ] && grep -q '^resume' "$STUB_SESSIONS"; then
  ok "once that session has ended, a run carries on with its claim"
else bad "once that session has ended, a run carries on with its claim" "rc=$rc $(cat "$STUB_SESSIONS") $(out)"; fi

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

# The runner's own halts are committed: a halt is the one thing a run leaves for
# a person, and uncommitted it was every later session's someone else's change.
workspace
plan claim-only claim-only
run > /dev/null
if [ "$(field 1-one status)" = halted ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show HEAD:changes/x/tickets/1-one.md | sed -n 's/^status: *//p')" = halted ]; then
  ok "a halt the runner writes is committed"
else bad "a halt the runner writes is committed" "$(git -C "$WORK" status --porcelain) $(git -C "$WORK" log --oneline | head -3)"; fi

# A drift nobody has resolved is the same halt on every start, not one more.
workspace
sed -i 's/the second thing happens\./the second thing happens, reworded./' "$WORK/changes/x/CRITERIA.md"; commit
plan build build review
run > /dev/null; run > /dev/null
if [ "$(grep -c '^## Halt' <(tkt 2-two))" = 1 ]; then
  ok "starting again on an unresolved drift does not halt it twice"
else bad "starting again on an unresolved drift does not halt it twice" "$(tkt 2-two)"; fi

# What the checks start in the background is not a session: it must not hold the
# lock after the run, or every later start is refused.
workspace
STUB_VERIFY='(/bin/sleep 3 >/dev/null 2>&1 &)'
plan build build review
run > /dev/null
rc="$(run)"
if [ "$rc" = 0 ]; then ok "a process the checks leave running does not hold the lock"
else bad "a process the checks leave running does not hold the lock" "rc=$rc $(out)"; fi

# One runner leaves one claim.
workspace
sed -i 's/^status: .*/status:    doing/' "$WORK"/changes/x/tickets/*.md; commit
plan build build review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'more than one' "$WORK/.out" && grep -q '1-one' "$WORK/.out" && grep -q '2-two' "$WORK/.out" && [ ! -s "$STUB_CALLS" ]; then
  ok "two claimed tickets are refused, named, and nothing is launched"
else bad "two claimed tickets are refused, named, and nothing is launched" "rc=$rc $(out) $(calls)"; fi

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

# --- the runner owns the claim
#
# A crashed session leaves its claim behind; only the runner can put it back,
# and the proof is that the ticket gets picked up again at all.

workspace
plan die build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ]; then ok "a ticket whose session died is picked up again"
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
# A session can end its turn with the work unfinished. Under an earlier CLI one
# that ended it to wait on a check it put in the background was not woken again,
# and the check was killed. That build did so with its work done and reviewed,
# and the retry started from nothing on top of the diff it left. The same
# session is resumed instead, once, and a second early stop is put aside where
# the next attempt cannot mistake it for the state the checks were green on.

workspace
plan stop-early build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 1 ]; then
  ok "a session that stopped early is carried on without spending an attempt"
else bad "a session that stopped early is carried on without spending an attempt" "$(field 1-one status) $(field 1-one attempts) $(out)"; fi
first="$(awk 'NR == 1 && $1 == "start" { print $2 }' "$STUB_SESSIONS")"
if [ -n "$first" ] && [ "$(sed -n 2p "$STUB_SESSIONS")" = "resume $first" ]; then
  ok "a session that stopped early is resumed, not started over"
else bad "a session that stopped early is resumed, not started over" "$(cat "$STUB_SESSIONS")"; fi
if grep -q 'background' <(sed -n 2p "$STUB_CALLS"); then ok "the resumed session is told its background work was killed"
else bad "the resumed session is told its background work was killed" "$(calls)"; fi

workspace
plan stop-early stop-early build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ] && [ "$(field 1-one attempts)" = 2 ] \
   && grep -q '^start ' <(sed -n 3p "$STUB_SESSIONS"); then
  ok "a session that stops early twice is started over, spending an attempt"
else bad "a session that stops early twice is started over, spending an attempt" "$(field 1-one attempts) $(cat "$STUB_SESSIONS") $(out)"; fi
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "what it left is stashed, not built on"
else bad "what it left is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# Started from a subdirectory, as the runner was in the run that found this: what
# is left at the repository root is put aside too.
workspace
plan stop-early stop-early build build review
( cd "$WORK/changes" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 LIMIT_MARGIN=0 MAX_ATTEMPTS=2 \
    bash "$RUNNER" x/tickets > "$WORK/.out" 2>&1 )
if [ ! -e "$WORK/code" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "started from a subdirectory, what is left at the root is stashed too"
else bad "started from a subdirectory, what is left at the root is stashed too" "$(git -C "$WORK" status --porcelain) / $(git -C "$WORK" stash list) $(out)"; fi

# Only a session that ended cleanly is resumed: a crash was not waiting on
# anything, and what a finished build left lying around is not the next one's.
workspace
plan build-dirty die build build review
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
plan build build review
run > /dev/null
# A background task that finishes wakes the session. One run's sessions, told
# nothing would, waited on their subagents with Monitor timers that outlived them
# and woke each finished session up to three times more.
if ! grep -q 'Nothing wakes you' <(head -1 "$STUB_CALLS") && ! grep -q 'Nothing wakes you' <(tail -1 "$STUB_CALLS"); then
  ok "neither the build nor the review is told nothing wakes it"
else bad "neither the build nor the review is told nothing wakes it" "$(calls)"; fi
# What a build leaves standing is printed at the end of the run and read at
# acceptance, and both find it under one heading. A departure from a nudge is
# the one thing about a nudge anybody gets to see.
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -q '`## Left standing`' <(head -1 "$STUB_CALLS") && grep -q 'departed from a nudge' <(head -1 "$STUB_CALLS") \
   && grep -q '`## Nudges`' <(head -1 "$STUB_CALLS"); then
  ok "the build is told its nudges, and to record under Left standing where it departed from one"
else bad "the build is told its nudges, and to record under Left standing where it departed from one" "$(head -1 "$STUB_CALLS")"; fi
# A list of which test proves which criterion says of nearly every ticket what
# `done` already says, and buried the one line in it worth reading: a criterion
# checked by hand, with no test behind it.
if grep -q 'no automated test proves' <(head -1 "$STUB_CALLS") && ! grep -qi 'which test proves' <(head -1 "$STUB_CALLS"); then
  ok "the build lists under Left standing only the criteria no test proves"
else bad "the build lists under Left standing only the criteria no test proves" "$(head -1 "$STUB_CALLS")"; fi

# --- a build that committed nothing
#
# `done` is a session's account of itself, and a session that wrote no code can
# still write it. The commit is the part that cannot be claimed, so the runner
# believes the one and checks the other.

workspace
plan claim-only build build review
run > /dev/null
if [ "$(field 1-one status)" = "done" ]; then ok "a ticket whose session committed nothing is picked up again"
else bad "a ticket whose session committed nothing is picked up again" "$(field 1-one status)"; fi
if [ "$(field 1-one attempts)" = 2 ]; then ok "a session that committed nothing still spends an attempt"
else bad "a session that committed nothing still spends an attempt" "attempts=$(field 1-one attempts)"; fi

workspace
plan claim-dirty build build review
run > /dev/null
if [ -z "$(git -C "$WORK" ls-files code)" ] && git -C "$WORK" stash list | grep -q '1-one.*attempt 1'; then
  ok "what a build that committed nothing left behind is stashed, not built on"
else bad "what a build that committed nothing left behind is stashed, not built on" "$(git -C "$WORK" ls-files) / $(git -C "$WORK" stash list)"; fi

# The finish goes into the build's own commit rather than one of its own, since
# only a session can write a message - and a ticket the session left out of that
# commit goes in with it.
workspace
plan code-only build review
run > /dev/null
built="$(git -C "$WORK" log -1 --format=%H --grep='^build 1-one')"
if [ "$(git -C "$WORK" rev-list --count "$built")" = 3 ] && [ -z "$(git -C "$WORK" status --porcelain)" ] \
   && [ "$(git -C "$WORK" show "$built:changes/x/tickets/1-one.md" | sed -n 's/^status: *//p')" = "done" ]; then
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

# A halt is the one thing a run leaves for a person, and the runner commits its
# own. A session's own was left uncommitted, for the next start to read as
# someone else's change.
if [ "$(git -C "$WORK" show HEAD:changes/x/tickets/1-one.md | sed -n 's/^status: *//p')" = halted ] \
   && [ -z "$(git -C "$WORK" status --porcelain -- changes/x/tickets)" ] \
   && [ "$(git -C "$WORK" log -1 --format=%s)" = "Halt 1-one: blocked" ]; then
  ok "a session's halt is committed, named for its kind"
else bad "a session's halt is committed, named for its kind" "$(git -C "$WORK" log --oneline | head -3) $(git -C "$WORK" status --porcelain)"; fi

# The kind is read off what the session wrote, whichever of the three it is.
workspace
plan halt:mystery
run > /dev/null
if [ "$(git -C "$WORK" log -1 --format=%s)" = "Halt 1-one: mystery" ]; then
  ok "a session's halt commit names the kind it wrote"
else bad "a session's halt commit names the kind it wrote" "$(git -C "$WORK" log --oneline | head -3)"; fi

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

# --- nothing selectable is not the same as everything finished

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/changes/x/tickets/2-two.md"; commit
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
# shellcheck disable=SC2016 # a Markdown fence, written literally
printf '\n## Left standing\n\n```\nstatus:    review\nattempts:  7\n```\n' >> "$WORK/changes/x/tickets/1-one.md"; commit
plan build build review
run > /dev/null
if [ "$(grep -c '^status:    review' "$WORK/changes/x/tickets/1-one.md")" = 1 ]; then
  ok "only the frontmatter is rewritten"
else bad "only the frontmatter is rewritten" "$(tkt 1-one)"; fi

# --- the final review
#
# Each build is reviewed on its own, which cannot see what lies between them:
# the same thing built twice, two names for one concept, seams that do not line
# up. One session reviews the whole change once every ticket is built.

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q 'critique' <(tail -1 "$STUB_CALLS"); then
  ok "once every ticket is done, one session reviews the whole change"
else bad "once every ticket is done, one session reviews the whole change" "rc=$rc $(calls) $(out)"; fi
if grep -qF "$(git -C "$WORK" rev-parse main~1)" <(tail -1 "$STUB_CALLS"); then
  ok "the review is given the change from before its tickets were added"
else bad "the review is given the change from before its tickets were added" "$(tail -1 "$STUB_CALLS")"; fi
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if grep -qF "$(realpath "$WORK")/changes/x/REVIEW.md" <(tail -1 "$STUB_CALLS") \
   && grep -q '`true`' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told where REVIEW.md goes, and the project's checks"
else bad "the review is told where REVIEW.md goes, and the project's checks" "$(tail -1 "$STUB_CALLS")"; fi
# A review fixes what it finds, and one fix went against a nudge the build had
# kept on purpose. A nudge is how the user agreed it gets built.
if grep -q 'departs from a nudge is not made' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told a fix that departs from a nudge is left standing, not made"
else bad "the review is told a fix that departs from a nudge is left standing, not made" "$(tail -1 "$STUB_CALLS")"; fi
# A second round costs a whole review, and five builds in one run paid it after a
# first round that found nothing that mattered.
if grep -q 'found only nits' <(tail -1 "$STUB_CALLS"); then
  ok "the review is told not to review again after a round of only nits"
else bad "the review is told not to review again after a round of only nits" "$(tail -1 "$STUB_CALLS")"; fi

# Tickets added in the very first commit have no commit before them, and the
# change is then everything.
workspace
rm -rf "$WORK/.git"
git -C "$WORK" init -q -b main
git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
printf '/.*\n' >> "$WORK/.git/info/exclude"
git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm paper
git -C "$WORK" checkout -q -b topic
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -qF "$(git -C "$WORK" hash-object -t tree /dev/null)" <(tail -1 "$STUB_CALLS"); then
  ok "tickets added in the first commit are reviewed from the empty tree"
else bad "tickets added in the first commit are reviewed from the empty tree" "rc=$rc $(tail -1 "$STUB_CALLS") $(out)"; fi

# One ticket was reviewed whole by its own build.
workspace
rm "$WORK/changes/x/tickets/2-two.md"
sed -i '/^- \*\*AC-2\*\*/d' "$WORK/changes/x/CRITERIA.md"; commit
plan build
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 1 ] && [ ! -e "$WORK/changes/x/REVIEW.md" ]; then
  ok "a single ticket gets no final review"
else bad "a single ticket gets no final review" "rc=$rc $(calls) $(out)"; fi

workspace
sed -i 's/^after: .*/after:/' "$WORK/changes/x/tickets/2-two.md"; commit
plan build halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 2 ]; then
  ok "a run with a halt gets no final review"
else bad "a run with a halt gets no final review" "rc=$rc $(calls) $(out)"; fi

# REVIEW.md is how the review is known to have finished, so a session that
# ended without one has not.
workspace
plan build build review-dies review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'the final review did not finish' "$WORK/.out"; then
  ok "a final review that ends without committing REVIEW.md fails the run, and says so"
else bad "a final review that ends without committing REVIEW.md fails the run, and says so" "rc=$rc $(out)"; fi
if ! grep -q '/accept-criteria' "$WORK/.out"; then
  ok "a run whose review did not finish does not point on to acceptance"
else bad "a run whose review did not finish does not point on to acceptance" "$(out)"; fi

# Started again, the review runs where it did not finish - and the checks are
# run first, because nothing in this run has run them yet.
rc="$(run)"
# shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
if [ "$rc" = 0 ] && git -C "$WORK" cat-file -e HEAD:changes/x/REVIEW.md 2>/dev/null \
   && grep -q '`true`' <(tail -1 "$STUB_CALLS"); then
  ok "a run started again after a failed review runs it again, told the checks"
else bad "a run started again after a failed review runs it again, told the checks" "rc=$rc $(calls) $(out)"; fi

# And where it did finish, it does not run again.
workspace
plan build build review
run > /dev/null
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ] && grep -q 'the review left: a seam' "$WORK/.out"; then
  ok "a run started again after its review reprints it rather than reviewing again"
else bad "a run started again after its review reprints it rather than reviewing again" "rc=$rc $(calls) $(out)"; fi

# --- the end of a run
#
# Nobody watches a run, so what needs a person is printed at the end of it,
# however it ended: the halts, what each build left standing, what the final
# review left, and where to go next.

workspace
plan build build review
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'left by 1-one.md' "$WORK/.out" && grep -q 'left by 2-two.md' "$WORK/.out"; then
  ok "each ticket's Left standing is printed at the end"
else bad "each ticket's Left standing is printed at the end" "rc=$rc $(out)"; fi
if grep -q 'the review left: a seam' "$WORK/.out"; then ok "REVIEW.md is printed at the end"
else bad "REVIEW.md is printed at the end" "$(out)"; fi
if grep -q '/accept-criteria .*changes/x' "$WORK/.out"; then
  ok "a finished run points on to /accept-criteria"
else bad "a finished run points on to /accept-criteria" "$(out)"; fi

workspace
plan build halt:blocked
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '2-two.md: halted - blocked' "$WORK/.out" && grep -q 'left by 1-one.md' "$WORK/.out"; then
  ok "a run that halts ends with the halt and what the builds left standing"
else bad "a run that halts ends with the halt and what the builds left standing" "rc=$rc $(out)"; fi
if ! grep -q '/accept-criteria' "$WORK/.out"; then ok "a run that halts does not point on to acceptance"
else bad "a run that halts does not point on to acceptance" "$(out)"; fi

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/changes/x/tickets/1-one.md"; commit
plan build
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '1-one.md: halted - drift' "$WORK/.out"; then
  ok "a run stopped by drift ends with the halt"
else bad "a run stopped by drift ends with the halt" "rc=$rc $(out)"; fi

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

# --- the usage line

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -qF 'run.sh changes/<slug>/tickets' "$WORK/.out"; then
  ok "the usage line names the change's ticket directory"
else bad "the usage line names the change's ticket directory" "rc=$rc $(out)"; fi

finish
