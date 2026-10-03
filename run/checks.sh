# shellcheck shell=bash
# shellcheck disable=SC2154
#
# The project's checks, before any build and after every one.
#
# Finding the command is judgement - what the project gates a change on, which
# CI says better than the scripts do - so a session names it. Running it is not,
# so the runner does, and believes the exit status rather than an account of it.
#
# Every build used to meet the same failures that were already on HEAD, prove
# each time by a different route that they were not its own, and in one case
# halt over them. A run that starts red does not start, and a build that is told
# the checks were green cannot mistake anything for someone else's.
#
# Once at the start, then on every build's commit: a build's account of its own
# checks is an account too.
#
# Sourced by run.sh, never run. Reads its `LOG_DIR`, sets `VERIFY` and
# `CHECKS_LOG`, and calls its `say`, `die` and `end_run`, and the session's
# `claude_through_limits`.

verify() {
  find_checks
  run_checks \
    || { tail -20 "$CHECKS_LOG" >&2; die "the checks fail before any build: $VERIFY - full output in $CHECKS_LOG"; }
  say "the checks pass"
}

find_checks() {
  claude_through_limits verify "$(checks_question)" --session-id "$(new_session_id)" \
    --json-schema '{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}'
  [ $? = "$EX_LIMIT" ] && end_run 1
  VERIFY="$(jq -R -r 'fromjson? | select(.type == "result") | .structured_output.command // empty' "$LOG")"
  [ -n "$VERIFY" ] || die "the session found no verification command - see $LOG"
}

run_checks() {  # -> their exit status; CHECKS_LOG names their output
  CHECKS_LOG="$LOG_DIR/verify-$(date +%Y%m%d-%H%M%S).log"
  say "running the checks: $VERIFY"
  bash -c "$VERIFY" > "$CHECKS_LOG" 2>&1 9>&-
}
