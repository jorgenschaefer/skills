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
#   1  an agent halted, the queue has tickets nothing can reach, or the reviews
#      would not converge - a human is needed
#   2  bad invocation - no ticket directory, not a repo, on main
#   3  a session died in a way the driver could neither wait out nor retry
#
# Neither of those is an agent decision, so neither ends a run. Running out of
# usage is waited out: the window reopens at a time the stream names to the
# second, and the driver sleeps until then, for as long as MAX_WAIT_HOURS (6)
# allows - a five-hour window, not a weekly one. Any other death - a dropped
# connection, a crash, a stream cut short - is tried again after a pause, seven
# of them over about three hours (RETRY_DELAYS). Only an error no delay can fix,
# a bad key or an empty balance, stops the run where it stands.
#
# Nobody is here to approve a tool call, so the run needs standing permission
# for the edits, commands and commits every ticket makes - a `permissions.allow`
# in settings that already covers them. `claude -p` cannot prompt: what it
# cannot get approved it declines, and a ticket that could not write a file
# halts as if the work were impossible.
#
# A run takes hours, so progress on screen is the model's own narration - one
# short line per phase - and nothing else. Every step's full transcript is kept
# as JSON under the log directory printed at startup: the screen stays quiet,
# the detail stays on disk. The closing handover is the exception, printed in
# full, because that brief is what the run was for.

set -uo pipefail

TICKETS="${1:-tickets}"
TICK_MINUTES=3

# Not tunable on purpose. Reviews that keep filing work after two passes are not
# short of budget, they are failing to converge, and that is a thing to read
# rather than a thing to raise.
MAX_PASSES=2

# Which model each kind of step runs on. Reviews read code a different model
# wrote: two sessions of one model share its blind spots, and a reviewer that
# misses a defect for the same reason the builder wrote it is not a second
# opinion, however adversarial its prompt. Which two models is an account's
# business - that they differ is not, so a run where they do not is refused
# rather than quietly downgraded to one opinion twice.
BUILD_MODEL="${BUILD_MODEL:-opus}"
REVIEW_MODEL="${REVIEW_MODEL:-sonnet}"
[ "$BUILD_MODEL" != "$REVIEW_MODEL" ] || {
  echo "BUILD_MODEL and REVIEW_MODEL must differ - a review by the model that wrote the code is not a second opinion" >&2
  exit 2; }

# Effort is per kind because the kinds are not alike: building a ticket and
# reading a diff for what is wrong with it are the thinking; the handover writes
# up work already done and decided. A kind with no flags would be a session on
# whatever model came to hand - the one thing the guard above exists to refuse -
# so an unknown one stops the run rather than defaulting.
step_flags() {
  case "$1" in
    build)    printf -- '--model %s --effort high'   "$BUILD_MODEL" ;;
    review)   printf -- '--model %s --effort high'   "$REVIEW_MODEL" ;;
    handover) printf -- '--model %s --effort medium' "$BUILD_MODEL" ;;
    *)        echo "no such kind of step: $1" >&2; exit 2 ;;
  esac
}

# How long one step may sit idle waiting for usage windows to reopen, summed
# over every wait it takes. Six hours covers any five-hour window; a weekly
# limit can be days off, and a terminal blocked for days is worse than a human
# reading a message in the morning. Summing rather than capping each wait alone
# is what stops a limit reported over and over from waiting out the night.
MAX_WAIT_HOURS="${MAX_WAIT_HOURS:-6}"
case "$MAX_WAIT_HOURS" in
  '' | *[!0-9]*)
    echo "MAX_WAIT_HOURS must be whole hours, not '$MAX_WAIT_HOURS'" >&2; exit 2 ;;
esac

# How long to pause before trying a step again after it died on something other
# than a usage limit. The pauses are the backoff and how many there are is the
# budget: eight attempts over about three hours, patient enough to sit out an
# incident and short of spending a whole night on a failure that will not clear.
# Empty never retries.
RETRY_DELAYS="${RETRY_DELAYS-60 120 300 600 1800 3600 3600}"
for pause in $RETRY_DELAYS; do
  case "$pause" in
    *[!0-9]*)
      echo "RETRY_DELAYS must be whole seconds, not '$pause'" >&2; exit 2 ;;
  esac
done

[ -d "$TICKETS" ] || { echo "no ticket directory: $TICKETS" >&2; exit 2; }
SPEC_DIR="$(cd "$(dirname "$TICKETS")" && pwd)"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
  echo "not a git repository" >&2; exit 2; }
case "$branch" in
  main|master)
    echo "refusing to run on $branch - work on a feature branch so a bad run is one 'git branch -D' away" >&2
    exit 2 ;;
esac

# Outside the repo, because the pipeline leaves no paper behind in the working
# tree - and out of $TMPDIR, which is swept, because a run's transcripts are the
# only record of how the pipeline behaved rather than how its skills read, and
# that record is worth more the longer it accumulates. One directory per run
# under one root, so reading across runs is a glob; the pid keeps two runs
# started in the same second from writing over each other.
#
# Logging nowhere is a bad invocation rather than a detail to discover later: a
# step whose transcript is missing reads as a session that died mid-stream, so
# the run would spend its whole retry ladder on the wrong diagnosis.
STATE="${XDG_STATE_HOME:-${HOME:+$HOME/.local/state}}"
[ -n "$STATE" ] || {
  echo "set XDG_STATE_HOME or HOME - the run's transcripts need somewhere to accumulate" >&2
  exit 2; }
LOG_DIR="$STATE/loop/${branch//\//-}-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$LOG_DIR" || { echo "cannot keep this run's transcripts in $LOG_DIR" >&2; exit 2; }
RUN_START=$SECONDS

# --- progress -----------------------------------------------------------------

# The line that closes a step, shared by both filters below.
STEP_RESULT='
def money:
  (. * 100 | round) as $c
  | "\($c / 100 | floor).\(if $c % 100 < 10 then "0" else "" end)\($c % 100)";
def closing:
  "  " + (if .is_error then "FAILED" else "ok" end)
  + "  \(.duration_ms / 1000 | floor)s · \(.num_turns) turns"
  + " · $\(.total_cost_usd | money)";
'

# Narration and a closing summary; everything else stays in the transcript.
PROGRESS_FILTER="$STEP_RESULT"'
if .type == "assistant" then
  .message.content[]?
  | select(.type == "text")
  | .text | split("\n")[0]
  | select(. != "")
  | "  " + (if length > 110 then .[0:107] + "..." else . end)
elif .type == "result" then closing
else empty end'

# Every line, for the one step whose words are the point. The handover brief is
# what the whole run was for, and a brief nobody reads is a brief that was never
# written - so it goes to the screen whole rather than into the transcript with
# its first line showing.
BRIEF_FILTER="$STEP_RESULT"'
if .type == "assistant" then
  .message.content[]? | select(.type == "text") | .text
elif .type == "result" then closing
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

# Some deaths no pause can fix, and a morning message should say which rather
# than hide under eight identical failures. The list is the one the CLI itself
# uses: a login that expired, a key that is not valid, nothing left to spend.
unrecoverable() {
  local fatal='not logged in|please run /login|authentication failed|credit balance'
  fatal="$fatal|invalid api key|oauth token (expired|revoked)|401 unauthorized"
  grep -qiE "$fatal|403 forbidden" <<< "$1"
}

# Sleeps, keeping the ticker's beat so a long pause still looks alive.
wait_for() {
  local left="$1" nap
  while [ "$left" -gt 0 ]; do
    nap=$(( TICK_MINUTES * 60 ))
    [ "$left" -lt "$nap" ] && nap="$left"
    sleep "$nap"
    left=$(( left - nap ))
    [ "$left" -gt 0 ] && printf '  … %dm to go\n' $(( (left + 59) / 60 ))
  done
}

# $1 = kind of step, $2 = log basename, $3 = prompt, $4 = how to print it.
# Non-zero means the session died, which is never a decision about the work - it
# leaves everything exactly where it was.
#
# Which is exactly why a death is answered here rather than handed back: the
# step decided nothing, so running it again resumes it. A usage limit even says
# when that will work, and waiting for a window is not a failure, so it does not
# spend a retry. Everything else gets the next pause off the ladder, and a run
# ends only once the ladder does. Each attempt's transcript is kept beside the
# next one's - they hold real work and real cost, and the run's total should
# still say so.
run_step() {
  local rc why reset attempt=0 retries=0 waited=0 pause note
  local filter="${4:-$PROGRESS_FILTER}"
  local -a pauses=($RETRY_DELAYS) flags=($(step_flags "$1"))
  while :; do
    attempt=$((attempt + 1))
    ticker_start
    claude -p "${flags[@]}" --output-format stream-json --verbose "$3" \
      | tee "$LOG_DIR/$2.jsonl" \
      | jq --unbuffered -r "$filter"
    rc=${PIPESTATUS[0]}
    ticker_stop
    why="$(session_died "$rc" "$2")" || return 0

    # A window worth waiting for is one that has not opened yet. A `resetsAt`
    # already behind us describes a window that came and went, and waiting no
    # time at all for it is a retry with the pause taken out - which is how a
    # session that keeps reporting a stale limit turns into a hot loop that
    # spends the night starting sessions. Such a reset falls through to the
    # ladder instead, where the pauses and the budget both apply.
    reset="$(limit_reset_at "$2")"
    pause=0
    [ -z "$reset" ] || pause=$(( reset + 60 - $(date +%s) ))
    if [ "$pause" -gt 0 ] && [ $(( waited + pause )) -le $(( MAX_WAIT_HOURS * 3600 )) ]; then
      waited=$(( waited + pause ))
      note="$(printf 'waiting until %s, then picking %s back up' \
        "$(date -d "@$((reset + 60))" +%H:%M)" "$2")"
    elif unrecoverable "$why"; then
      break
    elif [ -n "${pauses[retries]-}" ]; then
      pause="${pauses[retries]}"
      retries=$((retries + 1))
      note="$(printf 'trying %s again in %dm (attempt %d of %d)' \
        "$2" $(( pause / 60 )) $((attempt + 1)) $(( ${#pauses[@]} + 1 )))"
    else
      break
    fi

    mv "$LOG_DIR/$2.jsonl" "$LOG_DIR/$2.attempt-$attempt.jsonl"
    echo
    echo "!! $why"
    echo "   $note"
    wait_for "$pause"
    echo "==> $2 (attempt $((attempt + 1)))"
  done
  {
    echo
    echo "!! session died on $2 - $why"
    [ "$attempt" -eq 1 ] || echo "   gave up after $attempt attempts"
    ! unrecoverable "$why" || echo "   No delay fixes this one, so nothing was retried."
    echo "   Nothing was halted and no ticket changed, so re-running resumes here:"
    echo "     $0 $TICKETS"
    echo "   transcript: $LOG_DIR/$2.jsonl"
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

# Why a ticket the loop skipped can never come up. `ready` answers only yes or
# no, and the reasons want different responses from a human.
why_stuck() {
  local status dep file
  status="$(status_of "$1")"
  [ "$status" = "todo" ] || { echo "left $status by an earlier run"; return; }
  for dep in $(deps_of "$1"); do
    file="$(ticket_for "$dep")"
    [ -n "$file" ] || { echo "depends on $dep, which does not exist"; return; }
    [ "$(status_of "$file")" = "done" ] || {
      echo "depends on $dep, which is $(status_of "$file")"; return; }
  done
  echo "ready, and skipped anyway - this is a bug in the driver"
}

# Everything the loop has no path to: a halt left behind by an earlier run, a
# `depends_on` naming a ticket nobody wrote, two tickets waiting on each other.
# `next_ticket` returns nothing for these exactly as it does for a queue that is
# finished, and the two must never be confused - unbuilt work reported as a
# delivered feature is the one failure an unattended driver must not produce.
unreachable() {
  local file
  for file in "$TICKETS"/[0-9]*.md; do
    [ -e "$file" ] || continue
    [ "$(status_of "$file")" = "done" ] || printf '%s\n' "$file"
  done
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
drain() {
  local ticket name stuck
  while ticket="$(next_ticket)"; do
    name="$(basename "$ticket" .md)"
    echo "==> [$(position)] $name"
    run_step build "$name" "/implement $ticket" || return 3
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

  stuck="$(unreachable)"
  [ -n "$stuck" ] || return 0
  {
    echo
    echo "!! nothing left the loop can build, and these are not done:"
    while read -r ticket; do
      printf '     %s - %s\n' "$(basename "$ticket" .md)" "$(why_stuck "$ticket")"
    done <<< "$stuck"
    echo "   A halt needs whatever blocked it resolved; a dependency that is"
    echo "   missing or circular needs /plan --refresh. Set status back to todo"
    echo "   on what should be rebuilt, then re-run:"
    echo "     $0 $TICKETS"
  } >&2
  return 1
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
  printf '/trace %s\n' "$SPEC_DIR"
  [ -z "$CHECKED_AT" ] || cat <<EOF
Scope this to the commits since $CHECKED_AT - the tickets the last pass's
reviews filed. Everything up to that commit traced clean and its criteria are
pinned by tests the suite still runs, so check the criteria these commits claim
and whether they broke anything built earlier.
EOF
  # Named rather than left to the skill's default, which is a `tickets/` beside
  # the working directory. This run's may be anywhere, and a gap filed where the
  # loop does not read is a gap nothing builds.
  printf 'File each gap as a ticket in %s, where this run keeps its tickets.\n' "$TICKETS"
}

critique_prompt() {
  local since="this branch's start"
  [ -z "$CHECKED_AT" ] || since="$CHECKED_AT"
  cat <<EOF
Run /critique over the diff from $since.
For each Blocker and Should-fix, file a remediation ticket in $TICKETS,
in the shape TICKET_FORMAT.md specifies.
Do not file nits - leave those in your report for /handover to triage.
EOF
}

echo "logs: $LOG_DIR"

# Bounded, because work the loop cannot converge on should reach a human.
for pass in $(seq "$MAX_PASSES"); do
  drain || exit $?

  echo "==> trace (pass $pass)"
  run_step review "trace-$pass" "$(trace_prompt)" || exit 3
  drain || exit $?

  echo "==> critique (pass $pass)"
  run_step review "critique-$pass" "$(critique_prompt)" || exit 3

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
run_step handover "handover" "/handover $SPEC_DIR" "$BRIEF_FILTER" || exit 3

# Handover's last step - promoting what must survive, then deleting the spec and
# the tickets - is the user's to authorise, and there was nobody here to ask.
echo
echo "Accepting the run means promoting what must survive and deleting the paper."
echo "That one needs you present: /handover $SPEC_DIR"
