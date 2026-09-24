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
  STUB_CALLS="$WORK/.calls"; STUB_PLAN="$WORK/.plan"; : > "$STUB_CALLS"; : > "$STUB_PLAN"
  export STUB_CALLS STUB_PLAN
  mkdir -p "$WORK/.bin" && ln -sf "$HERE/stub-session" "$WORK/.bin/claude"
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
run()   { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}" \
              bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$WORK/intents/x/tickets/$1.md" | head -1; }
tkt()   { cat "$WORK/intents/x/tickets/$1.md"; }
out()   { cat "$WORK/.out"; }
calls() { cat "$STUB_CALLS"; }

# --- refusals, before anything is launched

workspace; git -C "$WORK" checkout -q main
plan review
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
plan review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'no commits' "$WORK/.out" && grep -q 'branch refusal' "$WORK/.out"; then
  ok "it refuses a repository with no commits, for the reason it gives"
else bad "it refuses a repository with no commits, for the reason it gives" "rc=$rc $(out)"; fi
if [ ! -s "$STUB_CALLS" ]; then ok "a repository with no commits launches nothing"
else bad "a repository with no commits launches nothing" "$(calls)"; fi

# Someone's notes in the ticket directory are not a ticket.
workspace
printf '# notes\n' > "$WORK/intents/x/tickets/README.md"
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ] && grep -q 'ignoring' "$WORK/.out"; then
  ok "a file that is not a ticket is ignored, and said so"
else bad "a file that is not a ticket is ignored, and said so" "rc=$rc $(out)"; fi

# --- the drift pre-flight, in both directions
#
# A session never reads the solution and a committed ticket is revisited by
# nobody, so this is the only place the two can be found to disagree.

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/intents/x/tickets/1-one.md"
plan review
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
printf -- '- **AC-3** a third thing happens. *(C-3)*\n' >> "$WORK/intents/x/02-SOLUTION.md"
plan review
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

# A criterion withdrawn in the solution keeps its number, struck through, because
# numbers are never handed out twice. Nothing is left for a ticket to quote.
workspace
printf -- '- **AC-3** ~~a third thing happens.~~ Withdrawn: replaced by AC-2.\n' \
  >> "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam withdraw
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a withdrawn criterion is quoted by no ticket, and that is no drift"
else bad "a withdrawn criterion is quoted by no ticket, and that is no drift" "rc=$rc $(out)"; fi

# Withdrawing a criterion a ticket still quotes is the upstream edit the check
# exists for, and skipping withdrawn ones in the other direction must not hide it.
workspace
sed -i 's/^- \*\*AC-1\*\* .*/- **AC-1** ~~the first thing happens.~~ Withdrawn./' \
  "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam withdraw
plan review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'AC-1 no longer matches' "$WORK/.out"; then
  ok "a ticket quoting a withdrawn criterion stops the run"
else bad "a ticket quoting a withdrawn criterion stops the run" "rc=$rc $(out)"; fi

# The tag is what the ticket leaves off, whatever it says: a decision taken by
# the user rather than for a condition, a constraint named in words.
workspace
sed -i 's/\*(C-1)\*/*(Nutzer)*/' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam retag
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a tag of any word is left off the comparison"
else bad "a tag of any word is left off the comparison" "rc=$rc $(out)"; fi

workspace
sed -i 's/ \*(C-2)\*/ *(C-2; Constraint\n  „the groups the tool knows")*/' "$WORK/intents/x/02-SOLUTION.md"
git -C "$WORK" commit -qam retag
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ] && ! grep -q 'drift' "$WORK/.out"; then
  ok "a tag with punctuation, broken over two lines, is left off the comparison"
else bad "a tag with punctuation, broken over two lines, is left off the comparison" "rc=$rc $(out)"; fi

workspace
rm "$WORK/intents/x/02-SOLUTION.md"
plan review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'not there' "$WORK/.out"; then
  ok "a ticket whose solution is gone stops the run"
else bad "a ticket whose solution is gone stops the run" "rc=$rc $(out)"; fi
if grep -q 'drift' <(tkt 1-one) && [ "$(field 1-one status)" = halted ]; then
  ok "drift is written into the ticket: the solution is gone"
else bad "drift is written into the ticket: the solution is gone" "$(tkt 1-one)"; fi

# --- the ordinary pass

workspace
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ]; then ok "a clean run finishes"; else bad "a clean run finishes" "rc=$rc $(out)"; fi
if [ "$(field 1-one status)" = done ] && [ "$(field 2-two status)" = done ]; then
  ok "every ticket ends done"
else bad "every ticket ends done" "$(field 1-one status) / $(field 2-two status)"; fi
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
sed -i 's/^after: .*/after:     /'      "$WORK/intents/x/tickets/2-two.md"
plan review review walk
run > /dev/null
if grep -q '2-two' <(head -1 "$STUB_CALLS"); then ok "after: decides the order, not the filename"
else bad "after: decides the order, not the filename" "$(calls)"; fi

# --- the runner owns the claim
#
# A crashed session leaves its claim behind; only the runner can put it back,
# and the proof is that the ticket gets picked up again at all.

workspace
plan die review review walk
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

# --- a build that committed nothing
#
# `review` is a session's account of itself, and a session that wrote no code can
# still write it. The commit is the part that cannot be claimed, so the runner
# believes the one and checks the other.

workspace
plan claim-only review review walk
run > /dev/null
if [ "$(field 1-one status)" = done ]; then ok "a ticket whose session committed nothing is picked up again"
else bad "a ticket whose session committed nothing is picked up again" "$(field 1-one status)"; fi
if [ "$(field 1-one attempts)" = 2 ]; then ok "a session that committed nothing still spends an attempt"
else bad "a session that committed nothing still spends an attempt" "attempts=$(field 1-one attempts)"; fi

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
# A usage limit is not a failure of the work: the session never got to do any.
# Waiting it out and starting again is the whole reason this outlives its
# sessions.

workspace
plan limit review review walk
run > /dev/null
if [ "$(field 1-one status)" = done ]; then ok "a usage limit is waited out and the ticket still finishes"
else bad "a usage limit is waited out and the ticket still finishes" "$(field 1-one status) $(out)"; fi
if [ "$(field 1-one attempts)" = 1 ]; then ok "waiting out a limit does not spend an attempt"
else bad "waiting out a limit does not spend an attempt" "attempts=$(field 1-one attempts)"; fi

# And it is bounded: a limit that never lifts has to end the run rather than
# wait forever.
workspace
plan limit limit limit
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 MAX_WAITS=2 MAX_ATTEMPTS=1 \
           bash "$RUNNER" intents/x/tickets > "$WORK/.out" 2>&1 ); echo $?)"
if [ "$rc" != 0 ] && grep -q 'gave up waiting out the limit' "$WORK/.out"; then
  ok "a limit that never lifts gives up rather than waiting forever"
else bad "a limit that never lifts gives up rather than waiting forever" "rc=$rc $(out)"; fi

# --- nothing selectable is not the same as everything finished

workspace
sed -i 's/^status: .*/status:    doing/' "$WORK/intents/x/tickets/1-one.md"
plan review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q 'never came back' "$WORK/.out"; then
  ok "a stale claim is reported rather than counted as done"
else bad "a stale claim is reported rather than counted as done" "rc=$rc $(out)"; fi

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/intents/x/tickets/2-two.md"
plan review
rc="$(run)"
if [ "$rc" != 0 ] && grep -q '9-ghost' "$WORK/.out"; then
  ok "a dependency nobody can satisfy is named"
else bad "a dependency nobody can satisfy is named" "rc=$rc $(out)"; fi

# --- the frontmatter, and only the frontmatter
#
# A ticket about the ticket format has body lines that look exactly like fields,
# and this repository's own tickets are full of them.

workspace
printf '\n## Record\n\n```\nstatus:    review\nattempts:  7\n```\n' >> "$WORK/intents/x/tickets/1-one.md"
plan review review walk
run > /dev/null
if [ "$(grep -c '^status:    review' "$WORK/intents/x/tickets/1-one.md")" = 1 ]; then
  ok "only the frontmatter is rewritten"
else bad "only the frontmatter is rewritten" "$(tkt 1-one)"; fi

# --- the walk

workspace
plan review review walk
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
rm "$WORK/intents/x/01-INTENT.md"
plan review review walk
rc="$(run)"
if [ "$rc" = 0 ] && [ "$(wc -l < "$STUB_CALLS")" = 3 ]; then
  ok "with no intent the walk still runs"
else bad "with no intent the walk still runs" "rc=$rc $(calls)"; fi
if grep -q '^/accept-intent .*02-SOLUTION.md' <(tail -1 "$STUB_CALLS"); then
  ok "with no intent the walk is given the solution that carries the conditions"
else bad "with no intent the walk is given the solution that carries the conditions" "$(tail -1 "$STUB_CALLS")"; fi

finish
