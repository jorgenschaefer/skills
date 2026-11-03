# shellcheck shell=bash
#
# The chunks' state in git: what is claimed, what a session left behind, and
# the halts a run leaves for a person.
#
# Sourced by run.sh, never run.

# The parts are plan/NN.md, where the plan was split, and plan.md itself where
# it was not. A file without the frontmatter is someone's notes, and reading it
# as a part fails every pass.
#
# Everything but the part files, as a pathspec: what is uncommitted in them is
# the runner's own bookkeeping, and a run started again carries on from it.
load_chunks() {
  local f t
  CHUNK_FILES=()
  for f in "$PARTS"/[0-9][0-9].md; do
    [ -n "$(field "$f" status)" ] && CHUNK_FILES+=("$f") || printf 'ignoring %s: not a part\n' "$f" >&2
  done
  [ "${#CHUNK_FILES[@]}" -gt 0 ] || CHUNK_FILES=("$PLAN")
  NOT_CHUNKS=(':/')
  for t in "${CHUNK_FILES[@]}"; do NOT_CHUNKS+=(":!$t"); done
}

is_split() { [ "${CHUNK_FILES[*]}" != "$PLAN" ]; }

# On a first start only: plan.md unclaimed and never attempted, and no parts.
# Once plan.md is claimed as the one part its attempts count, so a run started
# again does not split again; one killed in the split itself does, which costs
# a session and nothing else.
#
# The split asks nobody anything. A step only a person can do is a halt in
# plan.md, and the run ends on it before anything is built.
split_change() {
  local rc
  is_split && return 0
  [ "$(field "$PLAN" status)" = ready ] && [ "$(field "$PLAN" attempts)" = 0 ] || return 0
  [ -n "$CHECKED" ] || verify
  say "splitting $PLAN where one agent cannot build it within one context"
  claude_through_limits split "$(split_brief)" --session-id "$(new_session_id)"; rc=$?
  [ "$rc" = "$EX_LIMIT" ] && end_run 1 "a usage limit outlasted every wait while splitting the plan - run again once it has lifted"
  if [ "$(field "$PLAN" status)" = halted ]; then
    commit_halt "$PLAN" "$(halt_kind "$PLAN")"
    end_run 1 "$PLAN"
  fi
  [ "$rc" = 0 ] || end_run 1 "the split failed, exit $rc - see $LOG, then run again"
  # Before the parts are loaded: once they are, what is uncommitted in them
  # reads as bookkeeping, and a split that never committed its parts would
  # pass for one that did.
  [ -z "$(left_behind)" ] \
    || end_run 1 "the split left work uncommitted - commit or remove it, then run again:"$'\n'"$(left_behind)"
  load_chunks
  if is_split; then say "split into ${#CHUNK_FILES[@]} parts"; else say "it fits one agent: building plan.md as it is"; fi
}

# Whatever is lying around uncommitted is someone's, and a session cannot tell
# it from its own work: it lints it, reviews it, and carves it out of every
# diff. Untracked files count - an untracked mockup failed the lint of every
# session in a whole run. The chunk files are not counted: what is uncommitted
# in them is the runner's own bookkeeping - a claim, a counter, a halt it wrote
# - and a run started again reads it as the state to carry on from.
#
# Except beside a claim. A chunk at `doing` when no runner is running is one a
# killed runner was building, and what is uncommitted is that session's work,
# which the loop carries on with. One runner leaves one claim; more than one is
# not something this script did.
check_tree() {
  local dirty
  dirty="$(git status --porcelain -- "${NOT_CHUNKS[@]}")"
  case "$(claimed | wc -l)" in
    0) [ -z "$dirty" ] || die "refusing to run on a dirty tree: commit or remove what is here first"$'\n'"$dirty" ;;
    1) [ -z "$dirty" ] || say "carrying on with $(claimed), taking this as its session's work:"$'\n'"$dirty" ;;
    *) die "more than one part is claimed, which one runner cannot leave behind - put back all but one:"$'\n'"$(claimed)" ;;
  esac
}

claimed() {  # the chunks in flight - at `doing`, on record, or `done` unchecked - one per line
  local t
  for t in "${CHUNK_FILES[@]}"; do
    if [ "$(field "$t" status)" = doing ] || [ -f "$(claim_record "$t")" ] || unchecked_done "$t"; then
      printf '%s\n' "$t"
    fi
  done
}

# A `done` in the working tree that HEAD does not carry: a session's claim the
# runner never got to check, whatever became of its record.
unchecked_done() {  # chunk
  [ "$(field "$1" status)" = "done" ] && [ "$(field <(git show "HEAD:./$1" 2>/dev/null) status)" != "done" ]
}

# Which session a claim was given, and where HEAD stood, for a runner started
# again after being killed. Named for the chunk's whole path: every change has
# a plan/01.md, and one's record resumed another's session. It stays until the
# runner has settled the chunk, not only until the session returns: a `done`
# the runner was killed before checking is a claim to check, not a result.
claim_record() {  # chunk -> the file
  printf '%s/%s.claim' "$LOG_DIR" "$(realpath --relative-to="$(git rev-parse --show-toplevel)" "$1" | tr / _)"
}
release() { rm -f "$(claim_record "$1")"; }

# What a session left in the tree besides the chunk files, which are the
# runner's bookkeeping - another chunk's halt among them, which went into the
# stash with a later build's leftovers and came back out as a fresh budget.
left_behind() {  # -> git status lines, empty for none
  git status --porcelain -- "${NOT_CHUNKS[@]}"
}

# The next attempt is told the checks were green when the run started, which is
# only true of a tree without this one's leftovers in it. Stashed rather than
# dropped: it may be most of a build.
put_aside() {  # chunk, attempt
  [ -n "$(left_behind)" ] || return 0
  git stash push -q -u -m "run.sh: $(basename "$1") attempt $2, left uncommitted" -- "${NOT_CHUNKS[@]}"
  say "what it left uncommitted is in the stash"
}

# Committed, and once: a halt is the one thing a run leaves for a person, and
# left uncommitted it was every later session's someone else's change.
#
# HALTED names the last chunk halted here, for the end of the run to name what
# stopped it.
halt() {  # chunk, kind, why
  # shellcheck disable=SC2034 # read where the run ends, in run.sh and the loop
  HALTED="$1"
  [ "$(field "$1" status)" != halted ] || return 0
  printf '\n## Halt\n\n%s - %s\n' "$2" "$3" >> "$1"
  set_field "$1" status halted
  commit_halt "$1" "$2"
}

# A session's own halt is committed the same way, and only the chunk file:
# whatever the session left besides is its unfinished build, for the person who
# settles the halt to keep or throw away.
commit_halt() {  # chunk, kind
  git diff --quiet HEAD -- "$1" && return 0
  git commit -q -m "Halt $(basename "$1" .md)${2:+: $2}" -- "$1" >/dev/null \
    || echo "could not commit the halt in $1" >&2
}

# The kind a halt names, read off its first line in whatever shape its writer
# put it; empty where that line names none of them.
halt_kind() {  # chunk
  sed -n '/^## Halt$/,$p' "$1" | sed -n '2,$p' | sed '/^[[:space:]]*$/d' | head -1 \
    | grep -o -m1 -w 'blocked\|mystery\|departure\|exhausted\|unbuilt' | head -1
}

# The journeys a session's commits changed since the given commit, one per
# line: approved before the build, so a change to one is a departure.
journeys_touched() {  # commit
  git diff --name-only "$1" HEAD -- "$(git rev-parse --show-toplevel)/journeys"
}
