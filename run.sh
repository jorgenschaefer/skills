#!/usr/bin/env bash
#
# Drive a ticket directory to completion with nobody watching.
#
#   ./run.sh changes/<slug>/tickets
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. A session cannot
# enforce a budget it is spending, cannot reset a claim it is holding when it
# dies, and cannot wait out a limit that has already stopped it.
#
# The loop per ticket: claim it, build it, and either finish it or send it
# back. The runner owns `doing`, and a session writes `done` or `halted` and
# nothing else. A `done` is the session's claim, which the runner checks against
# the commit - a claim with no commit behind it is sent back - so nothing reaches
# `done` unbuilt, and a run killed at any point is started again from whatever
# the ticket files and the claim record say.
#
# There is no review pass per ticket. `/implement` spawns its own reviewer in a
# subagent that did not write the code, which is the property a second session
# used to buy, and a second review of a reviewed commit reviews a review. What
# no ticket's review can see - what lies between the tickets - gets one review
# of the whole change at the end.

set -uo pipefail

TICKETS="${1:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # builds of one ticket before it is exhausted
WAIT_SECONDS="${WAIT_SECONDS:-300}"   # after a usage limit that names no reset time
LIMIT_MARGIN="${LIMIT_MARGIN:-120}"   # past a limit's reset time, before carrying on
MAX_WAITS="${MAX_WAITS:-8}"           # limits in a row before the run gives up
VERIFY=""                             # the checks, once they have passed - never from outside

die() { printf '%s\n' "$*" >&2; exit 2; }
say() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }

# --- refusals, before anything is launched

[ -n "$TICKETS" ] || die "usage: run.sh changes/<slug>/tickets"
[ -d "$TICKETS" ] || die "no ticket directory: $TICKETS"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"
# The branch refusal just above passes by accident in a repository with no
# commits: it reads the branch that has nothing on it yet. The HEAD check below
# would survive there - `rev-parse HEAD` prints the literal `HEAD` when it
# fails, so a build still moves it and a claim still does not - but a
# correctness check resting on a command echoing its own argument back is not
# one to leave standing.
git rev-parse HEAD >/dev/null 2>&1 \
  || die "no commits here: the branch refusal passes in an empty repository, and the build check would rest on rev-parse echoing HEAD back - commit something first"

branch="$(git rev-parse --abbrev-ref HEAD)"
case "$branch" in
  main|master) die "refusing to run on $branch: a run belongs on a branch of its own" ;;
esac

command -v claude >/dev/null || die "no claude on PATH: the runner drives sessions, it does not do the work"

# One runner per repository. A second one started beside a live run took over
# its claim and resumed the session it was running. The lock is held on a
# descriptor every session inherits, so a session that outlives a killed runner
# still holds it and is still building; what that session starts does not
# inherit it, so a server left running does not.
LOCK="$(git rev-parse --absolute-git-dir)/run.lock"
exec 9>"$LOCK"
flock -n 9 || die "another run, or a session one started, is still working this repository (pids:$(exec 9>&-; fuser "$LOCK" 2>/dev/null | tr -s ' ' '\n' | grep -vx "$$" | tr '\n' ' ')) - let it finish or stop it, then start again"

shopt -s nullglob
files=()
for f in "$TICKETS"/*.md; do
  # A ticket is a file with criteria behind it. Anything else in the directory
  # is someone's notes, and reading it as a ticket fails every pass.
  grep -q '^criteria:' "$f" && files+=("$f") || printf 'ignoring %s: not a ticket\n' "$f" >&2
done
[ "${#files[@]}" -gt 0 ] || die "no tickets in $TICKETS"

field()     { sed -n "2,/^---$/s/^$2: *//p" "$1" | head -1; }
# Scoped to the frontmatter: a ticket about the ticket format has lines in its
# body that look exactly like fields, and this repo's tickets are full of them.
set_field() { sed -i "2,/^---$/s|^$2:.*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# Where each session's full event stream goes. Inside the git directory, so a
# session that commits everything it sees cannot commit its own transcript.
LOG_DIR="${LOG_DIR:-$(git rev-parse --absolute-git-dir)/run-logs}"
mkdir -p "$LOG_DIR"

# Which session a claim was given, and where HEAD stood, for a runner started
# again after being killed. Named for the ticket's whole path: every change has
# a 1-one.md, and one's record resumed another's session. It stays until the
# runner has settled the ticket, not only until the session returns: a `done`
# the runner was killed before checking is a claim to check, not a result.
claim_record() {  # ticket -> the file
  printf '%s/%s.claim' "$LOG_DIR" "$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$1" | tr / _)"
}
release() { rm -f "$(claim_record "$1")"; }

claimed() {  # the tickets in flight - at `doing`, on record, or `done` unchecked - one per line
  local t
  for t in "${files[@]}"; do
    if [ "$(field "$t" status)" = doing ] || [ -f "$(claim_record "$t")" ] || unchecked_done "$t"; then
      printf '%s\n' "$t"
    fi
  done
}

# A `done` in the working tree that HEAD does not carry: a session's claim the
# runner never got to check, whatever became of its record.
unchecked_done() {  # ticket
  [ "$(field "$1" status)" = "done" ] && [ "$(field <(git show "HEAD:./$1" 2>/dev/null) status)" != "done" ]
}

# Whatever is lying around uncommitted is someone's, and a session cannot tell
# it from its own work: it lints it, reviews it, and carves it out of every
# diff. Untracked files count - an untracked mockup failed the lint of every
# session in a whole run. The ticket files are not counted: what is uncommitted
# in them is the runner's own bookkeeping - a claim, a counter, a halt it wrote
# - and a run started again reads it as the state to carry on from.
#
# Except beside a claim. A ticket at `doing` when no runner is running is one a
# killed runner was building, and what is uncommitted is that session's work,
# which the loop carries on with. One runner leaves one claim; more than one is
# not something this script did.
not_tickets=(':/')
for t in "${files[@]}"; do not_tickets+=(":!$t"); done
dirty="$(git status --porcelain -- "${not_tickets[@]}")"
case "$(claimed | wc -l)" in
  0) [ -z "$dirty" ] || die "refusing to run on a dirty tree: commit or remove what is here first"$'\n'"$dirty" ;;
  1) [ -z "$dirty" ] || say "carrying on with $(claimed), taking this as its session's work:"$'\n'"$dirty" ;;
  *) die "more than one ticket is claimed, which one runner cannot leave behind - put back all but one:"$'\n'"$(claimed)" ;;
esac

# The criteria a ticket quotes, and the criteria CRITERIA.md carries, in the
# one shape both can be compared in.
quoted()   { grep -o '^> \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
claims()   { printf '%s %s\n' "$(field "$1" closes)" "$(field "$1" advances)" | grep -o 'AC-[0-9]\+' | sort -u; }
declared() { grep -o '^- \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
text_of()  { # file, id -> the criterion as written, marker stripped
  awk -v id="$2" '
    index($0, "- **" id "**") == 1 || index($0, "> **" id "**") == 1 { found = 1; print; next }
    found && (/^[->] \*\*AC-/ || /^#/ || /^$/) { exit }
    found { print }
  ' "$1" | sed 's/^[[:space:]]*[->][[:space:]]*//' | tr '\n' ' ' | sed 's/  */ /g; s/ *$//'
}
# Whether a ticket comes after another, directly or by way of others.
comes_after() {  # ticket, slug of the other
  local target="$2" dep seen=" " todo more
  read -ra todo <<< "$(field "$1" after | tr ',' ' ')"
  while [ "${#todo[@]}" -gt 0 ]; do
    dep="${todo[0]}"; todo=("${todo[@]:1}")
    [ "$dep" = "$target" ] && return 0
    [[ "$seen" == *" $dep "* ]] && continue
    seen+="$dep "
    [ -f "$TICKETS/$dep.md" ] && read -ra more <<< "$(field "$TICKETS/$dep.md" after | tr ',' ' ')" && todo+=(${more[@]+"${more[@]}"})
  done
  return 1
}
# A nudge has no id, so it is found by its words: one per line, whitespace
# flattened, as a `- ` item in CRITERIA.md and as a `> ` quote in a ticket.
nudges_of() {  # file, the marker its nudges start with
  awk -v m="$2" '
    function flush() { if (item != "") print item; item = "" }
    /^#/ { flush(); in_nudges = ($0 == "## Nudges"); next }
    !in_nudges { next }
    /^[[:space:]]*$/ { flush(); next }
    index($0, m) == 1 { if (m == "-") flush(); sub(/^[->][[:space:]]*/, "") }
    { gsub(/[[:space:]]+/, " "); sub(/^ /, ""); sub(/ $/, ""); item = item (item == "" ? "" : " ") $0 }
    END { flush() }
  ' "$1"
}

# --- the drift pre-flight
#
# Before each pass, in both directions. A session never reads CRITERIA.md and a
# committed ticket is revisited by nobody but a re-slice, so this is the only place the two can
# be found to disagree - and the report has to say which way, because an edit
# upstream and a slicing that lost something need different answers.

preflight() {
  local t criteria id dep nudge problems="" culprit="" all_criteria=() closers=()
  for t in "${files[@]}"; do
    # Resolved beside the tickets/ directory, not from the working directory:
    # the frontmatter says `CRITERIA.md` and means the one this slicing came
    # from, whatever the runner was invoked from.
    criteria="$(dirname "$TICKETS")/$(field "$t" criteria)"
    if [ ! -f "$criteria" ]; then
      problems+="$(basename "$t"): names $criteria, which is not there"$'\n'
      [ -n "$culprit" ] || culprit="$t"
      continue
    fi
    [[ " ${all_criteria[*]-} " == *" $criteria "* ]] || all_criteria+=("$criteria")
    # A deleted ticket leaves the ones after it waiting on something that will
    # never be done, and the loop would only say so once it had run out of work.
    for dep in $(field "$t" after | tr ',' ' '); do
      if ! grep -qs '^criteria:' "$TICKETS/$dep.md"; then
        problems+="$(basename "$t"): after: names $dep, which is not a ticket"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    for id in $(quoted "$t"); do
      # A criterion deleted upstream and one reworded need the same re-slice,
      # but the person reading the halt should not have to diff to tell which.
      if [ -z "$(text_of "$criteria" "$id")" ]; then
        problems+="$(basename "$t"): $id is gone from $criteria"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      elif [ "$(text_of "$t" "$id")" != "$(text_of "$criteria" "$id")" ]; then
        problems+="$(basename "$t"): $id no longer matches $criteria"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    # Coverage is counted from the frontmatter and the builder reads the quote.
    for id in $(claims "$t"); do
      if ! quoted "$t" | grep -qx "$id"; then
        problems+="$(basename "$t"): claims $id and does not quote it"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    for id in $(quoted "$t"); do
      if ! claims "$t" | grep -qx "$id"; then
        problems+="$(basename "$t"): quotes $id and neither closes nor advances it"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    while IFS= read -r nudge; do
      if ! nudges_of "$criteria" - | grep -qxF -- "$nudge"; then
        problems+="$(basename "$t"): a nudge it quotes is not in $criteria word for word: $nudge"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done < <(nudges_of "$t" '>')
  done
  # Once per CRITERIA.md, not once per ticket: this direction asks something of
  # the directory as a whole, and asking it inside the loop above reported a
  # lost criterion once for every ticket that had not lost it.
  for criteria in ${all_criteria[@]+"${all_criteria[@]}"}; do
    # Exactly one ticket closes each criterion - the one after which it is
    # true, and which writes its test - and it comes after every ticket that
    # advances it, or that test is red for want of work still to run.
    for id in $(declared "$criteria"); do
      closers=()
      for t in "${files[@]}"; do
        field "$t" closes | grep -qw -- "$id" && closers+=("$t")
      done
      case "${#closers[@]}" in
        0) problems+="$criteria: $id is closed by no ticket"$'\n'
           [ -n "$culprit" ] || culprit="${files[0]}" ;;
        1) for t in "${files[@]}"; do
             field "$t" advances | grep -qw -- "$id" || continue
             comes_after "${closers[0]}" "$(basename "$t" .md)" && continue
             problems+="$(basename "${closers[0]}"): closes $id and does not come after $(basename "$t" .md), which advances it"$'\n'
             [ -n "$culprit" ] || culprit="${closers[0]}"
           done ;;
        *) problems+="$criteria: $id is closed by more than one ticket: $(for t in "${closers[@]}"; do basename "$t" .md; done | tr '\n' ' ' | sed 's/ $//')"$'\n'
           [ -n "$culprit" ] || culprit="${closers[0]}" ;;
      esac
    done
  done
  if [ -n "$problems" ]; then
    printf 'drift - the tickets and CRITERIA.md disagree:\n%s' "$problems" >&2
    # The stop is named in the ticket, not only on someone's terminal - nobody is
    # watching the terminal, which is the whole premise. The first offender
    # carries it, because that is where a person will look; where the offence
    # belongs to the directory rather than to one ticket, the first ticket does.
    #
    # Carried alongside the message rather than parsed back out of it. Reading
    # the ticket off the text meant two of the three messages named no ticket
    # the `-f` guard could find, and both fell through it silently.
    [ -n "$culprit" ] && halt "$culprit" drift \
      "CRITERIA.md and this ticket no longer agree - re-slice the unbuilt tickets with /criteria-to-tickets"
    return 1
  fi
}

# --- one session

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

# --- the token log
#
# What each ticket cost, to find out where a slice gets too big to build. It is
# counted in context read, because a session re-reads its whole context on every
# turn, and a long session pays for its size again each time. Subagents are
# counted apart: a review is one. One line per session round, `name main
# subagents`, in a file per change that outlives a run started again.
TOKENS="$LOG_DIR/$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$(dirname "$TICKETS")" | tr / _).tokens"

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
claude_run() {  # log, --session-id or --resume, session id, prompt, claude's own options... -> claude's exit status
  claude -p --output-format stream-json --verbose --permission-mode acceptEdits \
    --allowedTools Bash Edit Write Read Glob Grep Skill Agent TodoWrite Monitor \
    "$2" "$3" "${@:5}" -- "$4" </dev/null 2>&1 | tee "$1" | narrate
  return "${PIPESTATUS[0]}"
}

# What a session left in the tree besides the ticket files, which are the
# runner's bookkeeping - another ticket's halt among them, which went into the
# stash with a later build's leftovers and came back out as a fresh budget.
left_behind() {  # -> git status lines, empty for none
  git status --porcelain -- "${not_tickets[@]}"
}

# The next attempt is told the checks were green when the run started, which is
# only true of a tree without this one's leftovers in it. Stashed rather than
# dropped: it may be most of a build.
put_aside() {  # ticket, attempt
  [ -n "$(left_behind)" ] || return 0
  git stash push -q -u -m "run.sh: $(basename "$1") attempt $2, left uncommitted" -- "${not_tickets[@]}"
  say "what it left uncommitted is in the stash"
}

# Committed, and once: a halt is the one thing a run leaves for a person, and
# left uncommitted it was every later session's someone else's change - and a
# drift nobody had resolved yet was halted again on every start.
halt() {  # ticket, kind, why
  [ "$(field "$1" status)" != halted ] || return 0
  printf '\n## Halt\n\n%s - %s\n' "$2" "$3" >> "$1"
  set_field "$1" status halted
  commit_halt "$1" "$2"
}

# A session's own halt is committed the same way, and only the ticket file:
# whatever the session left besides is its unfinished build, for the person who
# settles the halt to keep or throw away.
commit_halt() {  # ticket, kind
  git diff --quiet HEAD -- "$1" && return 0
  git commit -q -m "Halt $(basename "$1" .md)${2:+: $2}" -- "$1" >/dev/null \
    || echo "could not commit the halt in $1" >&2
}

# The kind a session named, read off the first line of its halt in whatever
# shape it wrote it; empty where that line names none of the three.
halt_kind() {  # ticket
  sed -n '/^## Halt$/,$p' "$1" | sed -n '2,$p' | sed '/^[[:space:]]*$/d' | head -1 \
    | grep -o -m1 -w 'blocked\|undecided\|mystery' | head -1
}

# The ticket protocol is stated here rather than in the skill. `/implement` is
# the generic build skill - it fires when anyone asks for code and knows nothing
# about tickets, statuses or halt kinds. A runner that needs those has to say so
# itself, which is the cost of the skill staying general.
session() {  # ticket, --session-id or --resume, session id, prompt to resume with -> 0 ran, EX_LIMIT gave up on a limit, anything else failed
  local rc prompt="${4:-$(brief "$1")}"
  say "session on $(basename "$1")"
  claude_through_limits "$(basename "$1" .md)" "$prompt" "$2" "$3"; rc=$?
  say "session ended, exit $rc, ticket says status: $(field "$1" status)"
  return $rc
}

brief() {  # ticket -> the prompt a fresh session on it starts from
  local prompt t built=""
  # By its absolute path: a session runs wherever the runner was started, and
  # one in a subdirectory looked for a relative path at the repository root.
  prompt="Use /implement on the work described in $(realpath "$1").

The project's checks are \`$VERIFY\`, and they passed when this run started. A check that fails now failed because of this build.

Nothing wakes you once your turn ends: the run moves on, and whatever you left running in the background is killed. Wait for background work with Monitor, or run the checks in the foreground.

That file is the whole brief. Its \`## Done when\` is the definition of done - not the diff, not what you would have built, not what CRITERIA.md probably meant. Its \`## Nudges\` are how it was agreed this gets built: follow them, and where you depart from one, say why. Its \`## Not here\` names what a neighbouring ticket owns, and building it is two tickets building the same code. Its \`## Plan\` is how it was decided this gets built; where you find the plan wrong, say so rather than following it off a cliff.

A criterion the frontmatter's \`closes:\` names is true once this ticket is built: write its test first and red, where its user acts - the action, the route, the form - and make it pass. One under \`## Toward\` is built only in part here, and closed by a later ticket: prove the narrower behaviour \`## Done when\` states, and leave the whole criterion to the ticket that closes it.

Do not open the CRITERIA.md the frontmatter names. The ticket quotes what it needs, and going upstream is how a ticket quietly becomes a different one.

When the criteria are green and the project's checks pass, write the ticket's \`## Record\` - which test proves each criterion it closes, which proves the part it advances, and the command you ran - and in it a \`### Left standing\`: review findings you did not fix and why, checks you did not run, where you departed from the plan, and where you departed from a nudge, with the reason. Nobody reads your closing message in an unattended run; Left standing is printed at the end of the run and read at acceptance. Set \`status: done\` in the frontmatter and commit the code and the ticket file together, in one commit.

If you cannot proceed, append a \`## Halt\` section naming the kind and stop: \`blocked\` (a precondition the ticket assumed is not there), \`undecided\` (a decision the ticket's criteria do not settle and that is not yours to settle), or \`mystery\` (a failure you cannot explain, which is different from one you cannot fix). Then set \`status: halted\`.

Never write \`status: doing\`. It belongs to the runner."
  # What earlier builds left standing is in their Records, and a session reads
  # its own ticket and no other - so an item one build left for the next was
  # never seen by it. Pointed at rather than extracted: a Record says it in
  # whatever shape its build chose.
  for t in "${files[@]}"; do
    [ "$(field "$t" status)" = "done" ] && built+=$'\n'"- $(realpath "$t")"
  done
  [ -z "$built" ] || prompt+="

Tickets in this directory already built:$built

Each one's \`## Record\` says what its build left standing. Handle an item that falls inside this ticket's \`## Done when\`, and leave the rest; this ticket's \`## Not here\` still holds."
  printf '%s' "$prompt"
}

# The two ways a claimed session is carried on rather than started over.
STOPPED_EARLY="Your turn ended before the ticket was finished. Nothing wakes an unattended session once its turn ends, so whatever you had running in the background was killed; your uncommitted work is still in the tree. Carry on from there - rerun what was killed - and finish as the brief said."
INTERRUPTED="The run was interrupted while you were working, and has been started again. Your uncommitted work is still in the tree. Carry on from where you stopped - rerun whatever was cut short, a subagent or a check included - and finish as the brief said."

# --- the project's checks, once, before any build
#
# Finding the command is judgement - what the project gates a change on, which
# CI says better than the scripts do - so a session names it. Running it is not,
# so the runner does, and believes the exit status rather than an account of it.
#
# Every build used to meet the same failures that were already on HEAD, prove
# each time by a different route that they were not its own, and in one case
# halt over them. A run that starts red does not start, and a build that is told
# the checks were green cannot mistake anything for someone else's.

verify() {
  local log
  claude_through_limits verify "Find this project's verification command: the one shell line, run from $(pwd), that runs everything a change here has to pass - tests, type check, lint. Where CI runs these, what CI runs is the authority. Do not run it and change nothing; answer with the command." --session-id "$(new_session_id)" \
    --json-schema '{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}'
  [ $? = "$EX_LIMIT" ] && end_run 1
  VERIFY="$(jq -R -r 'fromjson? | select(.type == "result") | .structured_output.command // empty' "$LOG")"
  [ -n "$VERIFY" ] || die "the session found no verification command - see $LOG"
  log="$LOG_DIR/verify-$(date +%Y%m%d-%H%M%S).log"
  say "running the checks: $VERIFY"
  bash -c "$VERIFY" > "$log" 2>&1 9>&- \
    || { tail -20 "$log" >&2; die "the checks fail before any build: $VERIFY - full output in $log"; }
  say "the checks pass"
}

# --- the end of a run
#
# Nobody watches a run, so whatever needs a person is printed at the end of it,
# however it ended. Acceptance is pointed to only when there is something to
# accept.

end_run() {  # exit status
  local t left
  if [ -n "$(unfinished)" ]; then
    printf 'stopped with work left in %s:\n%s' "$TICKETS" "$(unfinished)" >&2
  fi
  for t in "${files[@]}"; do
    left="$(sed -n '/^### Left standing$/,/^#/{/^#/d;p;}' "$t" | sed '/^[[:space:]]*$/d')"
    [ -z "$left" ] || printf '\n%s left standing:\n%s\n' "$(basename "$t")" "$left"
  done
  [ ! -f "$REVIEW" ] || printf '\nthe final review left:\n%s\n' "$(cat "$REVIEW")"
  token_summary
  [ "$1" != 0 ] || printf '\nevery ticket in %s is done - walk it with /accept-criteria %s\n' \
                          "$TICKETS" "$(dirname "$TICKETS")"
  exit "$1"
}

unfinished() {  # the tickets not done, one line each, saying why
  local t
  for t in "${files[@]}"; do
    case "$(field "$t" status)" in
      done) ;;
      halted) printf '%s: halted - %s\n' "$(basename "$t")" "$(sed -n '/^## Halt$/,$p' "$t" | sed -n '3p')" ;;
      *)      printf '%s: %s, after: %s\n' "$(basename "$t")" "$(field "$t" status)" "$(field "$t" after)" ;;
    esac
  done
}

# --- the final review
#
# Each build was reviewed on its own, which cannot see what lies between them.
# Over one ticket there is nothing between. REVIEW.md committed is how the
# review is known to have finished, so a run started again once it has does not
# review again - a re-slice deletes it, because it reviewed what is changing.

REVIEW="$(dirname "$TICKETS")/REVIEW.md"

review_brief() {  # -> the prompt the final review starts from
  printf '%s' "Review the whole change this run built: \`git diff $(review_base)\`. The tickets in $(realpath "$TICKETS") built it, and each build was reviewed on its own - which cannot see what lies between them. Look for that: the same thing built twice, one concept under two names, seams between tickets that do not line up.

The project's checks are \`$VERIFY\`, and they passed when this run started.

Spawn \`critique\` as a subagent with a fresh context. Hand it the diff, the result of the checks, and $(realpath "$(dirname "$TICKETS")/$(field "${files[0]}" criteria)") as what was asked for - not the tickets' plans or Records, which are the reasoning behind the code. Evaluate what comes back, fix what is worth fixing test-first, run the checks and commit. Then review again the same way. Two rounds at most: stop when a review comes back clean or the second round is done.

Nothing wakes you once your turn ends: the run moves on, and whatever you left running in the background is killed. Wait for background work with Monitor, or run the checks in the foreground.

Then write what you left standing to $(realpath "$REVIEW") - findings you did not fix and why, checks you did not run - and commit it. Nobody reads your closing message in an unattended run: REVIEW.md is printed at its end, and the run counts the review as finished only once that file is committed."
}

# The change starts where its tickets were first added: every build since is
# part of it, whatever the branch it came from is called.
review_base() {
  local added
  added="$(git log --diff-filter=A --format=%H -- "$TICKETS" | tail -1)"
  git rev-parse -q --verify "$added^" || git hash-object -t tree /dev/null
}

preflight || end_run 2

# --- the loop

ready_ticket() {  # the first ticket whose dependencies are done
  local t dep ok
  for t in "${files[@]}"; do
    [ "$(field "$t" status)" = ready ] || continue
    ok=yes
    for dep in $(field "$t" after | tr ',' ' '); do
      [ "$(field "$TICKETS/$dep.md" status)" = "done" ] 2>/dev/null || ok=no
    done
    [ "$ok" = yes ] && { printf '%s' "$t"; return 0; }
  done
  return 1
}

while :; do
  preflight || end_run 2

  # A ticket in flight at the top of the loop is one a killed runner left: every
  # pass below settles its ticket and releases the record. What the record says
  # - which session, and where HEAD was - is picked up wherever the kill
  # interrupted it. Where there is no record it was killed around the session
  # rather than in it, and there is nothing to resume.
  if ticket="$(claimed)" && [ -n "$ticket" ]; then
    attempts="$(field "$ticket" attempts)"
    if ! read -r id head_before 2>/dev/null < "$(claim_record "$ticket")"; then
      say "$(basename "$ticket") was claimed and no session is on record - back to ready"
      put_aside "$ticket" "$attempts"
      set_field "$ticket" status ready
      continue
    fi
    case "$(field "$ticket" status)" in
      doing) say "carrying on with $(basename "$ticket"), attempt $attempts of $MAX_ATTEMPTS"
             session "$ticket" --resume "$id" "$INTERRUPTED"; rc=$? ;;
      *)     say "settling $(basename "$ticket"), left at $(field "$ticket" status)"; rc=0 ;;
    esac
  else
    ticket="$(ready_ticket)" || break
    # Run here rather than at startup: a run started again runs them only once
    # the ticket it was killed in is finished, never on its half-built work.
    [ -n "$VERIFY" ] || verify

    attempts=$(( $(field "$ticket" attempts) + 1 ))
    if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
      halt "$ticket" exhausted "$MAX_ATTEMPTS attempts spent without a build that stuck - read the build output and \`git stash list\`, which holds what each attempt left uncommitted, and decide whether to raise the budget or re-slice"
      end_run 1
    fi
    set_field "$ticket" attempts "$attempts"
    set_field "$ticket" status doing
    say "claimed $(basename "$ticket"), attempt $attempts of $MAX_ATTEMPTS"

    # Where HEAD was before the build, so that `done` can be checked against
    # what the session did rather than only against what it says it did. On
    # record with the session, because a runner killed during the build is
    # started again with neither.
    head_before="$(git rev-parse HEAD)"
    id="$(new_session_id)"
    printf '%s %s\n' "$id" "$head_before" > "$(claim_record "$ticket")"
    session "$ticket" --session-id "$id"; rc=$?
  fi

  # A session that ended its turn with its work uncommitted and the ticket still
  # claimed was waiting on something `-p` killed when the turn ended - one did
  # so with its build done and reviewed. It is resumed once rather than started
  # over, because everything it did is still in the tree and in its context.
  if [ "$rc" = 0 ] && [ "$(field "$ticket" status)" = doing ] && [ -n "$(left_behind)" ]; then
    say "session stopped with its work uncommitted - resuming it"
    session "$ticket" --resume "$id" "$STOPPED_EARLY"; rc=$?
  fi
  if [ "$rc" = "$EX_LIMIT" ]; then
    # A limit that outlasted every wait says nothing about the ticket, so it is
    # handed back as it was claimed, attempt and all, rather than left for the
    # budget to halt.
    if [ "$(field "$ticket" status)" = doing ]; then
      set_field "$ticket" status ready
      set_field "$ticket" attempts "$((attempts - 1))"
    fi
    echo "$(basename "$ticket") is at $(field "$ticket" status) - run again once the limit has lifted" >&2
    release "$ticket"
    end_run 1
  fi

  # Read off the ticket whatever the exit status: a session that crashed after
  # committing its build has built it, and one that crashed before has left the
  # claim for the runner to put back. The attempt is spent either way.
  case "$(field "$ticket" status)" in
    halted) commit_halt "$ticket" "$(halt_kind "$ticket")"; release "$ticket"; end_run 1 ;;
    done) ;;
    *) say "session left $(basename "$ticket") at $(field "$ticket" status) - back to ready"
       put_aside "$ticket" "$attempts"
       set_field "$ticket" status ready; release "$ticket"; continue ;;
  esac

  # A session that says `done` without a commit built nothing, and accepting
  # it is how a ticket reaches done unbuilt - nothing else looks at the commit.
  # Given the same tolerance as a crash, because it is the same kind of failure
  # - a session that did not do what it was launched for - and the halt at the
  # end of it says that, rather than that a budget ran out. Which is why the
  # edge here is `-ge` where the selection above is `-gt`: this fires on the
  # attempt that spends the last of the budget, because falling through to the
  # next pass would halt as `exhausted` and lose the thing worth saying.
  if [ "$(git rev-parse HEAD)" = "$head_before" ]; then
    if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
      halt "$ticket" unbuilt "the session reported a build and committed nothing, and the last of $MAX_ATTEMPTS attempts is spent - read the build output for what stopped it committing, and \`git stash list\` for what each attempt left uncommitted"
      release "$ticket"
      end_run 1
    fi
    echo "unbuilt: $ticket reported a build and committed nothing - building it again" >&2
    put_aside "$ticket" "$attempts"
    set_field "$ticket" status ready
    release "$ticket"
    continue
  fi

  # A ticket the session left out of its commit goes into it all the same: left
  # uncommitted, `done` - and the claim and counter under it - was every later
  # session's "someone else's change", and lost to anything that reset the tree.
  # Into the build's own commit rather than one of the runner's, because a
  # commit message needs a session and amending keeps the one it wrote.
  if ! git diff --quiet HEAD -- "$ticket"; then
    git commit -q --amend --no-edit -- "$ticket" \
      || { echo "could not amend $ticket into $(git rev-parse --short HEAD)" >&2; end_run 1; }
  fi
  say "done: $(basename "$ticket") at $(git rev-parse --short HEAD)"
  # Whatever the build left lying around besides its commit is not the next
  # ticket's, and would read to its session as its own work.
  put_aside "$ticket" "$attempts"
  release "$ticket"
done

# Nothing selectable is not the same as everything finished: a halt and a
# dependency nobody can satisfy look identical from inside the loop, and the
# report says which.
[ -z "$(unfinished)" ] || end_run 1

if [ "${#files[@]}" -gt 1 ] && ! git cat-file -e "HEAD:./$REVIEW" 2>/dev/null; then
  [ -n "$VERIFY" ] || verify
  claude_through_limits review "$(review_brief)" --session-id "$(new_session_id)"
  [ $? = "$EX_LIMIT" ] && end_run 1
  git cat-file -e "HEAD:./$REVIEW" 2>/dev/null \
    || { echo "the final review did not finish: it committed no $REVIEW - see $LOG" >&2; end_run 1; }
fi
end_run 0
