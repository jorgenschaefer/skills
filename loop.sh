#!/usr/bin/env bash
#
# Drive one feature's ticket loop to completion, unattended.
#
#   ./loop.sh path/to/tickets
#
# Builds every ready ticket in dependency order, then checks the result against
# the spec, reviews it, and hands it back. Stops at the first halt it cannot
# answer itself: /implement-ticket records the reason rather than guessing past
# it.
#
# Exit codes say what kind of stop it was, because they want opposite responses:
#   1  the run ended somewhere other than clean: an agent halted, a build
#      changed a ratified workflow test it was not authorised to touch, the
#      queue has tickets nothing can reach, the spec check would not converge,
#      or the review left blockers or a disagreement standing. Re-running after
#      resolving it is the way back, up to MAX_RUNS times.
#   2  bad invocation - no ticket directory, not a repo, on main
#   3  a session died in a way the driver could neither wait out nor retry
#
# A halt on `drift` or a stale spec hash is the exception: the code or the spec
# moved under a ticket, and re-deriving the unbuilt tickets against what is
# actually there is mechanical rather than a decision. The driver does that once
# per run and carries on. Everything else it hands back.
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
# for the edits, commands and commits every ticket makes - and for starting and
# driving the app itself, which the acceptance step does and no ticket does - a `permissions.allow`
# in settings that already covers them. `claude -p` cannot prompt: what it
# cannot get approved it declines, and a ticket that could not write a file
# halts as if the work were impossible.
#
# A run takes hours, so progress on screen is the model's own narration - one
# short line per phase - and nothing else. Every step's full transcript is kept
# as JSON under the log directory printed at startup: the screen stays quiet,
# the detail stays on disk. The closing handover is the exception, printed in
# full, because that description is what the run was for - preceded by this
# script's own account of how the run ended, collected from the tickets rather
# than judged.

set -uo pipefail

# A shell completes a directory name with a slash on the end, so that is how
# this is invoked as often as not - and the path goes on to be pasted into
# every prompt an agent reads and into the command that resumes the run. Since
# `tickets//01-thing.md` costs its reader a moment satisfying themselves it is
# the file they think it is, the slash comes back off here rather than at each
# of the dozen places that print it. A lone `/` keeps its own: it is still a
# directory, a bad one to point this at, and the check further down is what
# says so.
TICKETS="${1:-tickets}"
while [ "${TICKETS%/}" != "$TICKETS" ] && [ -n "${TICKETS%/}" ]; do
  TICKETS="${TICKETS%/}"
done

TICK_MINUTES=3

# Not tunable on purpose. Reviews that keep filing work after two passes are not
# short of budget, they are failing to converge, and that is a thing to read
# rather than a thing to raise.
MAX_PASSES=2

# How many runs may end on the same paper before somebody has to say that is
# deliberate. A halt is resolved by a human and then by re-running, and each
# re-run starts the pass budget over - so without this, MAX_PASSES above is a
# ceiling in the same sense a door is locked when the window is open. Two, plus
# the run that reaches it, is enough to tell a bad night from work that is not
# converging. Also not tunable: raising it is the decision it exists to force.
MAX_RUNS=2

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
    plan)     printf -- '--model %s --effort high'   "$BUILD_MODEL" ;;
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

# The reason a build wrote into its `## Halt`. Two of the four are the code
# having moved under a ticket, which is a re-derivation rather than a decision.
halt_reason() {
  sed -n '/^## Halt/,$p' "$1" \
    | sed -n 's/^\*\*Reason:\*\*[[:space:]]*\([a-z][a-z-]*\).*/\1/p' | tail -1
}

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

# The same list as one line. What ended a run has to fit beside `state:` in the
# closing report, and a reader who is told only that something is unbuilt still
# has to go and find out what.
unreachable_names() {
  local file names=""
  while read -r file; do
    [ -n "$file" ] || continue
    names="${names:+$names, }$(basename "$file" .md)"
  done < <(unreachable)
  printf '%s\n' "$names"
}

# Recomputed each time: the end-of-run checks can file new tickets mid-run, so
# the denominator is what exists now, not what existed at the start.
position() {
  local total done_n
  total=$(ls "$TICKETS"/[0-9]*.md 2>/dev/null | wc -l)
  done_n=$(grep -lE '^status:[[:space:]]*done' "$TICKETS"/[0-9]*.md 2>/dev/null | wc -l)
  printf '%d/%d' "$((done_n + 1))" "$total"
}

# --- the workflow guard -------------------------------------------------------

# A journey ratified into tests/workflows/ is a promise every feature after it
# keeps green. A ticket may still have to change one - a rename reaches every
# caller - but only where somebody decided that before the run and wrote it into
# the ticket. Anything else is a build quietly editing the record of what the
# product does, which is the one change no review would think to question,
# because the test it would check against is the thing that moved.
#
# Post-commit on purpose. The work is committed and stays that way: reverting is
# a judgement about what the branch should contain, and a driver that reverted
# would be making it. This one halt is the driver's own, so its text is fixed -
# the reason, the commit, the paths - and there is no judgement in it.
# `:(top)` because the path is the repository's, not the working directory's,
# and the driver can be started from anywhere inside the tree.
WORKFLOWS=':(top)tests/workflows'

# What a build changed under there, committed or not. Uncommitted counts: a
# build that halts is told to leave its work in the tree, so an edit left there
# would otherwise be invisible here and swept into the next ticket's commit,
# where this would name the wrong ticket. quotePath off, because these files are
# named for journeys in the user's language and half of them are not ASCII.
workflows_touched() {
  { git -c core.quotePath=false diff --name-only "$1"..HEAD -- "$WORKFLOWS"
    git -c core.quotePath=false status --porcelain -- "$WORKFLOWS" | cut -c4-
  } | sort -u
}

# Read before the build, never after. The ticket is a file the build edits, so
# an authorisation read afterwards is one the build could have written itself -
# which is the agent deciding the question it was sent here to be checked on.
authorised_for_workflows() { grep -q '^## Workflow tests' "$1"; }

halt_for_workflows() {
  local ticket="$1" before="$2" paths="$3" sha
  sha="$(git log -1 --format=%h "$before"..HEAD -- "$WORKFLOWS")"
  [ -n "$sha" ] || sha="not committed - the change is still in the working tree"
  # Only the first `status:` line: a ticket body may quote frontmatter of its own.
  sed -i "0,/^status:.*/s//status: blocked/" "$ticket"
  {
    echo
    echo '## Halt'
    echo '**Reason:** unauthorised'
    echo 'This ticket changed a ratified workflow test, and it carried no'
    echo '`## Workflow tests` authorisation when the build started.'
    echo
    echo "**Commit:** $sha"
    echo '**Paths:**'
    printf '%s\n' "$paths" | sed 's/^/- /'
    echo
    echo 'Nothing was reverted; whether to keep the change is yours to decide. To'
    echo 'let it stand, add the authorisation to this ticket, set status back to'
    echo 'done, and re-run - the work itself already happened. This is not a'
    echo 're-plan.'
  } >> "$ticket"
  git add "$ticket" && git commit -qm "halt $(basename "$ticket" .md): workflow test changed without authorisation" && return 0
  echo "!! could not commit the halt - $ticket says it, but the tree is dirty" >&2
}

# --- the loop -----------------------------------------------------------------

# /implement-ticket sets `status` in the ticket before it finishes, and that is
# the signal - not the exit code, since a session can end without deciding anything.
# So an unfinished ticket means one of two things, and they want opposite
# responses: a dead session leaves work to resume, a halt leaves work to read.
# The mutation gate is the one part of a ticket that can need a change to the
# project itself - and a change to the project is a ticket here, never a side
# effect of building something else. Said in the prompt rather than left to the
# skill, because the skill cannot know that this run has a queue to file into.
implement_prompt() {
  cat <<EOF
/implement-ticket $1
The mutation gate runs on this ticket like any other. Where the project has no
mutation testing tool configured, say so in the ticket rather than installing
one: setting one up is a change to the project, and it comes back as a ticket
of its own.
EOF
}

drain() {
  local ticket name stuck before touched authorised reason
  while ticket="$(next_ticket)"; do
    name="$(basename "$ticket" .md)"
    echo "==> [$(position)] $name"
    before="$(git rev-parse HEAD)"
    authorised=no
    ! authorised_for_workflows "$ticket" || authorised=yes
    run_step build "$name" "$(implement_prompt "$ticket")" || return 3

    touched="$(workflows_touched "$before")"
    if [ -n "$touched" ] && [ "$authorised" = no ]; then
      halt_for_workflows "$ticket" "$before" "$touched"
      {
        echo
        stop_because "$name halted: it changed a ratified workflow test and carried no authorisation for that - $ticket records the halt"
        printf '%s\n' "$touched" | sed 's/^/     /'
        echo "   Nothing was reverted."
      } >&2
      return 1
    fi
    [ "$(status_of "$ticket")" = "done" ] && continue

    # Drift and a stale hash are both the same thing: what the ticket assumed
    # is no longer what the code or the spec says. Re-deriving the unbuilt
    # tickets against what is actually there is mechanical, and the skill has
    # documented it since before the driver existed - it simply never called it.
    # Once, though: a refresh that drifts again has found something a
    # re-derivation cannot fix, and a second one would only find it again.
    reason="$(halt_reason "$ticket")"
    case "$reason" in
      drift|stale-spec)
        if [ -z "$REFRESHED" ]; then
          REFRESHED=1
          # A stale hash means the spec moved, so what the earlier passes checked
          # was checked against a different one. The check reads the run whole
          # again rather than narrowing to what the last pass filed.
          [ "$reason" = drift ] || CHECKED_AT=""
          echo "==> $reason on $name - re-deriving the unbuilt tickets"
          run_step plan "refresh" "$(refresh_prompt)" || return 3
          # The refresh is a session that edits and commits like any other, and
          # nothing authorises it to touch a ratified journey.
          touched="$(workflows_touched "$before")"
          if [ -n "$touched" ]; then
            halt_for_workflows "$ticket" "$before" "$touched"
            stop_because "the re-derivation changed a ratified workflow test, and no ticket authorises one to - $ticket records the halt"
            return 1
          fi
          continue
        fi ;;
    esac

    # The session ran to the end, so it had every chance to say why it stopped.
    # If it didn't, the ticket cannot tell you and the transcript has to.
    {
      echo
      if grep -q '^## Halt' "$ticket"; then
        stop_because "$name halted${reason:+ on $reason} - $ticket records why"
        sed -n '/^## Halt/,$p' "$ticket"
      else
        stop_because "$name halted, left status '$(status_of "$ticket")' and wrote no ## Halt section - why it stopped is in its transcript and nowhere else"
      fi
      echo "   transcript: $LOG_DIR/$name.jsonl"
    } >&2
    return 1
  done

  stuck="$(unreachable)"
  [ -n "$stuck" ] || return 0
  {
    echo
    stop_because "nothing left the loop can build, and these are not done: $(unreachable_names)"
    while read -r ticket; do
      printf '     %s - %s\n' "$(basename "$ticket" .md)" "$(why_stuck "$ticket")"
    done <<< "$stuck"
    echo "   A halt needs whatever blocked it resolved; a dependency that is"
    echo "   missing or circular needs /spec-to-tickets --refresh. Set status"
    echo "   back to todo on what should be rebuilt, then re-run:"
    echo "     $0 $TICKETS"
  } >&2
  return 1
}

# Both end-of-run checks feed findings back as tickets, so a fix re-enters the
# same loop with the same TDD and review discipline instead of being patched by
# hand after everything else has been verified. /check-against-spec runs first
# and inside the pass loop: a gap it finds becomes code, and that code has to be
# checked like everything else. /critique stays a generic review skill - the
# prompt here, not the skill, knows this pipeline files tickets.
#
# CHECKED_AT is a baseline both prompts read. The check's first pass reads the
# whole run and a later pass reads only what the previous one filed, because
# re-reading twelve tickets' code to check three fixes is the same review twice.
# Narrowing is safe because pass 1 proves every criterion is pinned by a test
# that fails without it - once that holds, the green suite guards the old
# criteria rather than another read of them. It is cleared before /critique,
# which has had no passes and reads the branch whole, and set again between its
# two reads.
CHECKED_AT=""

# One per run. A refresh that drifts again has found something re-deriving
# cannot fix, and a second would only find it again.
REFRESHED=""

# Named rather than left to the skill, which was written for a human running it
# after a halt. Two things it cannot know: this run's ticket directory may hold
# tickets the end-of-run checks filed, which come from findings rather than from
# the spec and are nobody's to re-derive; and there is no user here to send back
# to /discovery.
refresh_prompt() {
  cat <<EOF
/spec-to-tickets --refresh $SPEC_DIR
Leave any ticket that a review filed during this run exactly as it is - it came
from a finding rather than from the spec, and re-deriving it would delete work
nothing else is tracking.
If the halt turns out to need a spec decision rather than a re-derivation, stop
and say so in the ticket rather than deciding it: there is nobody here to ask.
EOF
}

check_prompt() {
  printf '/check-against-spec %s\n' "$SPEC_DIR"
  [ -z "$CHECKED_AT" ] || cat <<EOF
Scope this to the commits since $CHECKED_AT - the tickets the last pass's
reviews filed. Everything up to that commit checked clean and its criteria are
pinned by tests the suite still runs, so check the criteria these commits claim
and whether they broke anything built earlier.
EOF
  # Named rather than left to the skill's default, which is a `tickets/` beside
  # the working directory. This run's may be anywhere, and a gap filed where the
  # loop does not read is a gap nothing builds.
  printf 'File each gap as a ticket in %s, where this run keeps its tickets.\n' "$TICKETS"
  printf 'Where a fix would reach tests/workflows/, say so in the ticket you file.\n'
  # The builds wrote down what they noticed and did not fix. Nothing else reads
  # those, and the agent that wrote one is gone.
  cat <<EOF
The done tickets in $TICKETS carry a Record of what each build decided, left
Unresolved, and left open. Read them as leads - places worth looking - and
verify each for yourself. None of them is a verdict you inherit.
Close with the verdict line the skill specifies, alone on the last line.
EOF
}

critique_prompt() {
  local since="this branch's start"
  [ -z "$CHECKED_AT" ] || since="$CHECKED_AT"
  cat <<EOF
Run /critique over the diff from $since.
For each Blocker and Should-fix, file a remediation ticket in $TICKETS,
in the shape TICKET_FORMAT.md specifies.
Do not file nits - leave those in your report, which this run keeps as a
transcript and names in its closing report.
Where a fix would reach tests/workflows/, say so in the ticket you file.
The done tickets there carry a Record of what each build decided, left
Unresolved, and left open. Read them as leads and verify each for yourself.
Close with the verdict line the skill specifies, alone on the last line.
EOF
}

# --- how the run ends ---------------------------------------------------------

# Three ways out, and they want different things from the reader: a clean run
# wants accepting, a halted one wants reading, and one with blockers standing
# wants deciding. Each is written down rather than inferred from an exit code,
# because the person who reads this was not here for any of it.
#
# The mechanical half of the closing text is the driver's: what state the run
# reached, what every build recorded, what the review counted, and the one
# command that comes next. The judgement half is /handover's, and both are
# produced on every path - the run that ended badly is the one whose reader
# most needs both.

# Every fork a build recorded and every finding it argued down, ordered by what
# it costs to have been wrong. The marks were written while the reasoning was
# live, so this only sorts; nothing is ranked here at the end.
run_entries() {
  local file name
  for file in "$TICKETS"/[0-9]*.md; do
    [ -e "$file" ] || continue
    name="$(basename "$file" .md)"
    # Only under `## Record`, and only the two marked lists: a ticket quoting the
    # format in its body would otherwise contribute the example. An entry runs
    # until the next one, so a wrapped line keeps its reasoning and its
    # file:line - the half that makes a fork judgeable.
    awk -v t="$name" '
      function flush() { if (e != "") { print r "\t" t "\t" e; e = "" } }
      /^## /  { flush(); rec = ($0 == "## Record"); list = 0 }
      !rec    { next }
      /^\*\*(Decisions|Unresolved):\*\*/ { flush(); list = 1; next }
      /^\*\*/ { flush(); list = 0 }
      !list   { next }
      /^- \*\*\[(high|medium|low)\]\*\*/ {
        flush()
        r = /\[high\]/ ? 1 : (/\[medium\]/ ? 2 : 3)
        e = $0; sub(/^- \*\*\[[a-z]+\]\*\* */, "", e); next
      }
      /^[[:space:]]+[^[:space:]]/ { if (e != "") { c = $0; sub(/^[[:space:]]+/, "", c); e = e " " c }; next }
      { flush() }
      END { flush() }
    ' "$file"
  done | sort -n -k1,1 -s | awk -F'\t' \
      '{ print "  " ($1 == 1 ? "[high]  " : $1 == 2 ? "[medium]" : "[low]   ") "  " $2 "  " $3 }'
}

# Both end-of-run checks close with a fixed line so this can read a count
# instead of spending a second agent on the first one's prose. All four fields
# or none: a line that half matches is a step that did not close the way it was
# asked to, and reading three of its numbers would be worse than reading none of
# them. Singular tolerated on the way in, though the skills ask for the plural
# always: strictness belongs in the instruction, forgiveness in the thing that
# reads it.
#
# The two count different things because they judge different things. The review
# counts defects by what they cost; the acceptance counts criteria by what it
# could establish about them - and its last field is the one nothing else in the
# run can say, since a criterion checked by reading is a criterion nobody drove.
VERDICT_RE='^VERDICT: [0-9]+ blockers?, [0-9]+ should-fix, [0-9]+ nits?, [0-9]+ standing disagreements?$'
CHECK_VERDICT_RE='^VERDICT: [0-9]+ gaps? filed, [0-9]+ gaps? reported, [0-9]+ standing disagreements?, [0-9]+ criteria checked on evidence$'
verdict_line() {
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' \
     "$LOG_DIR/$1.jsonl" 2>/dev/null | grep -E "$2" | tail -1
}

# The last acceptance pass's line, and the reason where there was none. Kept
# here rather than passed down: every path out of the run prints it, including
# the ones that end before the review has anything to say.
CHECK_VERDICT=""

# Why the run ended where it did, kept for the two readers who were not there
# when it was said. `state:` names the ending and this names the cause, and on
# the stops nothing counts they are different answers: work filed with no pass
# left to build it ends a run whose every verdict reads zero, and a box that
# says only `requires human review` is then asking for a decision it never
# names. Set at the point that knows, because nowhere later does.
STOP_REASON=""

# Says it once and keeps it. The `!!` on the way past is for whoever is still
# watching; a run takes hours, and by the ending it has scrolled - so the same
# sentence goes into the report below and into the /handover prompt, which
# otherwise gets the state and is left to re-derive the rest if it thinks to
# look. Word each one to survive on its own: it reaches its reader with no line
# above it and no line below.
stop_because() {
  STOP_REASON="$1"
  echo "!! $1" >&2
}

report() {
  local state="$1" verdict="$2" entries
  entries="$(run_entries)"
  echo
  echo "── the run ──────────────────────────────────────────────"
  echo "state: $state"
  [ -z "$STOP_REASON" ] || echo "reason: $STOP_REASON"
  [ -z "$CHECK_VERDICT" ] || echo "acceptance: $CHECK_VERDICT"
  [ -z "$verdict" ] || echo "review: $verdict"
  ! ls "$LOG_DIR"/critique-*.jsonl >/dev/null 2>&1 \
    || echo "the review in full, nits included: $LOG_DIR/critique-*.jsonl"
  if [ -n "$entries" ]; then
    echo
    echo "what the builds decided and left standing:"
    printf '%s\n' "$entries"
  fi
  echo
}

# What the run's own half of the brief cannot supply. The skill is told not to
# restate the mechanical half, and the cause is collected from the tickets like
# the rest of it - so handing the reason over as a line to lead with would ask
# the skill for the one thing it is told not to do, and get an aside instead.
# What the reader wants from this half is not the cause again but what it means:
# a run that stopped on unbuilt work still has a branch somebody has to read,
# and whether the rest of it stands without that work is judgement nothing here
# can collect.
handover_prompt() {
  printf '/handover %s\n' "$SPEC_DIR"
  printf "The run's state: %s. Write the pull request description for it.\n" "$1"
  [ -z "$STOP_REASON" ] || cat <<EOF
Why it stopped: $STOP_REASON
That cause is printed on the driver's page beside yours, so do not restate it.
Say what it means for the branch: what a reviewer can rely on, what is not there
yet, and whether the rest of it stands without that.
EOF
}

# The closing brief, on every path. What is left after it is the one command
# that follows from the state the run reached.
finish_run() {
  local state="$1" verdict="${2:-}"
  # Written here rather than at startup: what counts is how a run ended, and
  # this is the only place that is known.
  if [ "$state" = clean ]; then rm -f "$ATTEMPTS"; else echo "$((ended + 1))" > "$ATTEMPTS"; fi
  report "$state" "$verdict"
  echo "==> handover"
  # A handover that dies does not change what the run reached, and the half above
  # is already printed. Say so and let the state stand, rather than reporting the
  # death as the ending.
  run_step handover "handover" "$(handover_prompt "$state")" "$BRIEF_FILTER" \
    || echo "!! no pull request description was written - the report above stands" >&2
  echo
  case "$state" in
    clean)
      echo "Accepting deletes the spec and the tickets, and that is yours to do:"
      echo "  ./accept.sh $SPEC_DIR" ;;
    *)
      echo "Resolve what stands above, then re-run - it drains whatever that"
      echo "produced and checks and reviews the new commits:"
      echo "  $0 $TICKETS" ;;
  esac
}

# drain stops for two different reasons and they are not both endings: 1 is a
# decision somebody has to read, 3 is a session that died and left the work
# exactly where it was, which is a run to resume rather than one to hand over.
drain_or_end() {
  local rc=0
  drain || rc=$?
  [ "$rc" -eq 0 ] && return 0
  [ "$rc" -eq 1 ] || exit "$rc"
  finish_run halted
  exit 1
}

# What the last run on this paper ended as, counted against the paper rather
# than the branch: two of the five runs that routed around MAX_PASSES were the
# same work under a new branch name. Only an ending is counted - a session that
# died decided nothing and re-running it resumes rather than restarts.
ATTEMPTS="$STATE/loop/attempts/$(printf '%s' "$SPEC_DIR" | md5sum | cut -c1-12)"
mkdir -p "$(dirname "$ATTEMPTS")" ||
  { echo "cannot keep this run's count in $ATTEMPTS" >&2; exit 2; }
ended=$(cat "$ATTEMPTS" 2>/dev/null || echo 0)
case "$ended" in *[!0-9]*|'') ended=0 ;; esac

case "${ANOTHER_RUN:-}" in
  ''|1) ;;
  *) echo "ANOTHER_RUN is set or unset, not '$ANOTHER_RUN'" >&2; exit 2 ;;
esac

if [ "$ended" -gt 0 ]; then
  echo "attempt $((ended + 1)) on $SPEC_DIR - $ended run(s) ended without finishing it"
  if [ "$ended" -ge "$MAX_RUNS" ]; then
    if [ -z "${ANOTHER_RUN:-}" ]; then
      {
        echo "!! $ended runs have already ended on this work without finishing it, and"
        echo "   each one started the pass budget over. Another is a decision somebody"
        echo "   should make rather than a default. If it is deliberate:"
        echo "     ANOTHER_RUN=1 $0 $TICKETS"
      } >&2
      exit 1
    fi
    echo "ANOTHER_RUN is set: going past the ceiling of $MAX_RUNS deliberately"
  fi
fi

echo "logs: $LOG_DIR"

# The spec check belongs in the loop: a gap it finds becomes code, and that code
# has to be checked like everything else. The review does not - it reads the run
# whole, once, and re-reads only what it filed itself. Passes 2 and 3 of a review
# inside this loop spent their budget re-reading a test-only diff.
for pass in $(seq "$MAX_PASSES"); do
  drain_or_end

  echo "==> spec check (pass $pass)"
  run_step review "spec-check-$pass" "$(check_prompt)" || exit 3
  # Each pass overwrites the last. An earlier pass's gaps are built and checked
  # again by the pass after it, so the only line that still stands at the end is
  # the one from the pass that filed nothing.
  CHECK_VERDICT="$(verdict_line "spec-check-$pass" "$CHECK_VERDICT_RE")"

  if ! next_ticket >/dev/null; then
    checks_clean=1
    break
  fi
  CHECKED_AT="$(git rev-parse HEAD)"
  echo "==> the check filed work; draining again"
done

if [ -z "${checks_clean:-}" ]; then
  stop_because "the spec check filed work again after $MAX_PASSES passes, so it would not converge - what it filed last is unbuilt"
  finish_run "requires human review"
  exit 1
fi

# The acceptance is read the same way as the review below, and for the same
# reason: what a check refuses to file reaches nobody otherwise. A gap it did
# file is not that - the loop above built it and the pass after it checked the
# result - so what stands here is what it would not file, and a pass that closed
# with nothing at all. Neither ends the run here: the review still reads the
# branch and still files what it finds, and a human ruling on one disagreement
# wants that reading done rather than skipped.
#
# `check_stands` is not a flag: the `acceptance:` line above carries a verdict or nothing, and a
# sentence where a verdict belongs is a field doing a second job badly. What
# stopped the run belongs on the reason line with the rest of the causes, where
# it can be read beside them and composed with them.
check_stands=""
check_standing="$(sed -n 's/.*, \([0-9]*\) standing disagreements*, .*/\1/p' <<< "$CHECK_VERDICT")"
if [ -z "$CHECK_VERDICT" ]; then
  check_stands="no verdict line - the acceptance did not say"
elif [ "$check_standing" -gt 0 ]; then
  check_stands="the acceptance left $check_standing disagreement(s) it would not reopen"
fi

# The check narrowed its later passes to what the previous one filed. The review
# has had no passes: it reads the branch whole, so that narrowing is not its.
CHECKED_AT=""
echo "==> critique"
run_step review "critique-1" "$(critique_prompt)" || exit 3
verdict="$(verdict_line critique-1 "$VERDICT_RE")"

# What it filed is built, and then it reads that and nothing else.
if next_ticket >/dev/null; then
  CHECKED_AT="$(git rev-parse HEAD)"
  drain_or_end
  echo "==> critique (over what it filed)"
  run_step review "critique-2" "$(critique_prompt)" || exit 3
  verdict="$(verdict_line critique-2 "$VERDICT_RE")"
fi

# A blocker that survived being filed, built and re-read is not work the loop
# can converge on, and a disagreement either check refused to reopen is not work
# at all. All of them are for a human, and none makes the run a failure.
blockers="$(sed -n 's/^VERDICT: \([0-9]*\) blockers.*/\1/p' <<< "$verdict")"
standing="$(sed -n 's/.*, \([0-9]*\) standing disagreements*$/\1/p' <<< "$verdict")"
if next_ticket >/dev/null; then
  # Filed by the last read, with nothing after it to build them. Unbuilt work
  # reported as a delivered feature is the one failure this must not produce.
  # Named, because every count on the page reads zero here: the review found
  # what it found and then filed it, and the ticket is the whole of what a
  # reader is being asked to pick up.
  stop_because "the review filed work on its second read and no pass is left to build it: $(unreachable_names)"
  finish_run "requires human review" "$verdict"
  exit 1
elif [ -z "$verdict" ]; then
  stop_because "no verdict line - the review did not say"
  finish_run "requires human review"
  exit 1
elif [ "${blockers:-0}" -gt 0 ] || [ "${standing:-0}" -gt 0 ] || [ -n "$check_stands" ]; then
  # All three can stand at once and the reason line is one line, so it says all
  # of them. Which one ended the run is the question the counts above cannot
  # answer: a reader looking at a clean review and a standing acceptance has to
  # correlate two lines to find out, and this is the line that saves them that.
  reasons=""
  [ "${blockers:-0}" -eq 0 ] || reasons="$blockers blocker(s) survived being filed, built and re-read"
  [ "${standing:-0}" -eq 0 ] || reasons="${reasons:+$reasons; }the review left $standing disagreement(s) it would not reopen"
  [ -z "$check_stands" ]     || reasons="${reasons:+$reasons; }$check_stands"
  stop_because "$reasons"
  finish_run "requires human review" "$verdict"
  exit 1
fi

finish_run clean "$verdict"
