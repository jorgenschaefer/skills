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
# The fixtures are real records, cut from the transcripts of runs on disk, so
# what the driver reads here is what the CLI actually writes.

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
# in $LOGS.
drive() {
  : > "$WORK/calls"
  OUT="$(cd "$WORK" && env \
    PATH="$WORK/bin:$PATH" TMPDIR="$WORK/logs" \
    STUB_PLAN="$WORK/plan" STUB_CALLS="$WORK/calls" \
    STUB_FIXTURES="$HERE/fixtures" \
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

# --- a run nothing interrupts -------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive
expect_rc 0 "a clean run builds the ticket, checks it and hands over"
expect_calls 4 "a clean run calls out once per step"

# --- stops that are not limits ------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
crashed.jsonl 0 -
EOF
drive
expect_rc 3 "a stream cut mid-message is still a dead session"
expect_out "stopped mid-message" "a cut stream says so"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive
expect_rc 1 "a ticket left unfinished by a whole session is a halt"
expect_out "halted on 01-thing" "a halt names the ticket"

# ------------------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
