# shellcheck shell=bash
#
# The tickets' state in git: what is claimed, what a session left behind, and
# the halts a run leaves for a person.
#
# Sourced by run.sh, never run.

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
check_tree() {
  local dirty
  dirty="$(git status --porcelain -- "${NOT_TICKETS[@]}")"
  case "$(claimed | wc -l)" in
    0) [ -z "$dirty" ] || die "refusing to run on a dirty tree: commit or remove what is here first"$'\n'"$dirty" ;;
    1) [ -z "$dirty" ] || say "carrying on with $(claimed), taking this as its session's work:"$'\n'"$dirty" ;;
    *) die "more than one ticket is claimed, which one runner cannot leave behind - put back all but one:"$'\n'"$(claimed)" ;;
  esac
}

claimed() {  # the tickets in flight - at `doing`, on record, or `done` unchecked - one per line
  local t
  for t in "${TICKET_FILES[@]}"; do
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

# Which session a claim was given, and where HEAD stood, for a runner started
# again after being killed. Named for the ticket's whole path: every change has
# a 1-one.md, and one's record resumed another's session. It stays until the
# runner has settled the ticket, not only until the session returns: a `done`
# the runner was killed before checking is a claim to check, not a result.
claim_record() {  # ticket -> the file
  printf '%s/%s.claim' "$LOG_DIR" "$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$1" | tr / _)"
}
release() { rm -f "$(claim_record "$1")"; }

# What a session left in the tree besides the ticket files, which are the
# runner's bookkeeping - another ticket's halt among them, which went into the
# stash with a later build's leftovers and came back out as a fresh budget.
left_behind() {  # -> git status lines, empty for none
  git status --porcelain -- "${NOT_TICKETS[@]}"
}

# The next attempt is told the checks were green when the run started, which is
# only true of a tree without this one's leftovers in it. Stashed rather than
# dropped: it may be most of a build.
put_aside() {  # ticket, attempt
  [ -n "$(left_behind)" ] || return 0
  git stash push -q -u -m "run.sh: $(basename "$1") attempt $2, left uncommitted" -- "${NOT_TICKETS[@]}"
  say "what it left uncommitted is in the stash"
}

# Committed, and once: a halt is the one thing a run leaves for a person, and
# left uncommitted it was every later session's someone else's change - and a
# drift nobody had resolved yet was halted again on every start.
#
# HALTED names the last ticket halted here, for the end of the run to name what
# stopped it: one already halted is named again, as a drift nobody resolved is.
halt() {  # ticket, kind, why
  # shellcheck disable=SC2034 # read where the run ends, in run.sh and the loop
  HALTED="$1"
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

# The kind a halt names, read off its first line in whatever shape its writer
# put it; empty where that line names none of them.
halt_kind() {  # ticket
  sed -n '/^## Halt$/,$p' "$1" | sed -n '2,$p' | sed '/^[[:space:]]*$/d' | head -1 \
    | grep -o -m1 -w 'blocked\|undecided\|mystery\|exhausted\|drift\|unbuilt' | head -1
}
