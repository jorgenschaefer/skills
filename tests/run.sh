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

# The pauses between retries are the driver's, not the suite's: a case that
# expects a stop should reach it at once, and a case about retrying passes its
# own ladder of zeroes.
export RETRY_DELAYS=""

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

# Rewrites one ticket's frontmatter, for the cases about a queue the driver
# cannot drain.
ticket() {
  printf -- '---\nstatus: %s\ndepends_on: [%s]\n---\n\n# %s\n' \
    "$2" "$3" "$1" > "$WORK/tickets/$1.md"
}

# Runs the driver in $WORK against the plan already written to $WORK/plan.
# Leaves the run's output in $OUT, its exit code in $RC, and its log directory
# in $LOGS. $1 is the epoch the fixtures' reset is rewritten to.
drive() {
  local resets_at="$1"; shift
  : > "$WORK/calls"; : > "$WORK/prompts"
  OUT="$(cd "$WORK" && env \
    PATH="$WORK/bin:$PATH" TMPDIR="$WORK/logs" \
    STUB_PLAN="$WORK/plan" STUB_CALLS="$WORK/calls" \
    STUB_PROMPTS="$WORK/prompts" \
    STUB_FIXTURES="$HERE/fixtures" STUB_RESETS_AT="$resets_at" \
    "$@" timeout 60 bash "$LOOP" "${TICKET_DIR:-tickets}" 2>&1)"
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
# The prompt for one step, whole. Prompts are recorded separated by a `---`
# line, so a case can ask what a given step was actually told rather than
# whether the word appears anywhere in the run.
prompt_for()     { awk -v c="$1" 'BEGIN { RS = "\n---\n" } index($0, c) == 1' \
                     "$WORK/prompts"; }
expect_prompt()  { grep -q -- "$2" <<< "$(prompt_for "$1")" && ok "$3" \
                   || bad "$3" "no '$2' in the '$1' prompt:
$(prompt_for "$1")"; }
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
expect_log "01-thing.attempt-1.jsonl" "the limited attempt's transcript is kept"
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

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 1 -
errored.jsonl 0 -
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive "$(just_reset)" RETRY_DELAYS=0
expect_rc 0 "waiting for a window does not spend the one retry a failure needs"
expect_calls 6 "the limit is waited out and the failure after it still retried"

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

drive 0 RETRY_DELAYS="soon"
expect_rc 2 "a RETRY_DELAYS that is not seconds is a bad invocation"
expect_calls 0 "a bad RETRY_DELAYS never starts a step"

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
errored.jsonl 0 -
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0 RETRY_DELAYS="0 0"
expect_rc 0 "a dropped connection is retried and the run finishes"
expect_out "trying 01-thing again" "a retry says what it is about to do"
expect_calls 5 "the step is run again, not skipped"
expect_log "01-thing.attempt-1.jsonl" "the failed attempt's transcript is kept"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
errored.jsonl 0 -
errored.jsonl 0 -
errored.jsonl 0 -
EOF
drive 0 RETRY_DELAYS="0 0"
expect_rc 3 "a failure that will not clear stops once the pauses run out"
expect_calls 3 "the run is tried as often as there are pauses, and no more"
expect_out "gave up after 3 attempts" "giving up says how often it tried"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
unauthorized.jsonl 0 -
EOF
drive 0 RETRY_DELAYS="0 0"
expect_rc 3 "an error no delay can fix is not retried"
expect_calls 1 "a bad key is not tried again"
expect_out "No delay fixes" "a bad key says why nothing was retried"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive 0 RETRY_DELAYS="0 0"
expect_rc 1 "a ticket left unfinished by a whole session is a halt"
expect_out "halted on 01-thing" "a halt names the ticket"
expect_calls 1 "a halt is a decision, so it is never retried"

# --- a queue that cannot be drained -------------------------------------------

workspace 01-thing 02-other
ticket 02-other todo 01
ticket 01-thing blocked ""
drive 0
expect_rc 1 "a ticket nothing can reach is a stop, not a finished run"
expect_calls 0 "an unreachable queue never reaches trace, critique or handover"
expect_out "01-thing" "the stop names the ticket that is stuck"
expect_out "02-other" "the stop names what is stuck behind it"

workspace 01-thing
ticket 01-thing todo 09
drive 0
expect_rc 1 "a dependency that does not exist is a stop"
expect_out "does not exist" "a missing dependency says what is missing"

workspace 01-thing 02-other
ticket 01-thing todo 02
ticket 02-other todo 01
drive 0
expect_rc 1 "two tickets waiting on each other are a stop"
expect_calls 0 "a cycle never reaches handover"

# --- a reset that has already passed ------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 1 -
EOF
drive "$(hours_off -2)"
expect_rc 3 "a reset already long past is no window to wait for"
expect_no_out "waiting until" "a stale reset never becomes a wait"
expect_calls 1 "a stale reset falls through to the retry ladder, which is empty"

# --- what the driver asks for -------------------------------------------------

workspace 01-thing
mkdir -p "$WORK/docs/feature"
mv "$WORK/tickets" "$WORK/docs/feature/tickets"
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
TICKET_DIR=docs/feature/tickets drive 0
unset TICKET_DIR
expect_rc 0 "the ticket directory need not be ./tickets"
expect_prompt /trace     docs/feature/tickets "trace is told where to file a gap"
expect_prompt "Run /critique" docs/feature/tickets "critique is told where to file a blocker"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0 REVIEWS=code
expect_rc 0 "the reduced-review mode runs"
expect_prompt /implement "quality review" "the reduced mode says which review it drops"

# --- the handover reaches the screen ------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
handover.jsonl 0 -
EOF
drive 0
expect_rc 0 "a run ends with the handover"
expect_out "status page" "the handover brief is printed whole, not just its first line"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
handover.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_out "Closing out the run" "a building step still narrates its first line"
expect_no_out "status page" "a building step is still only its narration"

# ------------------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
