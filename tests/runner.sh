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
[ ! -s "$STUB_CALLS" ] || bad "it launches nothing when it refuses" "$(cat "$STUB_CALLS")"

workspace
rc="$( ( cd "$WORK" && PATH="$WORK/.bin:$PATH" bash "$RUNNER" tickets/nope >"$WORK/.out" 2>&1 ); echo $?)"
[ "$rc" != 0 ] && ok "it refuses a ticket directory that is not there" \
               || bad "it refuses a ticket directory that is not there" "$(out)"

# --- the drift pre-flight, in both directions

workspace
sed -i 's/the first thing happens./the first thing happens, differently./' "$WORK/tickets/t/1-one.md"
plan "implement review"
rc="$(run)"
[ "$rc" != 0 ] && grep -q 'drift' "$WORK/.out" \
  && ok "a ticket whose criterion left the solution stops the run" \
  || bad "a ticket whose criterion left the solution stops the run" "rc=$rc $(out)"
[ ! -s "$STUB_CALLS" ] || bad "drift stops it before any session" "$(cat "$STUB_CALLS")"

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

# --- review findings send it back, bounded

workspace
plan "implement review" "critique findings" "implement review" "critique clean" "implement review" "critique clean"
run > /dev/null
[ "$(field 1-one reviews)" = 1 ] && [ "$(field 1-one status)" = done ] \
  && ok "findings send the ticket back and it can still finish" \
  || bad "findings send the ticket back and it can still finish" "reviews=$(field 1-one reviews) status=$(field 1-one status)"

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

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
