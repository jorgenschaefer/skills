#!/usr/bin/env bash
#
# The tests for the runner: what it does with a ticket directory when nobody is
# watching.
#
#   tests/runner.sh
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. Each case builds a
# throwaway repository with a solution, a ticket directory and a stub standing
# in for `claude`, then runs the real thing against it.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$HERE/../run.sh"
passed=0 failed=0
WORKSPACES=()

ok()  { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
        [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

# A repository with one topic: a solution with two criteria, a ticket for each.
workspace() {
  WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
  git -C "$WORK" init -q -b main
  git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
  cat > "$WORK/SOLUTION_T.md" <<'EOF'
## Behaviour
- **AC-1** the first thing happens. *(C-1)*
- **AC-2** the second thing happens. *(C-2)*
EOF
  mkdir -p "$WORK/tickets/t"
  ticket 1 AC-1 "the first thing happens." ""
  ticket 2 AC-2 "the second thing happens." "1-one"
  git -C "$WORK" add -A >/dev/null; git -C "$WORK" commit -qm paper
  git -C "$WORK" checkout -q -b topic
  STUB_CALLS="$WORK/.calls"; STUB_PLAN="$WORK/.plan"; : > "$STUB_CALLS"; : > "$STUB_PLAN"
  export STUB_CALLS STUB_PLAN
  mkdir -p "$WORK/.bin" && ln -sf "$HERE/stub-session" "$WORK/.bin/claude"
}

ticket() {  # n, id, text, after
  local slug; case "$1" in 1) slug=1-one ;; 2) slug=2-two ;; esac
  cat > "$WORK/tickets/t/$slug.md" <<EOF
---
solution:  SOLUTION_T.md
satisfies: $2
after:     $4
status:    ready
attempts:  0
reviews:   0
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

plan() { printf '%s\n' "$@" > "$STUB_PLAN"; }
run()  { ( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 MAX_ATTEMPTS=2 MAX_REVIEWS=2 \
             bash "$RUNNER" tickets/t > "$WORK/.out" 2>&1 ); echo $?; }
field() { sed -n "s/^$2: *//p" "$WORK/tickets/t/$1.md" | head -1; }
out()   { cat "$WORK/.out"; }

# --- refusals, before anything is launched

workspace; git -C "$WORK" checkout -q main
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -qi 'branch' "$WORK/.out" \
  && ok "it refuses to run on the main branch" \
  || bad "it refuses to run on the main branch" "rc=$rc $(out)"
[ ! -s "$STUB_CALLS" ] && ok "it launches nothing when it refuses" \
                       || bad "it launches nothing when it refuses" "$(cat "$STUB_CALLS")"

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" tickets/nope >"$WORK/.out" 2>&1 ); echo $?)"
[ "$rc" != 0 ] && ok "it refuses a ticket directory that is not there" \
               || bad "it refuses a ticket directory that is not there" "$(out)"

# A repository with nothing committed yet is inside a work tree and has a branch
# name, so both refusals above pass it - and there is no HEAD to compare a build
# against, which would make every build look like it moved nothing.
workspace
rm -rf "$WORK/.git"
git -C "$WORK" init -q -b topic
git -C "$WORK" config user.email t@t; git -C "$WORK" config user.name t
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -q 'no commits' "$WORK/.out" \
  && ok "it refuses a repository with no commits" \
  || bad "it refuses a repository with no commits" "rc=$rc $(out)"
[ ! -s "$STUB_CALLS" ] && ok "a repository with no commits launches nothing" \
                       || bad "a repository with no commits launches nothing" "$(cat "$STUB_CALLS")"

# --- the drift pre-flight, in both directions

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/tickets/t/1-one.md"
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out" \
  && ok "a ticket whose criterion left the solution stops the run" \
  || bad "a ticket whose criterion left the solution stops the run" "rc=$rc $(out)"
[ ! -s "$STUB_CALLS" ] && ok "drift stops it before any session" \
                       || bad "drift stops it before any session" "$(cat "$STUB_CALLS")"

workspace
printf -- '- **AC-3** a third thing happens. *(C-3)*\n' >> "$WORK/SOLUTION_T.md"
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out" \
  && ok "a criterion in no ticket stops the run" \
  || bad "a criterion in no ticket stops the run" "rc=$rc $(out)"

# --- the ordinary pass

workspace
plan "implement review" "critique clean" "implement review" "critique clean"
rc="$(run)"
[ "$rc" = 0 ] && ok "a clean run finishes" || bad "a clean run finishes" "rc=$rc $(out)"
[ "$(field 1-one status)" = done ] && [ "$(field 2-two status)" = done ] \
  && ok "every ticket ends done" \
  || bad "every ticket ends done" "$(field 1-one status) / $(field 2-two status)"
grep -q '1-one' <(head -1 "$STUB_CALLS") \
  && ok "it builds in dependency order" \
  || bad "it builds in dependency order" "$(cat "$STUB_CALLS")"
[ "$(wc -l < "$STUB_CALLS")" = 4 ] \
  && ok "each ticket is built once and reviewed once" \
  || bad "each ticket is built once and reviewed once" "$(cat "$STUB_CALLS")"

# --- the runner owns the claim

# A crashed session leaves its claim behind; only the runner can put it back,
# and the proof is that the ticket gets picked up again at all.
workspace
plan "implement die" "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one status)" = done ] \
  && ok "a ticket whose session died is picked up again" \
  || bad "a ticket whose session died is picked up again" "$(field 1-one status)"
[ "$(field 1-one attempts)" = 2 ] \
  && ok "a dead session still spends an attempt" \
  || bad "a dead session still spends an attempt" "$(field 1-one attempts)"

workspace
plan "implement die" "implement die" "implement die"
run > /dev/null
[ "$(field 1-one status)" = halted ] && grep -q 'exhausted' "$WORK/tickets/t/1-one.md" \
  && ok "the attempt ceiling halts the ticket as exhausted" \
  || bad "the attempt ceiling halts the ticket as exhausted" "$(field 1-one status) $(cat "$WORK/tickets/t/1-one.md" | tail -3)"

# --- a build that committed nothing
#
# `review` is a session's account of itself, and a session that wrote no code
# can still write it. The commit is the part that cannot be claimed, so the
# runner believes the one and checks the other.

workspace
plan "implement claim-only" "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one status)" = done ] \
  && ok "a ticket whose session committed nothing is picked up again" \
  || bad "a ticket whose session committed nothing is picked up again" "$(field 1-one status)"
[ "$(field 1-one attempts)" = 2 ] \
  && ok "a session that committed nothing still spends an attempt" \
  || bad "a session that committed nothing still spends an attempt" "$(field 1-one attempts)"

workspace
plan "implement claim-only" "implement claim-only"
rc="$(run)"
[ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ] \
  && ok "a build that never commits halts once the budget is spent" \
  || bad "a build that never commits halts once the budget is spent" "rc=$rc status=$(field 1-one status)"
grep -q 'unbuilt' "$WORK/tickets/t/1-one.md" \
  && ok "the halt is named for what happened, not for the budget" \
  || bad "the halt is named for what happened, not for the budget" "$(tail -3 "$WORK/tickets/t/1-one.md")"
grep -q 'committed nothing' "$WORK/tickets/t/1-one.md" \
  && ok "and says the session claimed a build and committed nothing" \
  || bad "and says the session claimed a build and committed nothing" "$(tail -3 "$WORK/tickets/t/1-one.md")"

# --- review findings send it back, bounded

workspace
plan "implement review" "critique findings" "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one reviews)" = 1 ] && [ "$(field 1-one status)" = done ] \
  && ok "findings send the ticket back and it can still finish" \
  || bad "findings send the ticket back and it can still finish" "reviews=$(field 1-one reviews) status=$(field 1-one status)"

# A rework commits onto the commit the first pass left, which is a HEAD that
# moved for the second time rather than one that never moved.
workspace
plan "implement review" "critique findings" "implement review" "critique clean" \
     "implement review" "critique clean"
rc="$(run)"
[ "$rc" = 0 ] && ! grep -q '^## Halt' "$WORK/tickets/t/1-one.md" \
  && ok "a rework that commits again is not read as a build that committed nothing" \
  || bad "a rework that commits again is not read as a build that committed nothing" \
         "rc=$rc $(tail -3 "$WORK/tickets/t/1-one.md")"

workspace
plan "implement review" "critique findings" "implement review" "critique findings" "implement review" "critique findings"
run > /dev/null
[ "$(field 1-one status)" = halted ] && grep -q 'exhausted' "$WORK/tickets/t/1-one.md" \
  && ok "the review ceiling halts the ticket as exhausted" \
  || bad "the review ceiling halts the ticket as exhausted" "$(field 1-one status)"

# --- a session's own halt stops the run

workspace
plan "implement halt:blocked"
rc="$(run)"
[ "$rc" != 0 ] && [ "$(field 1-one status)" = halted ] \
  && ok "a session halt stops the run" \
  || bad "a session halt stops the run" "rc=$rc status=$(field 1-one status)"
[ "$(field 2-two status)" = ready ] \
  && ok "a halt leaves the rest of the directory alone" \
  || bad "a halt leaves the rest of the directory alone" "$(field 2-two status)"

# --- the limit is waited out rather than spent

workspace
plan "implement limit" "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one status)" = done ] \
  && ok "a usage limit is waited out and the ticket still finishes" \
  || bad "a usage limit is waited out and the ticket still finishes" "$(field 1-one status) $(out)"
[ "$(field 1-one attempts)" = 1 ] \
  && ok "waiting out a limit does not spend an attempt" \
  || bad "waiting out a limit does not spend an attempt" "attempts=$(field 1-one attempts)"

# --- what the review found the first version of this suite did not cover

# The rework session is handed the ticket and nothing else, so the findings have
# to still be in it when the next build starts.
workspace
plan "implement review" "critique findings"
run > /dev/null
grep -q '^## Findings' "$WORK/tickets/t/1-one.md" \
  && ok "the findings are still there for the next build to read" \
  || bad "the findings are still there for the next build to read" "$(cat "$WORK/tickets/t/1-one.md")"

# And gone again once it is finished: a done ticket carrying findings reads as
# work outstanding to everything downstream.
workspace
plan "implement review" "critique findings" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one status)" = done ] && ! grep -q '^## Findings' "$WORK/tickets/t/1-one.md" \
  && ok "a finished ticket carries no findings" \
  || bad "a finished ticket carries no findings" "$(tail -4 "$WORK/tickets/t/1-one.md")"

# Nothing selectable is not the same as everything finished.
workspace
sed -i 's/^status: .*/status:    doing/' "$WORK/tickets/t/1-one.md"
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -q 'never came back' "$WORK/.out" \
  && ok "a stale claim is reported rather than counted as done" \
  || bad "a stale claim is reported rather than counted as done" "rc=$rc $(out)"

workspace
sed -i 's/^after: .*/after:     9-ghost/' "$WORK/tickets/t/2-two.md"
plan "implement review" "critique clean"
rc="$(run)"
[ "$rc" != 0 ] && grep -q '9-ghost' "$WORK/.out" \
  && ok "a dependency nobody can satisfy is named" \
  || bad "a dependency nobody can satisfy is named" "rc=$rc $(out)"

# AC-7 says the stop is named in the ticket, not only on a terminal.
workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/tickets/t/1-one.md"
plan "implement review"
run > /dev/null
grep -q 'drift' "$WORK/tickets/t/1-one.md" \
  && ok "drift is written into the ticket" \
  || bad "drift is written into the ticket" "$(cat "$WORK/tickets/t/1-one.md")"

# Dependency order, where the numbering says the opposite.
workspace
sed -i 's/^after: .*/after:     2-two/' "$WORK/tickets/t/1-one.md"
sed -i 's/^after: .*/after:     /' "$WORK/tickets/t/2-two.md"
plan "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
grep -q '2-two' <(head -1 "$STUB_CALLS") \
  && ok "after: decides the order, not the filename" \
  || bad "after: decides the order, not the filename" "$(cat "$STUB_CALLS")"

# Each ceiling has to be the one that fired.
workspace
plan "implement review" "critique findings" "implement review" "critique findings" \
     "implement review" "critique findings" "implement review" "critique findings"
( cd "$WORK" && PATH="$WORK/.bin:$PATH" WAIT_SECONDS=0 MAX_ATTEMPTS=9 MAX_REVIEWS=2 \
    bash "$RUNNER" tickets/t > "$WORK/.out" 2>&1 )
grep -q 'reviews without a clean one' "$WORK/tickets/t/1-one.md" \
  && ok "the review ceiling says it was the review ceiling" \
  || bad "the review ceiling says it was the review ceiling" "$(tail -3 "$WORK/tickets/t/1-one.md")"
[ "$(field 1-one reviews)" = 3 ] \
  && ok "the review counter is read from the file and kept" \
  || bad "the review counter is read from the file and kept" "reviews=$(field 1-one reviews)"

# A ticket about the ticket format has body lines that look like frontmatter.
workspace
printf '\n## Record\n\n```\nstatus:    review\nattempts:  7\n```\n' >> "$WORK/tickets/t/1-one.md"
plan "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(grep -c '^status:    review' "$WORK/tickets/t/1-one.md")" = 1 ] \
  && ok "only the frontmatter is rewritten" \
  || bad "only the frontmatter is rewritten" "$(cat "$WORK/tickets/t/1-one.md")"

# Someone's notes in the ticket directory are not a ticket.
workspace
printf '# notes\n' > "$WORK/tickets/t/README.md"
plan "implement review" "critique clean" "implement review" "critique clean"
rc="$(run)"
[ "$rc" = 0 ] \
  && ok "a file that is not a ticket is ignored" \
  || bad "a file that is not a ticket is ignored" "rc=$rc $(out)"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
