# shellcheck shell=bash
# shellcheck disable=SC2154
#
# One session: launching `claude`, carrying it through usage limits, and
# reading what its event stream says - what it did, whether a limit stopped it,
# and what it cost.
#
# Sourced by run.sh, never run. Reads its `LOG_DIR`, `TOKENS`, `files` and the
# limit settings, sets `LOG`, and calls its `say` and `field`, and `brief`.

session() {  # ticket, --session-id or --resume, session id, prompt to resume with -> 0 ran, EX_LIMIT gave up on a limit, anything else failed
  local rc prompt="${4:-$(brief "$1")}"
  say "session on $(basename "$1")"
  claude_through_limits "$(basename "$1" .md)" "$prompt" "$2" "$3"; rc=$?
  say "session ended, exit $rc, ticket says status: $(field "$1" status)"
  return $rc
}

# One session, carried through every usage limit that stops it. A limit is not a
# failure of the work - it stops a session wherever it happens to be, often with
# a build done and its review half run - so the session is waited out to the
# reset the limit names and then resumed, not started over. Each round gets its
# own log, and LOG names the last one.
#
# Returns the session's exit status, or EX_LIMIT when the limit outlasted
# MAX_WAITS: that is nobody's failure, and the caller must not charge it to the
# work.
EX_LIMIT=75
claude_through_limits() {  # log name, prompt, --session-id or --resume, session id, claude's own options...
  local name="$1" prompt="$2" how="$3" id="$4" reset until rc waits=0
  shift 4
  while :; do
    LOG="$LOG_DIR/$name-$(date +%Y%m%d-%H%M%S)$([ "$waits" = 0 ] || printf -- '-resumed-%s' "$waits").jsonl"
    say "full log in $LOG"
    claude_run "$LOG" "$how" "$id" "$prompt" "$@"; rc=$?
    printf '%s %s\n' "$name" "$(context_read "$LOG")" >> "$TOKENS"
    reset="$(limit_reset "$LOG")"
    [ -n "$reset" ] || return "$rc"
    waits=$((waits + 1))
    [ "$waits" -le "$MAX_WAITS" ] \
      || { echo "gave up waiting out the limit after $MAX_WAITS waits" >&2; return "$EX_LIMIT"; }
    if [ "$reset" -gt 0 ]; then until=$(( reset + LIMIT_MARGIN )); else until=$(( $(date +%s) + WAIT_SECONDS )); fi
    say "usage limit - waiting until $(date -d "@$until" '+%a %H:%M') ($waits of $MAX_WAITS)"
    sleep_until "$until"
    how=--resume
    prompt="You were stopped by a usage limit, which has now reset. Carry on with the task from where you stopped; redo any step the limit cut short, a subagent included."
  done
}

# Nobody is here to approve a tool call, and `claude -p` cannot prompt: what it
# cannot get approved it declines, and a session that could not run the tests
# halts as if the work were impossible. The first live run of this script halted
# exactly that way. So the tools a build needs are named here rather than left
# to whatever the operator has in settings.
#
# `Agent` is the subagent tool, and it is what makes the review real:
# `/implement` reviews its own diff by spawning `critique` in a session that did
# not write it, and there is no review pass here to fall back on. Without it the
# build declines the spawn and every ticket reaches `done` unreviewed.
#
# `Monitor` is how a session waits on checks it put in the background: `sleep`
# is refused, and without it a build that backgrounded its test run had no way
# to wait for the result.
#
# The same list is every built-in tool a session has, not only the ones it may
# use unasked: each call carries the definition of every tool there is, and one
# run made some 850 calls. `ToolSearch` stays because without it the MCP tools
# are not deferred and their definitions go into every call whole. Playwright is
# kept, for testing in the browser; the claude.ai connectors are not.
TOOLS=(Bash Edit Write Read Glob Grep Skill Agent Monitor TaskStop ToolSearch WebFetch WebSearch)
claude_run() {  # log, --session-id or --resume, session id, prompt, claude's own options... -> claude's exit status
  ENABLE_CLAUDEAI_MCP_SERVERS=false \
  claude -p --output-format stream-json --verbose --permission-mode acceptEdits \
    --tools "${TOOLS[@]}" --allowedTools "${TOOLS[@]}" mcp__playwright \
    "$2" "$3" "${@:5}" -- "$4" </dev/null 2>&1 | tee "$1" | narrate
  return "${PIPESTATUS[0]}"
}

# A session's event stream, cut to one line per tool call, remark and result.
# Subagents are left out - their spawn shows, their insides are in the log.
# Lines that are not JSON are the CLI talking rather than the session, and are
# passed through as they are.
narrate() {
  jq -R --unbuffered -r '
    def line(n): tostring | split("\n")[0] | .[0:n];
    (fromjson? // {type: "raw", line: .})
    | select(.parent_tool_use_id == null)
    | if .type == "raw" then "    \(.line)"
      elif .type == "assistant" then
        .message.content[]?
        | if .type == "tool_use" then
            "    \(.name): \(.input | (.description // .file_path // .pattern // .skill // .command // "") | line(100))"
          elif .type == "text" then "    > \(.text | line(120))"
          else empty end
      elif .type == "rate_limit_event" then
        select(.rate_limit_info.status == "rejected")
        | "    ! usage limit, resets \(.rate_limit_info.resetsAt // 0 | strflocaltime("%a %H:%M"))"
      elif .type == "result" then
        "    = \(.subtype)\(if .is_error then " (error)" else "" end), \(.num_turns // "?") turns, $\(.total_cost_usd // 0 | . * 100 | round / 100)"
      else empty end'
}

# Read off the events the CLI writes, never its wording: the message changed
# once already, and a runner matching the old one relaunched a limited session
# three times in four seconds and halted the ticket as exhausted. A session that
# still finished was not stopped, whatever was rejected on the way - a subagent's
# window, or one that overage paid for.
limit_reset() {  # log -> the epoch the limit lifts, 0 where it named none; nothing when there was no limit
  jq -R -s -r '[split("\n")[] | fromjson? | select(.parent_tool_use_id == null)]
    | if any(.[]; .type == "result" and .is_error == false) then empty
      else [.[] | if .type == "rate_limit_event" and .rate_limit_info.status == "rejected" then .rate_limit_info.resetsAt // 0
                  elif .error == "rate_limit" then 0
                  else empty end]
           | max // empty end' "$1"
}

# `sleep` counts only the time the machine is awake, so one long sleep across a
# suspend runs on past its end by however long the machine was suspended - a run
# once slept on well past the reset it was waiting for. Short sleeps against the
# clock notice the time that passed.
sleep_until() {  # epoch
  local left
  while left=$(( $1 - $(date +%s) )); [ "$left" -gt 0 ]; do
    sleep $(( left < 60 ? left : 60 ))
  done
}

new_session_id() {
  cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen | tr '[:upper:]' '[:lower:]'
}

# The token log: what each ticket cost, to find out where a slice gets too big
# to build. It is counted in context read, because a session re-reads its whole
# context on every turn, and a long session pays for its size again each time.
# Subagents are counted apart: a review is one. One line per session round,
# `name main subagents`, in a file per change that outlives a run started again.
#
# The CLI writes a message once per content block, each copy carrying the whole
# message's usage, so a message is counted once by its id.
context_read() {  # log -> "main subagents"
  jq -R -s -r '[split("\n")[] | fromjson? | select(.type == "assistant" and .message.usage != null)]
    | unique_by(.message.id)
    | map({sub: (.parent_tool_use_id != null),
           n: (.message.usage | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))})
    | "\(map(select(.sub | not) | .n) | add // 0) \(map(select(.sub) | .n) | add // 0)"' "$1"
}

token_summary() {
  local t name
  [ -f "$TOKENS" ] || return 0
  printf '\ncontext read, per ticket:\n'
  for name in $(for t in "${files[@]}"; do basename "$t" .md; done) review; do
    awk -v n="$name" '$1 == n { m += $2; s += $3; seen = 1 }
      END { if (seen) printf "  %-30s main %12d  subagents %12d  total %12d\n", n, m, s, m + s }' "$TOKENS"
  done
}
