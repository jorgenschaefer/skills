# shellcheck shell=bash
#
# The project's checks, before any build, after every one and after the final
# review.
#
# A project's checks are a fast check, which every build runs, and a slow check,
# for the tests that can't be made fast. The project names them on the
# `Fast check:` and `Slow check:` lines of its CLAUDE.md - an older `Check:` line
# with no `Fast check:` line is the fast check - and the runner reads them
# before every run of the checks - a grep, not a session - so a build that
# declares one is held to it from its own commit on. Where no line names a fast
# check, finding the command is judgement - what the project gates a change on,
# which CI says better than the scripts do - so a session names it, once in a
# run. A slow check nobody declared is none. Running them is not judgement, so
# the runner does, and believes the exit status rather than an account of it.
#
# Every build used to meet the same failures that were already on HEAD, prove
# each time by a different route that they were not its own, and in one case
# halt over them. A run that starts red does not start, and a build that is told
# the checks were green cannot mistake anything for someone else's.
#
# Once at the start, then on every build's commit and on the final review's: a
# session's account of its own checks is an account too. The runner runs both
# each time, so the sessions run only the fast one.
#
# Sourced by run.sh, never run.

verify() {
  local log
  if ! run_checks; then
    for log in "${RED_LOGS[@]}"; do tail -20 "$log" >&2; done
    die "the run does not start: $RED"
  fi
  say "the checks pass"
}

run_checks() {  # -> 0 where every check is green; else RED says which is not, and RED_LOGS holds their output
  RED="" RED_LOGS=()
  if ! read_checks; then
    RED="CLAUDE.md at $(git rev-parse --short HEAD) has both a \`Check:\` and a \`Fast check:\` line, and only one may say what every build runs - remove \`Check:\`"
    return 1
  fi
  run_check fast "$FAST_CHECK"
  [ -z "$SLOW_CHECK" ] || run_check slow "$SLOW_CHECK"
  [ -z "$RED" ]
}

# Two lines that both name what every build runs would leave it to chance which
# one does, so a CLAUDE.md with both is refused rather than read.
read_checks() {  # -> FAST_CHECK and SLOW_CHECK as HEAD declares them, else the session's fast check; fails on both Check: and Fast check:
  local claude
  claude="$(git show HEAD:CLAUDE.md 2>/dev/null)"
  SLOW_CHECK="$(check_line 'Slow check' <<< "$claude")"
  FAST_CHECK="$(check_line 'Fast check' <<< "$claude")"
  if [ -n "$FAST_CHECK" ]; then
    [ -z "$(check_line Check <<< "$claude")" ]
    return
  fi
  FAST_CHECK="$(check_line Check <<< "$claude")"
  [ -n "$FAST_CHECK" ] && return 0
  [ -n "$ASKED_FAST_CHECK" ] || find_checks
  FAST_CHECK="$ASKED_FAST_CHECK"
}

check_line() {  # what the line names -> the command on the first such line on stdin
  # shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
  sed -n "s/^$1: \`\(.*\)\`[[:space:]]*\$/\1/p" | head -1
}

find_checks() {
  claude_through_limits verify "$(checks_question)" --session-id "$(new_session_id)" \
    --json-schema '{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}'
  [ $? = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait while finding the project's checks - run again once it has lifted"
  ASKED_FAST_CHECK="$(jq -R -r 'fromjson? | select(.type == "result") | .structured_output.command // empty' "$LOG")"
  [ -n "$ASKED_FAST_CHECK" ] || die "the session found no verification command, and CLAUDE.md names no fast check on a Fast check: or Check: line - see $LOG"
}

run_check() {  # fast or slow, its command -> its exit status; a red one is added to RED and RED_LOGS
  local log
  # Unique, because a session is told to read it: a green run in the same second
  # wrote over the red one it had been pointed at.
  log="$(mktemp "$LOG_DIR/$1-check-$(date +%Y%m%d-%H%M%S)-XXXX.log")"
  say "running the $1 check: $2"
  bash -c "$2" > "$log" 2>&1 9>&- && return 0
  RED+="${RED:+; }the $1 check, \`$2\`, is red - its output is in $log"
  RED_LOGS+=("$log")
  return 1
}
