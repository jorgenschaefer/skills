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

branch="$(git rev-parse --abbrev-ref HEAD)"
case "$branch" in
  main|master) die "refusing to run on $branch: a run belongs on a branch of its own" ;;
esac

shopt -s nullglob
files=("$TICKETS"/*.md)
[ "${#files[@]}" -gt 0 ] || die "no tickets in $TICKETS"

field()     { sed -n "s/^$2: *//p" "$1" | head -1; }
set_field() { sed -i "s|^$2: .*|$2:$(printf '%*s' $((10 - ${#2})) '')$3|" "$1"; }

# The criteria a ticket quotes, and the criteria its solution carries, in the
# one shape both can be compared in.
quoted()   { grep -o '^> \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
declared() { grep -o '^- \*\*AC-[0-9]\+\*\*' "$1" | grep -o 'AC-[0-9]\+' | sort -u; }
text_of()  { # file, id -> the criterion as written, tag and marker stripped
  awk -v id="$2" '
    index($0, "**" id "**") { found = 1; print; next }
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
      grep -ql "^> \*\*$id\*\*" "${files[@]}" \
        || problems+="$solution: $id is quoted by no ticket"$'\n'
    done
  done
  [ -z "$problems" ] || { printf 'drift - the tickets and the solution disagree:\n%s' "$problems" >&2; return 1; }
}

# --- one session

halt() {  # ticket, kind, why
  printf '\n## Halt\n\n%s - %s\n' "$2" "$3" >> "$1"
  set_field "$1" status halted
}

# A usage limit is not a failure of the work: the session never got to do any.
# Waiting it out and trying again is the whole reason this is a process that
# outlives its sessions.
session() {  # ticket, role -> 0 ran, 1 failed, 3 hit a limit
  local out rc waits=0
  while :; do
    out="$(claude -p --permission-mode acceptEdits \
             "Use /$2 on $1" 2>&1)"; rc=$?
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
    halt "$ticket" exhausted "$MAX_ATTEMPTS attempts spent without reaching a review"
    exit 1
  fi
  set_field "$ticket" attempts "$attempts"
  set_field "$ticket" status doing

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

  sed -i '/^## Findings$/,$d' "$ticket"
  session "$ticket" critique || { set_field "$ticket" status ready; continue; }

  if grep -q '^## Findings' "$ticket"; then
    reviews=$(( $(field "$ticket" reviews) + 1 ))
    set_field "$ticket" reviews "$reviews"
    if [ "$reviews" -ge "$MAX_REVIEWS" ]; then
      halt "$ticket" exhausted "$reviews reviews without a clean one"
      exit 1
    fi
    set_field "$ticket" status ready
  else
    set_field "$ticket" status done
  fi
  # Findings belong to the round that raised them. Left in place, the next
  # review's clean verdict reads as one more round of the same complaint.
  sed -i '/^## Findings$/,$d' "$ticket"
done

printf 'every ticket in %s is done\n' "$TICKETS"
