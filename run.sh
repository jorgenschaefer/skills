#!/usr/bin/env bash
#
# Drive a ticket directory to completion with nobody watching.
#
#   ./run.sh tickets/<topic>
#
# Everything here is something that has to hold when a session is dead or
# misbehaving, which is why it is a script and not a skill. A session cannot
# enforce a budget it is spending, cannot reset a claim it is holding when it
# dies, and cannot wait out a limit that has already stopped it.
#
# The loop per ticket: claim it, build it, review what was built in a session
# that did not write it, and either finish it or send it back. The runner owns
# both ends of the status - a session writes `review` or `halted` and nothing
# else - because a ticket left at `doing` by a crash is indistinguishable from
# one being worked on, and only the process that launched it knows which.

set -uo pipefail

TICKETS="${1:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"     # builds of one ticket before it is exhausted
MAX_REVIEWS="${MAX_REVIEWS:-2}"       # times a review may send the same ticket back
WAIT_SECONDS="${WAIT_SECONDS:-900}"   # between hitting a usage limit and trying again
MAX_WAITS="${MAX_WAITS:-8}"

die() { printf '%s\n' "$*" >&2; exit 2; }

# --- refusals, before anything is launched

[ -n "$TICKETS" ] || die "usage: run.sh tickets/<topic>"
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
  ' "$1" | sed 's/\*([a-z:, C0-9-]*)\*//' \
         | sed 's/^[[:space:]]*[->][[:space:]]*//' | tr '\n' ' ' | sed 's/  */ /g; s/ *$//'
}

# --- the drift pre-flight
#
# Before each pass, in both directions. A session never reads the solution and a
# committed ticket is revisited by nobody, so this is the only place the two can
# be found to disagree - and the report has to say which way, because an edit
# upstream and a slicing that lost something need different answers.

preflight() {
  local t solution id problems=""
  for t in "${files[@]}"; do
    solution="$(field "$t" solution)"
    [ -f "$solution" ] || { problems+="$t names $solution, which is not there"$'\n'; continue; }
    for id in $(quoted "$t"); do
      [ "$(text_of "$t" "$id")" = "$(text_of "$solution" "$id")" ] \
        || problems+="$(basename "$t"): $id no longer matches $solution"$'\n'
    done
    for id in $(declared "$solution"); do
      grep -q "^> \*\*$id\*\*" "${files[@]}" \
        || problems+="$solution: $id is quoted by no ticket"$'\n'
    done
  done
  if [ -n "$problems" ]; then
    printf 'drift - the tickets and the solution disagree:\n%s' "$problems" >&2
    # AC-7: the stop is named in the ticket, not only on someone's terminal. The
    # first offender carries it, because that is where a person will look.
    local first; first="$(printf '%s' "$problems" | sed -n '1s/:.*//p')"
    [ -f "$TICKETS/$first" ] && halt "$TICKETS/$first" drift \
      "the solution and this ticket no longer agree - re-slice the unbuilt tickets through plan mode"
    return 1
  fi
}

# --- one session

halt() {  # ticket, kind, why
  printf '\n## Halt\n\n%s - %s\n' "$2" "$3" >> "$1"
  set_field "$1" status halted
}

# A usage limit is not a failure of the work: the session never got to do any.
# Waiting it out and trying again is the whole reason this is a process that
# outlives its sessions.
session() {  # ticket, role -> 0 ran, 1 failed
  local out rc waits=0
  while :; do
    # Nobody is here to approve a tool call, and `claude -p` cannot prompt: what
    # it cannot get approved it declines, and a session that could not run the
    # tests halts as if the work were impossible. The first live run of this
    # script halted exactly that way. So the tools a build needs are named here
    # rather than left to whatever the operator has in settings.
    out="$(claude -p --permission-mode acceptEdits \
             --allowedTools Bash Edit Write Read Glob Grep Skill TodoWrite \
             -- "Use /$2 on $1" 2>&1)"; rc=$?
    printf '%s\n' "$out"
    case "$out" in
      *"usage limit reached"*)
        waits=$((waits + 1))
        [ "$waits" -le "$MAX_WAITS" ] || { echo "gave up waiting out the limit" >&2; return 1; }
        sleep "$WAIT_SECONDS"
        continue ;;
    esac
    return $rc
  done
}

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
    halt "$ticket" exhausted "$MAX_ATTEMPTS attempts spent, $(field "$ticket" reviews) of them after a review sent it back - read the build output, decide whether to raise the budget or re-slice"
    exit 1
  fi
  set_field "$ticket" attempts "$attempts"
  set_field "$ticket" status doing

  # Where HEAD was before the build, so that `review` can be checked against
  # what the session did rather than only against what it says it did.
  head_before="$(git rev-parse HEAD)"

  if ! session "$ticket" implement; then
    # The session did not get to say what happened, so the runner says it: the
    # claim goes back, and the attempt is spent either way.
    [ "$(field "$ticket" status)" = doing ] && set_field "$ticket" status ready
    continue
  fi

  case "$(field "$ticket" status)" in
    halted) echo "halted: $ticket" >&2; exit 1 ;;
    review) ;;
    *) set_field "$ticket" status ready; continue ;;
  esac

  # A session that says `review` without a commit built nothing: there is no
  # work for the review to read, and accepting it is how a ticket reaches done
  # unbuilt. Given the same tolerance as a crash, because it is the same kind of
  # failure - a session that did not do what it was launched for - and the
  # halt at the end of it says that, rather than that a budget ran out. Which is
  # why the edge here is `-ge` where the selection above is `-gt`: this fires on
  # the attempt that spends the last of the budget, because falling through to
  # the next pass would halt as `exhausted` and lose the thing worth saying.
  if [ "$(git rev-parse HEAD)" = "$head_before" ]; then
    if [ "$attempts" -ge "$MAX_ATTEMPTS" ]; then
      halt "$ticket" unbuilt "the session reported a build and committed nothing, and the last of $MAX_ATTEMPTS attempts is spent - read the build output for what stopped it committing"
      exit 1
    fi
    echo "unbuilt: $ticket reported a build and committed nothing - building it again" >&2
    set_field "$ticket" status ready
    continue
  fi

  # Cleared before the review, not after it: what is in the ticket when the next
  # build starts has to be this round's findings, and a section left from the
  # last round would read as a complaint nobody made.
  sed -i '/^## Findings$/,$d' "$ticket"
  session "$ticket" critique || { set_field "$ticket" status ready; continue; }

  if grep -q '^## Findings' "$ticket"; then
    reviews=$(( $(field "$ticket" reviews) + 1 ))
    set_field "$ticket" reviews "$reviews"
    if [ "$reviews" -gt "$MAX_REVIEWS" ]; then
      halt "$ticket" exhausted "$reviews reviews without a clean one - read the findings below and decide whether they are answerable as written"
      exit 1
    fi
    set_field "$ticket" status ready
  else
    set_field "$ticket" status done
  fi
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
printf 'every ticket in %s is done - /accept judges whether they solved the problem\n' "$TICKETS"
