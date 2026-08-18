#!/usr/bin/env bash
#
# Drive one feature's ticket loop to completion, unattended.
#
#   ./loop.sh path/to/tickets
#
# Builds every ready ticket in dependency order, then checks the result against
# the spec, reviews it, and hands it back. Stops at the first halt: /implement
# records the reason in the ticket rather than guessing past it, so a stopped
# loop means a human is needed, not that something crashed.
#
# A run takes hours, so progress on screen is the model's own narration - one
# short line per phase - and nothing else. Every step's full transcript is kept
# as JSON under the log directory printed at startup: the screen stays quiet,
# the detail stays on disk.

set -uo pipefail

TICKETS="${1:-tickets}"
MAX_PASSES=2
TICK_MINUTES=3

[ -d "$TICKETS" ] || { echo "no ticket directory: $TICKETS" >&2; exit 2; }
SPEC_DIR="$(cd "$(dirname "$TICKETS")" && pwd)"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  echo "not a git repository" >&2; exit 2; }
case "$branch" in
  main|master)
    echo "refusing to run on $branch - work on a feature branch so a bad run is one 'git branch -D' away" >&2
    exit 2 ;;
esac

# Outside the repo on purpose. Logs are debugging aids, not artifacts, and the
# pipeline's habit is to leave no paper behind in the working tree.
LOG_DIR="${TMPDIR:-/tmp}/loop-${branch//\//-}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"
RUN_START=$SECONDS

# --- progress -----------------------------------------------------------------

# Narration and a closing summary; everything else stays in the transcript.
PROGRESS_FILTER='
def money:
  (. * 100 | round) as $c
  | "\($c / 100 | floor).\(if $c % 100 < 10 then "0" else "" end)\($c % 100)";
if .type == "assistant" then
  .message.content[]?
  | select(.type == "text")
  | .text | split("\n")[0]
  | select(. != "")
  | "  " + (if length > 110 then .[0:107] + "..." else . end)
elif .type == "result" then
  "  " + (if .is_error then "FAILED" else "ok" end)
  + "  \(.duration_ms / 1000 | floor)s · \(.num_turns) turns"
  + " · $\(.total_cost_usd | money)"
else empty end'

# Proof of life for the stretches the model works without narrating - a long
# review can be silent for many minutes, and silence is what a hang looks like.
TICKER_PID=""
ticker_start() {
  ( m=0
    while sleep $((TICK_MINUTES * 60)); do
      m=$((m + TICK_MINUTES)); printf '  … %dm\n' "$m"
    done ) &
  TICKER_PID=$!
}
ticker_stop() {
  [ -n "$TICKER_PID" ] || return 0
  # The subshell's `sleep` is a separate process and outlives a kill aimed at
  # its parent, so take the child first - otherwise every step leaves an orphan.
  pkill -P "$TICKER_PID" 2>/dev/null
  kill "$TICKER_PID" 2>/dev/null
  wait "$TICKER_PID" 2>/dev/null
  TICKER_PID=""
}

run_total_cost() {
  local logs=("$LOG_DIR"/*.jsonl)
  [ -e "${logs[0]}" ] || { echo 0; return; }
  jq -s 'map(select(.type == "result") | .total_cost_usd // 0) | add // 0' "${logs[@]}"
}

finish() {
  ticker_stop
  local secs=$((SECONDS - RUN_START))
  printf '\n%dm%02ds · $%.2f · logs in %s\n' \
    $((secs / 60)) $((secs % 60)) "$(run_total_cost)" "$LOG_DIR"
}
trap finish EXIT
trap 'exit 130' INT TERM

# $1 = log basename, $2 = prompt. A non-zero exit here is a session failure -
# a crash or an auth problem - not an agent decision, so it stops the run.
run_step() {
  local rc
  ticker_start
  claude -p --output-format stream-json --verbose "$2" \
    | tee "$LOG_DIR/$1.jsonl" \
    | jq --unbuffered -r "$PROGRESS_FILTER"
  rc=${PIPESTATUS[0]}
  ticker_stop
  [ "$rc" -eq 0 ] || echo "!! claude exited $rc on $1 - see $LOG_DIR/$1.jsonl" >&2
  return "$rc"
}

# --- ticket frontmatter -------------------------------------------------------

field() { sed -n "s/^$2:[[:space:]]*\([^#]*\).*/\1/p" "$1" | head -1 | xargs; }
status_of() { field "$1" status; }
deps_of() { field "$1" depends_on | tr -d '[]' | tr ',' ' '; }
ticket_for() { ls "$TICKETS/$1"-*.md 2>/dev/null | head -1; }

ready() {
  local dep file
  for dep in $(deps_of "$1"); do
    file="$(ticket_for "$dep")"
    [ -n "$file" ] && [ "$(status_of "$file")" = "done" ] || return 1
  done
}

next_ticket() {
  local file
  for file in "$TICKETS"/[0-9]*.md; do
    [ -e "$file" ] || continue
    [ "$(status_of "$file")" = "todo" ] || continue
    ready "$file" && { printf '%s\n' "$file"; return 0; }
  done
  return 1
}

# Recomputed each time: /trace and /critique can file new tickets mid-run, so
# the denominator is what exists now, not what existed at the start.
position() {
  local total done_n
  total=$(ls "$TICKETS"/[0-9]*.md 2>/dev/null | wc -l)
  done_n=$(grep -lE '^status:[[:space:]]*done' "$TICKETS"/[0-9]*.md 2>/dev/null | wc -l)
  printf '%d/%d' "$((done_n + 1))" "$total"
}

# --- the loop -----------------------------------------------------------------

# /implement sets `status` in the ticket before it finishes. That, not the exit
# code, is the signal: a session that dies without setting it reads as a halt
# rather than passing silently.
drain() {
  local ticket name
  while ticket="$(next_ticket)"; do
    name="$(basename "$ticket" .md)"
    echo "==> [$(position)] $name"
    run_step "$name" "/implement $ticket"
    if [ "$(status_of "$ticket")" != "done" ]; then
      echo
      echo "!! halted on $name - transcript: $LOG_DIR/$name.jsonl"
      sed -n '/^## Halt/,$p' "$ticket"
      return 1
    fi
  done
}

# Both end-of-run checks feed findings back as tickets, so a fix re-enters the
# same loop with the same TDD and review discipline instead of being patched by
# hand after everything else has been verified. /trace runs first: a gap it finds
# becomes code, and that code should pass under /critique rather than land behind
# it. /critique stays a generic review skill - the prompt here, not the skill,
# knows this pipeline files tickets.
#
# Pass 1 checks the whole run; a later pass checks only what the previous pass's
# findings added. Re-reading twelve tickets' code to check three fixes is the
# same review over again, and it is what makes a second pass cost as much as the
# first. Narrowing is safe because pass 1 is the check that proves every
# criterion is pinned by a test that fails without it - once that holds, the
# green suite is what guards the old criteria, not another read of them.
#
# Set to HEAD once a pass's checks are done, so the next pass's baseline is
# every commit built after them.
CHECKED_AT=""

trace_prompt() {
  [ -n "$CHECKED_AT" ] || { printf '/trace %s\n' "$SPEC_DIR"; return; }
  cat <<EOF
/trace $SPEC_DIR
Scope this to the commits since $CHECKED_AT - the tickets the last pass's
reviews filed. Everything up to that commit traced clean and its criteria are
pinned by tests the suite still runs, so check the criteria these commits claim
and whether they broke anything built earlier.
EOF
}

critique_prompt() {
  local since="this branch's start"
  [ -z "$CHECKED_AT" ] || since="$CHECKED_AT"
  cat <<EOF
Run /critique over the diff from $since.
For each Blocker and Should-fix, file a remediation ticket in $TICKETS,
following TICKET_FORMAT.md as documented in the /implement skill.
Do not file nits - leave those in your report for /handover to triage.
EOF
}

echo "logs: $LOG_DIR"

# Bounded, because work the loop cannot converge on should reach a human.
for pass in $(seq "$MAX_PASSES"); do
  drain || exit 1

  echo "==> trace (pass $pass)"
  run_step "trace-$pass" "$(trace_prompt)" || exit 1
  drain || exit 1

  echo "==> critique (pass $pass)"
  run_step "critique-$pass" "$(critique_prompt)" || exit 1

  if ! next_ticket >/dev/null; then
    reviews_clean=1
    break
  fi
  CHECKED_AT="$(git rev-parse HEAD)"
  echo "==> reviews filed work; draining again"
done

if [ -z "${reviews_clean:-}" ]; then
  echo "!! reviews still filing work after $MAX_PASSES passes - stopping for a human" >&2
  exit 1
fi

echo "==> handover"
run_step "handover" "/handover $SPEC_DIR" || exit 1
