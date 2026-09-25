#!/usr/bin/env bash
#
# Drive a ticket directory to completion with nobody watching.
#
#   ./run.sh intents/<slug>/tickets
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. A session cannot
# enforce a budget it is spending, cannot reset a claim it is holding when it
# dies, and cannot wait out a limit that has already stopped it.
#
# The loop per ticket: claim it, build it, and either finish it or send it
# back. The runner owns both ends of the status - a session writes `review` or
# `halted` and nothing else - because a ticket left at `doing` by a crash is
# indistinguishable from one being worked on, and only the process that
# launched it knows which.
#
# There is no review pass here. `/implement` spawns its own reviewer in a
# subagent that did not write the code, which is the property a second session
# used to buy, and a second review of a reviewed commit reviews a review.

set -uo pipefail

TICKETS="${1:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # builds of one ticket before it is exhausted
WAIT_SECONDS="${WAIT_SECONDS:-300}"   # after a usage limit that names no reset time
LIMIT_MARGIN="${LIMIT_MARGIN:-120}"   # past a limit's reset time, before carrying on
MAX_WAITS="${MAX_WAITS:-8}"           # limits in a row before the run gives up

die() { printf '%s\n' "$*" >&2; exit 2; }
say() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*"; }

# --- refusals, before anything is launched

[ -n "$TICKETS" ] || die "usage: run.sh intents/<slug>/tickets"
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

# Whatever is lying around uncommitted is someone's, and a session cannot tell
# it from its own work: it lints it, reviews it, and carves it out of every
# diff. Untracked files count - an untracked mockup failed the lint of every
# session in a whole run.
dirty="$(git status --porcelain)"
[ -z "$dirty" ] || die "refusing to run on a dirty tree: commit or remove what is here first"$'\n'"$dirty"

command -v claude >/dev/null || die "no claude on PATH: the runner drives sessions, it does not do the work"

shopt -s nullglob
files=()
for f in "$TICKETS"/*.md; do
  # A ticket is a file with a solution behind it. Anything else in the directory
  # is someone's notes, and reading it as a ticket fails every pass.
  grep -q '^solution:' "$f" && files+=("$f") || printf 'ignoring %s: not a ticket\n' "$f" >&2
done
[ "${#files[@]}" -gt 0 ] || die "no tickets in $TICKETS"

field()     { sed -n "2,/^---$/s/^$2: *//p" "$1" | head -1; }
# Scoped to the frontmatter: a ticket about the ticket format has lines in its
# body that look exactly like fields, and this repo's tickets are full of them.
set_field() { sed -i "2,/^---$/s|^$2:.*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# The criteria a ticket quotes, and the criteria its solution carries, in the
# one shape both can be compared in.
quoted()   { grep -o '^> \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
declared() { grep -o '^- \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
text_of()  { # file, id -> the criterion as written, tag and marker stripped
  awk -v id="$2" '
    index($0, "- **" id "**") == 1 || index($0, "> **" id "**") == 1 { found = 1; print; next }
    found && (/^[->] \*\*AC-/ || /^#/ || /^$/) { exit }
    found { print }
  ' "$1" | sed 's/^[[:space:]]*[->][[:space:]]*//' | tr '\n' ' ' | sed 's/  */ /g; s/ *$//' \
         | sed 's/ *\*([^*]*)\*$//'
}

# --- the drift pre-flight
#
# Before each pass, in both directions. A session never reads the solution and a
# committed ticket is revisited by nobody but a re-slice, so this is the only place the two can
# be found to disagree - and the report has to say which way, because an edit
# upstream and a slicing that lost something need different answers.

preflight() {
  local t solution id dep problems="" culprit="" solutions=()
  for t in "${files[@]}"; do
    # Resolved beside the tickets/ directory, not from the working directory:
    # the frontmatter says `02-SOLUTION.md` and means the one this slicing came
    # from, whatever the runner was invoked from.
    solution="$(dirname "$TICKETS")/$(field "$t" solution)"
    if [ ! -f "$solution" ]; then
      problems+="$(basename "$t"): names $solution, which is not there"$'\n'
      [ -n "$culprit" ] || culprit="$t"
      continue
    fi
    [[ " ${solutions[*]-} " == *" $solution "* ]] || solutions+=("$solution")
    # A deleted ticket leaves the ones after it waiting on something that will
    # never be done, and the loop would only say so once it had run out of work.
    for dep in $(field "$t" after | tr ',' ' '); do
      if ! grep -qs '^solution:' "$TICKETS/$dep.md"; then
        problems+="$(basename "$t"): after: names $dep, which is not a ticket"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
    for id in $(quoted "$t"); do
      # A criterion deleted upstream and one reworded need the same re-slice,
      # but the person reading the halt should not have to diff to tell which.
      if [ -z "$(text_of "$solution" "$id")" ]; then
        problems+="$(basename "$t"): $id is gone from $solution"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      elif [ "$(text_of "$t" "$id")" != "$(text_of "$solution" "$id")" ]; then
        problems+="$(basename "$t"): $id no longer matches $solution"$'\n'
        [ -n "$culprit" ] || culprit="$t"
      fi
    done
  done
  # Once per solution, not once per ticket: this direction asks something of the
  # directory as a whole, and asking it inside the loop above reported a lost
  # criterion once for every ticket that had not lost it.
  for solution in ${solutions[@]+"${solutions[@]}"}; do
    for id in $(declared "$solution"); do
      if ! grep -q "^> \*\*$id\*\*" "${files[@]}"; then
        problems+="$solution: $id is quoted by no ticket"$'\n'
        [ -n "$culprit" ] || culprit="${files[0]}"
      fi
    done
  done
  if [ -n "$problems" ]; then
    printf 'drift - the tickets and the solution disagree:\n%s' "$problems" >&2
    # The stop is named in the ticket, not only on someone's terminal - nobody is
    # watching the terminal, which is the whole premise. The first offender
    # carries it, because that is where a person will look; where the offence
    # belongs to the directory rather than to one ticket, the first ticket does.
    #
    # Carried alongside the message rather than parsed back out of it. Reading
    # the ticket off the text meant two of the three messages named no ticket
    # the `-f` guard could find, and both fell through it silently.
    [ -n "$culprit" ] && halt "$culprit" drift \
      "the solution and this ticket no longer agree - re-slice the unbuilt tickets through plan mode"
    return 1
  fi
}

# --- one session

# Where each session's full event stream goes. Inside the git directory, so a
# session that commits everything it sees cannot commit its own transcript.
LOG_DIR="${LOG_DIR:-$(git rev-parse --absolute-git-dir)/run-logs}"
mkdir -p "$LOG_DIR"

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
claude_through_limits() {  # log name, prompt, claude's own options...
  local id reset delay rc waits=0 how=--session-id prompt="$2" name="$1"
  shift 2
  id="$(new_session_id)"
  while :; do
    LOG="$LOG_DIR/$name-$(date +%Y%m%d-%H%M%S)$([ "$waits" = 0 ] || printf -- '-resumed-%s' "$waits").jsonl"
    say "full log in $LOG"
    claude_run "$LOG" "$how" "$id" "$prompt" "$@"; rc=$?
    reset="$(limit_reset "$LOG")"
    [ -n "$reset" ] || return "$rc"
    waits=$((waits + 1))
    [ "$waits" -le "$MAX_WAITS" ] \
      || { echo "gave up waiting out the limit after $MAX_WAITS waits" >&2; return "$EX_LIMIT"; }
    if [ "$reset" -gt 0 ]; then delay=$(( reset + LIMIT_MARGIN - $(date +%s) )); else delay="$WAIT_SECONDS"; fi
    [ "$delay" -gt 0 ] || delay=0
    say "usage limit - waiting until $(date -d "@$(( $(date +%s) + delay ))" '+%a %H:%M') ($waits of $MAX_WAITS)"
    sleep "$delay"
    how=--resume
    prompt="You were stopped by a usage limit, which has now reset. Carry on with the task from where you stopped; redo any step the limit cut short, a subagent included."
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

halt() {  # ticket, kind, why
  printf '\n## Halt\n\n%s - %s\n' "$2" "$3" >> "$1"
  set_field "$1" status halted
}

# The ticket protocol is stated here rather than in the skill. `/implement` is
# the generic build skill - it fires when anyone asks for code and knows nothing
# about tickets, statuses or halt kinds. A runner that needs those has to say so
# itself, which is the cost of the skill staying general.
session() {  # ticket -> 0 ran, EX_LIMIT gave up on a limit, anything else failed
  local rc prompt
  # By its absolute path: a session runs wherever the runner was started, and
  # one in a subdirectory looked for a relative path at the repository root.
  prompt="Use /implement on the work described in $(realpath "$1").

The project's checks are \`$VERIFY\`, and they passed on this commit before the run started. A check that fails now failed because of this build.

That file is the whole brief. Its \`## Done when\` is the definition of done - not the diff, not what you would have built, not what the solution probably meant. Its \`## Not here\` names what a neighbouring ticket owns, and building it is two tickets building the same code. Its \`## Plan\` is how it was decided this gets built; where you find the plan wrong, say so rather than following it off a cliff.

Do not open the solution the frontmatter names. The ticket quotes what it needs, and going upstream is how a ticket quietly becomes a different one.

When the criteria are green and the project's checks pass, write the ticket's \`## Record\` - which test names which criterion, the command you ran, and what you left standing: review findings you did not fix and why, checks you did not run, and where you departed from the plan. Nobody reads your closing message in an unattended run; the walk reads the Record. Set \`status: review\` in the frontmatter and commit the code and the ticket file together, in one commit.

If you cannot proceed, append a \`## Halt\` section naming the kind and stop: \`blocked\` (a precondition the ticket assumed is not there), \`undecided\` (a decision the ticket's criteria do not settle and that is not yours to settle), or \`mystery\` (a failure you cannot explain, which is different from one you cannot fix). Then set \`status: halted\`.

Never write \`status: doing\` or \`status: done\`. Both ends belong to the runner."
  say "session on $(basename "$1")"
  claude_through_limits "$(basename "$1" .md)" "$prompt"; rc=$?
  say "session ended, exit $rc, ticket says status: $(field "$1" status)"
  return $rc
}

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
  claude_through_limits verify "Find this project's verification command: the one shell line, run from $(pwd), that runs everything a change here has to pass - tests, type check, lint. Where CI runs these, what CI runs is the authority. Do not run it and change nothing; answer with the command." \
    --json-schema '{"type":"object","properties":{"command":{"type":"string"}},"required":["command"]}'
  [ $? = "$EX_LIMIT" ] && exit 1
  VERIFY="$(jq -R -r 'fromjson? | select(.type == "result") | .structured_output.command // empty' "$LOG")"
  [ -n "$VERIFY" ] || die "the session found no verification command - see $LOG"
  log="$LOG_DIR/verify-$(date +%Y%m%d-%H%M%S).log"
  say "running the checks: $VERIFY"
  bash -c "$VERIFY" > "$log" 2>&1 \
    || { tail -20 "$log" >&2; die "the checks fail before any build: $VERIFY - full output in $log"; }
  say "the checks pass"
}

preflight || exit 2
verify

# --- the loop

ready_ticket() {  # the first ticket whose dependencies are done
  local t dep ok
  for t in "${files[@]}"; do
    [ "$(field "$t" status)" = ready ] || continue
    ok=yes
    for dep in $(field "$t" after | tr ',' ' '); do
      [ "$(field "$TICKETS/$dep.md" status)" = done ] 2>/dev/null || ok=no
    done
    [ "$ok" = yes ] && { printf '%s' "$t"; return 0; }
  done
  return 1
}

while :; do
  preflight || exit 2

  ticket="$(ready_ticket)" || break

  attempts=$(( $(field "$ticket" attempts) + 1 ))
  if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
    halt "$ticket" exhausted "$MAX_ATTEMPTS attempts spent without a build that stuck - read the build output, decide whether to raise the budget or re-slice"
    exit 1
  fi
  set_field "$ticket" attempts "$attempts"
  set_field "$ticket" status doing
  say "claimed $(basename "$ticket"), attempt $attempts of $MAX_ATTEMPTS"

  # Where HEAD was before the build, so that `review` can be checked against
  # what the session did rather than only against what it says it did.
  head_before="$(git rev-parse HEAD)"

  session "$ticket"; rc=$?
  if [ "$rc" = "$EX_LIMIT" ]; then
    # A limit that outlasted every wait says nothing about the ticket, so it is
    # handed back as it was claimed, attempt and all, rather than left for the
    # budget to halt.
    if [ "$(field "$ticket" status)" = doing ]; then
      set_field "$ticket" status ready
      set_field "$ticket" attempts "$((attempts - 1))"
    fi
    echo "$(basename "$ticket") is at $(field "$ticket" status) - run again once the limit has lifted" >&2
    exit 1
  fi

  # Read off the ticket whatever the exit status: a session that crashed after
  # committing its build has built it, and one that crashed before has left the
  # claim for the runner to put back. The attempt is spent either way.
  case "$(field "$ticket" status)" in
    halted) echo "halted: $ticket" >&2; exit 1 ;;
    review) ;;
    *) say "session left $(basename "$ticket") at $(field "$ticket" status) - back to ready"
       set_field "$ticket" status ready; continue ;;
  esac

  # A session that says `review` without a commit built nothing, and accepting
  # it is how a ticket reaches done unbuilt - nothing else looks at the commit.
  # Given the same tolerance as a crash, because it is the same kind of failure
  # - a session that did not do what it was launched for - and the halt at the
  # end of it says that, rather than that a budget ran out. Which is why the
  # edge here is `-ge` where the selection above is `-gt`: this fires on the
  # attempt that spends the last of the budget, because falling through to the
  # next pass would halt as `exhausted` and lose the thing worth saying.
  if [ "$(git rev-parse HEAD)" = "$head_before" ]; then
    if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
      halt "$ticket" unbuilt "the session reported a build and committed nothing, and the last of $MAX_ATTEMPTS attempts is spent - read the build output for what stopped it committing"
      exit 1
    fi
    echo "unbuilt: $ticket reported a build and committed nothing - building it again" >&2
    set_field "$ticket" status ready
    continue
  fi

  # Into the build's own commit rather than one of the runner's, because a
  # commit message needs a session and amending keeps the one it wrote. Left
  # uncommitted, `done` - and the claim and counter under it - was every later
  # session's "someone else's change", and lost to anything that reset the tree.
  # The ticket goes in whole, so one the session left out of its commit is
  # recorded all the same.
  set_field "$ticket" status done
  git commit -q --amend --no-edit -- "$ticket" \
    || { echo "could not amend $ticket into $(git rev-parse --short HEAD)" >&2; exit 1; }
  say "done: $(basename "$ticket") at $(git rev-parse --short HEAD)"
done

# `break` means nothing could be selected, which is not the same as everything
# being finished: a stale claim, a halt, or a dependency nobody can satisfy all
# look identical from inside the loop.
stuck=""
for t in "${files[@]}"; do
  case "$(field "$t" status)" in
    done) ;;
    doing)  stuck+="$(basename "$t"): claimed by a session that never came back"$'\n' ;;
    halted) stuck+="$(basename "$t"): halted - $(sed -n '/^## Halt$/,$p' "$t" | sed -n '3p')"$'\n' ;;
    *)      stuck+="$(basename "$t"): waiting on $(field "$t" after)"$'\n' ;;
  esac
done
if [ -n "$stuck" ]; then
  printf 'stopped with work left in %s:\n%s' "$TICKETS" "$stuck" >&2
  exit 1
fi
# Every ticket done is not the same as the problem solved, and nothing so far
# has asked the second question: each pass compared a commit to the ticket that
# asked for it. The walk is the only stage that reads a statement written before
# the solution existed. It is printed and not acted on - a condition nobody
# could find is for a person to look at, and the runner does not get to decide
# that the change is good.
printf 'every ticket in %s is done\n' "$TICKETS"

intent="$(dirname "$TICKETS")/01-INTENT.md"
# Where the change was small enough that no intent document was written,
# `/find-solution` puts the conditions in the solution's own `## Intent` section
# and `/accept-intent` reads them there. So the walk follows the conditions
# rather than the filename: skipping it on a missing `01-INTENT.md` dropped the
# only stage that asks whether the problem was solved, on a route the pipeline
# offers on purpose, with a line on a terminal nobody is watching.
[ -f "$intent" ] || intent="$(dirname "$TICKETS")/$(field "${files[0]}" solution)"

printf 'walking %s\n\n' "$intent"
# The prompt starts with the slash command, and has to. `accept-intent` is
# `disable-model-invocation`, so it is not among the skills a session can
# reach on its own - naming it in a sentence gets a session that improvises
# the one stage that asks whether the problem was solved.
claude_through_limits accept-intent "/accept-intent $intent"
[ $? = "$EX_LIMIT" ] && exit 1
# The walk's report is the one thing here meant to be read in full.
printf '\n'
jq -R -r 'fromjson? | select(.type == "result") | .result // empty' "$LOG"
