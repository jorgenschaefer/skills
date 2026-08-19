#!/usr/bin/env bash
#
# The driver's tests.
#
#   tests/run.sh
#
# Plain bash, because a repo of Markdown skills and one script should not have
# to install a test framework to check that script. Each case builds a throwaway
# repo, puts `stub-claude` on PATH as `claude`, and runs loop.sh against it, so
# what is under test is the driver's behaviour and not its internals.
#
# The rate-limit fixtures are real records from runs that hit the real limit.
# Their reset is written two seconds out - `resetsAt` a minute in the past, plus
# the minute of slack the driver waits past a reset - so the wait is genuinely
# slept through and the suite still finishes in seconds.

set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
LOOP="$HERE/../loop.sh"
passed=0 failed=0
WORKSPACES=()

# A failing case is worth walking through, so its workspace survives; a passing
# suite should leave the tmp dir as it found it.
cleanup() {
  [ "$failed" -eq 0 ] && rm -rf "${WORKSPACES[@]}" && return 0
  printf '\nworkspaces kept: %s\n' "${WORKSPACES[*]}"
}
trap cleanup EXIT

ok()   { printf 'ok    %s\n' "$1"; passed=$((passed + 1)); }
bad()  { printf 'FAIL  %s\n' "$1"; failed=$((failed + 1))
         [ $# -lt 2 ] || printf '%s\n' "$2" | sed 's/^/        /'; }

# A repo the driver will agree to run in: a feature branch, one commit, and a
# ticket per argument, each ready to build. Leaves it in $WORK.
workspace() {
  local dir n
  dir="$(mktemp -d)"
  git -C "$dir" init -q
  git -C "$dir" config user.email loop@test
  git -C "$dir" config user.name loop
  : > "$dir/README"
  git -C "$dir" add README
  git -C "$dir" commit -qm "first"
  git -C "$dir" checkout -qb feature
  mkdir -p "$dir/tickets" "$dir/logs" "$dir/bin"
  ln -s "$HERE/stub-claude" "$dir/bin/claude"
  for n in "$@"; do
    printf -- '---\nstatus: todo\ndepends_on: []\n---\n\n# %s\n' "$n" > "$dir/tickets/$n.md"
  done
  WORKSPACES+=("$dir")
  WORK="$dir"
}

# Runs the driver in $WORK against the plan already written to $WORK/plan.
# Leaves the run's output in $OUT, its exit code in $RC, and its log directory
# in $LOGS. $1 is the epoch the fixtures' reset is rewritten to.
drive() {
  local resets_at="$1"; shift
  : > "$WORK/calls"
  OUT="$(cd "$WORK" && env \
    PATH="$WORK/bin:$PATH" TMPDIR="$WORK/logs" \
    STUB_PLAN="$WORK/plan" STUB_CALLS="$WORK/calls" \
    STUB_FIXTURES="$HERE/fixtures" STUB_RESETS_AT="$resets_at" \
    "$@" timeout 60 bash "$LOOP" tickets 2>&1)"
  RC=$?
  LOGS="$(printf '%s\n' "$OUT" | sed -n 's/^logs: //p' | head -1)"
}

expect_rc()      { [ "$RC" = "$1" ] && ok "$2" || bad "$2" "exit $RC, wanted $1
$OUT"; }
expect_out()     { grep -q -- "$1" <<< "$OUT" && ok "$2" || bad "$2" "no '$1' in:
$OUT"; }
expect_no_out()  { grep -q -- "$1" <<< "$OUT" && bad "$2" "found '$1' in:
$OUT" || ok "$2"; }
expect_calls()   { local n; n=$(wc -l < "$WORK/calls")
                   [ "$n" = "$1" ] && ok "$2" || bad "$2" "$n calls, wanted $1
$(cat "$WORK/calls")"; }
expect_log()     { local m=("$LOGS"/$1)
                   [ -e "${m[0]}" ] && ok "$2" || bad "$2" "no $1 in $LOGS
$(ls "$LOGS" 2>&1)"; }

# A reset a minute ago: past the window, still two seconds of waiting once the
# driver adds its slack.
just_reset() { echo $(( $(date +%s) - 58 )); }
hours_off()  { echo $(( $(date +%s) + $1 * 3600 )); }

# --- a run nothing interrupts -------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a clean run builds the ticket, checks it and hands over"
expect_calls 4 "a clean run calls out once per step"

# --- a usage limit ------------------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 1 -
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive "$(just_reset)"
expect_rc 0 "a session limit is waited out and the run finishes"
expect_out "waiting until" "the wait says when it will pick up again"
expect_calls 5 "the limited step is retried, not skipped"
expect_log "01-thing.limited-1.jsonl" "the limited attempt's transcript is kept"
expect_out '\$34.25' "the limited attempt's cost stays in the run total"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 0 -
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive "$(just_reset)"
expect_rc 0 "a limit that exits 0 is waited out just the same"
expect_calls 5 "a limit that exits 0 is retried too"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
warned.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive "$(hours_off 1)"
expect_rc 0 "a utilization warning is not a limit"
expect_no_out "waiting until" "a warned run never waits"

# --- a limit too far off to wait for ------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-weekly.jsonl 1 -
EOF
drive "$(hours_off 22)"
expect_rc 3 "a weekly limit past the cap stops for a human"
expect_no_out "waiting until" "a limit past the cap is not waited out"
expect_out "re-running resumes" "a limit past the cap says how to resume"
expect_calls 1 "a limit past the cap is not retried"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 1 -
EOF
drive "$(hours_off 1)" MAX_WAIT_HOURS=0
expect_rc 3 "MAX_WAIT_HOURS=0 refuses a wait the default would take"
expect_no_out "waiting until" "MAX_WAIT_HOURS=0 never waits"

workspace 01-thing
drive 0 MAX_WAIT_HOURS=soon
expect_rc 2 "a MAX_WAIT_HOURS that is not hours is a bad invocation"
expect_out "whole hours" "a bad MAX_WAIT_HOURS says what it wanted"
expect_calls 0 "a bad MAX_WAIT_HOURS never starts a step"

# --- stops that are not limits ------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
crashed.jsonl 0 -
EOF
drive 0
expect_rc 3 "a stream cut mid-message is still a dead session"
expect_out "stopped mid-message" "a cut stream says so"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
errored.jsonl 0 -
EOF
drive 0
expect_rc 3 "a session that ended on an error is dead, not halted"
expect_no_out "halted on" "an errored session is never reported as a halt"
expect_out "Connection error" "an errored session reports what the session said"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a ticket left unfinished by a whole session is a halt"
expect_out "halted on 01-thing" "a halt names the ticket"

# ------------------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
