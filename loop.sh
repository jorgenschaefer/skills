#!/usr/bin/env bash
#
# Drive one feature's ticket loop to completion, unattended.
#
#   ./loop.sh path/to/tickets
#
# Builds every ready ticket in dependency order, then checks the result against
# the spec, reviews it, and hands it back. Stops at the first halt: /implement
# records the reason in the ticket rather than guessing past it.
#
# Exit codes say what kind of stop it was, because they want opposite responses:
#   1  an agent halted, or the reviews would not converge - a human is needed
#   2  bad invocation - no ticket directory, not a repo, on main
#   3  a session died in a way the driver could not wait out - re-running resumes
#
# Running out of usage is not one of those stops: the window reopens at a time
# the stream names to the second, so the driver sleeps until then and picks the
# same step back up. It waits only for a reset within MAX_WAIT_HOURS (6), which
# covers a five-hour window and leaves a weekly one to a human.
#
# A run takes hours, so progress on screen is the model's own narration - one
# short line per phase - and nothing else. Every step's full transcript is kept
# as JSON under the log directory printed at startup: the screen stays quiet,
# the detail stays on disk.

set -uo pipefail

TICKETS="${1:-tickets}"
MAX_PASSES=2
TICK_MINUTES=3

# REVIEWS=code drops the quality review and the code review's second round.
# Reviews are about half a ticket's wall clock, so this roughly halves it - a
# trade worth making against a deadline and not otherwise. The skill keeps its
# full discipline as the default; the driver asks for less, the same way it asks
# /critique to file tickets.
REVIEWS="${REVIEWS:-full}"
case "$REVIEWS" in full|code) ;;
  *) echo "REVIEWS must be 'full' or 'code', not '$REVIEWS'" >&2; exit 2 ;;
esac

# How long a run may sit idle waiting for a usage window to reopen. Six hours
# covers any five-hour window; a weekly limit can be days off, and a terminal
# blocked for days is worse than a human reading a message in the morning.
MAX_WAIT_HOURS="${MAX_WAIT_HOURS:-6}"
case "$MAX_WAIT_HOURS" in
  '' | *[!0-9]*)
    echo "MAX_WAIT_HOURS must be whole hours, not '$MAX_WAIT_HOURS'" >&2; exit 2 ;;
esac

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
# The subshell's stderr is discarded because it announces "Terminated" when its
# sleep is killed, which is a line of noise per step on a deliberately quiet
# screen; the ticks themselves go to stdout and survive.
TICKER_PID=""
ticker_start() {
  ( m=0
    while sleep $((TICK_MINUTES * 60)); do
      m=$((m + TICK_MINUTES)); printf '  … %dm\n' "$m"
    done ) 2>/dev/null &
  TICKER_PID=$!
}
ticker_stop() {
  [ -n "$TICKER_PID" ] || return 0
  # The subshell's `sleep` is a separate process and outlives a kill aimed at
  # its parent, so take the child first - otherwise every step leaves an orphan.
  pkill -P "$TICKER_PID" 2>/dev/null
  kill "$TICKER_PID" 2>/dev/null
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

# A session that never reached its end - a crash, an auth problem, a usage
# window running out - is not an agent decision. Three things can say so, and the
# best of them comes first: the closing `result` record carries the session's own
# account of what went wrong ("You've hit your session limit - resets 2:30pm"),
# which beats anything composed here. Failing that, a non-zero exit. Failing
# that, a missing `result` record, because a stream cut mid-message still exits
# 0. Echoes what went wrong, or nothing if the session finished.
session_died() {
  local rc="$1" log="$LOG_DIR/$2.jsonl" said
  said="$(jq -r 'select(.type == "result" and .is_error)
                 | .result // "the session ended on an error"' "$log" 2>/dev/null | tail -1)"
  [ -z "$said" ] || { echo "$said"; return 0; }
  [ "$rc" -eq 0 ] || { echo "claude exited $rc"; return 0; }
  grep -q '"type":"result"' "$log" || { echo "the stream stopped mid-message"; return 0; }
  return 1
}

# The stream announces a usage limit as a record of its own, carrying the second
# the window reopens. The same record reports utilization on the way up, so only
# `rejected` counts: `allowed_warning` is a session still working.
limit_reset_at() {
  jq -r 'select(.type == "rate_limit_event" and .rate_limit_info.status == "rejected")
         | .rate_limit_info.resetsAt' "$LOG_DIR/$1.jsonl" 2>/dev/null | tail -1
}

# Sleeps to a minute past the reset - starting on the second it reopens only
# invites a second rejection - keeping the ticker's beat so a long wait still
# looks alive.
wait_until() {
  local until=$(( $1 + 60 )) left nap
  while :; do
    left=$(( until - $(date +%s) ))
    [ "$left" -gt 0 ] || break
    nap=$(( TICK_MINUTES * 60 ))
    [ "$left" -lt "$nap" ] && nap="$left"
    sleep "$nap"
    left=$(( until - $(date +%s) ))
    [ "$left" -gt 0 ] && printf '  … %dm to go\n' $(( (left + 59) / 60 ))
  done
}

# $1 = log basename, $2 = prompt. Non-zero means the session died, which is
# never a decision about the work - it leaves everything exactly where it was.
#
# Which is exactly why a usage limit can be waited out here rather than handed
# back: the step decided nothing, so running it again resumes it, and the stream
# said when that will work. The limited attempt's transcript is kept beside the
# retry's - it holds real work and real cost, and the run's total should still
# say so. Retries are not counted, because each one needs a fresh rejection from
# the API and so cannot spin on its own.
run_step() {
  local rc why reset attempt=0
  while :; do
    ticker_start
    claude -p --output-format stream-json --verbose "$2" \
      | tee "$LOG_DIR/$1.jsonl" \
      | jq --unbuffered -r "$PROGRESS_FILTER"
    rc=${PIPESTATUS[0]}
    ticker_stop
    why="$(session_died "$rc" "$1")" || return 0

    reset="$(limit_reset_at "$1")"
    if [ -z "$reset" ] || [ $(( reset - $(date +%s) )) -gt $(( MAX_WAIT_HOURS * 3600 )) ]; then
      break
    fi

    attempt=$((attempt + 1))
    mv "$LOG_DIR/$1.jsonl" "$LOG_DIR/$1.limited-$attempt.jsonl"
    echo
    echo "!! $why"
    printf '   waiting until %s, then picking %s back up\n' \
      "$(date -d "@$((reset + 60))" +%H:%M)" "$1"
    wait_until "$reset"
    echo "==> $1 (attempt $((attempt + 1)))"
  done
  {
    echo
    echo "!! session died on $1 - $why"
    echo "   Nothing was halted and no ticket changed, so re-running resumes here:"
    echo "     $0 $TICKETS"
    echo "   transcript: $LOG_DIR/$1.jsonl"
  } >&2
  return 1
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

# /implement sets `status` in the ticket before it finishes, and that is the
# signal - not the exit code, since a session can end without deciding anything.
# So an unfinished ticket means one of two things, and they want opposite
# responses: a dead session leaves work to resume, a halt leaves work to read.
implement_prompt() {
  [ "$REVIEWS" = "code" ] || { printf '/implement %s\n' "$1"; return; }
  cat <<EOF
/implement $1
Run the code review only - once, no second round - and skip the quality review
entirely. Everything else in the skill stands: the RED-first loop, the halt
rules, the Record. This is a deliberate trade against a deadline, so note in the
Record that the ticket shipped without a quality review.
EOF
}

drain() {
  local ticket name
  while ticket="$(next_ticket)"; do
    name="$(basename "$ticket" .md)"
    echo "==> [$(position)] $name"
    run_step "$name" "$(implement_prompt "$ticket")" || return 3
    [ "$(status_of "$ticket")" = "done" ] && continue

    echo
    echo "!! halted on $name - transcript: $LOG_DIR/$name.jsonl"
    # The session ran to the end, so it had every chance to say why it stopped.
    # If it didn't, the ticket cannot tell you and the transcript has to.
    if grep -q '^## Halt' "$ticket"; then
      sed -n '/^## Halt/,$p' "$ticket"
    else
      echo "   It left status '$(status_of "$ticket")' and wrote no ## Halt section,"
      echo "   so why it stopped is in the transcript and nowhere else."
    fi
    return 1
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
[ "$REVIEWS" = "full" ] || echo "reviews: $REVIEWS (quality review skipped)"

# Bounded, because work the loop cannot converge on should reach a human.
for pass in $(seq "$MAX_PASSES"); do
  drain || exit $?

  echo "==> trace (pass $pass)"
  run_step "trace-$pass" "$(trace_prompt)" || exit 3
  drain || exit $?

  echo "==> critique (pass $pass)"
  run_step "critique-$pass" "$(critique_prompt)" || exit 3

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
run_step "handover" "/handover $SPEC_DIR" || exit 3
