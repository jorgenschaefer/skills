#!/usr/bin/env bash
#
# The tests for the two scripts: the driver, and accepting what it produced.
#
#   tests/run.sh
#
# Plain bash, because a repo of Markdown skills and two scripts should not have
# to install a test framework to check them. Each case builds a throwaway repo,
# puts `stub-claude` on PATH as `claude`, and runs loop.sh or accept.sh against
# it, so what is under test is behaviour and not internals.
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
  git -C "$dir" init -q -b main
  git -C "$dir" config user.email loop@test
  git -C "$dir" config user.name loop
  : > "$dir/README.md"
  # The suite's own scaffolding is not part of the repo under test, and a case
  # about a clean tree should not have to know it is there. Anchored, so a case
  # whose own paths happen to be named these is still visible.
  printf '/bin/\n/tmp/\n/state/\n' > "$dir/.gitignore"
  git -C "$dir" add README.md .gitignore
  git -C "$dir" commit -qm "first"
  git -C "$dir" checkout -qb feature
  mkdir -p "$dir/tickets" "$dir/tmp" "$dir/bin"
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
  : > "$WORK/calls"; : > "$WORK/prompts"; : > "$WORK/argv"
  OUT="$(cd "$WORK" && env \
    PATH="$WORK/bin:$PATH" TMPDIR="$WORK/tmp" XDG_STATE_HOME="$WORK/state" \
    STUB_PLAN="$WORK/plan" STUB_CALLS="$WORK/calls" \
    STUB_PROMPTS="$WORK/prompts" STUB_ARGV="$WORK/argv" \
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
# The flags one step was run with. Calls and flags are recorded in lockstep, so the
# nth call's flags are the nth line - a step is asked for by the prompt that
# names it rather than by its position in the run.
argv_for()       { local n; n="$(grep -n -- "^$1" "$WORK/calls" | head -1 | cut -d: -f1)"
                   [ -n "$n" ] && sed -n "${n}p" "$WORK/argv"; }
expect_argv()    { grep -q -- "$2" <<< "$(argv_for "$1")" && ok "$3" \
                   || bad "$3" "no '$2' in what '$1' was run as:
$(argv_for "$1")"; }
expect_prompt()  { grep -q -- "$2" <<< "$(prompt_for "$1")" && ok "$3" \
                   || bad "$3" "no '$2' in the '$1' prompt:
$(prompt_for "$1")"; }
expect_no_prompt() { grep -q -- "$2" <<< "$(prompt_for "$1")" \
                   && bad "$3" "found '$2' in the '$1' prompt:
$(prompt_for "$1")" || ok "$3"; }
expect_log()     { local m=("$LOGS"/$1)
                   [ -e "${m[0]}" ] && ok "$2" || bad "$2" "no $1 in $LOGS
$(ls "$LOGS" 2>&1)"; }
expect_file()    { [ -s "$1" ] && ok "$2" || bad "$2" "no $1
$(ls "$(dirname "$1")" 2>&1)"; }
expect_no_file() { [ -e "$1" ] && bad "$2" "found $1" || ok "$2"; }
expect_ticket()  { grep -q -- "$2" "$WORK/${TICKET_DIR:-tickets}/$1.md" && ok "$3" \
                   || bad "$3" "no '$2' in $1:
$(cat "$WORK/${TICKET_DIR:-tickets}/$1.md")"; }
# The last commit in $WORK: what it says, and what it did to which files. Two
# questions, asked apart, so a ticket id in the file list cannot answer for one
# in the message.
commit_msg()     { git -C "$WORK" log -1 --format='%B'; }
commit_diff()    { git -C "$WORK" show --name-status --format= HEAD; }
expect_commit()  { grep -q -- "$1" <<< "$(commit_msg)" && ok "$2" || bad "$2" "no '$1' in:
$(commit_msg)"; }
expect_no_commit() { grep -q -- "$1" <<< "$(commit_msg)" && bad "$2" "found '$1' in:
$(commit_msg)" || ok "$2"; }
# Which of two strings the run printed first, for the report's ordering.
expect_order()   { local a b
                   a="$(grep -n -- "$1" <<< "$OUT" | head -1 | cut -d: -f1)"
                   b="$(grep -n -- "$2" <<< "$OUT" | head -1 | cut -d: -f1)"
                   [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ] && ok "$3" \
                     || bad "$3" "'$1' at ${a:-nowhere}, '$2' at ${b:-nowhere}
$OUT"; }
# A path that is in the history with nothing uncommitted against it - for the
# halt the driver writes over work it deliberately leaves standing.
expect_committed() { git -C "$WORK" log --oneline -- "$1" | grep -q . \
                     && [ -z "$(git -C "$WORK" status --porcelain -- "$1")" ] \
                     && ok "$2" || bad "$2" "$1 is not committed
$(git -C "$WORK" status --porcelain -- "$1")"; }
expect_diff()    { grep -q -- "$1" <<< "$(commit_diff)" && ok "$2" || bad "$2" "no '$1' in:
$(commit_diff)"; }
expect_no_diff() { grep -q -- "$1" <<< "$(commit_diff)" && bad "$2" "found '$1' in:
$(commit_diff)" || ok "$2"; }

# A reset a minute ago: past the window, still two seconds of waiting once the
# driver adds its slack.
just_reset() { echo $(( $(date +%s) - 58 )); }
hours_off()  { echo $(( $(date +%s) + $1 * 3600 )); }

# --- a run nothing interrupts -------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a clean run builds the ticket, checks it and hands over"
expect_calls 4 "a clean run calls out once per step"

# --- the run's evidence -------------------------------------------------------

# Transcripts outlive their run and accumulate where the next run can read them.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
first="$LOGS"
expect_out "logs: $WORK/state/loop/" "a run's transcripts land under the state directory"
expect_no_out "logs: $WORK/tmp" "a run's transcripts are not left in the temp directory"

cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a second run over a drained queue finishes"
expect_out "logs: $WORK/state/loop/" "the next run logs beside the last one"
expect_file "$first/01-thing.jsonl" "an earlier run's transcripts survive the next run"
expect_no_file "$LOGS/01-thing.jsonl" "a run never writes into an earlier run's directory"

# A run that cannot log loses exactly what it exists to leave behind, and reads
# its own missing transcript as a dead session - so it stops before the first
# step rather than eight attempts later.

workspace 01-thing
drive 0 XDG_STATE_HOME= HOME=
expect_rc 2 "nowhere to keep the transcripts is a bad invocation"
expect_out "XDG_STATE_HOME" "the stop names what to set"
expect_calls 0 "a run with nowhere to log never starts a step"

: > "$WORK/not-a-directory"
drive 0 XDG_STATE_HOME="$WORK/not-a-directory"
expect_rc 2 "a log directory that cannot be made stops the run"
expect_calls 0 "a run that cannot log never starts a step"

# --- a usage limit ------------------------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
rate-limited-session.jsonl 1 -
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
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
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive "$(just_reset)"
expect_rc 0 "a limit that exits 0 is waited out just the same"
expect_calls 5 "a limit that exits 0 is retried too"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
warned.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
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
reviewed.jsonl 0 -
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
reviewed.jsonl 0 -
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
clean.jsonl 0 -
EOF
drive 0 RETRY_DELAYS="0 0"
expect_rc 1 "a ticket left unfinished by a whole session is a halt"
expect_out "halted on 01-thing" "a halt names the ticket"
expect_calls 2 "a halt is a decision, so it is never retried - only handed over"

# --- a queue that cannot be drained -------------------------------------------

workspace 01-thing 02-other
ticket 02-other todo 01
ticket 01-thing blocked ""
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a ticket nothing can reach is a stop, not a finished run"
expect_calls 1 "an unreachable queue reaches the handover and nothing before it"
expect_out "01-thing" "the stop names the ticket that is stuck"
expect_out "02-other" "the stop names what is stuck behind it"

workspace 01-thing
ticket 01-thing todo 09
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a dependency that does not exist is a stop"
expect_out "does not exist" "a missing dependency says what is missing"

workspace 01-thing 02-other
ticket 01-thing todo 02
ticket 02-other todo 01
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "two tickets waiting on each other are a stop"
expect_calls 1 "a cycle reaches nothing but the handover"

# --- how a run ends -----------------------------------------------------------

# Every path out of a run produces the same two things: the driver's account of
# what happened, which is mechanical, and the handover's, which is judgement.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 record
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a run with nothing standing ends clean"
expect_out "state: clean" "the run says which of the three ways it ended"
expect_out "./accept.sh" "and how to accept it"
expect_calls 4 "one build, one check, one critique, one handover"
expect_out "rejection reasons have no length ceiling" "the report carries what the builds decided"
expect_out "the status page's two branches" "and what they left standing"
expect_order "no length ceiling" "named the flag" "sorted by what it costs to be wrong"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a run that halts is a run that ended, not one that stopped"
expect_out "state: halted" "it says so"
expect_calls 2 "and still gets its handover - that reader needs it most"
expect_out "$LOOP" "the report says what resumes it"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 record
clean.jsonl 0 -
critique-blockers.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "blockers left standing are a run a human has to rule on"
expect_out "state: requires human review" "the third state says what is wanted"
expect_out "2 blockers" "the verdict line is read rather than the prose around it"
expect_out "re-run" "and the way back is written down"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 record
clean.jsonl 0 -
critique-standing.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a disagreement the review refused to reopen also wants a human"
expect_out "state: requires human review" "even with nothing filed and nothing blocking"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 record
clean.jsonl 0 -
critique-mute.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a review that never closed with its verdict line is not a pass"
expect_out "no verdict line" "the report says the review did not say"

# The spec check is the loop's; the review is not. It reads the whole run once
# after the last drain, then only what it filed itself.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 file
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
SHA="$(git -C "$WORK" rev-parse HEAD~1)"
expect_rc 0 "a gap the check files is built inside the pass loop"
expect_calls 6 "and the review still runs once at the end"
expect_prompt /check-against-spec "Scope this to the commits since $SHA" \
  "the check's second pass reads only what the first one filed"
expect_prompt "Run /critique" "from this branch's start" \
  "and the review still reads the whole branch"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
clean.jsonl 0 file
clean.jsonl 0 done
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
SHA="$(git -C "$WORK" rev-parse HEAD~1)"
expect_rc 0 "work the review files is built and then re-reviewed"
expect_calls 6 "which is one more build and one more review, not another pass"
expect_prompt "Run /critique" "over the diff from $SHA" \
  "the second read covers only what the first one filed"

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
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
TICKET_DIR=docs/feature/tickets drive 0
unset TICKET_DIR
expect_rc 0 "the ticket directory need not be ./tickets"
expect_prompt /check-against-spec docs/feature/tickets "the spec check is told where to file a gap"
expect_prompt "Run /critique"     docs/feature/tickets "critique is told where to file a blocker"
expect_prompt /check-against-spec "Read them as leads" "the check is pointed at what the builds left behind"
expect_prompt "Run /critique"     "Read them as leads" "the review is pointed there too"
expect_prompt "Run /critique"     "Close with the verdict line" "the review is asked to close with a countable verdict"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
handover.jsonl 0 -
EOF
drive 0 REVIEWS=code
expect_rc 0 "a run asks for no less than the skills' full discipline"
expect_no_prompt /implement-ticket "quality review" "no run trades a review away for time"
expect_prompt /implement-ticket "say so in the ticket rather than installing" \
  "a build that finds the mutation tooling missing files it rather than fixing it"
expect_no_prompt /implement-ticket "authorised" "no run authorises a build to change the project"

# What each step is run as. A review reads code a different model wrote, and the
# steps are not alike enough to think equally hard about.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_argv /implement-ticket "--model opus" "a ticket is built by the build model"
expect_argv /check-against-spec "--model sonnet" "the check runs on a model that did not write the code"
expect_argv "Run /critique" "--model sonnet" "so does the review"
expect_argv /handover "--model opus" "the handover is not a review and stays on the build model"
expect_argv /implement-ticket "--effort high" "building a ticket gets the budget for it"
expect_argv "Run /critique" "--effort high" "so does reading a diff adversarially"
expect_argv /handover "--effort medium" "writing up finished work does not"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0 BUILD_MODEL=sonnet REVIEW_MODEL=opus
expect_rc 0 "a run may name the two models itself"
expect_argv /implement-ticket "--model sonnet" "the build runs on the model the run named"
expect_argv /check-against-spec "--model opus" "and the reviews on the other one"

workspace 01-thing
drive 0 REVIEW_MODEL=opus
expect_rc 2 "a review by the model that wrote the code is a bad invocation"
expect_out "must differ" "the stop says what was wrong"
expect_calls 0 "a run with no second opinion never starts a step"

# --- the handover reaches the screen ------------------------------------------

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
handover.jsonl 0 -
EOF
drive 0
expect_rc 0 "a run ends with the handover"
expect_out "status page" "the handover brief is printed whole, not just its first line"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
handover.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_out "Closing out the run" "a building step still narrates its first line"
expect_no_out "status page" "a building step is still only its narration"

# --- the workflow-test guard --------------------------------------------------

# A journey ratified into tests/workflows/ is a promise every later feature
# keeps, so a build that rewrites one is rewriting the record of what the
# product does. It is allowed only where somebody decided that before the run.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 workflow
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a build that changes a workflow test with no authorisation stops the run"
expect_calls 2 "the run stops at that ticket and hands over"
expect_out "tests/workflows/" "the stop names what was touched"
expect_ticket 01-thing "^## Halt" "the driver writes the halt into the ticket"
expect_ticket 01-thing "tests/workflows/journey.test" "the halt names the paths"
expect_ticket 01-thing "^status: blocked" "and leaves the ticket blocked"
expect_ticket 01-thing "^\*\*Reason:\*\* unauthorised" "the halt says which halt it is"
expect_ticket 01-thing "^\*\*Commit:\*\*" "and which commit made the change"
expect_commit "workflow test" "the driver commits its own halt, so the tree stays clean"
expect_committed tests/workflows/journey.test "the change itself is left standing"

# The permission is the plan's, not the build's: a ticket that writes its own is
# an agent deciding what it was sent to be checked on.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 self-authorised
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a build cannot authorise itself on the way past"
expect_ticket 01-thing "^status: blocked" "it is halted like any other"

# A ticket a review filed mid-run is guarded exactly the same.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 file
clean.jsonl 0 workflow
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a ticket a later pass filed is guarded too"
expect_calls 4 "the run stops on it and hands over"

workspace 01-thing
printf -- '---\nstatus: todo\ndepends_on: []\n---\n\n# 01-thing\n\n## Workflow tests\n- tests/workflows/journey.test - the rename reaches it\n' > "$WORK/tickets/01-thing.md"
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 workflow
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a ticket authorised at planning time changes one and the run goes on"
expect_calls 4 "the authorised ticket costs no extra step"

# --- what a run recovers from -------------------------------------------------

# Drift is the code moving under a ticket, which is a re-derivation rather than
# a decision - so the driver does it, once, and hands back anything else.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 drift
clean.jsonl 0 refresh
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a drifted ticket is re-derived and the run goes on"
expect_calls 6 "the refresh costs one step"
expect_prompt "/spec-to-tickets --refresh" "$WORK" "the driver asks for it by name and where"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 drift
clean.jsonl 0 refresh
clean.jsonl 0 drift
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "drifting again after a refresh is a halt, not a second refresh"
expect_calls 4 "one refresh per run, then a human"

expect_argv "/spec-to-tickets --refresh" "--model opus" "the refresh is planning, not reviewing"
expect_argv "/spec-to-tickets --refresh" "--effort high" "and gets the budget for it"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 stale-spec
clean.jsonl 0 refresh
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a spec that moved under the tickets is re-derived too"
expect_calls 6 "at the same cost"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 blocked
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "a blocked halt is nobody's to re-derive"
expect_calls 2 "so it is not refreshed, only handed over"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 mystery
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "and neither is a test failing for reasons nobody knows"
expect_calls 2 "which is a diagnosis, not a re-derivation"

# Re-running is how a human resolves a halt, and it resets the pass budget. A
# ceiling routed around without anybody deciding to is not a ceiling.

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "the first run halts"

cat > "$WORK/plan" <<'EOF'
errored.jsonl 0 -
EOF
drive 0
expect_rc 3 "a session that dies decides nothing"
expect_out "attempt 2" "it is still a re-run onto work that did not finish"

cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 1 "and the run after it is still attempt 2, not 3"
expect_out "attempt 2" "because only an ending counts"
drive 0
expect_rc 1 "a third attempt on work two runs could not finish stops for a decision"
expect_calls 0 "and starts nothing"
expect_out "ANOTHER_RUN" "the stop says how to say it was deliberate"
drive 0 ANOTHER_RUN=1
expect_out "attempt 3" "which then runs, and says which attempt it is"
expect_out "deliberately" "and says the ceiling was passed on purpose"

workspace 01-thing
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 done
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_rc 0 "a clean run"
cat > "$WORK/plan" <<'EOF'
clean.jsonl 0 -
reviewed.jsonl 0 -
clean.jsonl 0 -
EOF
drive 0
expect_no_out "attempt" "clears the count, so the next run is a first run again"

# --- the skills' shared files ---------------------------------------------------

# Five skills read the ticket format and each carries its own copy, because a
# skill installs alone and cannot reach into a sibling's directory. Identical is
# the whole point, and a five-way edit is easy to make four-way by accident.

copies=("$HERE"/../*/TICKET_FORMAT.md)
[ "${#copies[@]}" -eq 5 ] \
  && ok "every skill that reads a ticket has the format beside it" \
  || bad "every skill that reads a ticket has the format beside it" "${copies[*]}"
[ "$(md5sum "${copies[@]}" | awk '{print $1}' | sort -u | wc -l)" = 1 ] \
  && ok "the ticket format's copies are byte-identical" \
  || bad "the ticket format's copies are byte-identical" "$(md5sum "${copies[@]}")"

# --- accepting a run ----------------------------------------------------------

# Deleting the spec and the tickets is the pipeline's one irreversible act and
# the only one that destroys the record of what was asked, so accept.sh refuses
# rather than trusts, and a refusal leaves the tree exactly as it found it.

# A repo holding a finished run's paper: a spec beside the tickets it produced,
# every ticket done, and nothing uncommitted.
accepted() {
  workspace "$@"
  mkdir -p "$WORK/docs/feature"
  mv "$WORK/tickets" "$WORK/docs/feature/tickets"
  sed -i 's/^status:.*/status: done/' "$WORK/docs/feature/tickets"/*.md
  printf '# Reviewer rejection\n' > "$WORK/docs/feature/reviewer-rejection.md"
  git -C "$WORK" add docs
  git -C "$WORK" commit -qm "the run's paper"
}

# Runs accept.sh in $WORK against $1, `docs/feature` by default. Leaves its
# output in $OUT and its exit code in $RC.
accept() {
  OUT="$(cd "$WORK" && timeout 60 bash "$HERE/../accept.sh" "${1-docs/feature}" 2>&1)"
  RC=$?
}

accepted 01-thing 02-other
accept
expect_rc 0 "a finished run is accepted"
expect_no_file "$WORK/docs/feature/tickets" "the tickets are gone"
expect_no_file "$WORK/docs/feature/reviewer-rejection.md" "the spec is gone"
expect_commit "^Accept reviewer rejection$" "the commit is named for the feature"
expect_commit "^  01-thing$" "the commit says which tickets the run built"
expect_diff "^D.docs/feature/tickets/02-other.md" "the deletion is what it commits"
expect_no_diff "^[AM]" "it adds and changes nothing"

accepted 01-thing
git -C "$WORK" checkout -q main && git -C "$WORK" merge -q feature
accept
expect_rc 2 "a run is not accepted on the default branch"
expect_out "refusing to accept on main" "the refusal says where it was asked to"
expect_file "$WORK/docs/feature/reviewer-rejection.md" "a refusal deletes nothing"
expect_no_commit "^Accept" "a refusal commits nothing"

WORK="$(mktemp -d)"; WORKSPACES+=("$WORK")
mkdir -p "$WORK/docs/feature/tickets"
accept
expect_rc 2 "a directory outside a repository is not a run"
expect_out "no run's paper here" "the refusal says what is missing"

accepted 01-thing 02-other
sed -i 's/^status: done/status: todo/' "$WORK/docs/feature/tickets/02-other.md"
git -C "$WORK" commit -qam "send one back"
accept
expect_rc 2 "a run with work left in it is not accepted"
expect_out "02-other" "the refusal names the ticket that is not done"
expect_file "$WORK/docs/feature/tickets/01-thing.md" "a refusal deletes no ticket either"

accepted 01-thing
: > "$WORK/uncommitted"
accept
expect_rc 2 "a dirty tree is not accepted"
expect_out "commit or stash" "the refusal says how to get past it"

accepted 01-thing
git -C "$WORK" rm -rq docs/feature/tickets && git -C "$WORK" commit -qm "no tickets"
accept
expect_rc 2 "a spec with no tickets beside it is not a run"
expect_out "no ticket directory" "the refusal says what is missing"
expect_file "$WORK/docs/feature/reviewer-rejection.md" "and deletes the spec anyway"

accepted 01-thing
git -C "$WORK" rm -q docs/feature/tickets/01-thing.md
git -C "$WORK" commit -qm "the last ticket goes"
mkdir -p "$WORK/docs/feature/tickets"
accept
expect_rc 2 "a ticket directory with no tickets in it is not a run"
expect_out "nothing to accept" "the refusal says what it found"

accepted 01-thing
accept ""
expect_rc 2 "accept.sh has to be told which run"
expect_out "usage" "it says how it wants to be called"

accepted 01-thing
git -C "$WORK" checkout -q --detach
accept
expect_rc 2 "a detached HEAD is nowhere to accept a run"
expect_file "$WORK/docs/feature/reviewer-rejection.md" "a refusal there deletes nothing either"

accepted 01-thing
printf 'scratch/\n' >> "$WORK/.gitignore"
git -C "$WORK" commit -qam "ignore scratch"
mkdir -p "$WORK/docs/feature/scratch"
printf 'notes\n' > "$WORK/docs/feature/scratch/notes.md"
accept
expect_rc 2 "a file git ignores under the spec is not left behind by deleting around it"
expect_out "scratch" "the refusal names what it cannot delete"
expect_file "$WORK/docs/feature/reviewer-rejection.md" "and the spec stays until someone decides"

accepted 01-thing
accept .
expect_rc 2 "the repository itself is not one run's paper"
expect_out "whole repository" "the refusal says what it was pointed at"
expect_file "$WORK/docs/feature/reviewer-rejection.md" "a refusal at the root deletes nothing"

accepted 01-thing
printf '# Notes\n' > "$WORK/docs/feature/notes.md"
git -C "$WORK" add docs && git -C "$WORK" commit -qm notes
accept
expect_rc 2 "two markdown files beside the tickets is a guess this will not make"
expect_out "notes.md" "the refusal names what it found instead"

# ------------------------------------------------------------------------------

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
