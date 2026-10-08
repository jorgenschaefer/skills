# shellcheck shell=bash
#
# The project's checks, before any build and after every one.
#
# The project names its own command, on a `Check:` line in its CLAUDE.md, and
# the runner reads it before every run of the checks - a grep, not a session -
# so a build that declares one is held to it from its own commit on. Where there
# is no such line, finding the command is judgement - what the project gates a
# change on, which CI says better than the scripts do - so a session names it,
# once in a run. Running it is not, so the runner does, and believes the exit
# status rather than an account of it.
#
# Every build used to meet the same failures that were already on HEAD, prove
# each time by a different route that they were not its own, and in one case
# halt over them. A run that starts red does not start, and a build that is told
# the checks were green cannot mistake anything for someone else's.
#
# Once at the start, then on every build's commit: a build's account of its own
# checks is an account too.
#
# Sourced by run.sh, never run.

verify() {
  checks_command
  run_checks \
    || { tail -20 "$CHECKS_LOG" >&2; die "the checks fail before any build: $VERIFY - full output in $CHECKS_LOG"; }
  say "the checks pass"
}

checks_command() {  # -> VERIFY: the declared command at HEAD, else the session's
  # shellcheck disable=SC2016 # the backticks are Markdown's, matched literally
  VERIFY="$(git show HEAD:CLAUDE.md 2>/dev/null | sed -n 's/^Check: `\(.*\)`[[:space:]]*$/\1/p' | head -1)"
  [ -z "$VERIFY" ] || return 0
  [ -n "$ASKED_VERIFY" ] || find_checks
  VERIFY="$ASKED_VERIFY"
}

find_checks() {
  claude_through_limits verify "$(checks_question)" --session-id "$(new_session_id)" \
    --json-schema '{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}'
  [ $? = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait while finding the project's checks - run again once it has lifted"
  ASKED_VERIFY="$(jq -R -r 'fromjson? | select(.type == "result") | .structured_output.command // empty' "$LOG")"
  [ -n "$ASKED_VERIFY" ] || die "the session found no verification command, and CLAUDE.md declares none on a Check: line - see $LOG"
}

run_checks() {  # -> their exit status; CHECKS_LOG names their output
  CHECKS_LOG="$LOG_DIR/verify-$(date +%Y%m%d-%H%M%S).log"
  say "running the checks: $VERIFY"
  bash -c "$VERIFY" > "$CHECKS_LOG" 2>&1 9>&-
}
